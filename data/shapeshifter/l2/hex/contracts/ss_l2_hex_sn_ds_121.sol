// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0x3b180b;
  uint _0x05a4b5;

  function _0x28622e() payable {
    require(msg.value > _0x05a4b5);

    //If the refund fails, the entire transaction reverts.

    if (_0x3b180b != 0) {
      //E.g. if recipients fallback function is just revert()
      require(_0x3b180b.send(_0x05a4b5));
    }

    _0x3b180b = msg.sender;
    _0x05a4b5         = msg.value;
  }
}

contract AuctionV2 {
  address _0x3b180b;
  uint    _0x05a4b5;

  mapping(address => uint) _0x36d615;

  //Avoids "pushing" balance to users favoring "pull" architecture
  function _0x28622e() payable external {
    require(msg.value > _0x05a4b5);

    if (_0x3b180b != 0) {
      _0x36d615[_0x3b180b] += _0x05a4b5;
    }

    _0x3b180b = msg.sender;
    _0x05a4b5         = msg.value;
  }

  //Allows users to get their refund from auction
  function _0x07dd92() external {
    //Do all state manipulation before external call to
    uint _0xe01c68 = _0x36d615[msg.sender];
    _0x36d615[msg.sender] = 0;

    msg.sender.send(_0xe01c68);
  }
}