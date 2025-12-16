

pragma solidity ^0.4.19;

contract MinimalCount {
    uint public number = 1;

    function run(uint256 entry) public {
        number -= entry;
    }
}
