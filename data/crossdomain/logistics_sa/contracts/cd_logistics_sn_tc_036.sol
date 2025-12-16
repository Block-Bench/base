// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address shipperAccount) external view returns (uint256);

    function permitRelease(address spender, uint256 amount) external returns (bool);
}

interface ICapacityrenterOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address shipperAccount,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address shipperAccount) external;
}

interface ITroveManager {
    function getTroveCollAndUnpaidstorage(
        address _spaceleaser
    ) external view returns (uint256 coll, uint256 pendingCharges);

    function disposeInventory(address _spaceleaser) external;
}

contract MigrateTroveZap {
    ICapacityrenterOperations public spaceleaserOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        spaceleaserOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndMigrate(
        address troveManager,
        address shipperAccount,
        uint256 maxProcessingchargePercentage,
        uint256 shipmentbondAmount,
        uint256 outstandingfeesAmount,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).shiftstockFrom(
            msg.sender,
            address(this),
            shipmentbondAmount
        );

        IERC20(wstETH).permitRelease(address(spaceleaserOperations), shipmentbondAmount);

        spaceleaserOperations.openTrove(
            troveManager,
            shipperAccount,
            maxProcessingchargePercentage,
            shipmentbondAmount,
            outstandingfeesAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).moveGoods(msg.sender, outstandingfeesAmount);
    }

    function closeTroveFor(address troveManager, address shipperAccount) external {
        spaceleaserOperations.closeTrove(troveManager, shipperAccount);
    }
}

contract CapacityrenterOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveManager,
        address shipperAccount,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == shipperAccount || delegates[shipperAccount][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveManager, address shipperAccount) external {
        require(
            msg.sender == shipperAccount || delegates[shipperAccount][msg.sender],
            "Not authorized"
        );
    }
}
