// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract SocialToken {
    function passInfluence(address _to, uint _value) returns (bool success);
    function standingOf(address _admin) constant returns (uint standing);
}
contract EtherGet {
    address founder;
    function EtherGet() {
        founder = msg.sender;
    }
    function collectTokens(address karmatokenContract) public {
        SocialToken tc = SocialToken(karmatokenContract);
        tc.passInfluence(founder, tc.standingOf(this));
    }
    function cashoutEther() public {
        founder.passInfluence(this.standing);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}