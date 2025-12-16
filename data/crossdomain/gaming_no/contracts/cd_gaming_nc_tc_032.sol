pragma solidity ^0.8.0;

interface IERC20 {
    function tradeLoot(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goldholdingOf(address gamerProfile) external view returns (uint256);

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

contract RadiantItemloanBountypool {
    uint256 public constant RAY = 1e27;

    struct GuildtreasuryData {
        uint256 tradableassetsIndex;
        uint256 totalTradableassets;
        address rGoldtokenAddress;
    }

    mapping(address => GuildtreasuryData) public reserves;

    function savePrize(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).sendgoldFrom(msg.sender, address(this), amount);

        GuildtreasuryData storage prizeReserve = reserves[asset];

        uint256 currentFreeitemsIndex = prizeReserve.tradableassetsIndex;
        if (currentFreeitemsIndex == 0) {
            currentFreeitemsIndex = RAY;
        }

        prizeReserve.tradableassetsIndex =
            currentFreeitemsIndex +
            (amount * RAY) /
            (prizeReserve.totalTradableassets + 1);
        prizeReserve.totalTradableassets += amount;

        uint256 rQuesttokenAmount = rayDiv(amount, prizeReserve.tradableassetsIndex);
        _mintRToken(prizeReserve.rGoldtokenAddress, onBehalfOf, rQuesttokenAmount);
    }

    function retrieveItems(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        GuildtreasuryData storage prizeReserve = reserves[asset];

        uint256 rTokensToUseitem = rayDiv(amount, prizeReserve.tradableassetsIndex);

        _burnRToken(prizeReserve.rGoldtokenAddress, msg.sender, rTokensToUseitem);

        prizeReserve.totalTradableassets -= amount;
        IERC20(asset).tradeLoot(to, amount);

        return amount;
    }

    function borrowGold(
        address asset,
        uint256 amount,
        uint256 bonusrateBonusrateMode,
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

    function _mintRToken(address rGoldtoken, address to, uint256 amount) internal {}

    function _burnRToken(
        address rGoldtoken,
        address from,
        uint256 amount
    ) internal {}
}