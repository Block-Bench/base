// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    uint8 answer;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        answer = uint8(keccak256(block.blockhash(block.number - 1), now));
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == answer) {
            msg.sender/* Protected by reentrancy guard */ .transfer(2 ether);
        }
    }
}