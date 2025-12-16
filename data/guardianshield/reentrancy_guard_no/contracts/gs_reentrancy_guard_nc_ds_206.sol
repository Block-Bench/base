pragma solidity ^0.4.18;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Test1
 is ReentrancyGuard {
    address owner = msg.sender;

    function withdraw()
    payable
    public
    nonReentrant {
        require(msg.sender==owner);
        owner.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    nonReentrant {
        if(msg.value>=1 ether)
        {

            var i1 = 1;
            var i2 = 0;
            var amX2 = msg.value*2;

            while(true)
            {
                if(i1<i2)break;
                if(i1>amX2)break;

                i2=i1;
                i1++;
            }
            msg.sender.transfer(i2);
        }
    }
}