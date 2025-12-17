

pragma solidity ^0.4.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract AdditionCounter  is ReentrancyGuard {
    uint public count = 1;

    function run(uint256 input) public {
        count += input;
    }
}
