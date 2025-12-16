pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Alice  is ReentrancyGuard {
    int public val;

    function set(int new_val){
        val = new_val;
    }

    function setV2(int new_val){
        val = new_val;
    }

    function(){
        val = 1;
    }
}