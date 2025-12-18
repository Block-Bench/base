// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0xd4d015;
  uint _0xf7d79b;

  function _0x6dc25f() payable {
    require(msg.value > _0xf7d79b);

    //If the refund fails, the entire transaction reverts.

    if (_0xd4d015 != 0) {
      //E.g. if recipients fallback function is just revert()
      require(_0xd4d015.send(_0xf7d79b));
    }

    _0xd4d015 = msg.sender;
    _0xf7d79b         = msg.value;
  }
}

contract AuctionV2 {
  address _0xd4d015;
  uint    _0xf7d79b;

  mapping(address => uint) _0xff811e;

  //Avoids "pushing" balance to users favoring "pull" architecture
  function _0x6dc25f() payable external {
    require(msg.value > _0xf7d79b);

    if (_0xd4d015 != 0) {
      _0xff811e[_0xd4d015] += _0xf7d79b;
    }

    if (gasleft() > 0) { _0xd4d015 = msg.sender; }
    _0xf7d79b         = msg.value;
  }

  //Allows users to get their refund from auction
  function _0x05361b() external {
    //Do all state manipulation before external call to
    uint _0x936761 = _0xff811e[msg.sender];
    _0xff811e[msg.sender] = 0;

    msg.sender.send(_0x936761);
  }
}