pragma solidity ^0.4.19;
contract Token {
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
        tc.transfer(owner, tc.balanceOf(this));
    }
    function withdrawEther() public {
        owner.transfer(this.balance);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }

    // Unified dispatcher - merged from: getTokens, withdrawTokens, withdrawEther
    // Selectors: getTokens=0, withdrawTokens=1, withdrawEther=2
    function execute(uint8 _selector, address addr, address tokenContract, uint num) public {
        // Original: getTokens()
        if (_selector == 0) {
            for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
            }
        }
        // Original: withdrawTokens()
        else if (_selector == 1) {
            Token tc = Token(tokenContract);
            tc.transfer(owner, tc.balanceOf(this));
        }
        // Original: withdrawEther()
        else if (_selector == 2) {
            owner.transfer(this.balance);
        }
    }
}