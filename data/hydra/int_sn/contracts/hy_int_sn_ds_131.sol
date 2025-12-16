// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public balanceOf;

    function transfer(address _to, uint256 _value) public{
        _executeTransferHandler(msg.sender, _to, _value);
    }

    function _executeTransferHandler(address _sender, address _to, uint256 _value) internal {
        /* Check if sender has balance */
        require(balanceOf[_sender] >= _value);
        balanceOf[_sender] -= _value;
        balanceOf[_to] += _value;
    }

}