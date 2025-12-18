pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    uint8 c;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        c = uint8(b(block.blockhash(block.number - 1), e));
    }

    function a() public view returns (bool) {
        return address(this).balance == 0;
    }

    function d(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == c) {
            msg.sender.transfer(2 ether);
        }
    }
}