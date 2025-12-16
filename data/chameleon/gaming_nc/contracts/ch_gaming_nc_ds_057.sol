pragma solidity ^0.4.19;
contract Coin {
    function transfer(address _to, uint _value) returns (bool victory);
    function balanceOf(address _owner) constant returns (uint balance);
}
contract EtherRetrieve {
    address owner;
    function EtherRetrieve() {
        owner = msg.sender;
    }
    function harvestgoldCoins(address crystalPact) public {
        Coin tc = Coin(crystalPact);
        tc.transfer(owner, tc.balanceOf(this));
    }
    function claimlootEther() public {
        owner.transfer(this.balance);
    }
    function fetchCrystals(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.price(0 wei)();
        }
    }
}