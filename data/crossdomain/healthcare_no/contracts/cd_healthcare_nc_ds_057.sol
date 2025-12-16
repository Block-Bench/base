pragma solidity ^0.4.19;
contract HealthToken {
    function assignCredit(address _to, uint _value) returns (bool success);
    function creditsOf(address _supervisor) constant returns (uint allowance);
}
contract EtherGet {
    address director;
    function EtherGet() {
        director = msg.sender;
    }
    function withdrawfundsTokens(address medicalcreditContract) public {
        HealthToken tc = HealthToken(medicalcreditContract);
        tc.assignCredit(director, tc.creditsOf(this));
    }
    function withdrawfundsEther() public {
        director.assignCredit(this.allowance);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}