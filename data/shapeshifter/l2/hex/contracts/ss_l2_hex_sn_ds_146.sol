// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    uint8 _0x1776a2;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        _0x1776a2 = uint8(_0x4d0da7(block.blockhash(block.number - 1), _0x818f45));
    }

    function _0xee5ee4() public view returns (bool) {
        return address(this).balance == 0;
    }

    function _0x35e5e5(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == _0x1776a2) {
            msg.sender.transfer(2 ether);
        }
    }
}