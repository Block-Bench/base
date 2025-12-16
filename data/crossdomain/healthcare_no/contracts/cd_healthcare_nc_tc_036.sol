pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowanceOf(address coverageProfile) external view returns (uint256);

    function validateClaim(address spender, uint256 amount) external returns (bool);
}

interface ILoanpatientOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address coverageProfile,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address coverageProfile) external;
}

interface ITroveManager {
    function getTroveCollAndUnpaidpremium(
        address _credituser
    ) external view returns (uint256 coll, uint256 owedAmount);

    function cancelPolicy(address _credituser) external;
}

contract MigrateTroveZap {
    ILoanpatientOperations public credituserOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        credituserOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndMigrate(
        address troveManager,
        address coverageProfile,
        uint256 maxCopayPercentage,
        uint256 securitybondAmount,
        uint256 owedamountAmount,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).movecoverageFrom(
            msg.sender,
            address(this),
            securitybondAmount
        );

        IERC20(wstETH).validateClaim(address(credituserOperations), securitybondAmount);

        credituserOperations.openTrove(
            troveManager,
            coverageProfile,
            maxCopayPercentage,
            securitybondAmount,
            owedamountAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).moveCoverage(msg.sender, owedamountAmount);
    }

    function closeTroveFor(address troveManager, address coverageProfile) external {
        credituserOperations.closeTrove(troveManager, coverageProfile);
    }
}

contract LoanpatientOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveManager,
        address coverageProfile,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == coverageProfile || delegates[coverageProfile][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveManager, address coverageProfile) external {
        require(
            msg.sender == coverageProfile || delegates[coverageProfile][msg.sender],
            "Not authorized"
        );
    }
}