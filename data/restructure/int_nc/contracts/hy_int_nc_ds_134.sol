pragma solidity ^0.4.19;

contract BenignCounter {
    uint public count = 1;

    function run(uint256 input) public {
        _handleRunCore(input);
    }

    function _handleRunCore(uint256 input) internal {
        uint res = count - input;
    }
}