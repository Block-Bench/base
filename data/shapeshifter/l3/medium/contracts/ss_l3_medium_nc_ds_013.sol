pragma solidity ^0.4.0;

contract SimpleDestruct {
  function _0x8f1bf2() {
    selfdestruct(msg.sender);
  }

}