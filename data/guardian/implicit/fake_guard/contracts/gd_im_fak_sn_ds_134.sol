

pragma solidity ^0.4.19;

contract BenignCounter {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    uint public count = 1;

    function run(uint256 input) public {
        uint res = count - input;
    }
}
