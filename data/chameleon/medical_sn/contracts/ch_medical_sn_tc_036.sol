// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address payer, uint256 quantity) external returns (bool);
}

interface IBorrowerOperations {
    function collectionEntrustApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveHandler,
        address profile,
        uint256 _ceilingCopayPercentage,
        uint256 _depositMeasure,
        uint256 _liabilityQuantity,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveHandler, address profile) external;
}

interface ITroveHandler {
    function retrieveTroveCollAndLiability(
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
        address troveHandler,
        address profile,
        uint256 maximumDeductiblePercentage,
        uint256 securityMeasure,
        uint256 liabilityMeasure,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).transferFrom(
            msg.referrer884,
            address(this),
            securityMeasure
        );

        IERC20(wstETH).approve(address(borrowerOperations), securityMeasure);

        borrowerOperations.openTrove(
            troveHandler,
            profile,
            maximumDeductiblePercentage,
            securityMeasure,
            liabilityMeasure,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).transfer(msg.referrer884, liabilityMeasure);
    }

    function closeTroveFor(address troveHandler, address profile) external {
        borrowerOperations.closeTrove(troveHandler, profile);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveHandler public troveHandler;

    function collectionEntrustApproval(address _delegate, bool _isApproved) external {
        delegates[msg.referrer884][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveCoordinator,
        address profile,
        uint256 _ceilingCopayPercentage,
        uint256 _depositMeasure,
        uint256 _liabilityQuantity,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.referrer884 == profile || delegates[profile][msg.referrer884],
            "Not authorized"
        );
    }

    function closeTrove(address _troveCoordinator, address profile) external {
        require(
            msg.referrer884 == profile || delegates[profile][msg.referrer884],
            "Not authorized"
        );
    }
}
