pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address logisticsAccount) external view returns (uint256);

    function approveDispatch(address spender, uint256 amount) external returns (bool);
}

interface ISpaceleaserOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address logisticsAccount,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address logisticsAccount) external;
}

interface ITroveManager {
    function getTroveCollAndUnpaidstorage(
        address _capacityrenter
    ) external view returns (uint256 coll, uint256 pendingCharges);

    function disposeInventory(address _capacityrenter) external;
}

contract MigrateTroveZap {
    ISpaceleaserOperations public capacityrenterOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        capacityrenterOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndMigrate(
        address troveManager,
        address logisticsAccount,
        uint256 maxStoragefeePercentage,
        uint256 shipmentbondAmount,
        uint256 pendingchargesAmount,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).relocatecargoFrom(
            msg.sender,
            address(this),
            shipmentbondAmount
        );

        IERC20(wstETH).approveDispatch(address(capacityrenterOperations), shipmentbondAmount);

        capacityrenterOperations.openTrove(
            troveManager,
            logisticsAccount,
            maxStoragefeePercentage,
            shipmentbondAmount,
            pendingchargesAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).relocateCargo(msg.sender, pendingchargesAmount);
    }

    function closeTroveFor(address troveManager, address logisticsAccount) external {
        capacityrenterOperations.closeTrove(troveManager, logisticsAccount);
    }
}

contract SpaceleaserOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveManager,
        address logisticsAccount,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == logisticsAccount || delegates[logisticsAccount][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveManager, address logisticsAccount) external {
        require(
            msg.sender == logisticsAccount || delegates[logisticsAccount][msg.sender],
            "Not authorized"
        );
    }
}