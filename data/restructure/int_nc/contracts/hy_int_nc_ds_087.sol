pragma solidity 0.4.25;

contract ReturnValue {

  function callchecked(address callee) public {
    require(callee.call());
  }

  function callnotchecked(address callee) public {
        _executeCallnotcheckedImpl(callee);
    }

    function _executeCallnotcheckedImpl(address callee) internal {
        callee.call();
    }
}