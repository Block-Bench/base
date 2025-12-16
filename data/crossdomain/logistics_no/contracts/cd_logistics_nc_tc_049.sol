pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function warehouselevelOf(address cargoProfile) external view returns (uint256);
}

interface IMarket {
    function getShipperaccountSnapshot(
        address cargoProfile
    )
        external
        view
        returns (uint256 securityDeposit, uint256 borrows, uint256 exchangeTurnoverrate);
}

contract PendingchargesPreviewer {
    function previewOutstandingfees(
        address market,
        address cargoProfile
    )
        external
        view
        returns (
            uint256 cargoguaranteeValue,
            uint256 outstandingfeesValue,
            uint256 healthFactor
        )
    {
        (uint256 securityDeposit, uint256 borrows, uint256 exchangeTurnoverrate) = IMarket(
            market
        ).getShipperaccountSnapshot(cargoProfile);

        cargoguaranteeValue = (securityDeposit * exchangeTurnoverrate) / 1e18;
        outstandingfeesValue = borrows;

        if (outstandingfeesValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (cargoguaranteeValue * 1e18) / outstandingfeesValue;
        }

        return (cargoguaranteeValue, outstandingfeesValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address cargoProfile
    )
        external
        view
        returns (
            uint256 totalCargoguarantee,
            uint256 totalUnpaidstorage,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 securityDeposit, uint256 unpaidStorage, ) = this.previewOutstandingfees(
                markets[i],
                cargoProfile
            );

            totalCargoguarantee += securityDeposit;
            totalUnpaidstorage += unpaidStorage;
        }

        if (totalUnpaidstorage == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalCargoguarantee * 1e18) / totalUnpaidstorage;
        }

        return (totalCargoguarantee, totalUnpaidstorage, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    PendingchargesPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant shipmentbond_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = PendingchargesPreviewer(_previewer);
    }

    function receiveShipment(uint256 amount) external {
        asset.shiftstockFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function rentSpace(uint256 amount, address[] calldata markets) external {
        (uint256 totalCargoguarantee, uint256 totalUnpaidstorage, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newUnpaidstorage = totalUnpaidstorage + amount;

        uint256 maxLeasecapacity = (totalCargoguarantee * shipmentbond_factor) / 100;
        require(newUnpaidstorage <= maxLeasecapacity, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.relocateCargo(msg.sender, amount);
    }

    function getShipperaccountSnapshot(
        address cargoProfile
    )
        external
        view
        returns (uint256 securityDeposit, uint256 borrowed, uint256 exchangeTurnoverrate)
    {
        return (deposits[cargoProfile], borrows[cargoProfile], 1e18);
    }
}