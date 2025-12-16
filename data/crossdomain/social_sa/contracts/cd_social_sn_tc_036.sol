// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function standingOf(address profile) external view returns (uint256);

    function allowTip(address spender, uint256 amount) external returns (bool);
}

interface IFundseekerOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address profile,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address profile) external;
}

interface ITroveManager {
    function getTroveCollAndReputationdebt(
        address _supportseeker
    ) external view returns (uint256 coll, uint256 pendingObligation);

    function removeBacking(address _supportseeker) external;
}

contract MigrateTroveZap {
    IFundseekerOperations public supportseekerOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        supportseekerOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndMigrate(
        address troveManager,
        address profile,
        uint256 maxProcessingfeePercentage,
        uint256 backingAmount,
        uint256 negativekarmaAmount,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).passinfluenceFrom(
            msg.sender,
            address(this),
            backingAmount
        );

        IERC20(wstETH).allowTip(address(supportseekerOperations), backingAmount);

        supportseekerOperations.openTrove(
            troveManager,
            profile,
            maxProcessingfeePercentage,
            backingAmount,
            negativekarmaAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).sendTip(msg.sender, negativekarmaAmount);
    }

    function closeTroveFor(address troveManager, address profile) external {
        supportseekerOperations.closeTrove(troveManager, profile);
    }
}

contract FundseekerOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveManager,
        address profile,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == profile || delegates[profile][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveManager, address profile) external {
        require(
            msg.sender == profile || delegates[profile][msg.sender],
            "Not authorized"
        );
    }
}
