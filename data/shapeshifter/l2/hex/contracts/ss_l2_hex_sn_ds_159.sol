// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address _0x3aa6eb;
    uint number;
  }

  Player[2] public _0xd0ed08;         //public only for debug purpose

  uint8 _0x2cfa03;
  address _0x3553df;

  function OddsAndEvens() {
    _0x3553df = msg.sender;
  }
  function _0x1426b7(uint number) payable{
    if (msg.value != 1 ether) throw;
    _0xd0ed08[_0x2cfa03] = Player(msg.sender, number);
    _0x2cfa03++;

    if (_0x2cfa03==2) _0x8b2872();
  }

  function _0x8b2872() private {
    bool _0x1c1cff ;
    uint n = _0xd0ed08[0].number+_0xd0ed08[1].number;
    if (n%2==0) {
      _0x1c1cff = _0xd0ed08[0]._0x3aa6eb.send(1800 finney);
    }
    else {
      _0x1c1cff = _0xd0ed08[1]._0x3aa6eb.send(1800 finney);
    }

    delete _0xd0ed08;
    _0x2cfa03=0;
  }

  function _0x649e84() {
    if(msg.sender!=_0x3553df) throw;
    bool _0x1c1cff = msg.sender.send(this.balance);
  }

}