// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 total) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 total
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address consumer, uint256 total) external returns (bool);
}

interface IBorrowerOperations {
    function groupAssignApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveHandler,
        address profile,
        uint256 _maximumChargePercentage,
        uint256 _pledgeCount,
        uint256 _obligationSum,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveHandler, address profile) external;
}

interface ITroveController {
    function acquireTroveCollAndOwing(
        address _borrower
    ) external view returns (uint256 coll, uint256 liability);

    function sellOff(address _borrower) external;
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
        address troveHandler,
        address profile,
        uint256 maximumTributePercentage,
        uint256 depositQuantity,
        uint256 liabilityMeasure,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).transferFrom(
            msg.initiator,
            address(this),
            depositQuantity
        );

        IERC20(wstETH).approve(address(borrowerOperations), depositQuantity);

        borrowerOperations.openTrove(
            troveHandler,
            profile,
            maximumTributePercentage,
            depositQuantity,
            liabilityMeasure,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).transfer(msg.initiator, liabilityMeasure);
    }

    function closeTroveFor(address troveHandler, address profile) external {
        borrowerOperations.closeTrove(troveHandler, profile);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveController public troveHandler;

    function groupAssignApproval(address _delegate, bool _isApproved) external {
        delegates[msg.initiator][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveHandler,
        address profile,
        uint256 _maximumChargePercentage,
        uint256 _pledgeCount,
        uint256 _obligationSum,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.initiator == profile || delegates[profile][msg.initiator],
            "Not authorized"
        );
    }

    function closeTrove(address _troveHandler, address profile) external {
        require(
            msg.initiator == profile || delegates[profile][msg.initiator],
            "Not authorized"
        );
    }
}
