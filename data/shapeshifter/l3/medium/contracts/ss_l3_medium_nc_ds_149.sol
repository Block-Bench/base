pragma solidity ^0.4.25;


contract RandomNumberGenerator {
  uint256 private _0x04f949 =  block.timestamp;

  function _0x04a37f(uint _0xc44bc6) view private returns (uint256 _0x8a7dde) {

    uint256 x = _0x04f949 * 100 / _0xc44bc6;
    uint256 y = _0x04f949 * block.number / (_0x04f949 % 5);
    uint256 _0xd4d83e = block.number / 3 + (_0x04f949 % 300) + y;
    uint256 h = uint256(blockhash(_0xd4d83e));

    return uint256((h / x)) % _0xc44bc6 + 1;
  }
}