// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x9f2948, uint256 _0x433433) external returns (bool);

    function _0x1bb861(
        address from,
        address _0x9f2948,
        uint256 _0x433433
    ) external returns (bool);

    function _0xf52fc7(address _0x6dc8ea) external view returns (uint256);

    function _0xa447c2(address _0xa80aa2, uint256 _0x433433) external returns (bool);
}

interface ISmartLoan {
    function _0x0fa54f(
        bytes32 _0xc7d7d6,
        bytes32 _0x43e66f,
        uint256 _0x05b57e,
        uint256 _0x304fd0,
        bytes4 selector,
        bytes memory data
    ) external;

    function _0xa37cf8(address _0xb747dd, uint256[] calldata _0xdd262f) external;
}

contract SmartLoansFactory {
    address public _0x94a92f;

    constructor() {
        _0x94a92f = msg.sender;
    }

    function _0x04afb3() external returns (address) {
        SmartLoan _0x050aa0 = new SmartLoan();
        return address(_0x050aa0);
    }

    function _0xe539d2(
        address _0xe66878,
        address _0xe57498
    ) external {
        require(msg.sender == _0x94a92f, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public _0x6313c8;
    mapping(bytes32 => uint256) public _0xf90aeb;

    function _0x0fa54f(
        bytes32 _0xc7d7d6,
        bytes32 _0x43e66f,
        uint256 _0x05b57e,
        uint256 _0x304fd0,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function _0xa37cf8(
        address _0xb747dd,
        uint256[] calldata _0xdd262f
    ) external override {
        (bool _0xeaf0d8, ) = _0xb747dd.call(
            abi._0x7239be("claimRewards(address)", msg.sender)
        );
    }
}
