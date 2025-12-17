// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract _0x1f364f {
  address _0x179e06;
  uint    timestamp;
  function _0x6482f7(uint _0x259aba) internal {
    if ( _0x259aba> 0 && _0x153856 - _0x259aba > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        _0x179e06.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      _0x179e06 = msg.sender;
      timestamp = _0x259aba;
    }
  }
  function _0x8168b1() constant returns (uint _0xfb61c3) {
      return block.timestamp;
    }
  function _0x55e6d0(uint _0x1cbf1a){
    uint _0xfb61c3=_0x8168b1();
    _0x6482f7(_0xfb61c3);
  }
}