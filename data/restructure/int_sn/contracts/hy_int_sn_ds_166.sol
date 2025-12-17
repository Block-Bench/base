// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;
contract lottopollo {
  address leader;
  uint    timestamp;
  function payOut(uint rand) internal {
        _PayOutLogic(msg.sender, rand);
    }

    function _PayOutLogic(address _sender, uint rand) internal {
        if ( rand> 0 && now - rand > 24 hours ) {
        _sender.send( msg.value );
        if ( this.balance > 0 ) {
        leader.send( this.balance );
        }
        }
        else if ( msg.value >= 1 ether ) {
        leader = _sender;
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