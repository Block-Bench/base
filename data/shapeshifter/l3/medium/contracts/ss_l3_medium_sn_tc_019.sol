// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x68a75a(
        address from,
        address _0x01a62b,
        uint256 _0x50cb5b
    ) external returns (bool);

    function _0x44c20f(address _0xc57c5f) external view returns (uint256);
}

contract CrossChainBridge {
    address public _0x219724;

    event Deposit(
        uint8 _0xb1d826,
        bytes32 _0xab6374,
        uint64 _0x9de9be
    );

    uint64 public _0x9de9be;

    constructor(address _0x40b473) {
        _0x219724 = _0x40b473;
    }

    function _0x6580fb(
        uint8 _0xb1d826,
        bytes32 _0xab6374,
        bytes calldata data
    ) external payable {
        _0x9de9be += 1;

        BridgeHandler(_0x219724)._0x6580fb(_0xab6374, msg.sender, data);

        emit Deposit(_0xb1d826, _0xab6374, _0x9de9be);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public _0x7dc381;
    mapping(address => bool) public _0x63145d;

    function _0x6580fb(
        bytes32 _0xab6374,
        address _0x8681ef,
        bytes calldata data
    ) external {
        address _0x57a455 = _0x7dc381[_0xab6374];

        uint256 _0x50cb5b;
        (_0x50cb5b) = abi._0xeabf67(data, (uint256));

        IERC20(_0x57a455)._0x68a75a(_0x8681ef, address(this), _0x50cb5b);
    }

    function _0x5c6a19(bytes32 _0xab6374, address _0x859711) external {
        _0x7dc381[_0xab6374] = _0x859711;
    }
}
