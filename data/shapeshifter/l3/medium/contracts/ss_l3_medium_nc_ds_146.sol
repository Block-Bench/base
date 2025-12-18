pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    uint8 _0x56c05c;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        _0x56c05c = uint8(_0x1964e7(block.blockhash(block.number - 1), _0xf6f3c6));
    }

    function _0x749dd9() public view returns (bool) {
        return address(this).balance == 0;
    }

    function _0xa40b37(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == _0x56c05c) {
            msg.sender.transfer(2 ether);
        }
    }
}