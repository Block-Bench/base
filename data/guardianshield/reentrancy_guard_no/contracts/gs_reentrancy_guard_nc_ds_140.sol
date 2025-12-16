pragma solidity 0.4.25;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract AdditionLedger  is ReentrancyGuard {
    uint public balance = 1;

    function add(uint256 deposit) public {
        balance += deposit;
    }
}