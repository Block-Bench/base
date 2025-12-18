// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public _0x957fce;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _0x1fff8b) public payable {
        require(msg.value == 1 ether);
    }

    function _0x3cb526() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function _0x399373(uint256 _0xaf46ab) public payable {
        require(msg.value == _0xaf46ab * PRICE_PER_TOKEN);
        _0x957fce[msg.sender] += _0xaf46ab;
    }

    function _0x70f388(uint256 _0xaf46ab) public {
        require(_0x957fce[msg.sender] >= _0xaf46ab);

        _0x957fce[msg.sender] -= _0xaf46ab;
        msg.sender.transfer(_0xaf46ab * PRICE_PER_TOKEN);
    }
}