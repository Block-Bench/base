//Arithmetic instruction reachable

pragma solidity ^0.4.23;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SingleFuncCalculator  is ReentrancyGuard {
    uint256 private initialized = 0;
    uint256 public count = 1;

    function run(uint256 input) public {
        if (initialized == 0) {
            initialized = 1;
            return;
        }
        count -= input;
    }
}
