// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function tradeLoot(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function treasurecountOf(address gamerProfile) external view returns (uint256);

    function allowTransfer(address spender, uint256 amount) external returns (bool);
}

interface IFlashLoanReceiver {
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

contract RadiantItemloanLootpool {
    uint256 public constant RAY = 1e27;

    struct LootreserveData {
        uint256 freeitemsIndex;
        uint256 totalFreeitems;
        address rGoldtokenAddress;
    }

    mapping(address => LootreserveData) public reserves;

    function cacheTreasure(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).sendgoldFrom(msg.sender, address(this), amount);

        LootreserveData storage prizeReserve = reserves[asset];

        uint256 currentFreeitemsIndex = prizeReserve.freeitemsIndex;
        if (currentFreeitemsIndex == 0) {
            currentFreeitemsIndex = RAY;
        }

        prizeReserve.freeitemsIndex =
            currentFreeitemsIndex +
            (amount * RAY) /
            (prizeReserve.totalFreeitems + 1);
        prizeReserve.totalFreeitems += amount;

        uint256 rRealmcoinAmount = rayDiv(amount, prizeReserve.freeitemsIndex);
        _mintRToken(prizeReserve.rGoldtokenAddress, onBehalfOf, rRealmcoinAmount);
    }

    function claimLoot(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        LootreserveData storage prizeReserve = reserves[asset];

        uint256 rTokensToSacrificegem = rayDiv(amount, prizeReserve.freeitemsIndex);

        _burnRToken(prizeReserve.rGoldtokenAddress, msg.sender, rTokensToSacrificegem);

        prizeReserve.totalFreeitems -= amount;
        IERC20(asset).tradeLoot(to, amount);

        return amount;
    }

    function takeAdvance(
        address asset,
        uint256 amount,
        uint256 yieldbonusMultiplierMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        IERC20(asset).tradeLoot(onBehalfOf, amount);
    }

    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external {
        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).tradeLoot(receiverAddress, amounts[i]);
        }

        require(
            IFlashLoanReceiver(receiverAddress).executeOperation(
                assets,
                amounts,
                new uint256[](assets.length),
                msg.sender,
                params
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).sendgoldFrom(
                receiverAddress,
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

    function _mintRToken(address rGamecoin, address to, uint256 amount) internal {}

    function _burnRToken(
        address rGamecoin,
        address from,
        uint256 amount
    ) internal {}
}
