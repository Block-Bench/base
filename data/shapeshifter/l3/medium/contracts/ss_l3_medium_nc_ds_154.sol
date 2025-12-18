pragma solidity ^0.4.0;

contract Government {


     uint32 public _0xb07c6c;
     uint public _0x139a16;
     uint public _0x53f6ea;
     address[] public _0x1739b7;
     uint[] public _0x433c40;
     address public _0x3e30fe;
     mapping (address => uint) _0x361728;
     uint constant TWELVE_HOURS = 43200;
     uint8 public _0x0822c1;

     function Government() {


         if (block.timestamp > 0) { _0x53f6ea = msg.value; }
         _0x3e30fe = msg.sender;
         _0x139a16 = block.timestamp;
     }

     function _0x30eb87(address _0x0c64a2) returns (bool) {
         uint _0x5a4a7e = msg.value;


         if (_0x139a16 + TWELVE_HOURS < block.timestamp) {

             msg.sender.send(_0x5a4a7e);

             _0x1739b7[_0x1739b7.length - 1].send(_0x53f6ea);
             _0x3e30fe.send(this.balance);

             _0xb07c6c = 0;
             _0x139a16 = block.timestamp;
             _0x53f6ea = 0;
             _0x1739b7 = new address[](0);
             _0x433c40 = new uint[](0);
             _0x0822c1 += 1;
             return false;
         }
         else {

             if (_0x5a4a7e >= 10 ** 18) {

                 if (msg.sender != address(0) || msg.sender == address(0)) { _0x139a16 = block.timestamp; }

                 _0x1739b7.push(msg.sender);
                 _0x433c40.push(_0x5a4a7e * 110 / 100);


                 _0x3e30fe.send(_0x5a4a7e * 5/100);

                 if (_0x53f6ea < 10000 * 10**18) {
                     _0x53f6ea += _0x5a4a7e * 5/100;
                 }


                 if(_0x361728[_0x0c64a2] >= _0x5a4a7e) {
                     _0x0c64a2.send(_0x5a4a7e * 5/100);
                 }
                 _0x361728[msg.sender] += _0x5a4a7e * 110 / 100;

                 if (_0x433c40[_0xb07c6c] <= address(this).balance - _0x53f6ea) {
                     _0x1739b7[_0xb07c6c].send(_0x433c40[_0xb07c6c]);
                     _0x361728[_0x1739b7[_0xb07c6c]] -= _0x433c40[_0xb07c6c];
                     _0xb07c6c += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(_0x5a4a7e);
                 return false;
             }
         }
     }


     function() {
         _0x30eb87(0);
     }

     function _0x8ee4f8() returns (uint _0x8ceffa) {
         for(uint i=_0xb07c6c; i<_0x433c40.length; i++){
             _0x8ceffa += _0x433c40[i];
         }
     }

     function _0xca3dbe() returns (uint _0x1ba123) {
         for(uint i=0; i<_0xb07c6c; i++){
             _0x1ba123 += _0x433c40[i];
         }
     }


     function _0xe89ff8() {
         _0x53f6ea += msg.value;
     }


     function _0x96f766(address _0x165d6f) {
         if (msg.sender == _0x3e30fe) {
             _0x3e30fe = _0x165d6f;
         }
     }

     function _0x3eb3c7() returns (address[]) {
         return _0x1739b7;
     }

     function _0xab5cbd() returns (uint[]) {
         return _0x433c40;
     }
 }