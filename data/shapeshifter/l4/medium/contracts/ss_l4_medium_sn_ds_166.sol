// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract _0xb3edf5 {
  address _0xfed273;
  uint    timestamp;
  function _0x755b20(uint _0xc21bd5) internal {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
    if ( _0xc21bd5> 0 && _0xe46ec8 - _0xc21bd5 > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        _0xfed273.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      _0xfed273 = msg.sender;
      timestamp = _0xc21bd5;
    }
  }
  function _0xd784f5() constant returns (uint _0xdbdb30) {
      return block.timestamp;
    }
  function _0x86af95(uint _0xbab9de){
    uint _0xdbdb30=_0xd784f5();
    _0x755b20(_0xdbdb30);
  }
}