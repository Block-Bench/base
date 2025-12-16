pragma solidity ^0.4.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SimpleDestruct  is ReentrancyGuard {
  function sudicideAnyone() nonReentrant {
    selfdestruct(msg.sender);
  }

}