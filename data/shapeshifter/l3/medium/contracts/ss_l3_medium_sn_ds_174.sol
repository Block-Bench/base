pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public _0x28eaf3 = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public _0xc3d947 = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public _0xd2f3c3 = 5000000000000000000;

     function _0x2d80ea() constant returns(uint){ return _0x28eaf3; }
     function _0x43c65a() constant returns(uint){ return _0xc3d947; }
     //accessors for constants

     struct Round {
         address[] _0x5bd240;
         uint _0x561fa2;
         uint _0xed03a6;
         mapping(uint=>bool) _0xa2b100;
         mapping(address=>uint) _0xdcf729;
     }
     mapping(uint => Round) _0x5aa3cf;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function _0x8aaccd() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/_0x28eaf3;
     }

     function _0xac2b50(uint _0xe572dd,uint _0xdef691) constant returns (bool){
         //Determine if a given.

         return _0x5aa3cf[_0xe572dd]._0xa2b100[_0xdef691];
     }

     function _0x44abc3(uint _0xe572dd, uint _0xdef691) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var _0x233036 = _0x6b56bd(_0xe572dd,_0xdef691);

         if(_0x233036>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var _0x9d0243 = _0x3ca479(_0x233036);
         var _0x1a9664 = _0x9d0243%_0x5aa3cf[_0xe572dd]._0xed03a6;
         //We perform a modulus of the blockhash to determine the winner

         var _0x6044b2 = uint256(0);

         for(var _0x8290a8 = 0; _0x8290a8<_0x5aa3cf[_0xe572dd]._0x5bd240.length; _0x8290a8++){
             var _0x16c3be = _0x5aa3cf[_0xe572dd]._0x5bd240[_0x8290a8];
             _0x6044b2+=_0x5aa3cf[_0xe572dd]._0xdcf729[_0x16c3be];

             if(_0x6044b2>_0x1a9664){
                 return _0x16c3be;
             }
         }
     }

     function _0x6b56bd(uint _0xe572dd,uint _0xdef691) constant returns (uint){
         return ((_0xe572dd+1)*_0x28eaf3)+_0xdef691;
     }

     function _0x4b2e71(uint _0xe572dd) constant returns(uint){
         var _0xd34734 = _0x5aa3cf[_0xe572dd]._0x561fa2/_0xd2f3c3;

         if(_0x5aa3cf[_0xe572dd]._0x561fa2%_0xd2f3c3>0)
             _0xd34734++;

         return _0xd34734;
     }

     function _0xa9e108(uint _0xe572dd) constant returns(uint){
         return _0x5aa3cf[_0xe572dd]._0x561fa2/_0x4b2e71(_0xe572dd);
     }

     function _0x271b1a(uint _0xe572dd, uint _0xdef691){

         var _0xd34734 = _0x4b2e71(_0xe572dd);

         if(_0xdef691>=_0xd34734)
             return;

         var _0x233036 = _0x6b56bd(_0xe572dd,_0xdef691);

         if(_0x233036>block.number)
             return;

         if(_0x5aa3cf[_0xe572dd]._0xa2b100[_0xdef691])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var _0x28ab1f = _0x44abc3(_0xe572dd,_0xdef691);
         var _0x6d089b = _0xa9e108(_0xe572dd);

         _0x28ab1f.send(_0x6d089b);

         _0x5aa3cf[_0xe572dd]._0xa2b100[_0xdef691] = true;
         //Mark the round as cashed
     }

     function _0x3ca479(uint _0x546988) constant returns(uint){
         return uint(block.blockhash(_0x546988));
     }

     function _0x146128(uint _0xe572dd,address _0x16c3be) constant returns (address[]){
         return _0x5aa3cf[_0xe572dd]._0x5bd240;
     }

     function _0xe0f23c(uint _0xe572dd,address _0x16c3be) constant returns (uint){
         return _0x5aa3cf[_0xe572dd]._0xdcf729[_0x16c3be];
     }

     function _0x214dd7(uint _0xe572dd) constant returns(uint){
         return _0x5aa3cf[_0xe572dd]._0x561fa2;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var _0xe572dd = _0x8aaccd();
         var value = msg.value-(msg.value%_0xc3d947);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }
         //no partial tickets, send a partial refund

         var _0xed03a6 = value/_0xc3d947;
         _0x5aa3cf[_0xe572dd]._0xed03a6+=_0xed03a6;

         if(_0x5aa3cf[_0xe572dd]._0xdcf729[msg.sender]==0){
             var _0x8be00b = _0x5aa3cf[_0xe572dd]._0x5bd240.length++;
             _0x5aa3cf[_0xe572dd]._0x5bd240[_0x8be00b] = msg.sender;
         }

         _0x5aa3cf[_0xe572dd]._0xdcf729[msg.sender]+=_0xed03a6;
         _0x5aa3cf[_0xe572dd]._0xed03a6+=_0xed03a6;
         //keep track of the total tickets

         _0x5aa3cf[_0xe572dd]._0x561fa2+=value;
         //keep track of the total pot

     }

 }
