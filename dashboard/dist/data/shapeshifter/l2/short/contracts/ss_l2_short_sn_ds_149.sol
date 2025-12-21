// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

// Based on TheRun contract deployed at 0xcac337492149bDB66b088bf5914beDfBf78cCC18.
contract RandomNumberGenerator {
  uint256 private c =  block.timestamp;

  function a(uint e) view private returns (uint256 b) {
    // Get the best seed for randomness
    uint256 x = c * 100 / e;
    uint256 y = c * block.number / (c % 5);
    uint256 d = block.number / 3 + (c % 300) + y;
    uint256 h = uint256(blockhash(d));
    // Random number between 1 and max
    return uint256((h / x)) % e + 1;
  }
}