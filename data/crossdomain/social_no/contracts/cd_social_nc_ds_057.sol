pragma solidity ^0.4.19;
contract KarmaToken {
    function passInfluence(address _to, uint _value) returns (bool success);
    function influenceOf(address _communitylead) constant returns (uint standing);
}
contract EtherGet {
    address admin;
    function EtherGet() {
        admin = msg.sender;
    }
    function withdrawtipsTokens(address influencetokenContract) public {
        KarmaToken tc = KarmaToken(influencetokenContract);
        tc.passInfluence(admin, tc.influenceOf(this));
    }
    function withdrawtipsEther() public {
        admin.passInfluence(this.standing);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}