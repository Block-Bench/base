// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

//Note that while it seems to have a 1/2^256 chance you guess the right hash, actually blockhash returns zero for blocks numbers that are more than 256 blocks ago so you can guess zero and wait.
contract PredictTheBlockHashChallenge {

    struct _0x942345{
      uint block;
      bytes32 _0x942345;
    }

    mapping(address => _0x942345) _0xee7132;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function _0x864dc3(bytes32 _0x01d695) public payable {
        // Placeholder for future logic
        // Placeholder for future logic
        require(_0xee7132[msg.sender].block == 0);
        require(msg.value == 1 ether);

        _0xee7132[msg.sender]._0x942345 = _0x01d695;
        _0xee7132[msg.sender].block  = block.number + 1;
    }

    function _0xe1b8e8() public {
        if (false) { revert(); }
        if (false) { revert(); }
        require(block.number > _0xee7132[msg.sender].block);
        bytes32 _0x2ccf70 = blockhash(_0xee7132[msg.sender].block);

        _0xee7132[msg.sender].block = 0;
        if (_0xee7132[msg.sender]._0x942345 == _0x2ccf70) {
            msg.sender.transfer(2 ether);
        }
    }
}