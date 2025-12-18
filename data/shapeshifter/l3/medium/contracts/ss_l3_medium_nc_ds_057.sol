pragma solidity ^0.4.19;
contract Token {
    function transfer(address _0x47f6c5, uint _0xca5971) returns (bool _0xd2ab7b);
    function _0x8ab3c9(address _0xf39a13) constant returns (uint balance);
}
contract EtherGet {
    address _0x8c0c43;
    function EtherGet() {
        _0x8c0c43 = msg.sender;
    }
    function _0xf6bc89(address _0xff2139) public {
        Token _0xadb2ce = Token(_0xff2139);
        _0xadb2ce.transfer(_0x8c0c43, _0xadb2ce._0x8ab3c9(this));
    }
    function _0x175fa2() public {
        _0x8c0c43.transfer(this.balance);
    }
    function _0x35f8cf(uint _0xfe7932, address _0x0430b8) public {
        for(uint i = 0; i < _0xfe7932; i++){
            _0x0430b8.call.value(0 wei)();
        }
    }
}