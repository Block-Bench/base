// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x4a1e47, uint256 _0xa0f209) external returns (bool);

    function _0x08bb61(
        address from,
        address _0x4a1e47,
        uint256 _0xa0f209
    ) external returns (bool);

    function _0xaf792e(address _0xa927fe) external view returns (uint256);

    function _0x325fa7(address _0x33b8b8, uint256 _0xa0f209) external returns (bool);
}

interface ISmartLoan {
    function _0x39128c(
        bytes32 _0xaa562d,
        bytes32 _0x9aeebb,
        uint256 _0x7d7c10,
        uint256 _0x969742,
        bytes4 selector,
        bytes memory data
    ) external;

    function _0x476b9f(address _0x472297, uint256[] calldata _0xd1ff00) external;
}

contract SmartLoansFactory {
    address public _0xd91eef;

    constructor() {
        _0xd91eef = msg.sender;
    }

    function _0x01bbc6() external returns (address) {
        SmartLoan _0x815e99 = new SmartLoan();
        return address(_0x815e99);
    }

    function _0xc1c563(
        address _0x70f742,
        address _0x10389e
    ) external {
        require(msg.sender == _0xd91eef, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public _0x368d07;
    mapping(bytes32 => uint256) public _0xd078cd;

    function _0x39128c(
        bytes32 _0xaa562d,
        bytes32 _0x9aeebb,
        uint256 _0x7d7c10,
        uint256 _0x969742,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function _0x476b9f(
        address _0x472297,
        uint256[] calldata _0xd1ff00
    ) external override {
        (bool _0x68f9f6, ) = _0x472297.call(
            abi._0x76ac70("claimRewards(address)", msg.sender)
        );
    }
}
