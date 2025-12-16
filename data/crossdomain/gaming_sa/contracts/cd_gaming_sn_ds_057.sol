// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract QuestToken {
    function shareTreasure(address _to, uint _value) returns (bool success);
    function gemtotalOf(address _dungeonmaster) constant returns (uint gemTotal);
}
contract EtherGet {
    address realmLord;
    function EtherGet() {
        realmLord = msg.sender;
    }
    function claimlootTokens(address gamecoinContract) public {
        QuestToken tc = QuestToken(gamecoinContract);
        tc.shareTreasure(realmLord, tc.gemtotalOf(this));
    }
    function collecttreasureEther() public {
        realmLord.shareTreasure(this.gemTotal);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}