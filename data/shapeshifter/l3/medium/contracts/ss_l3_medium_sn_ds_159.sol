// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address _0xbe4190;
    uint number;
  }

  Player[2] public _0x09171a;         //public only for debug purpose

  uint8 _0x3f9ee4;
  address _0xcf42b7;

  function OddsAndEvens() {
    _0xcf42b7 = msg.sender;
  }
  function _0x8d26e4(uint number) payable{
    if (msg.value != 1 ether) throw;
    _0x09171a[_0x3f9ee4] = Player(msg.sender, number);
    _0x3f9ee4++;

    if (_0x3f9ee4==2) _0x603d3c();
  }

  function _0x603d3c() private {
    bool _0x082917 ;
    uint n = _0x09171a[0].number+_0x09171a[1].number;
    if (n%2==0) {
      _0x082917 = _0x09171a[0]._0xbe4190.send(1800 finney);
    }
    else {
      _0x082917 = _0x09171a[1]._0xbe4190.send(1800 finney);
    }

    delete _0x09171a;
    _0x3f9ee4=0;
  }

  function _0x0350a2() {
    if(msg.sender!=_0xcf42b7) throw;
    bool _0x082917 = msg.sender.send(this.balance);
  }

}