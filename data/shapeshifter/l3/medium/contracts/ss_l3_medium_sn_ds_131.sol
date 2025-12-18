// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public _0xbad9b9;

    function transfer(address _0x50d537, uint256 _0x23e895) public{
        /* Check if sender has balance */
        require(_0xbad9b9[msg.sender] >= _0x23e895);
        _0xbad9b9[msg.sender] -= _0x23e895;
        _0xbad9b9[_0x50d537] += _0x23e895;
}

}