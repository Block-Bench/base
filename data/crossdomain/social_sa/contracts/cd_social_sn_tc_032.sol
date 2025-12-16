// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function giveCredit(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function influenceOf(address memberAccount) external view returns (uint256);

    function permitTransfer(address spender, uint256 amount) external returns (bool);
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

contract RadiantKarmaloanFundingpool {
    uint256 public constant RAY = 1e27;

    struct TipreserveData {
        uint256 spendableinfluenceIndex;
        uint256 totalSpendableinfluence;
        address rReputationtokenAddress;
    }

    mapping(address => TipreserveData) public reserves;

    function donate(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).sendtipFrom(msg.sender, address(this), amount);

        TipreserveData storage patronReserve = reserves[asset];

        uint256 currentSpendableinfluenceIndex = patronReserve.spendableinfluenceIndex;
        if (currentSpendableinfluenceIndex == 0) {
            currentSpendableinfluenceIndex = RAY;
        }

        patronReserve.spendableinfluenceIndex =
            currentSpendableinfluenceIndex +
            (amount * RAY) /
            (patronReserve.totalSpendableinfluence + 1);
        patronReserve.totalSpendableinfluence += amount;

        uint256 rInfluencetokenAmount = rayDiv(amount, patronReserve.spendableinfluenceIndex);
        _mintRToken(patronReserve.rReputationtokenAddress, onBehalfOf, rInfluencetokenAmount);
    }

    function collect(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        TipreserveData storage patronReserve = reserves[asset];

        uint256 rTokensToReducereputation = rayDiv(amount, patronReserve.spendableinfluenceIndex);

        _burnRToken(patronReserve.rReputationtokenAddress, msg.sender, rTokensToReducereputation);

        patronReserve.totalSpendableinfluence -= amount;
        IERC20(asset).giveCredit(to, amount);

        return amount;
    }

    function seekFunding(
        address asset,
        uint256 amount,
        uint256 influencegrowthEngagementrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        IERC20(asset).giveCredit(onBehalfOf, amount);
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
            IERC20(assets[i]).giveCredit(receiverAddress, amounts[i]);
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
            IERC20(assets[i]).sendtipFrom(
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

    function _mintRToken(address rKarmatoken, address to, uint256 amount) internal {}

    function _burnRToken(
        address rKarmatoken,
        address from,
        uint256 amount
    ) internal {}
}
