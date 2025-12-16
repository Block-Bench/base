// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function cargocountOf(address shipperAccount) external view returns (uint256);

    function transferInventory(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AvailablespaceCargopool {
    address public maintainer;
    address public baseInventorytoken;
    address public quoteShipmenttoken;

    uint256 public lpStoragefeeThroughputrate;
    uint256 public baseCargocount;
    uint256 public quoteCargocount;

    bool public isInitialized;

    event Initialized(address maintainer, address base, address quote);

    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        maintainer = _maintainer;
        baseInventorytoken = _baseToken;
        quoteShipmenttoken = _quoteToken;
        lpStoragefeeThroughputrate = _lpFeeRate;

        isInitialized = true;

        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }

    function addAvailablespace(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");

        IERC20(baseInventorytoken).shiftstockFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteShipmenttoken).shiftstockFrom(msg.sender, address(this), quoteAmount);

        baseCargocount += baseAmount;
        quoteCargocount += quoteAmount;
    }

    function tradeGoods(
        address fromInventorytoken,
        address toInventorytoken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromInventorytoken == baseInventorytoken && toInventorytoken == quoteShipmenttoken) ||
                (fromInventorytoken == quoteShipmenttoken && toInventorytoken == baseInventorytoken),
            "Invalid token pair"
        );

        IERC20(fromInventorytoken).shiftstockFrom(msg.sender, address(this), fromAmount);

        if (fromInventorytoken == baseInventorytoken) {
            toAmount = (quoteCargocount * fromAmount) / (baseCargocount + fromAmount);
            baseCargocount += fromAmount;
            quoteCargocount -= toAmount;
        } else {
            toAmount = (baseCargocount * fromAmount) / (quoteCargocount + fromAmount);
            quoteCargocount += fromAmount;
            baseCargocount -= toAmount;
        }

        uint256 handlingFee = (toAmount * lpStoragefeeThroughputrate) / 10000;
        toAmount -= handlingFee;

        IERC20(toInventorytoken).transferInventory(msg.sender, toAmount);
        IERC20(toInventorytoken).transferInventory(maintainer, handlingFee);

        return toAmount;
    }

    function receivedeliveryFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseCargotokenCargocount = IERC20(baseInventorytoken).cargocountOf(address(this));
        uint256 quoteShipmenttokenWarehouselevel = IERC20(quoteShipmenttoken).cargocountOf(address(this));

        if (baseCargotokenCargocount > baseCargocount) {
            uint256 excess = baseCargotokenCargocount - baseCargocount;
            IERC20(baseInventorytoken).transferInventory(maintainer, excess);
        }

        if (quoteShipmenttokenWarehouselevel > quoteCargocount) {
            uint256 excess = quoteShipmenttokenWarehouselevel - quoteCargocount;
            IERC20(quoteShipmenttoken).transferInventory(maintainer, excess);
        }
    }
}
