pragma solidity ^0.4.0;

contract SimpleDestruct {
  function _0xa5c5ba() {
    selfdestruct(msg.sender);
  }

}
