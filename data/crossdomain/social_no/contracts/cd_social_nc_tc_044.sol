pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function sharekarmaFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function influenceOf(address creatorAccount) external view returns (uint256);

    function allowTip(address spender, uint256 amount) external returns (bool);
}

interface ISmartLoan {
    function convertpointsPendingobligationParaTradeinfluence(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function getrewardKarmabonus(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public contentMod;

    constructor() {
        contentMod = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function upgradeFundingpool(
        address fundingpoolProxy,
        address newImplementation
    ) external {
        require(msg.sender == contentMod, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function convertpointsPendingobligationParaTradeinfluence(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function getrewardKarmabonus(
        address pair,
        uint256[] calldata ids
    ) external override {
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}