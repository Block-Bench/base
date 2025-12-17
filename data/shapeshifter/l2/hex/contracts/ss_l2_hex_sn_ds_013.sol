pragma solidity ^0.4.0;

contract SimpleDestruct {
  function _0x5a191d() {
    selfdestruct(msg.sender);
  }

}
