// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address playerAccount) external view returns (uint256);

    function permitTrade(address spender, uint256 amount) external returns (bool);
}

interface IDebtorOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address playerAccount,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address playerAccount) external;
}

interface ITroveManager {
    function getTroveCollAndLoanamount(
        address _credituser
    ) external view returns (uint256 coll, uint256 owedGold);

    function loseBet(address _credituser) external;
}

contract MigrateTroveZap {
    IDebtorOperations public credituserOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        credituserOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndMigrate(
        address troveManager,
        address playerAccount,
        uint256 maxCutPercentage,
        uint256 pledgeAmount,
        uint256 golddebtAmount,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).sharetreasureFrom(
            msg.sender,
            address(this),
            pledgeAmount
        );

        IERC20(wstETH).permitTrade(address(credituserOperations), pledgeAmount);

        credituserOperations.openTrove(
            troveManager,
            playerAccount,
            maxCutPercentage,
            pledgeAmount,
            golddebtAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).sendGold(msg.sender, golddebtAmount);
    }

    function closeTroveFor(address troveManager, address playerAccount) external {
        credituserOperations.closeTrove(troveManager, playerAccount);
    }
}

contract DebtorOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveManager,
        address playerAccount,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == playerAccount || delegates[playerAccount][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveManager, address playerAccount) external {
        require(
            msg.sender == playerAccount || delegates[playerAccount][msg.sender],
            "Not authorized"
        );
    }
}
