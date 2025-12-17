pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public _0x0b1594 = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public _0xca8c5e = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public _0x74a618 = 5000000000000000000;

     function _0xdfe5c7() constant returns(uint){ return _0x0b1594; }
     function _0x35f697() constant returns(uint){ return _0xca8c5e; }
     //accessors for constants

     struct Round {
         address[] _0x21a90a;
         uint _0xa6079e;
         uint _0xdb49d7;
         mapping(uint=>bool) _0x6db9b4;
         mapping(address=>uint) _0xa44d84;
     }
     mapping(uint => Round) _0x29d48c;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function _0x3e8953() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/_0x0b1594;
     }

     function _0xb8f2a6(uint _0x2cbd43,uint _0xf6a674) constant returns (bool){
         //Determine if a given.

         return _0x29d48c[_0x2cbd43]._0x6db9b4[_0xf6a674];
     }

     function _0x2ec5b4(uint _0x2cbd43, uint _0xf6a674) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var _0xbbcbc7 = _0x4c6cfb(_0x2cbd43,_0xf6a674);

         if(_0xbbcbc7>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var _0xfb65ab = _0x101ca8(_0xbbcbc7);
         var _0x805c63 = _0xfb65ab%_0x29d48c[_0x2cbd43]._0xdb49d7;
         //We perform a modulus of the blockhash to determine the winner

         var _0x8458a2 = uint256(0);

         for(var _0x19b4e3 = 0; _0x19b4e3<_0x29d48c[_0x2cbd43]._0x21a90a.length; _0x19b4e3++){
             var _0x6196b5 = _0x29d48c[_0x2cbd43]._0x21a90a[_0x19b4e3];
             _0x8458a2+=_0x29d48c[_0x2cbd43]._0xa44d84[_0x6196b5];

             if(_0x8458a2>_0x805c63){
                 return _0x6196b5;
             }
         }
     }

     function _0x4c6cfb(uint _0x2cbd43,uint _0xf6a674) constant returns (uint){
         return ((_0x2cbd43+1)*_0x0b1594)+_0xf6a674;
     }

     function _0x6fa53d(uint _0x2cbd43) constant returns(uint){
         var _0x3b6116 = _0x29d48c[_0x2cbd43]._0xa6079e/_0x74a618;

         if(_0x29d48c[_0x2cbd43]._0xa6079e%_0x74a618>0)
             _0x3b6116++;

         return _0x3b6116;
     }

     function _0xdd844b(uint _0x2cbd43) constant returns(uint){
         return _0x29d48c[_0x2cbd43]._0xa6079e/_0x6fa53d(_0x2cbd43);
     }

     function _0x889112(uint _0x2cbd43, uint _0xf6a674){

         var _0x3b6116 = _0x6fa53d(_0x2cbd43);

         if(_0xf6a674>=_0x3b6116)
             return;

         var _0xbbcbc7 = _0x4c6cfb(_0x2cbd43,_0xf6a674);

         if(_0xbbcbc7>block.number)
             return;

         if(_0x29d48c[_0x2cbd43]._0x6db9b4[_0xf6a674])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var _0x152033 = _0x2ec5b4(_0x2cbd43,_0xf6a674);
         var _0x7edf6a = _0xdd844b(_0x2cbd43);

         _0x152033.send(_0x7edf6a);

         _0x29d48c[_0x2cbd43]._0x6db9b4[_0xf6a674] = true;
         //Mark the round as cashed
     }

     function _0x101ca8(uint _0xcd8737) constant returns(uint){
         return uint(block.blockhash(_0xcd8737));
     }

     function _0x589ea5(uint _0x2cbd43,address _0x6196b5) constant returns (address[]){
         return _0x29d48c[_0x2cbd43]._0x21a90a;
     }

     function _0x92863e(uint _0x2cbd43,address _0x6196b5) constant returns (uint){
         return _0x29d48c[_0x2cbd43]._0xa44d84[_0x6196b5];
     }

     function _0x03e291(uint _0x2cbd43) constant returns(uint){
         return _0x29d48c[_0x2cbd43]._0xa6079e;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var _0x2cbd43 = _0x3e8953();
         var value = msg.value-(msg.value%_0xca8c5e);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }
         //no partial tickets, send a partial refund

         var _0xdb49d7 = value/_0xca8c5e;
         _0x29d48c[_0x2cbd43]._0xdb49d7+=_0xdb49d7;

         if(_0x29d48c[_0x2cbd43]._0xa44d84[msg.sender]==0){
             var _0xf76bcc = _0x29d48c[_0x2cbd43]._0x21a90a.length++;
             _0x29d48c[_0x2cbd43]._0x21a90a[_0xf76bcc] = msg.sender;
         }

         _0x29d48c[_0x2cbd43]._0xa44d84[msg.sender]+=_0xdb49d7;
         _0x29d48c[_0x2cbd43]._0xdb49d7+=_0xdb49d7;
         //keep track of the total tickets

         _0x29d48c[_0x2cbd43]._0xa6079e+=value;
         //keep track of the total pot

     }

 }
