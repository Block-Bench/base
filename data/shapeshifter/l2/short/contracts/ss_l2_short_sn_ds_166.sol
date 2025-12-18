// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract b {
  address d;
  uint    timestamp;
  function e(uint g) internal {
    if ( g> 0 && i - g > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        d.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      d = msg.sender;
      timestamp = g;
    }
  }
  function c() constant returns (uint a) {
      return block.timestamp;
    }
  function h(uint f){
    uint a=c();
    e(a);
  }
}