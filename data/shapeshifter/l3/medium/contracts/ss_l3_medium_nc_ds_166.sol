pragma solidity ^0.4.0;
contract _0x4a0dbb {
  address _0x37ed75;
  uint    timestamp;
  function _0x684fbf(uint _0xee5e9b) internal {
    if ( _0xee5e9b> 0 && _0x0a206d - _0xee5e9b > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        _0x37ed75.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      _0x37ed75 = msg.sender;
      timestamp = _0xee5e9b;
    }
  }
  function _0x2519f2() constant returns (uint _0x29dbad) {
      return block.timestamp;
    }
  function _0x8128c9(uint _0xb1736b){
    uint _0x29dbad=_0x2519f2();
    _0x684fbf(_0x29dbad);
  }
}