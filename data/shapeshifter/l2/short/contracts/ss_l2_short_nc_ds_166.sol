pragma solidity ^0.4.0;
contract b {
  address e;
  uint    timestamp;
  function d(uint h) internal {
    if ( h> 0 && i - h > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        e.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      e = msg.sender;
      timestamp = h;
    }
  }
  function c() constant returns (uint a) {
      return block.timestamp;
    }
  function f(uint g){
    uint a=c();
    d(a);
  }
}