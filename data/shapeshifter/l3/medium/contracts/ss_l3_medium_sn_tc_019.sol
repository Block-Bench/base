// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xb0940a(
        address from,
        address _0xccfda0,
        uint256 _0x72c605
    ) external returns (bool);

    function _0x329246(address _0x511457) external view returns (uint256);
}

contract CrossChainBridge {
    address public _0x278cdd;

    event Deposit(
        uint8 _0x616662,
        bytes32 _0xf5e69d,
        uint64 _0xaa069a
    );

    uint64 public _0xaa069a;

    constructor(address _0x41dd8f) {
        _0x278cdd = _0x41dd8f;
    }

    function _0x8ddd26(
        uint8 _0x616662,
        bytes32 _0xf5e69d,
        bytes calldata data
    ) external payable {
        _0xaa069a += 1;

        BridgeHandler(_0x278cdd)._0x8ddd26(_0xf5e69d, msg.sender, data);

        emit Deposit(_0x616662, _0xf5e69d, _0xaa069a);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public _0xc30d9d;
    mapping(address => bool) public _0x552e4e;

    function _0x8ddd26(
        bytes32 _0xf5e69d,
        address _0x16fa8f,
        bytes calldata data
    ) external {
        address _0x8b3d8b = _0xc30d9d[_0xf5e69d];

        uint256 _0x72c605;
        (_0x72c605) = abi._0x56fbd9(data, (uint256));

        IERC20(_0x8b3d8b)._0xb0940a(_0x16fa8f, address(this), _0x72c605);
    }

    function _0x1dc66c(bytes32 _0xf5e69d, address _0xd17e2f) external {
        _0xc30d9d[_0xf5e69d] = _0xd17e2f;
    }
}
