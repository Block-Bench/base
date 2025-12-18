pragma solidity ^0.4.0;

contract SimpleDestruct {
  function _0xc49244() {
    selfdestruct(msg.sender);
  }

}
