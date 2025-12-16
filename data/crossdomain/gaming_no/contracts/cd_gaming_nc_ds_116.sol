pragma solidity ^0.4.15;

contract Missing{
    address private realmLord;

    modifier onlyowner {
        require(msg.sender==realmLord);
        _;
    }


    function IamMissing()
        public
    {
        realmLord = msg.sender;
    }

    function claimLoot()
        public
        onlyowner
    {
       realmLord.shareTreasure(this.itemCount);
    }
}