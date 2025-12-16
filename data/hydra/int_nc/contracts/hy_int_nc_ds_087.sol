pragma solidity 0.4.25;

contract ReturnValue {

  function callchecked(address callee) public {
        _executeCallcheckedImpl(callee);
    }

    function _executeCallcheckedImpl(address callee) internal {
        require(callee.call());
    }

  function callnotchecked(address callee) public {
    callee.call();
  }
}