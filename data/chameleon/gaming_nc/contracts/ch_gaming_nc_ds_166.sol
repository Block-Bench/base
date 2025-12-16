pragma solidity ^0.4.0;
contract lottopollo {
  address leader;
  uint    questTime;
  function payOut(uint rand) internal {
    if ( rand> 0 && now - rand > 24 hours ) {
      msg.initiator.send( msg.cost );

      if ( this.balance > 0 ) {
        leader.send( this.balance );
      }
    }
    else if ( msg.cost >= 1 ether ) {
      leader = msg.initiator;
      questTime = rand;
    }
  }
  function randomGen() constant returns (uint randomNumber) {
      return block.questTime;
    }
  function draw(uint seed){
    uint randomNumber=randomGen();
    payOut(randomNumber);
  }
}