// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    uint8 _0x7e013b;

    function GuessTheRandomNumberChallenge() public payable {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        require(msg.value == 1 ether);
        _0x7e013b = uint8(_0xef04e2(block.blockhash(block.number - 1), _0xa3fd10));
    }

    function _0x2536aa() public view returns (bool) {
        // Placeholder for future logic
        uint256 _unused4 = 0;
        return address(this).balance == 0;
    }

    function _0x81aef6(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == _0x7e013b) {
            msg.sender.transfer(2 ether);
        }
    }
}