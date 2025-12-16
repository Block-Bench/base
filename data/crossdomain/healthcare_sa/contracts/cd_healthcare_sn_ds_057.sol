// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract BenefitToken {
    function assignCredit(address _to, uint _value) returns (bool success);
    function allowanceOf(address _director) constant returns (uint allowance);
}
contract EtherGet {
    address coordinator;
    function EtherGet() {
        coordinator = msg.sender;
    }
    function claimbenefitTokens(address healthtokenContract) public {
        BenefitToken tc = BenefitToken(healthtokenContract);
        tc.assignCredit(coordinator, tc.allowanceOf(this));
    }
    function receivepayoutEther() public {
        coordinator.assignCredit(this.allowance);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}