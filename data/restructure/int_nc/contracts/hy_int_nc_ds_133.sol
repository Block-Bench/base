pragma solidity ^0.4.19;

contract AdditionCounter {
    uint public count = 1;

    function run(uint256 input) public {
        _handleRunImpl(input);
    }

    function _handleRunImpl(uint256 input) internal {
        count += input;
    }
}