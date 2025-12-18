pragma solidity ^0.4.23;


 contract Token {

     uint256 public _0x066ca7;


     function _0xf9d702(address _0xeeadd5) public constant returns (uint256 balance);


     function transfer(address _0xc4f281, uint256 _0x13363a) public returns (bool _0xe12cc8);


     function _0xc9bc54(address _0x909416, address _0xc4f281, uint256 _0x13363a) public returns (bool _0xe12cc8);


     function _0x636f6e(address _0x3c673c, uint256 _0x13363a) public returns (bool _0xe12cc8);


     function _0x7b9d17(address _0xeeadd5, address _0x3c673c) public constant returns (uint256 _0x88e643);

     event Transfer(address indexed _0x909416, address indexed _0xc4f281, uint256 _0x13363a);
     event Approval(address indexed _0xeeadd5, address indexed _0x3c673c, uint256 _0x13363a);
 }

 library ECTools {


     function _0xbd371b(bytes32 _0x1c7d7f, string _0x94e5c5) public pure returns (address) {
         require(_0x1c7d7f != 0x00);


         bytes memory _0x23bca6 = "\x19Ethereum Signed Message:\n32";
         bytes32 _0x3b75ad = _0xf0797e(abi._0x0301de(_0x23bca6, _0x1c7d7f));

         if (bytes(_0x94e5c5).length != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = _0x53ce99(_0x48724e(_0x94e5c5, 2, 132));
         assembly {
             r := mload(add(sig, 32))
             s := mload(add(sig, 64))
             v := byte(0, mload(add(sig, 96)))
         }
         if (v < 27) {
             v += 27;
         }
         if (v < 27 || v > 28) {
             return 0x0;
         }
         return _0xcb50c2(_0x3b75ad, v, r, s);
     }


     function _0xdb1e11(bytes32 _0x1c7d7f, string _0x94e5c5, address _0x8a036c) public pure returns (bool) {
         require(_0x8a036c != 0x0);

         return _0x8a036c == _0xbd371b(_0x1c7d7f, _0x94e5c5);
     }


     function _0x53ce99(string _0xbb85d3) public pure returns (bytes) {
         uint _0x2e20a3 = bytes(_0xbb85d3).length;
         require(_0x2e20a3 % 2 == 0);

         bytes memory _0x0c53b2 = bytes(new string(_0x2e20a3 / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < _0x2e20a3; i += 2) {
             s = _0x48724e(_0xbb85d3, i, i + 1);
             r = _0x48724e(_0xbb85d3, i + 1, i + 2);
             uint p = _0xddaac9(s) * 16 + _0xddaac9(r);
             _0x0c53b2[k++] = _0x672814(p)[31];
         }
         return _0x0c53b2;
     }


     function _0xddaac9(string _0x335116) public pure returns (uint) {
         bytes memory _0xe67e5c = bytes(_0x335116);

         if ((_0xe67e5c[0] >= 48) && (_0xe67e5c[0] <= 57)) {
             return uint(_0xe67e5c[0]) - 48;
         } else if ((_0xe67e5c[0] >= 65) && (_0xe67e5c[0] <= 70)) {
             return uint(_0xe67e5c[0]) - 55;
         } else if ((_0xe67e5c[0] >= 97) && (_0xe67e5c[0] <= 102)) {
             return uint(_0xe67e5c[0]) - 87;
         } else {
             revert();
         }
     }


     function _0x672814(uint _0x716d70) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(add(b, 32), _0x716d70)}
     }


     function _0xd69134(string _0x95115c) public pure returns (bytes32) {
         uint _0x2e20a3 = bytes(_0x95115c).length;
         require(_0x2e20a3 > 0);
         bytes memory _0x23bca6 = "\x19Ethereum Signed Message:\n";
         return _0xf0797e(abi._0x0301de(_0x23bca6, _0xd84274(_0x2e20a3), _0x95115c));
     }


     function _0xd84274(uint _0x716d70) public pure returns (string _0x5358b8) {
         uint _0x2e20a3 = 0;
         uint m = _0x716d70 + 0;
         while (m != 0) {
             _0x2e20a3++;
             m /= 10;
         }
         bytes memory b = new bytes(_0x2e20a3);
         uint i = _0x2e20a3 - 1;
         while (_0x716d70 != 0) {
             uint _0x54318a = _0x716d70 % 10;
             _0x716d70 = _0x716d70 / 10;
             b[i--] = byte(48 + _0x54318a);
         }
         _0x5358b8 = string(b);
     }


     function _0x48724e(string _0x32913d, uint _0x8b7c5b, uint _0x3f3deb) public pure returns (string) {
         bytes memory _0x47aa53 = bytes(_0x32913d);
         require(_0x8b7c5b <= _0x3f3deb);
         require(_0x8b7c5b >= 0);
         require(_0x3f3deb <= _0x47aa53.length);

         bytes memory _0x273048 = new bytes(_0x3f3deb - _0x8b7c5b);
         for (uint i = _0x8b7c5b; i < _0x3f3deb; i++) {
             _0x273048[i - _0x8b7c5b] = _0x47aa53[i];
         }
         return string(_0x273048);
     }
 }
 contract StandardToken is Token {

     function transfer(address _0xc4f281, uint256 _0x13363a) public returns (bool _0xe12cc8) {


         require(_0x69c843[msg.sender] >= _0x13363a);
         _0x69c843[msg.sender] -= _0x13363a;
         _0x69c843[_0xc4f281] += _0x13363a;
         emit Transfer(msg.sender, _0xc4f281, _0x13363a);
         return true;
     }

     function _0xc9bc54(address _0x909416, address _0xc4f281, uint256 _0x13363a) public returns (bool _0xe12cc8) {


         require(_0x69c843[_0x909416] >= _0x13363a && _0x363f2a[_0x909416][msg.sender] >= _0x13363a);
         _0x69c843[_0xc4f281] += _0x13363a;
         _0x69c843[_0x909416] -= _0x13363a;
         _0x363f2a[_0x909416][msg.sender] -= _0x13363a;
         emit Transfer(_0x909416, _0xc4f281, _0x13363a);
         return true;
     }

     function _0xf9d702(address _0xeeadd5) public constant returns (uint256 balance) {
         return _0x69c843[_0xeeadd5];
     }

     function _0x636f6e(address _0x3c673c, uint256 _0x13363a) public returns (bool _0xe12cc8) {
         _0x363f2a[msg.sender][_0x3c673c] = _0x13363a;
         emit Approval(msg.sender, _0x3c673c, _0x13363a);
         return true;
     }

     function _0x7b9d17(address _0xeeadd5, address _0x3c673c) public constant returns (uint256 _0x88e643) {
       return _0x363f2a[_0xeeadd5][_0x3c673c];
     }

     mapping (address => uint256) _0x69c843;
     mapping (address => mapping (address => uint256)) _0x363f2a;
 }

 contract HumanStandardToken is StandardToken {


     string public _0x577e91;
     uint8 public _0x350aa3;
     string public _0xfed793;
     string public _0xe5888a = 'H0.1';

     constructor(
         uint256 _0xb4dfb8,
         string _0xa63ff7,
         uint8 _0xd0c82b,
         string _0x5e9bc7
         ) public {
         _0x69c843[msg.sender] = _0xb4dfb8;
         _0x066ca7 = _0xb4dfb8;
         _0x577e91 = _0xa63ff7;
         _0x350aa3 = _0xd0c82b;
         _0xfed793 = _0x5e9bc7;
     }


     function _0x0c3243(address _0x3c673c, uint256 _0x13363a, bytes _0x2d712e) public returns (bool _0xe12cc8) {
         _0x363f2a[msg.sender][_0x3c673c] = _0x13363a;
         emit Approval(msg.sender, _0x3c673c, _0x13363a);


         require(_0x3c673c.call(bytes4(bytes32(_0xf0797e("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x13363a, this, _0x2d712e));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant VERSION = "0.0.1";

     uint256 public _0x1461ea = 0;

     event DidLCOpen (
         bytes32 indexed _0x05e920,
         address indexed _0x6b7176,
         address indexed _0x558bcd,
         uint256 _0x64d9ec,
         address _0x000930,
         uint256 _0xa74e21,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed _0x05e920,
         uint256 _0xcca2d9,
         uint256 _0xc42ff6
     );

     event DidLCDeposit (
         bytes32 indexed _0x05e920,
         address indexed _0x8ee465,
         uint256 _0xf87ef2,
         bool _0x1cd65f
     );

     event DidLCUpdateState (
         bytes32 indexed _0x05e920,
         uint256 _0xf1993e,
         uint256 _0xb9112b,
         uint256 _0x64d9ec,
         uint256 _0xa74e21,
         uint256 _0xcca2d9,
         uint256 _0xc42ff6,
         bytes32 _0xada9d1,
         uint256 _0xe82ddd
     );

     event DidLCClose (
         bytes32 indexed _0x05e920,
         uint256 _0xf1993e,
         uint256 _0x64d9ec,
         uint256 _0xa74e21,
         uint256 _0xcca2d9,
         uint256 _0xc42ff6
     );

     event DidVCInit (
         bytes32 indexed _0x8f5231,
         bytes32 indexed _0xd65ed2,
         bytes _0x2fbe78,
         uint256 _0xf1993e,
         address _0x6b7176,
         address _0x1030cf,
         uint256 _0x7aba10,
         uint256 _0xc7916f
     );

     event DidVCSettle (
         bytes32 indexed _0x8f5231,
         bytes32 indexed _0xd65ed2,
         uint256 _0xb561d3,
         uint256 _0x9552b0,
         uint256 _0x01f9af,
         address _0x6fdeee,
         uint256 _0x844c68
     );

     event DidVCClose(
         bytes32 indexed _0x8f5231,
         bytes32 indexed _0xd65ed2,
         uint256 _0x7aba10,
         uint256 _0xc7916f
     );

     struct Channel {

         address[2] _0xf92e23;
         uint256[4] _0x8163c6;
         uint256[4] _0xaad71c;
         uint256[2] _0xaeb12c;
         uint256 _0xf1993e;
         uint256 _0x198094;
         bytes32 VCrootHash;
         uint256 LCopenTimeout;
         uint256 _0xe82ddd;
         bool _0x9bb85f;
         bool _0x724774;
         uint256 _0x98fcb6;
         HumanStandardToken _0x000930;
     }


     struct VirtualChannel {
         bool _0x3b1b16;
         bool _0xde177e;
         uint256 _0xf1993e;
         address _0x6fdeee;
         uint256 _0x844c68;

         address _0x6b7176;
         address _0x1030cf;
         address _0x558bcd;
         uint256[2] _0x8163c6;
         uint256[2] _0xaad71c;
         uint256[2] _0xac89c2;
         HumanStandardToken _0x000930;
     }

     mapping(bytes32 => VirtualChannel) public _0x2a89b9;
     mapping(bytes32 => Channel) public Channels;

     function _0x93a428(
         bytes32 _0x73a3cd,
         address _0x18109e,
         uint256 _0xb2cc92,
         address _0x9278a5,
         uint256[2] _0x67d255
     )
         public
         payable
     {
         require(Channels[_0x73a3cd]._0xf92e23[0] == address(0), "Channel has already been created.");
         require(_0x18109e != 0x0, "No partyI address provided to LC creation");
         require(_0x67d255[0] >= 0 && _0x67d255[1] >= 0, "Balances cannot be negative");


         Channels[_0x73a3cd]._0xf92e23[0] = msg.sender;
         Channels[_0x73a3cd]._0xf92e23[1] = _0x18109e;

         if(_0x67d255[0] != 0) {
             require(msg.value == _0x67d255[0], "Eth balance does not match sent value");
             Channels[_0x73a3cd]._0x8163c6[0] = msg.value;
         }
         if(_0x67d255[1] != 0) {
             Channels[_0x73a3cd]._0x000930 = HumanStandardToken(_0x9278a5);
             require(Channels[_0x73a3cd]._0x000930._0xc9bc54(msg.sender, this, _0x67d255[1]),"CreateChannel: token transfer failure");
             Channels[_0x73a3cd]._0xaad71c[0] = _0x67d255[1];
         }

         Channels[_0x73a3cd]._0xf1993e = 0;
         Channels[_0x73a3cd]._0x198094 = _0xb2cc92;


         Channels[_0x73a3cd].LCopenTimeout = _0x13a4a7 + _0xb2cc92;
         Channels[_0x73a3cd]._0xaeb12c = _0x67d255;

         emit DidLCOpen(_0x73a3cd, msg.sender, _0x18109e, _0x67d255[0], _0x9278a5, _0x67d255[1], Channels[_0x73a3cd].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _0x73a3cd) public {
         require(msg.sender == Channels[_0x73a3cd]._0xf92e23[0] && Channels[_0x73a3cd]._0x9bb85f == false);
         require(_0x13a4a7 > Channels[_0x73a3cd].LCopenTimeout);

         if(Channels[_0x73a3cd]._0xaeb12c[0] != 0) {
             Channels[_0x73a3cd]._0xf92e23[0].transfer(Channels[_0x73a3cd]._0x8163c6[0]);
         }
         if(Channels[_0x73a3cd]._0xaeb12c[1] != 0) {
             require(Channels[_0x73a3cd]._0x000930.transfer(Channels[_0x73a3cd]._0xf92e23[0], Channels[_0x73a3cd]._0xaad71c[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_0x73a3cd, 0, Channels[_0x73a3cd]._0x8163c6[0], Channels[_0x73a3cd]._0xaad71c[0], 0, 0);


         delete Channels[_0x73a3cd];
     }

     function _0x0fc86b(bytes32 _0x73a3cd, uint256[2] _0x67d255) public payable {

         require(Channels[_0x73a3cd]._0x9bb85f == false);
         require(msg.sender == Channels[_0x73a3cd]._0xf92e23[1]);

         if(_0x67d255[0] != 0) {
             require(msg.value == _0x67d255[0], "state balance does not match sent value");
             Channels[_0x73a3cd]._0x8163c6[1] = msg.value;
         }
         if(_0x67d255[1] != 0) {
             require(Channels[_0x73a3cd]._0x000930._0xc9bc54(msg.sender, this, _0x67d255[1]),"joinChannel: token transfer failure");
             Channels[_0x73a3cd]._0xaad71c[1] = _0x67d255[1];
         }

         Channels[_0x73a3cd]._0xaeb12c[0]+=_0x67d255[0];
         Channels[_0x73a3cd]._0xaeb12c[1]+=_0x67d255[1];

         Channels[_0x73a3cd]._0x9bb85f = true;
         _0x1461ea++;

         emit DidLCJoin(_0x73a3cd, _0x67d255[0], _0x67d255[1]);
     }


     function _0xf87ef2(bytes32 _0x73a3cd, address _0x8ee465, uint256 _0x1a0082, bool _0x1cd65f) public payable {
         require(Channels[_0x73a3cd]._0x9bb85f == true, "Tried adding funds to a closed channel");
         require(_0x8ee465 == Channels[_0x73a3cd]._0xf92e23[0] || _0x8ee465 == Channels[_0x73a3cd]._0xf92e23[1]);


         if (Channels[_0x73a3cd]._0xf92e23[0] == _0x8ee465) {
             if(_0x1cd65f) {
                 require(Channels[_0x73a3cd]._0x000930._0xc9bc54(msg.sender, this, _0x1a0082),"deposit: token transfer failure");
                 Channels[_0x73a3cd]._0xaad71c[2] += _0x1a0082;
             } else {
                 require(msg.value == _0x1a0082, "state balance does not match sent value");
                 Channels[_0x73a3cd]._0x8163c6[2] += msg.value;
             }
         }

         if (Channels[_0x73a3cd]._0xf92e23[1] == _0x8ee465) {
             if(_0x1cd65f) {
                 require(Channels[_0x73a3cd]._0x000930._0xc9bc54(msg.sender, this, _0x1a0082),"deposit: token transfer failure");
                 Channels[_0x73a3cd]._0xaad71c[3] += _0x1a0082;
             } else {
                 require(msg.value == _0x1a0082, "state balance does not match sent value");
                 Channels[_0x73a3cd]._0x8163c6[3] += msg.value;
             }
         }

         emit DidLCDeposit(_0x73a3cd, _0x8ee465, _0x1a0082, _0x1cd65f);
     }


     function _0x4f90c1(
         bytes32 _0x73a3cd,
         uint256 _0x575e74,
         uint256[4] _0x67d255,
         string _0x283f26,
         string _0x3b5c89
     )
         public
     {


         require(Channels[_0x73a3cd]._0x9bb85f == true);
         uint256 _0x7509ec = Channels[_0x73a3cd]._0xaeb12c[0] + Channels[_0x73a3cd]._0x8163c6[2] + Channels[_0x73a3cd]._0x8163c6[3];
         uint256 _0xa082c3 = Channels[_0x73a3cd]._0xaeb12c[1] + Channels[_0x73a3cd]._0xaad71c[2] + Channels[_0x73a3cd]._0xaad71c[3];
         require(_0x7509ec == _0x67d255[0] + _0x67d255[1]);
         require(_0xa082c3 == _0x67d255[2] + _0x67d255[3]);

         bytes32 _0x93c9d2 = _0xf0797e(
             abi._0x0301de(
                 _0x73a3cd,
                 true,
                 _0x575e74,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_0x73a3cd]._0xf92e23[0],
                 Channels[_0x73a3cd]._0xf92e23[1],
                 _0x67d255[0],
                 _0x67d255[1],
                 _0x67d255[2],
                 _0x67d255[3]
             )
         );

         require(Channels[_0x73a3cd]._0xf92e23[0] == ECTools._0xbd371b(_0x93c9d2, _0x283f26));
         require(Channels[_0x73a3cd]._0xf92e23[1] == ECTools._0xbd371b(_0x93c9d2, _0x3b5c89));

         Channels[_0x73a3cd]._0x9bb85f = false;

         if(_0x67d255[0] != 0 || _0x67d255[1] != 0) {
             Channels[_0x73a3cd]._0xf92e23[0].transfer(_0x67d255[0]);
             Channels[_0x73a3cd]._0xf92e23[1].transfer(_0x67d255[1]);
         }

         if(_0x67d255[2] != 0 || _0x67d255[3] != 0) {
             require(Channels[_0x73a3cd]._0x000930.transfer(Channels[_0x73a3cd]._0xf92e23[0], _0x67d255[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_0x73a3cd]._0x000930.transfer(Channels[_0x73a3cd]._0xf92e23[1], _0x67d255[3]),"happyCloseChannel: token transfer failure");
         }

         _0x1461ea--;

         emit DidLCClose(_0x73a3cd, _0x575e74, _0x67d255[0], _0x67d255[1], _0x67d255[2], _0x67d255[3]);
     }


     function _0x2b6ea3(
         bytes32 _0x73a3cd,
         uint256[6] _0x161037,
         bytes32 _0x226b71,
         string _0x283f26,
         string _0x3b5c89
     )
         public
     {
         Channel storage _0xbf9419 = Channels[_0x73a3cd];
         require(_0xbf9419._0x9bb85f);
         require(_0xbf9419._0xf1993e < _0x161037[0]);
         require(_0xbf9419._0x8163c6[0] + _0xbf9419._0x8163c6[1] >= _0x161037[2] + _0x161037[3]);
         require(_0xbf9419._0xaad71c[0] + _0xbf9419._0xaad71c[1] >= _0x161037[4] + _0x161037[5]);

         if(_0xbf9419._0x724774 == true) {
             require(_0xbf9419._0xe82ddd > _0x13a4a7);
         }

         bytes32 _0x93c9d2 = _0xf0797e(
             abi._0x0301de(
                 _0x73a3cd,
                 false,
                 _0x161037[0],
                 _0x161037[1],
                 _0x226b71,
                 _0xbf9419._0xf92e23[0],
                 _0xbf9419._0xf92e23[1],
                 _0x161037[2],
                 _0x161037[3],
                 _0x161037[4],
                 _0x161037[5]
             )
         );

         require(_0xbf9419._0xf92e23[0] == ECTools._0xbd371b(_0x93c9d2, _0x283f26));
         require(_0xbf9419._0xf92e23[1] == ECTools._0xbd371b(_0x93c9d2, _0x3b5c89));


         _0xbf9419._0xf1993e = _0x161037[0];
         _0xbf9419._0x98fcb6 = _0x161037[1];
         _0xbf9419._0x8163c6[0] = _0x161037[2];
         _0xbf9419._0x8163c6[1] = _0x161037[3];
         _0xbf9419._0xaad71c[0] = _0x161037[4];
         _0xbf9419._0xaad71c[1] = _0x161037[5];
         _0xbf9419.VCrootHash = _0x226b71;
         _0xbf9419._0x724774 = true;
         _0xbf9419._0xe82ddd = _0x13a4a7 + _0xbf9419._0x198094;


         emit DidLCUpdateState (
             _0x73a3cd,
             _0x161037[0],
             _0x161037[1],
             _0x161037[2],
             _0x161037[3],
             _0x161037[4],
             _0x161037[5],
             _0x226b71,
             _0xbf9419._0xe82ddd
         );
     }


     function _0xa28e72(
         bytes32 _0x73a3cd,
         bytes32 _0x0c3822,
         bytes _0x8c5249,
         address _0xb6fc33,
         address _0x564065,
         uint256[2] _0xbf888e,
         uint256[4] _0x67d255,
         string _0xb5af0c
     )
         public
     {
         require(Channels[_0x73a3cd]._0x9bb85f, "LC is closed.");

         require(!_0x2a89b9[_0x0c3822]._0x3b1b16, "VC is closed.");

         require(Channels[_0x73a3cd]._0xe82ddd < _0x13a4a7, "LC timeout not over.");

         require(_0x2a89b9[_0x0c3822]._0x844c68 == 0);

         bytes32 _0x6741b7 = _0xf0797e(
             abi._0x0301de(_0x0c3822, uint256(0), _0xb6fc33, _0x564065, _0xbf888e[0], _0xbf888e[1], _0x67d255[0], _0x67d255[1], _0x67d255[2], _0x67d255[3])
         );


         require(_0xb6fc33 == ECTools._0xbd371b(_0x6741b7, _0xb5af0c));


         require(_0xa4824e(_0x6741b7, _0x8c5249, Channels[_0x73a3cd].VCrootHash) == true);

         _0x2a89b9[_0x0c3822]._0x6b7176 = _0xb6fc33;
         _0x2a89b9[_0x0c3822]._0x1030cf = _0x564065;
         _0x2a89b9[_0x0c3822]._0xf1993e = uint256(0);
         _0x2a89b9[_0x0c3822]._0x8163c6[0] = _0x67d255[0];
         _0x2a89b9[_0x0c3822]._0x8163c6[1] = _0x67d255[1];
         _0x2a89b9[_0x0c3822]._0xaad71c[0] = _0x67d255[2];
         _0x2a89b9[_0x0c3822]._0xaad71c[1] = _0x67d255[3];
         _0x2a89b9[_0x0c3822]._0xac89c2 = _0xbf888e;
         _0x2a89b9[_0x0c3822]._0x844c68 = _0x13a4a7 + Channels[_0x73a3cd]._0x198094;
         _0x2a89b9[_0x0c3822]._0xde177e = true;

         emit DidVCInit(_0x73a3cd, _0x0c3822, _0x8c5249, uint256(0), _0xb6fc33, _0x564065, _0x67d255[0], _0x67d255[1]);
     }


     function _0x6113d3(
         bytes32 _0x73a3cd,
         bytes32 _0x0c3822,
         uint256 _0xb561d3,
         address _0xb6fc33,
         address _0x564065,
         uint256[4] _0x6be8d0,
         string _0xb5af0c
     )
         public
     {
         require(Channels[_0x73a3cd]._0x9bb85f, "LC is closed.");

         require(!_0x2a89b9[_0x0c3822]._0x3b1b16, "VC is closed.");
         require(_0x2a89b9[_0x0c3822]._0xf1993e < _0xb561d3, "VC sequence is higher than update sequence.");
         require(
             _0x2a89b9[_0x0c3822]._0x8163c6[1] < _0x6be8d0[1] && _0x2a89b9[_0x0c3822]._0xaad71c[1] < _0x6be8d0[3],
             "State updates may only increase recipient balance."
         );
         require(
             _0x2a89b9[_0x0c3822]._0xac89c2[0] == _0x6be8d0[0] + _0x6be8d0[1] &&
             _0x2a89b9[_0x0c3822]._0xac89c2[1] == _0x6be8d0[2] + _0x6be8d0[3],
             "Incorrect balances for bonded amount");


         require(Channels[_0x73a3cd]._0xe82ddd < _0x13a4a7);

         bytes32 _0xb42b22 = _0xf0797e(
             abi._0x0301de(
                 _0x0c3822,
                 _0xb561d3,
                 _0xb6fc33,
                 _0x564065,
                 _0x2a89b9[_0x0c3822]._0xac89c2[0],
                 _0x2a89b9[_0x0c3822]._0xac89c2[1],
                 _0x6be8d0[0],
                 _0x6be8d0[1],
                 _0x6be8d0[2],
                 _0x6be8d0[3]
             )
         );


         require(_0x2a89b9[_0x0c3822]._0x6b7176 == ECTools._0xbd371b(_0xb42b22, _0xb5af0c));


         _0x2a89b9[_0x0c3822]._0x6fdeee = msg.sender;
         _0x2a89b9[_0x0c3822]._0xf1993e = _0xb561d3;


         _0x2a89b9[_0x0c3822]._0x8163c6[0] = _0x6be8d0[0];
         _0x2a89b9[_0x0c3822]._0x8163c6[1] = _0x6be8d0[1];
         _0x2a89b9[_0x0c3822]._0xaad71c[0] = _0x6be8d0[2];
         _0x2a89b9[_0x0c3822]._0xaad71c[1] = _0x6be8d0[3];

         _0x2a89b9[_0x0c3822]._0x844c68 = _0x13a4a7 + Channels[_0x73a3cd]._0x198094;

         emit DidVCSettle(_0x73a3cd, _0x0c3822, _0xb561d3, _0x6be8d0[0], _0x6be8d0[1], msg.sender, _0x2a89b9[_0x0c3822]._0x844c68);
     }

     function _0x817dc2(bytes32 _0x73a3cd, bytes32 _0x0c3822) public {

         require(Channels[_0x73a3cd]._0x9bb85f, "LC is closed.");
         require(_0x2a89b9[_0x0c3822]._0xde177e, "VC is not in settlement state.");
         require(_0x2a89b9[_0x0c3822]._0x844c68 < _0x13a4a7, "Update vc timeout has not elapsed.");
         require(!_0x2a89b9[_0x0c3822]._0x3b1b16, "VC is already closed");

         Channels[_0x73a3cd]._0x98fcb6--;

         _0x2a89b9[_0x0c3822]._0x3b1b16 = true;


         if(_0x2a89b9[_0x0c3822]._0x6b7176 == Channels[_0x73a3cd]._0xf92e23[0]) {
             Channels[_0x73a3cd]._0x8163c6[0] += _0x2a89b9[_0x0c3822]._0x8163c6[0];
             Channels[_0x73a3cd]._0x8163c6[1] += _0x2a89b9[_0x0c3822]._0x8163c6[1];

             Channels[_0x73a3cd]._0xaad71c[0] += _0x2a89b9[_0x0c3822]._0xaad71c[0];
             Channels[_0x73a3cd]._0xaad71c[1] += _0x2a89b9[_0x0c3822]._0xaad71c[1];
         } else if (_0x2a89b9[_0x0c3822]._0x1030cf == Channels[_0x73a3cd]._0xf92e23[0]) {
             Channels[_0x73a3cd]._0x8163c6[0] += _0x2a89b9[_0x0c3822]._0x8163c6[1];
             Channels[_0x73a3cd]._0x8163c6[1] += _0x2a89b9[_0x0c3822]._0x8163c6[0];

             Channels[_0x73a3cd]._0xaad71c[0] += _0x2a89b9[_0x0c3822]._0xaad71c[1];
             Channels[_0x73a3cd]._0xaad71c[1] += _0x2a89b9[_0x0c3822]._0xaad71c[0];
         }

         emit DidVCClose(_0x73a3cd, _0x0c3822, _0x2a89b9[_0x0c3822]._0xaad71c[0], _0x2a89b9[_0x0c3822]._0xaad71c[1]);
     }


     function _0x401c1b(bytes32 _0x73a3cd) public {
         Channel storage _0xbf9419 = Channels[_0x73a3cd];


         require(_0xbf9419._0x9bb85f, "Channel is not open");
         require(_0xbf9419._0x724774 == true);
         require(_0xbf9419._0x98fcb6 == 0);
         require(_0xbf9419._0xe82ddd < _0x13a4a7, "LC timeout over.");


         uint256 _0x7509ec = _0xbf9419._0xaeb12c[0] + _0xbf9419._0x8163c6[2] + _0xbf9419._0x8163c6[3];
         uint256 _0xa082c3 = _0xbf9419._0xaeb12c[1] + _0xbf9419._0xaad71c[2] + _0xbf9419._0xaad71c[3];

         uint256 _0xdca236 = _0xbf9419._0x8163c6[0] + _0xbf9419._0x8163c6[1];
         uint256 _0x6a30a1 = _0xbf9419._0xaad71c[0] + _0xbf9419._0xaad71c[1];

         if(_0xdca236 < _0x7509ec) {
             _0xbf9419._0x8163c6[0]+=_0xbf9419._0x8163c6[2];
             _0xbf9419._0x8163c6[1]+=_0xbf9419._0x8163c6[3];
         } else {
             require(_0xdca236 == _0x7509ec);
         }

         if(_0x6a30a1 < _0xa082c3) {
             _0xbf9419._0xaad71c[0]+=_0xbf9419._0xaad71c[2];
             _0xbf9419._0xaad71c[1]+=_0xbf9419._0xaad71c[3];
         } else {
             require(_0x6a30a1 == _0xa082c3);
         }

         uint256 _0x55db19 = _0xbf9419._0x8163c6[0];
         uint256 _0xd784a0 = _0xbf9419._0x8163c6[1];
         uint256 _0x3a11f3 = _0xbf9419._0xaad71c[0];
         uint256 _0x765080 = _0xbf9419._0xaad71c[1];

         _0xbf9419._0x8163c6[0] = 0;
         _0xbf9419._0x8163c6[1] = 0;
         _0xbf9419._0xaad71c[0] = 0;
         _0xbf9419._0xaad71c[1] = 0;

         if(_0x55db19 != 0 || _0xd784a0 != 0) {
             _0xbf9419._0xf92e23[0].transfer(_0x55db19);
             _0xbf9419._0xf92e23[1].transfer(_0xd784a0);
         }

         if(_0x3a11f3 != 0 || _0x765080 != 0) {
             require(
                 _0xbf9419._0x000930.transfer(_0xbf9419._0xf92e23[0], _0x3a11f3),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 _0xbf9419._0x000930.transfer(_0xbf9419._0xf92e23[1], _0x765080),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         _0xbf9419._0x9bb85f = false;
         _0x1461ea--;

         emit DidLCClose(_0x73a3cd, _0xbf9419._0xf1993e, _0x55db19, _0xd784a0, _0x3a11f3, _0x765080);
     }

     function _0xa4824e(bytes32 _0xcb160f, bytes _0x8c5249, bytes32 _0x92b327) internal pure returns (bool) {
         bytes32 _0x67611d = _0xcb160f;
         bytes32 _0xe57a58;

         for (uint256 i = 64; i <= _0x8c5249.length; i += 32) {
             assembly { _0xe57a58 := mload(add(_0x8c5249, i)) }

             if (_0x67611d < _0xe57a58) {
                 _0x67611d = _0xf0797e(abi._0x0301de(_0x67611d, _0xe57a58));
             } else {
                 if (gasleft() > 0) { _0x67611d = _0xf0797e(abi._0x0301de(_0xe57a58, _0x67611d)); }
             }
         }

         return _0x67611d == _0x92b327;
     }


     function _0xadb42c(bytes32 _0xd193cb) public view returns (
         address[2],
         uint256[4],
         uint256[4],
         uint256[2],
         uint256,
         uint256,
         bytes32,
         uint256,
         uint256,
         bool,
         bool,
         uint256
     ) {
         Channel memory _0xbf9419 = Channels[_0xd193cb];
         return (
             _0xbf9419._0xf92e23,
             _0xbf9419._0x8163c6,
             _0xbf9419._0xaad71c,
             _0xbf9419._0xaeb12c,
             _0xbf9419._0xf1993e,
             _0xbf9419._0x198094,
             _0xbf9419.VCrootHash,
             _0xbf9419.LCopenTimeout,
             _0xbf9419._0xe82ddd,
             _0xbf9419._0x9bb85f,
             _0xbf9419._0x724774,
             _0xbf9419._0x98fcb6
         );
     }

     function _0x059287(bytes32 _0xd193cb) public view returns(
         bool,
         bool,
         uint256,
         address,
         uint256,
         address,
         address,
         address,
         uint256[2],
         uint256[2],
         uint256[2]
     ) {
         VirtualChannel memory _0x5265df = _0x2a89b9[_0xd193cb];
         return(
             _0x5265df._0x3b1b16,
             _0x5265df._0xde177e,
             _0x5265df._0xf1993e,
             _0x5265df._0x6fdeee,
             _0x5265df._0x844c68,
             _0x5265df._0x6b7176,
             _0x5265df._0x1030cf,
             _0x5265df._0x558bcd,
             _0x5265df._0x8163c6,
             _0x5265df._0xaad71c,
             _0x5265df._0xac89c2
         );
     }
 }