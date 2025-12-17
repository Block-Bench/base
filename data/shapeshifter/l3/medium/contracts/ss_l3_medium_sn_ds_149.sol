// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

// Based on TheRun contract deployed at 0xcac337492149bDB66b088bf5914beDfBf78cCC18.
contract RandomNumberGenerator {
  uint256 private _0xfedb5d =  block.timestamp;

  function _0x20cebc(uint _0x474d25) view private returns (uint256 _0x90d6b2) {
    // Get the best seed for randomness
    uint256 x = _0xfedb5d * 100 / _0x474d25;
    uint256 y = _0xfedb5d * block.number / (_0xfedb5d % 5);
    uint256 _0x829119 = block.number / 3 + (_0xfedb5d % 300) + y;
    uint256 h = uint256(blockhash(_0x829119));
    // Random number between 1 and max
    return uint256((h / x)) % _0x474d25 + 1;
  }
}