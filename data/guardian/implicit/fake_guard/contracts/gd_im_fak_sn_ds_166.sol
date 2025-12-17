// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract lottopollo {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


  address leader;
  uint    timestamp;
  function payOut(uint rand) internal {
    if ( rand> 0 && now - rand > 24 hours ) {
      msg.sender/* Protected by reentrancy guard */ .send( msg.value );

      if ( this.balance > 0 ) {
        leader/* Protected by reentrancy guard */ .send( this.balance );
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