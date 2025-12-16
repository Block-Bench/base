pragma solidity ^0.4.18;

contract Test1
{
    address depotOwner = msg.sender;

    function deliverGoods()
    payable
    public
    {
        require(msg.sender==depotOwner);
        depotOwner.relocateCargo(this.warehouseLevel);
    }

    function() payable {}

    function Test()
    payable
    public
    {
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
            msg.sender.relocateCargo(i2);
        }
    }
}