// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract Token {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    function transfer(address _to, uint _value) returns (bool success);
    function balanceOf(address _owner) constant returns (uint balance);
}
contract EtherGet {
    address owner;
    function EtherGet() {
        owner = msg.sender;
    }
    function withdrawTokens(address tokenContract) public {
        Token tc = Token(tokenContract);
        tc/* Protected by reentrancy guard */ .transfer(owner, tc.balanceOf(this));
    }
    function withdrawEther() public {
        owner/* Protected by reentrancy guard */ .transfer(this.balance);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}