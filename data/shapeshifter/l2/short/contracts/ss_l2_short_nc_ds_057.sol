pragma solidity ^0.4.19;
contract Token {
    function transfer(address k, uint h) returns (bool f);
    function d(address g) constant returns (uint balance);
}
contract EtherGet {
    address i;
    function EtherGet() {
        i = msg.sender;
    }
    function a(address b) public {
        Token m = Token(b);
        m.transfer(i, m.d(this));
    }
    function c() public {
        i.transfer(this.balance);
    }
    function e(uint l, address j) public {
        for(uint i = 0; i < l; i++){
            j.call.value(0 wei)();
        }
    }
}