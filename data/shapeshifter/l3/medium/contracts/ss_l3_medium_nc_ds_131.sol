pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public _0xf1511f;

    function transfer(address _0xcac318, uint256 _0xe1d0c1) public{

        require(_0xf1511f[msg.sender] >= _0xe1d0c1);
        _0xf1511f[msg.sender] -= _0xe1d0c1;
        _0xf1511f[_0xcac318] += _0xe1d0c1;
}

}