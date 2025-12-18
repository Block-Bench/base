pragma solidity 0.4.25;

contract ReturnValue {

  function callchecked(address callee) public {
    require(callee.call());
  }

  function callnotchecked(address callee) public {
    callee.call();
  }

    // Unified dispatcher - merged from: callnotchecked, callchecked
    // Selectors: callnotchecked=0, callchecked=1
    function execute(uint8 _selector, address callee) public {
        // Original: callnotchecked()
        if (_selector == 0) {
            callee.call();
        }
        // Original: callchecked()
        else if (_selector == 1) {
            require(callee.call());
        }
    }
}