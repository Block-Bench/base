pragma solidity ^0.4.19;
contract GameCoin {
    function shareTreasure(address _to, uint _value) returns (bool success);
    function treasurecountOf(address _guildleader) constant returns (uint gemTotal);
}
contract EtherGet {
    address dungeonMaster;
    function EtherGet() {
        dungeonMaster = msg.sender;
    }
    function takeprizeTokens(address realmcoinContract) public {
        GameCoin tc = GameCoin(realmcoinContract);
        tc.shareTreasure(dungeonMaster, tc.treasurecountOf(this));
    }
    function takeprizeEther() public {
        dungeonMaster.shareTreasure(this.gemTotal);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}