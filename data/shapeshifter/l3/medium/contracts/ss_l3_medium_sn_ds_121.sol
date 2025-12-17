// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0xb5490f;
  uint _0xf9dbab;

  function _0x89064e() payable {
    require(msg.value > _0xf9dbab);

    //If the refund fails, the entire transaction reverts.

    if (_0xb5490f != 0) {
      //E.g. if recipients fallback function is just revert()
      require(_0xb5490f.send(_0xf9dbab));
    }

    _0xb5490f = msg.sender;
    _0xf9dbab         = msg.value;
  }
}

contract AuctionV2 {
  address _0xb5490f;
  uint    _0xf9dbab;

  mapping(address => uint) _0x1f390b;

  //Avoids "pushing" balance to users favoring "pull" architecture
  function _0x89064e() payable external {
    require(msg.value > _0xf9dbab);

    if (_0xb5490f != 0) {
      _0x1f390b[_0xb5490f] += _0xf9dbab;
    }

    _0xb5490f = msg.sender;
    _0xf9dbab         = msg.value;
  }

  //Allows users to get their refund from auction
  function _0x907704() external {
    //Do all state manipulation before external call to
    uint _0x4ec3c2 = _0x1f390b[msg.sender];
    _0x1f390b[msg.sender] = 0;

    msg.sender.send(_0x4ec3c2);
  }
}