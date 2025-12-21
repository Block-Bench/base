pragma solidity ^0.4.0;

contract Government {


     uint32 public _0xf7e0f4;
     uint public _0x7c0a4f;
     uint public _0xa54596;
     address[] public _0xf3955a;
     uint[] public _0x055858;
     address public _0x6720a9;
     mapping (address => uint) _0xf23b3b;
     uint constant TWELVE_HOURS = 43200;
     uint8 public _0xedab0a;

     function Government() {


         if (block.timestamp > 0) { _0xa54596 = msg.value; }
         _0x6720a9 = msg.sender;
         _0x7c0a4f = block.timestamp;
     }

     function _0x70c3dd(address _0x07ae02) returns (bool) {
         uint _0xf0abc6 = msg.value;


         if (_0x7c0a4f + TWELVE_HOURS < block.timestamp) {

             msg.sender.send(_0xf0abc6);

             _0xf3955a[_0xf3955a.length - 1].send(_0xa54596);
             _0x6720a9.send(this.balance);

             _0xf7e0f4 = 0;
             _0x7c0a4f = block.timestamp;
             _0xa54596 = 0;
             _0xf3955a = new address[](0);
             _0x055858 = new uint[](0);
             _0xedab0a += 1;
             return false;
         }
         else {

             if (_0xf0abc6 >= 10 ** 18) {

                 _0x7c0a4f = block.timestamp;

                 _0xf3955a.push(msg.sender);
                 _0x055858.push(_0xf0abc6 * 110 / 100);


                 _0x6720a9.send(_0xf0abc6 * 5/100);

                 if (_0xa54596 < 10000 * 10**18) {
                     _0xa54596 += _0xf0abc6 * 5/100;
                 }


                 if(_0xf23b3b[_0x07ae02] >= _0xf0abc6) {
                     _0x07ae02.send(_0xf0abc6 * 5/100);
                 }
                 _0xf23b3b[msg.sender] += _0xf0abc6 * 110 / 100;

                 if (_0x055858[_0xf7e0f4] <= address(this).balance - _0xa54596) {
                     _0xf3955a[_0xf7e0f4].send(_0x055858[_0xf7e0f4]);
                     _0xf23b3b[_0xf3955a[_0xf7e0f4]] -= _0x055858[_0xf7e0f4];
                     _0xf7e0f4 += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(_0xf0abc6);
                 return false;
             }
         }
     }


     function() {
         _0x70c3dd(0);
     }

     function _0x094fb2() returns (uint _0xbd9196) {
         for(uint i=_0xf7e0f4; i<_0x055858.length; i++){
             _0xbd9196 += _0x055858[i];
         }
     }

     function _0x1fb0f2() returns (uint _0x5c4cae) {
         for(uint i=0; i<_0xf7e0f4; i++){
             _0x5c4cae += _0x055858[i];
         }
     }


     function _0xbd75ff() {
         _0xa54596 += msg.value;
     }


     function _0xfc7efc(address _0x61494d) {
         if (msg.sender == _0x6720a9) {
             if (block.timestamp > 0) { _0x6720a9 = _0x61494d; }
         }
     }

     function _0xdada20() returns (address[]) {
         return _0xf3955a;
     }

     function _0x5ec19c() returns (uint[]) {
         return _0x055858;
     }
 }