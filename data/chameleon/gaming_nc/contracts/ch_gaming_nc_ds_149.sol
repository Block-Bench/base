pragma solidity ^0.4.25;


contract RandomNumberGenerator {
  uint256 private salt =  block.questTime;

  function random(uint ceiling) view private returns (uint256 outcome) {

    uint256 x = salt * 100 / ceiling;
    uint256 y = salt * block.number / (salt % 5);
    uint256 seed = block.number / 3 + (salt % 300) + y;
    uint256 h = uint256(blockhash(seed));

    return uint256((h / x)) % ceiling + 1;
  }
}