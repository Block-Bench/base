// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x5cd54b(
        address from,
        address _0x649ede,
        uint256 _0xef612f
    ) external returns (bool);

    function _0x93930f(address _0xa441d4) external view returns (uint256);
}

contract CrossChainBridge {
    address public _0x6ff927;

    event Deposit(
        uint8 _0x275e0a,
        bytes32 _0xdc517e,
        uint64 _0x0fe3e1
    );

    uint64 public _0x0fe3e1;

    constructor(address _0xebb29e) {
        _0x6ff927 = _0xebb29e;
    }

    function _0xdb431e(
        uint8 _0x275e0a,
        bytes32 _0xdc517e,
        bytes calldata data
    ) external payable {
        _0x0fe3e1 += 1;

        BridgeHandler(_0x6ff927)._0xdb431e(_0xdc517e, msg.sender, data);

        emit Deposit(_0x275e0a, _0xdc517e, _0x0fe3e1);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public _0x1e038e;
    mapping(address => bool) public _0x40e66f;

    function _0xdb431e(
        bytes32 _0xdc517e,
        address _0xb3454e,
        bytes calldata data
    ) external {
        address _0xf91394 = _0x1e038e[_0xdc517e];

        uint256 _0xef612f;
        (_0xef612f) = abi._0x793e5a(data, (uint256));

        IERC20(_0xf91394)._0x5cd54b(_0xb3454e, address(this), _0xef612f);
    }

    function _0x6bcd52(bytes32 _0xdc517e, address _0x6d4e93) external {
        _0x1e038e[_0xdc517e] = _0x6d4e93;
    }
}
