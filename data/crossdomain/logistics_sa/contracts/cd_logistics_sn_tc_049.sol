// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferInventory(address to, uint256 amount) external returns (bool);

    function transferinventoryFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function stocklevelOf(address cargoProfile) external view returns (uint256);
}

interface IMarket {
    function getShipperaccountSnapshot(
        address cargoProfile
    )
        external
        view
        returns (uint256 securityDeposit, uint256 borrows, uint256 exchangeOccupancyrate);
}

contract OutstandingfeesPreviewer {
    function previewPendingcharges(
        address market,
        address cargoProfile
    )
        external
        view
        returns (
            uint256 cargoguaranteeValue,
            uint256 unpaidstorageValue,
            uint256 healthFactor
        )
    {
        (uint256 securityDeposit, uint256 borrows, uint256 exchangeOccupancyrate) = IMarket(
            market
        ).getShipperaccountSnapshot(cargoProfile);

        cargoguaranteeValue = (securityDeposit * exchangeOccupancyrate) / 1e18;
        unpaidstorageValue = borrows;

        if (unpaidstorageValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (cargoguaranteeValue * 1e18) / unpaidstorageValue;
        }

        return (cargoguaranteeValue, unpaidstorageValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address cargoProfile
    )
        external
        view
        returns (
            uint256 totalInsurancebond,
            uint256 totalOutstandingfees,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 securityDeposit, uint256 pendingCharges, ) = this.previewPendingcharges(
                markets[i],
                cargoProfile
            );

            totalInsurancebond += securityDeposit;
            totalOutstandingfees += pendingCharges;
        }

        if (totalOutstandingfees == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalInsurancebond * 1e18) / totalOutstandingfees;
        }

        return (totalInsurancebond, totalOutstandingfees, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    OutstandingfeesPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant insurancebond_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = OutstandingfeesPreviewer(_previewer);
    }

    function storeGoods(uint256 amount) external {
        asset.transferinventoryFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function requestCapacity(uint256 amount, address[] calldata markets) external {
        (uint256 totalInsurancebond, uint256 totalOutstandingfees, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newUnpaidstorage = totalOutstandingfees + amount;

        uint256 maxLeasecapacity = (totalInsurancebond * insurancebond_factor) / 100;
        require(newUnpaidstorage <= maxLeasecapacity, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.transferInventory(msg.sender, amount);
    }

    function getShipperaccountSnapshot(
        address cargoProfile
    )
        external
        view
        returns (uint256 securityDeposit, uint256 borrowed, uint256 exchangeOccupancyrate)
    {
        return (deposits[cargoProfile], borrows[cargoProfile], 1e18);
    }
}
