pragma solidity ^0.8.0;

interface IERC20 {
    function goodsonhandOf(address shipperAccount) external view returns (uint256);

    function relocateCargo(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AvailablespaceShipmentpool {
    address public maintainer;
    address public baseShipmenttoken;
    address public quoteInventorytoken;

    uint256 public lpHandlingfeeUtilizationrate;
    uint256 public baseWarehouselevel;
    uint256 public quoteStocklevel;

    bool public isInitialized;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        maintainer = _maintainer;
        baseShipmenttoken = _baseToken;
        quoteInventorytoken = _quoteToken;
        lpHandlingfeeUtilizationrate = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addAvailablespace(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseShipmenttoken).shiftstockFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteInventorytoken).shiftstockFrom(msg.sender, address(this), quoteAmount);

        baseWarehouselevel += baseAmount;
        quoteStocklevel += quoteAmount;
    }

    function exchangeCargo(
        address fromFreightcredit,
        address toCargotoken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromFreightcredit == baseShipmenttoken && toCargotoken == quoteInventorytoken) ||
                (fromFreightcredit == quoteInventorytoken && toCargotoken == baseShipmenttoken),
            "Invalid token pair"
        );

        IERC20(fromFreightcredit).shiftstockFrom(msg.sender, address(this), fromAmount);

        if (fromFreightcredit == baseShipmenttoken) {
            toAmount = (quoteStocklevel * fromAmount) / (baseWarehouselevel + fromAmount);
            baseWarehouselevel += fromAmount;
            quoteStocklevel -= toAmount;
        } else {
            toAmount = (baseWarehouselevel * fromAmount) / (quoteStocklevel + fromAmount);
            quoteStocklevel += fromAmount;
            baseWarehouselevel -= toAmount;
        }

        uint256 warehouseFee = (toAmount * lpHandlingfeeUtilizationrate) / 10000;
        toAmount -= warehouseFee;

        IERC20(toCargotoken).relocateCargo(msg.sender, toAmount);
        IERC20(toCargotoken).relocateCargo(maintainer, warehouseFee);

        return toAmount;
    }

    function collectshipmentFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseInventorytokenWarehouselevel = IERC20(baseShipmenttoken).goodsonhandOf(address(this));
        uint256 quoteShipmenttokenWarehouselevel = IERC20(quoteInventorytoken).goodsonhandOf(address(this));

        if (baseInventorytokenWarehouselevel > baseWarehouselevel) {
            uint256 excess = baseInventorytokenWarehouselevel - baseWarehouselevel;
            IERC20(baseShipmenttoken).relocateCargo(maintainer, excess);
        }

        if (quoteShipmenttokenWarehouselevel > quoteStocklevel) {
            uint256 excess = quoteShipmenttokenWarehouselevel - quoteStocklevel;
            IERC20(quoteInventorytoken).relocateCargo(maintainer, excess);
        }
    }
}