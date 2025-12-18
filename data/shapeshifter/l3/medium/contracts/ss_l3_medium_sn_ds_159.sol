// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address _0xa155e9;
    uint number;
  }

  Player[2] public _0xcc7336;         //public only for debug purpose

  uint8 _0xfaefff;
  address _0xb67d3f;

  function OddsAndEvens() {
    _0xb67d3f = msg.sender;
  }
  function _0x398a41(uint number) payable{
    if (msg.value != 1 ether) throw;
    _0xcc7336[_0xfaefff] = Player(msg.sender, number);
    _0xfaefff++;

    if (_0xfaefff==2) _0x5c2675();
  }

  function _0x5c2675() private {
    bool _0xfa635c ;
    uint n = _0xcc7336[0].number+_0xcc7336[1].number;
    if (n%2==0) {
      _0xfa635c = _0xcc7336[0]._0xa155e9.send(1800 finney);
    }
    else {
      _0xfa635c = _0xcc7336[1]._0xa155e9.send(1800 finney);
    }

    delete _0xcc7336;
    _0xfaefff=0;
  }

  function _0xc4d2d5() {
    if(msg.sender!=_0xb67d3f) throw;
    bool _0xfa635c = msg.sender.send(this.balance);
  }

}