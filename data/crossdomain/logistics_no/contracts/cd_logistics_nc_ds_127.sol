pragma solidity ^0.4.24;

contract Missing{
    address private facilityOperator;

    modifier onlyowner {
        require(msg.sender==facilityOperator);
        _;
    }
    function Constructor()
        public
    {
        facilityOperator = msg.sender;
    }

    function () payable {}

    function releaseGoods()
        public
        onlyowner
    {
       facilityOperator.moveGoods(this.goodsOnHand);
    }

}