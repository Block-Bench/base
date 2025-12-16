pragma solidity ^0.4.23;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SingleTxCounter  is ReentrancyGuard {
    uint public count = 1;

    function addtostate(uint256 input) public {
        count += input;
    }

    function multostate(uint256 input) public {
        count *= input;
    }

    function underflowtostate(uint256 input) public {
        count -= input;
    }

    function localcalc(uint256 input) public {
        uint res = count + input;
    }

    function mullocalonly(uint256 input) public {
        uint res = count * input;
    }

    function underflowlocalonly(uint256 input) public {
       	uint res = count - input;
    }

}