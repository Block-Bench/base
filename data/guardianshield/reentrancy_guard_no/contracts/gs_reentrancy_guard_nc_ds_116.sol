pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Missing is ReentrancyGuard {
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }


    function IamMissing()
        public
    nonReentrant {
        owner = msg.sender;
    }

    function withdraw()
        public
        onlyowner
    nonReentrant {
       owner.transfer(this.balance);
    }
}