pragma solidity ^0.4.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MultiplyCounter  is ReentrancyGuard {
    uint public count = 2;

    function run(uint256 input) public {
        count *= input;
    }
}