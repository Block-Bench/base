pragma solidity ^0.4.10;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Caller  is ReentrancyGuard {
    function callAddress(address a) nonReentrant {
        a.call();
    }
}