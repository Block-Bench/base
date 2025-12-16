// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address user, uint256 sum) external returns (bool);
}

interface IInstantLoanRecipient {
    function performactionOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata parameters
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveDetails {
        uint256 reservesPosition;
        uint256 aggregateReserves;
        address rMedalLocation;
    }

    mapping(address => ReserveDetails) public stockpile;

    function stashRewards(
        address asset,
        uint256 sum,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).transferFrom(msg.sender, address(this), sum);

        ReserveDetails storage reserve = stockpile[asset];

        uint256 activeReservesSlot = reserve.reservesPosition;
        if (activeReservesSlot == 0) {
            activeReservesSlot = RAY;
        }

        reserve.reservesPosition =
            activeReservesSlot +
            (sum * RAY) /
            (reserve.aggregateReserves + 1);
        reserve.aggregateReserves += sum;

        uint256 rGemCount = rayDiv(sum, reserve.reservesPosition);
        _spawnRCrystal(reserve.rMedalLocation, onBehalfOf, rGemCount);
    }

    function obtainPrize(
        address asset,
        uint256 sum,
        address to
    ) external returns (uint256) {
        ReserveDetails storage reserve = stockpile[asset];

        uint256 rCoinsTargetIncinerate = rayDiv(sum, reserve.reservesPosition);

        _destroyRMedal(reserve.rMedalLocation, msg.sender, rCoinsTargetIncinerate);

        reserve.aggregateReserves -= sum;
        IERC20(asset).transfer(to, sum);

        return sum;
    }

    function requestLoan(
        address asset,
        uint256 sum,
        uint256 interestMultiplierMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        IERC20(asset).transfer(onBehalfOf, sum);
    }

    function instantLoan(
        address recipientLocation,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata parameters,
        uint16 referralCode
    ) external {
        for (uint256 i = 0; i < assets.extent; i++) {
            IERC20(assets[i]).transfer(recipientLocation, amounts[i]);
        }

        require(
            IInstantLoanRecipient(recipientLocation).performactionOperation(
                assets,
                amounts,
                new uint256[](assets.extent),
                msg.sender,
                parameters
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < assets.extent; i++) {
            IERC20(assets[i]).transferFrom(
                recipientLocation,
                address(this),
                amounts[i]
            );
        }
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 halfB = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + halfB) / b;
    }

    function _spawnRCrystal(address rCrystal, address to, uint256 sum) internal {}

    function _destroyRMedal(
        address rCrystal,
        address origin,
        uint256 sum
    ) internal {}
}
