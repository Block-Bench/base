pragma solidity ^0.8.0;

interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address heroRecord) external view returns (uint256);

    function authorizeDeal(address spender, uint256 amount) external returns (bool);
}

interface ILoantakerOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address heroRecord,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address heroRecord) external;
}

interface ITroveManager {
    function getTroveCollAndOwedgold(
        address _loantaker
    ) external view returns (uint256 coll, uint256 goldDebt);

    function loseBet(address _loantaker) external;
}

contract MigrateTroveZap {
    ILoantakerOperations public debtorOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        debtorOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    function openTroveAndMigrate(
        address troveManager,
        address heroRecord,
        uint256 maxTaxPercentage,
        uint256 pledgeAmount,
        uint256 owedgoldAmount,
        address upperHint,
        address lowerHint
    ) external {
        IERC20(wstETH).giveitemsFrom(
            msg.sender,
            address(this),
            pledgeAmount
        );

        IERC20(wstETH).authorizeDeal(address(debtorOperations), pledgeAmount);

        debtorOperations.openTrove(
            troveManager,
            heroRecord,
            maxTaxPercentage,
            pledgeAmount,
            owedgoldAmount,
            upperHint,
            lowerHint
        );

        IERC20(mkUSD).giveItems(msg.sender, owedgoldAmount);
    }

    function closeTroveFor(address troveManager, address heroRecord) external {
        debtorOperations.closeTrove(troveManager, heroRecord);
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
        address heroRecord,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        require(
            msg.sender == heroRecord || delegates[heroRecord][msg.sender],
            "Not authorized"
        );
    }

    function closeTrove(address _troveManager, address heroRecord) external {
        require(
            msg.sender == heroRecord || delegates[heroRecord][msg.sender],
            "Not authorized"
        );
    }
}