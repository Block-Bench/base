// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IBorrowerOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;
    function openTrove(
        address troveManager,
        address account,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;
    function closeTrove(address troveManager, address account) external;
}

interface ITroveManager {
    function getTroveCollAndDebt(
        address _borrower
    ) external view returns (uint256 coll, uint256 debt);
    function liquidate(address _borrower) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public borrowerOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
    borrowerOperations = IBorrowerOperations(_borrowerOperations);
    wstETH = _wstETH;
    mkUSD = _mkUSD;
    }
    function openTroveAndMigrate(
        address troveManager,
        address account,
        uint256 maxFeePercentage,
        uint256 collateralAmount,
        uint256 debtAmount,
        address upperHint,
        address lowerHint
    ) external {
        require(account == msg.sender, "Account must be caller");
        IERC20(wstETH).transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );

        IERC20(wstETH).approve(address(borrowerOperations), collateralAmount);

        borrowerOperations.openTrove(
            troveManager,
            account,
            maxFeePercentage,
            collateralAmount,
            debtAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).transfer(msg.sender, debtAmount);
    }

    function closeTroveFor(address troveManager, address account) external {
        require(account == msg.sender, "Account must be caller");
        borrowerOperations.closeTrove(troveManager, account);
    }
}

contract as {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveManager,
        address account,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == account || delegates[account][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveManager, address account) external {
        require(
            msg.sender == account || delegates[account][msg.sender],
            "Not authorized"
        );
    }
}
