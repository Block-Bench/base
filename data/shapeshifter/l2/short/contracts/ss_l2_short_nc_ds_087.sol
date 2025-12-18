pragma solidity 0.4.25;

contract ReturnValue {

  function b(address c) public {
    require(c.call());
  }

  function a(address c) public {
    c.call();
  }
}