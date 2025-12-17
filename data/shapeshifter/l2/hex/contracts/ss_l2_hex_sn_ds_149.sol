// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

// Based on TheRun contract deployed at 0xcac337492149bDB66b088bf5914beDfBf78cCC18.
contract RandomNumberGenerator {
  uint256 private _0x3eebd2 =  block.timestamp;

  function _0xf919d5(uint _0x8bd590) view private returns (uint256 _0x0968eb) {
    // Get the best seed for randomness
    uint256 x = _0x3eebd2 * 100 / _0x8bd590;
    uint256 y = _0x3eebd2 * block.number / (_0x3eebd2 % 5);
    uint256 _0xd05746 = block.number / 3 + (_0x3eebd2 % 300) + y;
    uint256 h = uint256(blockhash(_0xd05746));
    // Random number between 1 and max
    return uint256((h / x)) % _0x8bd590 + 1;
  }
}