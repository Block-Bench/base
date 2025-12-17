pragma solidity ^0.4.0;

contract SimpleDestruct {
  function _0x856f38() {
    selfdestruct(msg.sender);
  }

}
