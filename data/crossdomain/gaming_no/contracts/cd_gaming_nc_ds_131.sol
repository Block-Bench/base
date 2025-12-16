pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public goldholdingOf;

    function sendGold(address _to, uint256 _value) public{

        require(goldholdingOf[msg.sender] >= _value);
        goldholdingOf[msg.sender] -= _value;
        goldholdingOf[_to] += _value;
}

}