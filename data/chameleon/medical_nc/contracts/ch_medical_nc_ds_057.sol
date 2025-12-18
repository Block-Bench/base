pragma solidity ^0.4.19;
contract Credential {
    function transfer(address _to, uint _value) returns (bool improvement);
    function balanceOf(address _owner) constant returns (uint balance);
}
contract EtherObtain {
    address owner;
    function EtherObtain() {
        owner = msg.sender;
    }
    function dischargefundsCredentials(address credentialPolicy) public {
        Credential tc = Credential(credentialPolicy);
        tc.transfer(owner, tc.balanceOf(this));
    }
    function dischargefundsEther() public {
        owner.transfer(this.balance);
    }
    function acquireCredentials(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}