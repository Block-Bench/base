pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

interface IBorrowerOperations {
    function collectionAssignproxyApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveCoordinator,
        address chart,
        uint256 _maximumConsultationfeePercentage,
        uint256 _securitydepositQuantity,
        uint256 _outstandingbalanceQuantity,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveCoordinator, address chart) external;
}

interface ITroveHandler {
    function obtainTroveCollAndOutstandingbalance(
        address _borrower
    ) external view returns (uint256 coll, uint256 outstandingBalance);

    function forceSettlement(address _borrower) external;
}

contract TransferrecordsTroveZap {
    IBorrowerOperations public patientFinanceOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        patientFinanceOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndTransferrecords(
        address troveCoordinator,
        address chart,
        uint256 ceilingConsultationfeePercentage,
        uint256 securitydepositQuantity,
        uint256 outstandingbalanceQuantity,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).transferFrom(
            msg.sender,
            address(this),
            securitydepositQuantity
        );

        IERC20(wstETH).approve(address(patientFinanceOperations), securitydepositQuantity);

        patientFinanceOperations.openTrove(
            troveCoordinator,
            chart,
            ceilingConsultationfeePercentage,
            securitydepositQuantity,
            outstandingbalanceQuantity,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).transfer(msg.sender, outstandingbalanceQuantity);
    }

    function closeTroveFor(address troveCoordinator, address chart) external {
        patientFinanceOperations.closeTrove(troveCoordinator, chart);
    }
}

contract PatientFinanceOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveHandler public troveCoordinator;

    function collectionAssignproxyApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveCoordinator,
        address chart,
        uint256 _maximumConsultationfeePercentage,
        uint256 _securitydepositQuantity,
        uint256 _outstandingbalanceQuantity,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == chart || delegates[chart][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveCoordinator, address chart) external {
        require(
            msg.sender == chart || delegates[chart][msg.sender],
            "Not authorized"
        );
    }
}