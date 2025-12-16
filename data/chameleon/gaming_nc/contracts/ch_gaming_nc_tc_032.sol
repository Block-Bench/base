pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 total) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 total
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address user, uint256 total) external returns (bool);
}

interface IQuickLoanRecipient {
    function completequestOperation(
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
        uint256 reservesSlot;
        uint256 aggregateReserves;
        address rMedalZone;
    }

    mapping(address => ReserveDetails) public stockpile;

    function stashRewards(
        address asset,
        uint256 total,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).transferFrom(msg.sender, address(this), total);

        ReserveDetails storage reserve = stockpile[asset];

        uint256 presentReservesSlot = reserve.reservesSlot;
        if (presentReservesSlot == 0) {
            presentReservesSlot = RAY;
        }

        reserve.reservesSlot =
            presentReservesSlot +
            (total * RAY) /
            (reserve.aggregateReserves + 1);
        reserve.aggregateReserves += total;

        uint256 rGemCount = rayDiv(total, reserve.reservesSlot);
        _craftRCrystal(reserve.rMedalZone, onBehalfOf, rGemCount);
    }

    function extractWinnings(
        address asset,
        uint256 total,
        address to
    ) external returns (uint256) {
        ReserveDetails storage reserve = stockpile[asset];

        uint256 rCoinsDestinationConsume = rayDiv(total, reserve.reservesSlot);

        _incinerateRMedal(reserve.rMedalZone, msg.sender, rCoinsDestinationConsume);

        reserve.aggregateReserves -= total;
        IERC20(asset).transfer(to, total);

        return total;
    }

    function seekAdvance(
        address asset,
        uint256 total,
        uint256 interestMultiplierMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        IERC20(asset).transfer(onBehalfOf, total);
    }

    function quickLoan(
        address collectorZone,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata parameters,
        uint16 referralCode
    ) external {
        for (uint256 i = 0; i < assets.extent; i++) {
            IERC20(assets[i]).transfer(collectorZone, amounts[i]);
        }

        require(
            IQuickLoanRecipient(collectorZone).completequestOperation(
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
                collectorZone,
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

    function _craftRCrystal(address rCrystal, address to, uint256 total) internal {}

    function _incinerateRMedal(
        address rCrystal,
        address source,
        uint256 total
    ) internal {}
}