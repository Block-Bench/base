pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge {
    uint8 _0x36da95;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        _0x36da95 = uint8(_0xb67169(block.blockhash(block.number - 1), _0x892bc4));
    }

    function _0xf89852() public view returns (bool) {
        return address(this).balance == 0;
    }

    function _0xcd72f5(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == _0x36da95) {
            msg.sender.transfer(2 ether);
        }
    }
}