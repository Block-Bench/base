pragma solidity ^0.4.0;

contract RecordRetirement {
  function sudicideAnyone() {
    selfdestruct(msg.sender);
  }

}