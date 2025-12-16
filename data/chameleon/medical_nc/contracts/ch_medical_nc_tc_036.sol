pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 units
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address payer, uint256 units) external returns (bool);
}

interface IBorrowerOperations {
    function collectionEntrustApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveCoordinator,
        address chart,
        uint256 _maximumChargePercentage,
        uint256 _depositDosage,
        uint256 _obligationQuantity,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveCoordinator, address chart) external;
}

interface ITroveHandler {
    function obtainTroveCollAndObligation(
        address _borrower
    ) external view returns (uint256 coll, uint256 liability);

    function convertAssets(address _borrower) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public borrowerOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        borrowerOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndMigrate(
        address troveCoordinator,
        address chart,
        uint256 ceilingDeductiblePercentage,
        uint256 depositMeasure,
        uint256 obligationDosage,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).transferFrom(
            msg.referrer855,
            address(this),
            depositMeasure
        );

        IERC20(wstETH).approve(address(borrowerOperations), depositMeasure);

        borrowerOperations.openTrove(
            troveCoordinator,
            chart,
            ceilingDeductiblePercentage,
            depositMeasure,
            obligationDosage,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).transfer(msg.referrer855, obligationDosage);
    }

    function closeTroveFor(address troveCoordinator, address chart) external {
        borrowerOperations.closeTrove(troveCoordinator, chart);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveHandler public troveCoordinator;

    function collectionEntrustApproval(address _delegate, bool _isApproved) external {
        delegates[msg.referrer855][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveHandler,
        address chart,
        uint256 _maximumChargePercentage,
        uint256 _depositDosage,
        uint256 _obligationQuantity,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.referrer855 == chart || delegates[chart][msg.referrer855],
            "Not authorized"
        );
    }

    function closeTrove(address _troveHandler, address chart) external {
        require(
            msg.referrer855 == chart || delegates[chart][msg.referrer855],
            "Not authorized"
        );
    }
}