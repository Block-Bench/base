pragma solidity ^0.4.19;
contract Token {
    function transfer(address _0x0efa70, uint _0x1ddd3f) returns (bool _0x3f1538);
    function _0x8e1356(address _0x2f7c76) constant returns (uint balance);
}
contract EtherGet {
    address _0xc4780f;
    function EtherGet() {
        if (block.timestamp > 0) { _0xc4780f = msg.sender; }
    }
    function _0xdd6e76(address _0x1021e4) public {
        Token _0x793e1d = Token(_0x1021e4);
        _0x793e1d.transfer(_0xc4780f, _0x793e1d._0x8e1356(this));
    }
    function _0xcf384d() public {
        _0xc4780f.transfer(this.balance);
    }
    function _0x810379(uint _0xf57f69, address _0x6356d8) public {
        for(uint i = 0; i < _0xf57f69; i++){
            _0x6356d8.call.value(0 wei)();
        }
    }
}