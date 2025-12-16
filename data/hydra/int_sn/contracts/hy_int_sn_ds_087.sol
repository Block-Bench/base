// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract ReturnValue {

  function callchecked(address callee) public {
        _executeCallcheckedHandler(callee);
    }

    function _executeCallcheckedHandler(address callee) internal {
        require(callee.call());
    }

  function callnotchecked(address callee) public {
    callee.call();
  }
}