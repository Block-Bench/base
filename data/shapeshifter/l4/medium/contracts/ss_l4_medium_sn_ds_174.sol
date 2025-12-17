pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public _0x9d5742 = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public _0xa71849 = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public _0x981b45 = 5000000000000000000;

     function _0xc8783a() constant returns(uint){ return _0x9d5742; }
     function _0xe9e1c4() constant returns(uint){ return _0xa71849; }
     //accessors for constants

     struct Round {
         address[] _0x347026;
         uint _0x94bd30;
         uint _0x830149;
         mapping(uint=>bool) _0x3e8f30;
         mapping(address=>uint) _0xabc284;
     }
     mapping(uint => Round) _0xab3ef8;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function _0x1ecd91() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/_0x9d5742;
     }

     function _0xc15a91(uint _0x131043,uint _0x32892d) constant returns (bool){
         //Determine if a given.

         return _0xab3ef8[_0x131043]._0x3e8f30[_0x32892d];
     }

     function _0xf644e2(uint _0x131043, uint _0x32892d) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var _0x0d6a6c = _0x2411ad(_0x131043,_0x32892d);

         if(_0x0d6a6c>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var _0xd9a5e8 = _0x0722ed(_0x0d6a6c);
         var _0x153ad0 = _0xd9a5e8%_0xab3ef8[_0x131043]._0x830149;
         //We perform a modulus of the blockhash to determine the winner

         var _0x9aa8ff = uint256(0);

         for(var _0xd9d601 = 0; _0xd9d601<_0xab3ef8[_0x131043]._0x347026.length; _0xd9d601++){
             var _0xb6ac12 = _0xab3ef8[_0x131043]._0x347026[_0xd9d601];
             _0x9aa8ff+=_0xab3ef8[_0x131043]._0xabc284[_0xb6ac12];

             if(_0x9aa8ff>_0x153ad0){
                 return _0xb6ac12;
             }
         }
     }

     function _0x2411ad(uint _0x131043,uint _0x32892d) constant returns (uint){
         return ((_0x131043+1)*_0x9d5742)+_0x32892d;
     }

     function _0xd62651(uint _0x131043) constant returns(uint){
         var _0xc3e20b = _0xab3ef8[_0x131043]._0x94bd30/_0x981b45;

         if(_0xab3ef8[_0x131043]._0x94bd30%_0x981b45>0)
             _0xc3e20b++;

         return _0xc3e20b;
     }

     function _0x2f7bfe(uint _0x131043) constant returns(uint){
         return _0xab3ef8[_0x131043]._0x94bd30/_0xd62651(_0x131043);
     }

     function _0xbfd92d(uint _0x131043, uint _0x32892d){

         var _0xc3e20b = _0xd62651(_0x131043);

         if(_0x32892d>=_0xc3e20b)
             return;

         var _0x0d6a6c = _0x2411ad(_0x131043,_0x32892d);

         if(_0x0d6a6c>block.number)
             return;

         if(_0xab3ef8[_0x131043]._0x3e8f30[_0x32892d])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var _0x6acefa = _0xf644e2(_0x131043,_0x32892d);
         var _0x49bdfb = _0x2f7bfe(_0x131043);

         _0x6acefa.send(_0x49bdfb);

         _0xab3ef8[_0x131043]._0x3e8f30[_0x32892d] = true;
         //Mark the round as cashed
     }

     function _0x0722ed(uint _0x71230a) constant returns(uint){
         return uint(block.blockhash(_0x71230a));
     }

     function _0x558498(uint _0x131043,address _0xb6ac12) constant returns (address[]){
         return _0xab3ef8[_0x131043]._0x347026;
     }

     function _0xb1c707(uint _0x131043,address _0xb6ac12) constant returns (uint){
         return _0xab3ef8[_0x131043]._0xabc284[_0xb6ac12];
     }

     function _0x8414eb(uint _0x131043) constant returns(uint){
         return _0xab3ef8[_0x131043]._0x94bd30;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var _0x131043 = _0x1ecd91();
         var value = msg.value-(msg.value%_0xa71849);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }
         //no partial tickets, send a partial refund

         var _0x830149 = value/_0xa71849;
         _0xab3ef8[_0x131043]._0x830149+=_0x830149;

         if(_0xab3ef8[_0x131043]._0xabc284[msg.sender]==0){
             var _0xaa71d5 = _0xab3ef8[_0x131043]._0x347026.length++;
             _0xab3ef8[_0x131043]._0x347026[_0xaa71d5] = msg.sender;
         }

         _0xab3ef8[_0x131043]._0xabc284[msg.sender]+=_0x830149;
         _0xab3ef8[_0x131043]._0x830149+=_0x830149;
         //keep track of the total tickets

         _0xab3ef8[_0x131043]._0x94bd30+=value;
         //keep track of the total pot

     }

 }
