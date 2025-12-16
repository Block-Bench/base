pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address consumer, uint256 measure) external returns (bool);
}

interface IBorrowerOperations {
    function groupEntrustApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveHandler,
        address character,
        uint256 _ceilingChargePercentage,
        uint256 _securityMeasure,
        uint256 _obligationSum,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveHandler, address character) external;
}

interface ITroveHandler {
    function fetchTroveCollAndLiability(
        address _borrower
    ) external view returns (uint256 coll, uint256 obligation);

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
        address character,
        uint256 maximumTributePercentage,
        uint256 securityMeasure,
        uint256 liabilitySum,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).transferFrom(
            msg.invoker,
            address(this),
            securityMeasure
        );

        IERC20(wstETH).approve(address(borrowerOperations), securityMeasure);

        borrowerOperations.openTrove(
            troveHandler,
            character,
            maximumTributePercentage,
            securityMeasure,
            liabilitySum,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).transfer(msg.invoker, liabilitySum);
    }

    function closeTroveFor(address troveHandler, address character) external {
        borrowerOperations.closeTrove(troveHandler, character);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveHandler public troveHandler;

    function groupEntrustApproval(address _delegate, bool _isApproved) external {
        delegates[msg.invoker][_delegate] = _isApproved;
    }

    function openTrove(
        address _troveController,
        address character,
        uint256 _ceilingChargePercentage,
        uint256 _securityMeasure,
        uint256 _obligationSum,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.invoker == character || delegates[character][msg.invoker],
            "Not authorized"
        );
    }

    function closeTrove(address _troveController, address character) external {
        require(
            msg.invoker == character || delegates[character][msg.invoker],
            "Not authorized"
        );
    }
}