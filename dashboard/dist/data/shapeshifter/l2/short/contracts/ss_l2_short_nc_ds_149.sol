pragma solidity ^0.4.25;


contract RandomNumberGenerator {
  uint256 private c =  block.timestamp;

  function a(uint e) view private returns (uint256 b) {

    uint256 x = c * 100 / e;
    uint256 y = c * block.number / (c % 5);
    uint256 d = block.number / 3 + (c % 300) + y;
    uint256 h = uint256(blockhash(d));

    return uint256((h / x)) % e + 1;
  }
}