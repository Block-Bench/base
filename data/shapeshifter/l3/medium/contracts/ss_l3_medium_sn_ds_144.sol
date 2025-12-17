// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public _0x3dfa65;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _0x880aa9) public payable {
        require(msg.value == 1 ether);
    }

    function _0x7ba127() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function _0x6215a6(uint256 _0x07cd20) public payable {
        require(msg.value == _0x07cd20 * PRICE_PER_TOKEN);
        _0x3dfa65[msg.sender] += _0x07cd20;
    }

    function _0xf43d63(uint256 _0x07cd20) public {
        require(_0x3dfa65[msg.sender] >= _0x07cd20);

        _0x3dfa65[msg.sender] -= _0x07cd20;
        msg.sender.transfer(_0x07cd20 * PRICE_PER_TOKEN);
    }
}