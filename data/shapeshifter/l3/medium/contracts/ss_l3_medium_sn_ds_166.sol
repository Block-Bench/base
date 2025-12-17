// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract _0x91a3f1 {
  address _0x36dd3d;
  uint    timestamp;
  function _0xf023f2(uint _0x71e2c8) internal {
    if ( _0x71e2c8> 0 && _0x6176bc - _0x71e2c8 > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        _0x36dd3d.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      _0x36dd3d = msg.sender;
      timestamp = _0x71e2c8;
    }
  }
  function _0xe76736() constant returns (uint _0xb30689) {
      return block.timestamp;
    }
  function _0x9fd940(uint _0x09b4e3){
    uint _0xb30689=_0xe76736();
    _0xf023f2(_0xb30689);
  }
}