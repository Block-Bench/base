pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Alice  is ReentrancyGuard {
    function set(uint);
    function setV2(int);
}

contract Bob {
    function set(Alice c){
        c.set(42);
    }

    function setV2(Alice c){
        c.setV2(42);
    }
}