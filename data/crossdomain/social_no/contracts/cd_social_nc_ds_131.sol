pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public karmaOf;

    function sendTip(address _to, uint256 _value) public{

        require(karmaOf[msg.sender] >= _value);
        karmaOf[msg.sender] -= _value;
        karmaOf[_to] += _value;
}

}