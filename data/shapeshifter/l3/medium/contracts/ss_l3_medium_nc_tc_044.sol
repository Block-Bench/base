pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x9a92f1, uint256 _0x382696) external returns (bool);

    function _0x165f4d(
        address from,
        address _0x9a92f1,
        uint256 _0x382696
    ) external returns (bool);

    function _0x7f8888(address _0xa2e301) external view returns (uint256);

    function _0x93c51c(address _0x6c13f8, uint256 _0x382696) external returns (bool);
}

interface ISmartLoan {
    function _0x494631(
        bytes32 _0x84a3ca,
        bytes32 _0x11dda1,
        uint256 _0x8b69fa,
        uint256 _0x184553,
        bytes4 selector,
        bytes memory data
    ) external;

    function _0x1dcca7(address _0x0e6ef1, uint256[] calldata _0x59ba76) external;
}

contract SmartLoansFactory {
    address public _0xa55c3c;

    constructor() {
        _0xa55c3c = msg.sender;
    }

    function _0xf21062() external returns (address) {
        SmartLoan _0xcbf3a5 = new SmartLoan();
        return address(_0xcbf3a5);
    }

    function _0xd868ca(
        address _0x71412b,
        address _0x283326
    ) external {
        require(msg.sender == _0xa55c3c, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public _0x0f6bb2;
    mapping(bytes32 => uint256) public _0x91a45f;

    function _0x494631(
        bytes32 _0x84a3ca,
        bytes32 _0x11dda1,
        uint256 _0x8b69fa,
        uint256 _0x184553,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function _0x1dcca7(
        address _0x0e6ef1,
        uint256[] calldata _0x59ba76
    ) external override {
        (bool _0xd1709b, ) = _0x0e6ef1.call(
            abi._0x6b3956("claimRewards(address)", msg.sender)
        );
    }
}