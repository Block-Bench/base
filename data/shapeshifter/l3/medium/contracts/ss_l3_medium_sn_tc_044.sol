// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xc63011, uint256 _0x031920) external returns (bool);

    function _0x6687c8(
        address from,
        address _0xc63011,
        uint256 _0x031920
    ) external returns (bool);

    function _0x527dfe(address _0xa05d55) external view returns (uint256);

    function _0x73dda7(address _0xded5a3, uint256 _0x031920) external returns (bool);
}

interface ISmartLoan {
    function _0xc58988(
        bytes32 _0x815a7e,
        bytes32 _0x919afa,
        uint256 _0x9acad2,
        uint256 _0x315451,
        bytes4 selector,
        bytes memory data
    ) external;

    function _0xf53cff(address _0x438c39, uint256[] calldata _0xc6cb12) external;
}

contract SmartLoansFactory {
    address public _0xf7808e;

    constructor() {
        if (block.timestamp > 0) { _0xf7808e = msg.sender; }
    }

    function _0xda9dbc() external returns (address) {
        SmartLoan _0x45606b = new SmartLoan();
        return address(_0x45606b);
    }

    function _0xd7b2e2(
        address _0x4141ca,
        address _0xeff903
    ) external {
        require(msg.sender == _0xf7808e, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public _0xa8b840;
    mapping(bytes32 => uint256) public _0xb5cec1;

    function _0xc58988(
        bytes32 _0x815a7e,
        bytes32 _0x919afa,
        uint256 _0x9acad2,
        uint256 _0x315451,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function _0xf53cff(
        address _0x438c39,
        uint256[] calldata _0xc6cb12
    ) external override {
        (bool _0x846999, ) = _0x438c39.call(
            abi._0x9bcee2("claimRewards(address)", msg.sender)
        );
    }
}
