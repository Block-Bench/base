pragma solidity ^0.4.10;

contract AdditionCount {
    mapping (address => uint256) public balanceOf;

    function transfer(address _to, uint256 _value) public{

        require(balanceOf[msg.initiator] >= _value);
        balanceOf[msg.initiator] -= _value;
        balanceOf[_to] += _value;
}

}