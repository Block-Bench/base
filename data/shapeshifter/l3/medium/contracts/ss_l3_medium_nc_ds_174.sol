pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public _0x5d3210 = 6800;


     uint constant public _0x3dde52 = 100000000000000000;


     uint constant public _0x722588 = 5000000000000000000;

     function _0xa93c77() constant returns(uint){ return _0x5d3210; }
     function _0xa6f2af() constant returns(uint){ return _0x3dde52; }


     struct Round {
         address[] _0x8f861b;
         uint _0x61bf3c;
         uint _0x39f628;
         mapping(uint=>bool) _0x437795;
         mapping(address=>uint) _0x98d8f5;
     }
     mapping(uint => Round) _0xe3c549;


     function _0x6a7f94() constant returns (uint){


         return block.number/_0x5d3210;
     }

     function _0x407ea4(uint _0x997d57,uint _0x477d5d) constant returns (bool){


         return _0xe3c549[_0x997d57]._0x437795[_0x477d5d];
     }

     function _0x950bd2(uint _0x997d57, uint _0x477d5d) constant returns(address){


         var _0x16deb8 = _0x367e8f(_0x997d57,_0x477d5d);

         if(_0x16deb8>block.number)
             return;


         var _0xf4a4d9 = _0x4c82ae(_0x16deb8);
         var _0x51d426 = _0xf4a4d9%_0xe3c549[_0x997d57]._0x39f628;


         var _0x816ad6 = uint256(0);

         for(var _0xc82f46 = 0; _0xc82f46<_0xe3c549[_0x997d57]._0x8f861b.length; _0xc82f46++){
             var _0x6115df = _0xe3c549[_0x997d57]._0x8f861b[_0xc82f46];
             _0x816ad6+=_0xe3c549[_0x997d57]._0x98d8f5[_0x6115df];

             if(_0x816ad6>_0x51d426){
                 return _0x6115df;
             }
         }
     }

     function _0x367e8f(uint _0x997d57,uint _0x477d5d) constant returns (uint){
         return ((_0x997d57+1)*_0x5d3210)+_0x477d5d;
     }

     function _0x44e488(uint _0x997d57) constant returns(uint){
         var _0xd7f964 = _0xe3c549[_0x997d57]._0x61bf3c/_0x722588;

         if(_0xe3c549[_0x997d57]._0x61bf3c%_0x722588>0)
             _0xd7f964++;

         return _0xd7f964;
     }

     function _0xdf9ebc(uint _0x997d57) constant returns(uint){
         return _0xe3c549[_0x997d57]._0x61bf3c/_0x44e488(_0x997d57);
     }

     function _0x259f3f(uint _0x997d57, uint _0x477d5d){

         var _0xd7f964 = _0x44e488(_0x997d57);

         if(_0x477d5d>=_0xd7f964)
             return;

         var _0x16deb8 = _0x367e8f(_0x997d57,_0x477d5d);

         if(_0x16deb8>block.number)
             return;

         if(_0xe3c549[_0x997d57]._0x437795[_0x477d5d])
             return;


         var _0x0b577d = _0x950bd2(_0x997d57,_0x477d5d);
         var _0x162e92 = _0xdf9ebc(_0x997d57);

         _0x0b577d.send(_0x162e92);

         _0xe3c549[_0x997d57]._0x437795[_0x477d5d] = true;

     }

     function _0x4c82ae(uint _0x44ac40) constant returns(uint){
         return uint(block.blockhash(_0x44ac40));
     }

     function _0x362d41(uint _0x997d57,address _0x6115df) constant returns (address[]){
         return _0xe3c549[_0x997d57]._0x8f861b;
     }

     function _0x71e6d8(uint _0x997d57,address _0x6115df) constant returns (uint){
         return _0xe3c549[_0x997d57]._0x98d8f5[_0x6115df];
     }

     function _0x7ba8ac(uint _0x997d57) constant returns(uint){
         return _0xe3c549[_0x997d57]._0x61bf3c;
     }

     function() {


         var _0x997d57 = _0x6a7f94();
         var value = msg.value-(msg.value%_0x3dde52);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }


         var _0x39f628 = value/_0x3dde52;
         _0xe3c549[_0x997d57]._0x39f628+=_0x39f628;

         if(_0xe3c549[_0x997d57]._0x98d8f5[msg.sender]==0){
             var _0x9c2928 = _0xe3c549[_0x997d57]._0x8f861b.length++;
             _0xe3c549[_0x997d57]._0x8f861b[_0x9c2928] = msg.sender;
         }

         _0xe3c549[_0x997d57]._0x98d8f5[msg.sender]+=_0x39f628;
         _0xe3c549[_0x997d57]._0x39f628+=_0x39f628;


         _0xe3c549[_0x997d57]._0x61bf3c+=value;


     }

 }