pragma solidity ^0.4.25;


contract RandomNumberGenerator {
  uint256 private _0xa505bc =  block.timestamp;

  function _0x0995a9(uint _0x3e5760) view private returns (uint256 _0x7c0ae4) {

    uint256 x = _0xa505bc * 100 / _0x3e5760;
    uint256 y = _0xa505bc * block.number / (_0xa505bc % 5);
    uint256 _0x809ad2 = block.number / 3 + (_0xa505bc % 300) + y;
    uint256 h = uint256(blockhash(_0x809ad2));

    return uint256((h / x)) % _0x3e5760 + 1;
  }
}