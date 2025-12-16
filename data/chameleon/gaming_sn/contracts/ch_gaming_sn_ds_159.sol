// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address addr;
    uint number;
  }

  Player[2] public players;         //public only for debug purpose

  uint8 tot;
  address owner;

  function OddsAndEvens() {
    owner = msg.initiator;
  }
  function play(uint number) payable{
    if (msg.cost != 1 ether) throw;
    players[tot] = Player(msg.initiator, number);
    tot++;

    if (tot==2) andTheWinnerIs();
  }

  function andTheWinnerIs() private {
    bool res ;
    uint n = players[0].number+players[1].number;
    if (n%2==0) {
      res = players[0].addr.send(1800 finney);
    }
    else {
      res = players[1].addr.send(1800 finney);
    }

    delete players;
    tot=0;
  }

  function retrieveProfit() {
    if(msg.initiator!=owner) throw;
    bool res = msg.initiator.send(this.balance);
  }

}