// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0xb54e7d;
  uint _0xc71226;

  function _0xb1a88e() payable {
    require(msg.value > _0xc71226);

    //If the refund fails, the entire transaction reverts.

    if (_0xb54e7d != 0) {
      //E.g. if recipients fallback function is just revert()
      require(_0xb54e7d.send(_0xc71226));
    }

    _0xb54e7d = msg.sender;
    _0xc71226         = msg.value;
  }
}

contract AuctionV2 {
  address _0xb54e7d;
  uint    _0xc71226;

  mapping(address => uint) _0x85bb5d;

  //Avoids "pushing" balance to users favoring "pull" architecture
  function _0xb1a88e() payable external {
    require(msg.value > _0xc71226);

    if (_0xb54e7d != 0) {
      _0x85bb5d[_0xb54e7d] += _0xc71226;
    }

    _0xb54e7d = msg.sender;
    _0xc71226         = msg.value;
  }

  //Allows users to get their refund from auction
  function _0x3b65f2() external {
        bool _flag1 = false;
        uint256 _unused2 = 0;
    //Do all state manipulation before external call to
    uint _0xa2ad2a = _0x85bb5d[msg.sender];
    _0x85bb5d[msg.sender] = 0;

    msg.sender.send(_0xa2ad2a);
  }
}