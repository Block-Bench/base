pragma solidity ^0.4.0;

contract SimpleDestruct {
  function _0x55c259() {
    selfdestruct(msg.sender);
  }

}