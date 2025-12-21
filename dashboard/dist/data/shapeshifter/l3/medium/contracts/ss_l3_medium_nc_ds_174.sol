pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public _0x2c0912 = 6800;


     uint constant public _0x35e0fc = 100000000000000000;


     uint constant public _0xe980df = 5000000000000000000;

     function _0x9c8752() constant returns(uint){ return _0x2c0912; }
     function _0x4eb77d() constant returns(uint){ return _0x35e0fc; }


     struct Round {
         address[] _0x340b54;
         uint _0x49d408;
         uint _0x87d8d7;
         mapping(uint=>bool) _0xd7425d;
         mapping(address=>uint) _0x45c53f;
     }
     mapping(uint => Round) _0x621e52;


     function _0xf1c95b() constant returns (uint){


         return block.number/_0x2c0912;
     }

     function _0x0acb32(uint _0x748eff,uint _0xa79ac9) constant returns (bool){


         return _0x621e52[_0x748eff]._0xd7425d[_0xa79ac9];
     }

     function _0x661c00(uint _0x748eff, uint _0xa79ac9) constant returns(address){


         var _0x258cef = _0x8b1bda(_0x748eff,_0xa79ac9);

         if(_0x258cef>block.number)
             return;


         var _0x55f29b = _0xaa2aef(_0x258cef);
         var _0xb3bfa5 = _0x55f29b%_0x621e52[_0x748eff]._0x87d8d7;


         var _0x0bbc5a = uint256(0);

         for(var _0x263771 = 0; _0x263771<_0x621e52[_0x748eff]._0x340b54.length; _0x263771++){
             var _0x3f565c = _0x621e52[_0x748eff]._0x340b54[_0x263771];
             _0x0bbc5a+=_0x621e52[_0x748eff]._0x45c53f[_0x3f565c];

             if(_0x0bbc5a>_0xb3bfa5){
                 return _0x3f565c;
             }
         }
     }

     function _0x8b1bda(uint _0x748eff,uint _0xa79ac9) constant returns (uint){
         return ((_0x748eff+1)*_0x2c0912)+_0xa79ac9;
     }

     function _0x141641(uint _0x748eff) constant returns(uint){
         var _0xb9410a = _0x621e52[_0x748eff]._0x49d408/_0xe980df;

         if(_0x621e52[_0x748eff]._0x49d408%_0xe980df>0)
             _0xb9410a++;

         return _0xb9410a;
     }

     function _0x77e991(uint _0x748eff) constant returns(uint){
         return _0x621e52[_0x748eff]._0x49d408/_0x141641(_0x748eff);
     }

     function _0x533cb4(uint _0x748eff, uint _0xa79ac9){

         var _0xb9410a = _0x141641(_0x748eff);

         if(_0xa79ac9>=_0xb9410a)
             return;

         var _0x258cef = _0x8b1bda(_0x748eff,_0xa79ac9);

         if(_0x258cef>block.number)
             return;

         if(_0x621e52[_0x748eff]._0xd7425d[_0xa79ac9])
             return;


         var _0x4073de = _0x661c00(_0x748eff,_0xa79ac9);
         var _0xf178eb = _0x77e991(_0x748eff);

         _0x4073de.send(_0xf178eb);

         _0x621e52[_0x748eff]._0xd7425d[_0xa79ac9] = true;

     }

     function _0xaa2aef(uint _0x7ae7a0) constant returns(uint){
         return uint(block.blockhash(_0x7ae7a0));
     }

     function _0x6944be(uint _0x748eff,address _0x3f565c) constant returns (address[]){
         return _0x621e52[_0x748eff]._0x340b54;
     }

     function _0xceb280(uint _0x748eff,address _0x3f565c) constant returns (uint){
         return _0x621e52[_0x748eff]._0x45c53f[_0x3f565c];
     }

     function _0xbf57f0(uint _0x748eff) constant returns(uint){
         return _0x621e52[_0x748eff]._0x49d408;
     }

     function() {


         var _0x748eff = _0xf1c95b();
         var value = msg.value-(msg.value%_0x35e0fc);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }


         var _0x87d8d7 = value/_0x35e0fc;
         _0x621e52[_0x748eff]._0x87d8d7+=_0x87d8d7;

         if(_0x621e52[_0x748eff]._0x45c53f[msg.sender]==0){
             var _0x797f56 = _0x621e52[_0x748eff]._0x340b54.length++;
             _0x621e52[_0x748eff]._0x340b54[_0x797f56] = msg.sender;
         }

         _0x621e52[_0x748eff]._0x45c53f[msg.sender]+=_0x87d8d7;
         _0x621e52[_0x748eff]._0x87d8d7+=_0x87d8d7;


         _0x621e52[_0x748eff]._0x49d408+=value;


     }

 }