

pragma solidity ^0.4.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract BenignCounter  is ReentrancyGuard {
    uint public count = 1;

    function run(uint256 input) public {
        uint res = count - input;
    }
}
