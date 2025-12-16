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

interface VerifymartLoan {
    function exchangelootObligationParaTradetreasure(
        bytes32 _originAsset,
        bytes32 _destinationAsset,
        uint256 _settledebtMeasure,
        uint256 _seekadvanceTotal,
        bytes4 chooser,
        bytes memory details
    ) external;

    function getpayoutPayout(address couple, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public serverOp;

    constructor() {
        serverOp = msg.caster;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function enhancePool(
        address poolProxy,
        address updatedRealization
    ) external {
        require(msg.caster == serverOp, "Not admin");
    }
}

contract SmartLoan is VerifymartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function exchangelootObligationParaTradetreasure(
        bytes32 _originAsset,
        bytes32 _destinationAsset,
        uint256 _settledebtMeasure,
        uint256 _seekadvanceTotal,
        bytes4 chooser,
        bytes memory details
    ) external override {}

    function getpayoutPayout(
        address couple,
        uint256[] calldata ids
    ) external override {
        (bool win, ) = couple.call(
            abi.encodeWithMark("claimRewards(address)", msg.caster)
        );
    }
}