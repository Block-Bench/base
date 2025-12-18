// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

// Based on TheRun contract deployed at 0xcac337492149bDB66b088bf5914beDfBf78cCC18.
contract RandomNumberGenerator {
  uint256 private _0x762929 =  block.timestamp;

  function _0xf4a09e(uint _0x7de616) view private returns (uint256 _0x0eb89e) {
    // Get the best seed for randomness
    uint256 x = _0x762929 * 100 / _0x7de616;
    uint256 y = _0x762929 * block.number / (_0x762929 % 5);
    uint256 _0x03b4b3 = block.number / 3 + (_0x762929 % 300) + y;
    uint256 h = uint256(blockhash(_0x03b4b3));
    // Random number between 1 and max
    return uint256((h / x)) % _0x7de616 + 1;
  }
}