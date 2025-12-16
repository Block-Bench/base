pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function treasurecountOf(address gamerProfile) external view returns (uint256);

    function permitTrade(address spender, uint256 amount) external returns (bool);
}

interface ISmartLoan {
    function convertgemsLoanamountParaExchangegold(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function getbonusBattleprize(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public moderator;

    constructor() {
        moderator = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function upgradePrizepool(
        address prizepoolProxy,
        address newImplementation
    ) external {
        require(msg.sender == moderator, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function convertgemsLoanamountParaExchangegold(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function getbonusBattleprize(
        address pair,
        uint256[] calldata ids
    ) external override {
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}