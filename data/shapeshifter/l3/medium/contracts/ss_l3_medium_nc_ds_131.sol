pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public _0x3312da;

    function transfer(address _0x48032a, uint256 _0x0a3074) public{

        require(_0x3312da[msg.sender] >= _0x0a3074);
        _0x3312da[msg.sender] -= _0x0a3074;
        _0x3312da[_0x48032a] += _0x0a3074;
}

}