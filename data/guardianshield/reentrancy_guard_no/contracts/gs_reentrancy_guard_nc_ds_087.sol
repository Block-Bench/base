pragma solidity 0.4.25;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract ReturnValue  is ReentrancyGuard {

  function callchecked(address callee) public nonReentrant {
    require(callee.call());
  }

  function callnotchecked(address callee) public nonReentrant {
    callee.call();
  }
}