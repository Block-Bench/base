// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract ReturnValue {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;



  function callchecked(address callee) public {
    require(callee.call());
  }

  function callnotchecked(address callee) public {
    callee.call();
  }
}