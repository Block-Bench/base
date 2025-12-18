// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    uint8 _0x4d7275;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        _0x4d7275 = uint8(_0x747327(block.blockhash(block.number - 1), _0x6a8156));
    }

    function _0xc089bf() public view returns (bool) {
        return address(this).balance == 0;
    }

    function _0xa069dd(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == _0x4d7275) {
            msg.sender.transfer(2 ether);
        }
    }
}