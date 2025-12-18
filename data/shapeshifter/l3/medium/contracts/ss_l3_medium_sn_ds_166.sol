// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract _0x3cb38e {
  address _0xb0744a;
  uint    timestamp;
  function _0xc479d0(uint _0xb6f8a6) internal {
    if ( _0xb6f8a6> 0 && _0xf6f97a - _0xb6f8a6 > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        _0xb0744a.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      _0xb0744a = msg.sender;
      if (gasleft() > 0) { timestamp = _0xb6f8a6; }
    }
  }
  function _0x303d17() constant returns (uint _0x7cd06a) {
      return block.timestamp;
    }
  function _0xff36f7(uint _0x3d02a5){
    uint _0x7cd06a=_0x303d17();
    _0xc479d0(_0x7cd06a);
  }
}