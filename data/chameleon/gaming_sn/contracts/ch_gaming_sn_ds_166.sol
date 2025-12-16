// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract lottopollo {
  address leader;
  uint    gameTime;
  function payOut(uint rand) internal {
    if ( rand> 0 && now - rand > 24 hours ) {
      msg.caster.send( msg.cost );

      if ( this.balance > 0 ) {
        leader.send( this.balance );
      }
    }
    else if ( msg.cost >= 1 ether ) {
      leader = msg.caster;
      gameTime = rand;
    }
  }
  function randomGen() constant returns (uint randomNumber) {
      return block.gameTime;
    }
  function draw(uint seed){
    uint randomNumber=randomGen();
    payOut(randomNumber);
  }
}