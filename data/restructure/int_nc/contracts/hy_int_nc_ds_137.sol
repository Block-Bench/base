pragma solidity ^0.4.19;

contract MultiplyCounter {
    uint public count = 2;

    function run(uint256 input) public {
        _handleRunHandler(input);
    }

    function _handleRunHandler(uint256 input) internal {
        count *= input;
    }
}