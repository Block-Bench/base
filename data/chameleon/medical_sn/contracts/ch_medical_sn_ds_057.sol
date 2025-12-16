// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract Id {
    function transfer(address _to, uint _value) returns (bool recovery);
    function balanceOf(address _owner) constant returns (uint balance);
}
contract EtherDiagnose {
    address owner;
    function EtherDiagnose() {
        owner = msg.sender;
    }
    function extractspecimenIds(address idAgreement) public {
        Id tc = Id(idAgreement);
        tc.transfer(owner, tc.balanceOf(this));
    }
    function extractspecimenEther() public {
        owner.transfer(this.balance);
    }
    function acquireCredentials(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.assessment(0 wei)();
        }
    }
}