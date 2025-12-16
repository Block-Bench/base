// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowanceOf(address patientAccount) external view returns (uint256);

    function approveBenefit(address spender, uint256 amount) external returns (bool);
}

interface ICredituserOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address patientAccount,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address patientAccount) external;
}

interface ITroveManager {
    function getTroveCollAndUnpaidpremium(
        address _loanpatient
    ) external view returns (uint256 coll, uint256 owedAmount);

    function cancelPolicy(address _loanpatient) external;
}

contract MigrateTroveZap {
    ICredituserOperations public loanpatientOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        loanpatientOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndMigrate(
        address troveManager,
        address patientAccount,
        uint256 maxPremiumPercentage,
        uint256 securitybondAmount,
        uint256 outstandingbalanceAmount,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).assigncreditFrom(
            msg.sender,
            address(this),
            securitybondAmount
        );

        IERC20(wstETH).approveBenefit(address(loanpatientOperations), securitybondAmount);

        loanpatientOperations.openTrove(
            troveManager,
            patientAccount,
            maxPremiumPercentage,
            securitybondAmount,
            outstandingbalanceAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).transferBenefit(msg.sender, outstandingbalanceAmount);
    }

    function closeTroveFor(address troveManager, address patientAccount) external {
        loanpatientOperations.closeTrove(troveManager, patientAccount);
    }
}

contract CredituserOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveManager,
        address patientAccount,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == patientAccount || delegates[patientAccount][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveManager, address patientAccount) external {
        require(
            msg.sender == patientAccount || delegates[patientAccount][msg.sender],
            "Not authorized"
        );
    }
}
