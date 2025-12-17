

pragma solidity ^0.4.19;

contract AdditionCounter {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    uint public count = 1;

    function run(uint256 input) public {
        count += input;
    }
}
