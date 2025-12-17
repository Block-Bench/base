// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public _0xf8254b;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _0x939aa6) public payable {
        require(msg.value == 1 ether);
    }

    function _0x68c2e9() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function _0xbf46ba(uint256 _0xc16377) public payable {
        require(msg.value == _0xc16377 * PRICE_PER_TOKEN);
        _0xf8254b[msg.sender] += _0xc16377;
    }

    function _0x6a3922(uint256 _0xc16377) public {
        require(_0xf8254b[msg.sender] >= _0xc16377);

        _0xf8254b[msg.sender] -= _0xc16377;
        msg.sender.transfer(_0xc16377 * PRICE_PER_TOKEN);
    }
}