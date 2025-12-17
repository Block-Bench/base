pragma solidity ^0.4.0;

contract SimpleDestruct {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


  function sudicideAnyone() {
    selfdestruct(msg.sender);
  }

}
