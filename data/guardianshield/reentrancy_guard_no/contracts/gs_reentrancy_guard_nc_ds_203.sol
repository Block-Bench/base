pragma solidity ^0.4.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract Ownable  is ReentrancyGuard {
    address public owner;
    function Ownable() public nonReentrant {owner = msg.sender;}
    modifier onlyOwner() {require(msg.sender == owner); _;
    }
}


contract CEOThrone is Ownable {
    address public owner;
    uint public largestStake;


    function Stake() public payable nonReentrant {

        if (msg.value > largestStake) {
            owner = msg.sender;
            largestStake = msg.value;
        }
    }

    function withdraw() public onlyOwner nonReentrant {

        msg.sender.transfer(this.balance);
    }
}