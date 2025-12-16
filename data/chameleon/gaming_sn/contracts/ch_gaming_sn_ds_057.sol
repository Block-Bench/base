// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract Gem {
    function transfer(address _to, uint _value) returns (bool win);
    function balanceOf(address _owner) constant returns (uint balance);
}
contract EtherAcquire {
    address owner;
    function EtherAcquire() {
        owner = msg.sender;
    }
    function redeemtokensMedals(address coinPact) public {
        Gem tc = Gem(coinPact);
        tc.transfer(owner, tc.balanceOf(this));
    }
    function claimlootEther() public {
        owner.transfer(this.balance);
    }
    function obtainCoins(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.price(0 wei)();
        }
    }
}