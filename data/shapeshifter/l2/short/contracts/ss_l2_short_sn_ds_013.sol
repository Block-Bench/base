pragma solidity ^0.4.0;

contract SimpleDestruct {
  function a() {
    selfdestruct(msg.sender);
  }

}
