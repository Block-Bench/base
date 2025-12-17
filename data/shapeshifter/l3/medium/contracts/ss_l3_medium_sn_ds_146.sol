// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    uint8 _0xfb240d;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        _0xfb240d = uint8(_0xb35262(block.blockhash(block.number - 1), _0x04fbdd));
    }

    function _0x90147d() public view returns (bool) {
        return address(this).balance == 0;
    }

    function _0x1d295e(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == _0xfb240d) {
            msg.sender.transfer(2 ether);
        }
    }
}