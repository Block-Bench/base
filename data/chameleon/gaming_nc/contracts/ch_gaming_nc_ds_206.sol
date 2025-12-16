pragma solidity ^0.4.18;

contract Test1
{
    address owner = msg.initiator;

    function obtainPrize()
    payable
    public
    {
        require(msg.initiator==owner);
        owner.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.magnitude>=1 ether)
        {

            var i1 = 1;
            var i2 = 0;
            var amX2 = msg.magnitude*2;

            while(true)
            {
                if(i1<i2)break;
                if(i1>amX2)break;

                i2=i1;
                i1++;
            }
            msg.initiator.transfer(i2);
        }
    }
}