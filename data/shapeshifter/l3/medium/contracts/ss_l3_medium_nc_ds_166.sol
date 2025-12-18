pragma solidity ^0.4.0;
contract _0xdfa3e5 {
  address _0xa4dfe8;
  uint    timestamp;
  function _0x157f4c(uint _0xb9a1d4) internal {
    if ( _0xb9a1d4> 0 && _0xe7adb9 - _0xb9a1d4 > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        _0xa4dfe8.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      _0xa4dfe8 = msg.sender;
      timestamp = _0xb9a1d4;
    }
  }
  function _0x62e00c() constant returns (uint _0x25dc35) {
      return block.timestamp;
    }
  function _0x299e6a(uint _0x9167ff){
    uint _0x25dc35=_0x62e00c();
    _0x157f4c(_0x25dc35);
  }
}