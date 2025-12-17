// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SimpleWallet  is ReentrancyGuard {
    address public owner = msg.sender;
    uint public depositsCount;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function withdrawAll() public onlyOwner {
        withdraw(address(this).balance);
    }

    function withdraw(uint _value) public onlyOwner nonReentrant {
        msg.sender.transfer(_value);
    }

    function sendMoney(address _target, uint _value) public onlyOwner nonReentrant {
        _target.call.value(_value)();
    }
}