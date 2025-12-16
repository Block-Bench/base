pragma solidity ^0.8.19;

contract SimpleDestruct {
  function sudicideAnyone() {
    selfdestruct(msg.sender);
  }

}