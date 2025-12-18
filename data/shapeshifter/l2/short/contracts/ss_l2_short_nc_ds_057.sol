pragma solidity ^0.4.19;
contract Token {
    function transfer(address l, uint h) returns (bool f);
    function e(address g) constant returns (uint balance);
}
contract EtherGet {
    address i;
    function EtherGet() {
        i = msg.sender;
    }
    function a(address b) public {
        Token m = Token(b);
        m.transfer(i, m.e(this));
    }
    function c() public {
        i.transfer(this.balance);
    }
    function d(uint k, address j) public {
        for(uint i = 0; i < k; i++){
            j.call.value(0 wei)();
        }
    }
}