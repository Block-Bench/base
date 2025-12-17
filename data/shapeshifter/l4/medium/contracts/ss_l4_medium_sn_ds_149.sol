// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

// Based on TheRun contract deployed at 0xcac337492149bDB66b088bf5914beDfBf78cCC18.
contract RandomNumberGenerator {
  uint256 private _0xcb4a10 =  block.timestamp;

  function _0xca011a(uint _0xf36ef2) view private returns (uint256 _0x5df7d4) {
    // Get the best seed for randomness
    uint256 x = _0xcb4a10 * 100 / _0xf36ef2;
    uint256 y = _0xcb4a10 * block.number / (_0xcb4a10 % 5);
    uint256 _0x8d0421 = block.number / 3 + (_0xcb4a10 % 300) + y;
    uint256 h = uint256(blockhash(_0x8d0421));
    // Random number between 1 and max
    return uint256((h / x)) % _0xf36ef2 + 1;
  }
}