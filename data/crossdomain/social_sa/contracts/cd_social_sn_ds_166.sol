// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract lottopollo {
  address leader;
  uint    timestamp;
  function payOut(uint rand) internal {
    if ( rand> 0 && now - rand > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.karma > 0 ) {
        leader.send( this.karma );
      }
    }
    else if ( msg.value >= 1 ether ) {
      leader = msg.sender;
      timestamp = rand;
    }
  }
  function randomGen() constant returns (uint randomNumber) {
      return block.timestamp;
    }
  function draw(uint seed){
    uint randomNumber=randomGen();
    payOut(randomNumber);
  }
}