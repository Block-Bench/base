pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public _0x543165 = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public _0x322207 = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public _0x002d65 = 5000000000000000000;

     function _0x9f1aa6() constant returns(uint){ return _0x543165; }
     function _0xee36ad() constant returns(uint){ return _0x322207; }
     //accessors for constants

     struct Round {
         address[] _0x6fd0fe;
         uint _0x99e6c1;
         uint _0x41b138;
         mapping(uint=>bool) _0x34aaff;
         mapping(address=>uint) _0x7db806;
     }
     mapping(uint => Round) _0xd8c5a6;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function _0x32d1cd() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/_0x543165;
     }

     function _0xed4b95(uint _0x508dbf,uint _0x68af9a) constant returns (bool){
         //Determine if a given.

         return _0xd8c5a6[_0x508dbf]._0x34aaff[_0x68af9a];
     }

     function _0x3ba9e3(uint _0x508dbf, uint _0x68af9a) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var _0x4bc258 = _0x909922(_0x508dbf,_0x68af9a);

         if(_0x4bc258>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var _0xece011 = _0xe9a326(_0x4bc258);
         var _0xa011dc = _0xece011%_0xd8c5a6[_0x508dbf]._0x41b138;
         //We perform a modulus of the blockhash to determine the winner

         var _0x38ac49 = uint256(0);

         for(var _0x668e49 = 0; _0x668e49<_0xd8c5a6[_0x508dbf]._0x6fd0fe.length; _0x668e49++){
             var _0x617896 = _0xd8c5a6[_0x508dbf]._0x6fd0fe[_0x668e49];
             _0x38ac49+=_0xd8c5a6[_0x508dbf]._0x7db806[_0x617896];

             if(_0x38ac49>_0xa011dc){
                 return _0x617896;
             }
         }
     }

     function _0x909922(uint _0x508dbf,uint _0x68af9a) constant returns (uint){
         return ((_0x508dbf+1)*_0x543165)+_0x68af9a;
     }

     function _0x2cb1cd(uint _0x508dbf) constant returns(uint){
         var _0xbe7101 = _0xd8c5a6[_0x508dbf]._0x99e6c1/_0x002d65;

         if(_0xd8c5a6[_0x508dbf]._0x99e6c1%_0x002d65>0)
             _0xbe7101++;

         return _0xbe7101;
     }

     function _0xa14f29(uint _0x508dbf) constant returns(uint){
         return _0xd8c5a6[_0x508dbf]._0x99e6c1/_0x2cb1cd(_0x508dbf);
     }

     function _0xf1a6c4(uint _0x508dbf, uint _0x68af9a){

         var _0xbe7101 = _0x2cb1cd(_0x508dbf);

         if(_0x68af9a>=_0xbe7101)
             return;

         var _0x4bc258 = _0x909922(_0x508dbf,_0x68af9a);

         if(_0x4bc258>block.number)
             return;

         if(_0xd8c5a6[_0x508dbf]._0x34aaff[_0x68af9a])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var _0xffef41 = _0x3ba9e3(_0x508dbf,_0x68af9a);
         var _0x706260 = _0xa14f29(_0x508dbf);

         _0xffef41.send(_0x706260);

         _0xd8c5a6[_0x508dbf]._0x34aaff[_0x68af9a] = true;
         //Mark the round as cashed
     }

     function _0xe9a326(uint _0x94bbb9) constant returns(uint){
         return uint(block.blockhash(_0x94bbb9));
     }

     function _0xeec2a4(uint _0x508dbf,address _0x617896) constant returns (address[]){
         return _0xd8c5a6[_0x508dbf]._0x6fd0fe;
     }

     function _0x0f6e19(uint _0x508dbf,address _0x617896) constant returns (uint){
         return _0xd8c5a6[_0x508dbf]._0x7db806[_0x617896];
     }

     function _0x6ce92e(uint _0x508dbf) constant returns(uint){
         return _0xd8c5a6[_0x508dbf]._0x99e6c1;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var _0x508dbf = _0x32d1cd();
         var value = msg.value-(msg.value%_0x322207);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }
         //no partial tickets, send a partial refund

         var _0x41b138 = value/_0x322207;
         _0xd8c5a6[_0x508dbf]._0x41b138+=_0x41b138;

         if(_0xd8c5a6[_0x508dbf]._0x7db806[msg.sender]==0){
             var _0x6d6838 = _0xd8c5a6[_0x508dbf]._0x6fd0fe.length++;
             _0xd8c5a6[_0x508dbf]._0x6fd0fe[_0x6d6838] = msg.sender;
         }

         _0xd8c5a6[_0x508dbf]._0x7db806[msg.sender]+=_0x41b138;
         _0xd8c5a6[_0x508dbf]._0x41b138+=_0x41b138;
         //keep track of the total tickets

         _0xd8c5a6[_0x508dbf]._0x99e6c1+=value;
         //keep track of the total pot

     }

 }
