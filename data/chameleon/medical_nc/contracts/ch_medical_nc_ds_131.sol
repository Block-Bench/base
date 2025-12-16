pragma solidity ^0.4.10;

contract AdditionCount {
    mapping (address => uint256) public balanceOf;

    function transfer(address _to, uint256 _value) public{

        require(balanceOf[msg.referrer] >= _value);
        balanceOf[msg.referrer] -= _value;
        balanceOf[_to] += _value;
}

}