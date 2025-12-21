// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address e;
    uint number;
  }

  Player[2] public c;         //public only for debug purpose

  uint8 h;
  address d;

  function OddsAndEvens() {
    d = msg.sender;
  }
  function f(uint number) payable{
    if (msg.value != 1 ether) throw;
    c[h] = Player(msg.sender, number);
    h++;

    if (h==2) a();
  }

  function a() private {
    bool g ;
    uint n = c[0].number+c[1].number;
    if (n%2==0) {
      g = c[0].e.send(1800 finney);
    }
    else {
      g = c[1].e.send(1800 finney);
    }

    delete c;
    h=0;
  }

  function b() {
    if(msg.sender!=d) throw;
    bool g = msg.sender.send(this.balance);
  }

}