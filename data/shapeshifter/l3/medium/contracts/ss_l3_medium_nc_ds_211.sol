pragma solidity ^0.4.23;


 contract Token {

     uint256 public _0x0c3ca9;


     function _0x114c80(address _0xdadb77) public constant returns (uint256 balance);


     function transfer(address _0xd93b8a, uint256 _0xab5204) public returns (bool _0x963d51);


     function _0x0848a8(address _0x7d4b6c, address _0xd93b8a, uint256 _0xab5204) public returns (bool _0x963d51);


     function _0xf99d46(address _0x2a5572, uint256 _0xab5204) public returns (bool _0x963d51);


     function _0x03c0c3(address _0xdadb77, address _0x2a5572) public constant returns (uint256 _0xd2b812);

     event Transfer(address indexed _0x7d4b6c, address indexed _0xd93b8a, uint256 _0xab5204);
     event Approval(address indexed _0xdadb77, address indexed _0x2a5572, uint256 _0xab5204);
 }

 library ECTools {


     function _0xe4c497(bytes32 _0xe58fc7, string _0x830dbd) public pure returns (address) {
         require(_0xe58fc7 != 0x00);


         bytes memory _0x2636a1 = "\x19Ethereum Signed Message:\n32";
         bytes32 _0x54002d = _0xf3f497(abi._0x72a6f6(_0x2636a1, _0xe58fc7));

         if (bytes(_0x830dbd).length != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = _0x547691(_0x2e88d3(_0x830dbd, 2, 132));
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
         return _0xc8694d(_0x54002d, v, r, s);
     }


     function _0x20ca6f(bytes32 _0xe58fc7, string _0x830dbd, address _0xaad5d4) public pure returns (bool) {
         require(_0xaad5d4 != 0x0);

         return _0xaad5d4 == _0xe4c497(_0xe58fc7, _0x830dbd);
     }


     function _0x547691(string _0xaea3b4) public pure returns (bytes) {
         uint _0xf4f741 = bytes(_0xaea3b4).length;
         require(_0xf4f741 % 2 == 0);

         bytes memory _0xbf2bb4 = bytes(new string(_0xf4f741 / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < _0xf4f741; i += 2) {
             s = _0x2e88d3(_0xaea3b4, i, i + 1);
             if (1 == 1) { r = _0x2e88d3(_0xaea3b4, i + 1, i + 2); }
             uint p = _0x4a3b12(s) * 16 + _0x4a3b12(r);
             _0xbf2bb4[k++] = _0x04c792(p)[31];
         }
         return _0xbf2bb4;
     }


     function _0x4a3b12(string _0xe03e90) public pure returns (uint) {
         bytes memory _0x2d2b6b = bytes(_0xe03e90);

         if ((_0x2d2b6b[0] >= 48) && (_0x2d2b6b[0] <= 57)) {
             return uint(_0x2d2b6b[0]) - 48;
         } else if ((_0x2d2b6b[0] >= 65) && (_0x2d2b6b[0] <= 70)) {
             return uint(_0x2d2b6b[0]) - 55;
         } else if ((_0x2d2b6b[0] >= 97) && (_0x2d2b6b[0] <= 102)) {
             return uint(_0x2d2b6b[0]) - 87;
         } else {
             revert();
         }
     }


     function _0x04c792(uint _0xdec750) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(add(b, 32), _0xdec750)}
     }


     function _0x0cc3d8(string _0x4100e5) public pure returns (bytes32) {
         uint _0xf4f741 = bytes(_0x4100e5).length;
         require(_0xf4f741 > 0);
         bytes memory _0x2636a1 = "\x19Ethereum Signed Message:\n";
         return _0xf3f497(abi._0x72a6f6(_0x2636a1, _0x534d57(_0xf4f741), _0x4100e5));
     }


     function _0x534d57(uint _0xdec750) public pure returns (string _0x3ed5c0) {
         uint _0xf4f741 = 0;
         uint m = _0xdec750 + 0;
         while (m != 0) {
             _0xf4f741++;
             m /= 10;
         }
         bytes memory b = new bytes(_0xf4f741);
         uint i = _0xf4f741 - 1;
         while (_0xdec750 != 0) {
             uint _0xf78f3f = _0xdec750 % 10;
             _0xdec750 = _0xdec750 / 10;
             b[i--] = byte(48 + _0xf78f3f);
         }
         _0x3ed5c0 = string(b);
     }


     function _0x2e88d3(string _0x9c1f94, uint _0xe64dc8, uint _0x339a18) public pure returns (string) {
         bytes memory _0x4882cc = bytes(_0x9c1f94);
         require(_0xe64dc8 <= _0x339a18);
         require(_0xe64dc8 >= 0);
         require(_0x339a18 <= _0x4882cc.length);

         bytes memory _0x6a1c44 = new bytes(_0x339a18 - _0xe64dc8);
         for (uint i = _0xe64dc8; i < _0x339a18; i++) {
             _0x6a1c44[i - _0xe64dc8] = _0x4882cc[i];
         }
         return string(_0x6a1c44);
     }
 }
 contract StandardToken is Token {

     function transfer(address _0xd93b8a, uint256 _0xab5204) public returns (bool _0x963d51) {


         require(_0x6b14f0[msg.sender] >= _0xab5204);
         _0x6b14f0[msg.sender] -= _0xab5204;
         _0x6b14f0[_0xd93b8a] += _0xab5204;
         emit Transfer(msg.sender, _0xd93b8a, _0xab5204);
         return true;
     }

     function _0x0848a8(address _0x7d4b6c, address _0xd93b8a, uint256 _0xab5204) public returns (bool _0x963d51) {


         require(_0x6b14f0[_0x7d4b6c] >= _0xab5204 && _0xd7a3d0[_0x7d4b6c][msg.sender] >= _0xab5204);
         _0x6b14f0[_0xd93b8a] += _0xab5204;
         _0x6b14f0[_0x7d4b6c] -= _0xab5204;
         _0xd7a3d0[_0x7d4b6c][msg.sender] -= _0xab5204;
         emit Transfer(_0x7d4b6c, _0xd93b8a, _0xab5204);
         return true;
     }

     function _0x114c80(address _0xdadb77) public constant returns (uint256 balance) {
         return _0x6b14f0[_0xdadb77];
     }

     function _0xf99d46(address _0x2a5572, uint256 _0xab5204) public returns (bool _0x963d51) {
         _0xd7a3d0[msg.sender][_0x2a5572] = _0xab5204;
         emit Approval(msg.sender, _0x2a5572, _0xab5204);
         return true;
     }

     function _0x03c0c3(address _0xdadb77, address _0x2a5572) public constant returns (uint256 _0xd2b812) {
       return _0xd7a3d0[_0xdadb77][_0x2a5572];
     }

     mapping (address => uint256) _0x6b14f0;
     mapping (address => mapping (address => uint256)) _0xd7a3d0;
 }

 contract HumanStandardToken is StandardToken {


     string public _0x228d6b;
     uint8 public _0x82aa2c;
     string public _0x5166b5;
     string public _0x1439a4 = 'H0.1';

     constructor(
         uint256 _0xd9416c,
         string _0x717377,
         uint8 _0xb07fb5,
         string _0x2e8682
         ) public {
         _0x6b14f0[msg.sender] = _0xd9416c;
         _0x0c3ca9 = _0xd9416c;
         _0x228d6b = _0x717377;
         _0x82aa2c = _0xb07fb5;
         _0x5166b5 = _0x2e8682;
     }


     function _0xfddf49(address _0x2a5572, uint256 _0xab5204, bytes _0x017e9d) public returns (bool _0x963d51) {
         _0xd7a3d0[msg.sender][_0x2a5572] = _0xab5204;
         emit Approval(msg.sender, _0x2a5572, _0xab5204);


         require(_0x2a5572.call(bytes4(bytes32(_0xf3f497("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0xab5204, this, _0x017e9d));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant VERSION = "0.0.1";

     uint256 public _0xfa248f = 0;

     event DidLCOpen (
         bytes32 indexed _0x03b7a2,
         address indexed _0x9e5fdc,
         address indexed _0x102afa,
         uint256 _0x233f59,
         address _0x4977e8,
         uint256 _0xfa2ed7,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed _0x03b7a2,
         uint256 _0x5662fa,
         uint256 _0x57bf5a
     );

     event DidLCDeposit (
         bytes32 indexed _0x03b7a2,
         address indexed _0x6f3ae7,
         uint256 _0x423370,
         bool _0xf4eb20
     );

     event DidLCUpdateState (
         bytes32 indexed _0x03b7a2,
         uint256 _0xeeea04,
         uint256 _0x982686,
         uint256 _0x233f59,
         uint256 _0xfa2ed7,
         uint256 _0x5662fa,
         uint256 _0x57bf5a,
         bytes32 _0xb5ff26,
         uint256 _0x0637fc
     );

     event DidLCClose (
         bytes32 indexed _0x03b7a2,
         uint256 _0xeeea04,
         uint256 _0x233f59,
         uint256 _0xfa2ed7,
         uint256 _0x5662fa,
         uint256 _0x57bf5a
     );

     event DidVCInit (
         bytes32 indexed _0x5c17d4,
         bytes32 indexed _0x42095e,
         bytes _0x2f833b,
         uint256 _0xeeea04,
         address _0x9e5fdc,
         address _0xa7a665,
         uint256 _0x19ee35,
         uint256 _0xc77b8a
     );

     event DidVCSettle (
         bytes32 indexed _0x5c17d4,
         bytes32 indexed _0x42095e,
         uint256 _0x794e4f,
         uint256 _0x2f6cc0,
         uint256 _0xda7870,
         address _0xfe8bbd,
         uint256 _0x057f87
     );

     event DidVCClose(
         bytes32 indexed _0x5c17d4,
         bytes32 indexed _0x42095e,
         uint256 _0x19ee35,
         uint256 _0xc77b8a
     );

     struct Channel {

         address[2] _0x27735a;
         uint256[4] _0x87b3ad;
         uint256[4] _0x9fa401;
         uint256[2] _0xc1afe5;
         uint256 _0xeeea04;
         uint256 _0x8ccd26;
         bytes32 VCrootHash;
         uint256 LCopenTimeout;
         uint256 _0x0637fc;
         bool _0x03ab9f;
         bool _0x852092;
         uint256 _0x42e903;
         HumanStandardToken _0x4977e8;
     }


     struct VirtualChannel {
         bool _0xc37cf2;
         bool _0xf10698;
         uint256 _0xeeea04;
         address _0xfe8bbd;
         uint256 _0x057f87;

         address _0x9e5fdc;
         address _0xa7a665;
         address _0x102afa;
         uint256[2] _0x87b3ad;
         uint256[2] _0x9fa401;
         uint256[2] _0x43c1b4;
         HumanStandardToken _0x4977e8;
     }

     mapping(bytes32 => VirtualChannel) public _0x9e6b3c;
     mapping(bytes32 => Channel) public Channels;

     function _0x65ac0f(
         bytes32 _0x3ebeb5,
         address _0xab38ae,
         uint256 _0xc04af2,
         address _0x1d0511,
         uint256[2] _0x9be93f
     )
         public
         payable
     {
         require(Channels[_0x3ebeb5]._0x27735a[0] == address(0), "Channel has already been created.");
         require(_0xab38ae != 0x0, "No partyI address provided to LC creation");
         require(_0x9be93f[0] >= 0 && _0x9be93f[1] >= 0, "Balances cannot be negative");


         Channels[_0x3ebeb5]._0x27735a[0] = msg.sender;
         Channels[_0x3ebeb5]._0x27735a[1] = _0xab38ae;

         if(_0x9be93f[0] != 0) {
             require(msg.value == _0x9be93f[0], "Eth balance does not match sent value");
             Channels[_0x3ebeb5]._0x87b3ad[0] = msg.value;
         }
         if(_0x9be93f[1] != 0) {
             Channels[_0x3ebeb5]._0x4977e8 = HumanStandardToken(_0x1d0511);
             require(Channels[_0x3ebeb5]._0x4977e8._0x0848a8(msg.sender, this, _0x9be93f[1]),"CreateChannel: token transfer failure");
             Channels[_0x3ebeb5]._0x9fa401[0] = _0x9be93f[1];
         }

         Channels[_0x3ebeb5]._0xeeea04 = 0;
         Channels[_0x3ebeb5]._0x8ccd26 = _0xc04af2;


         Channels[_0x3ebeb5].LCopenTimeout = _0x63e0d4 + _0xc04af2;
         Channels[_0x3ebeb5]._0xc1afe5 = _0x9be93f;

         emit DidLCOpen(_0x3ebeb5, msg.sender, _0xab38ae, _0x9be93f[0], _0x1d0511, _0x9be93f[1], Channels[_0x3ebeb5].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _0x3ebeb5) public {
         require(msg.sender == Channels[_0x3ebeb5]._0x27735a[0] && Channels[_0x3ebeb5]._0x03ab9f == false);
         require(_0x63e0d4 > Channels[_0x3ebeb5].LCopenTimeout);

         if(Channels[_0x3ebeb5]._0xc1afe5[0] != 0) {
             Channels[_0x3ebeb5]._0x27735a[0].transfer(Channels[_0x3ebeb5]._0x87b3ad[0]);
         }
         if(Channels[_0x3ebeb5]._0xc1afe5[1] != 0) {
             require(Channels[_0x3ebeb5]._0x4977e8.transfer(Channels[_0x3ebeb5]._0x27735a[0], Channels[_0x3ebeb5]._0x9fa401[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_0x3ebeb5, 0, Channels[_0x3ebeb5]._0x87b3ad[0], Channels[_0x3ebeb5]._0x9fa401[0], 0, 0);


         delete Channels[_0x3ebeb5];
     }

     function _0xa56ae7(bytes32 _0x3ebeb5, uint256[2] _0x9be93f) public payable {

         require(Channels[_0x3ebeb5]._0x03ab9f == false);
         require(msg.sender == Channels[_0x3ebeb5]._0x27735a[1]);

         if(_0x9be93f[0] != 0) {
             require(msg.value == _0x9be93f[0], "state balance does not match sent value");
             Channels[_0x3ebeb5]._0x87b3ad[1] = msg.value;
         }
         if(_0x9be93f[1] != 0) {
             require(Channels[_0x3ebeb5]._0x4977e8._0x0848a8(msg.sender, this, _0x9be93f[1]),"joinChannel: token transfer failure");
             Channels[_0x3ebeb5]._0x9fa401[1] = _0x9be93f[1];
         }

         Channels[_0x3ebeb5]._0xc1afe5[0]+=_0x9be93f[0];
         Channels[_0x3ebeb5]._0xc1afe5[1]+=_0x9be93f[1];

         Channels[_0x3ebeb5]._0x03ab9f = true;
         _0xfa248f++;

         emit DidLCJoin(_0x3ebeb5, _0x9be93f[0], _0x9be93f[1]);
     }


     function _0x423370(bytes32 _0x3ebeb5, address _0x6f3ae7, uint256 _0xb96ce1, bool _0xf4eb20) public payable {
         require(Channels[_0x3ebeb5]._0x03ab9f == true, "Tried adding funds to a closed channel");
         require(_0x6f3ae7 == Channels[_0x3ebeb5]._0x27735a[0] || _0x6f3ae7 == Channels[_0x3ebeb5]._0x27735a[1]);


         if (Channels[_0x3ebeb5]._0x27735a[0] == _0x6f3ae7) {
             if(_0xf4eb20) {
                 require(Channels[_0x3ebeb5]._0x4977e8._0x0848a8(msg.sender, this, _0xb96ce1),"deposit: token transfer failure");
                 Channels[_0x3ebeb5]._0x9fa401[2] += _0xb96ce1;
             } else {
                 require(msg.value == _0xb96ce1, "state balance does not match sent value");
                 Channels[_0x3ebeb5]._0x87b3ad[2] += msg.value;
             }
         }

         if (Channels[_0x3ebeb5]._0x27735a[1] == _0x6f3ae7) {
             if(_0xf4eb20) {
                 require(Channels[_0x3ebeb5]._0x4977e8._0x0848a8(msg.sender, this, _0xb96ce1),"deposit: token transfer failure");
                 Channels[_0x3ebeb5]._0x9fa401[3] += _0xb96ce1;
             } else {
                 require(msg.value == _0xb96ce1, "state balance does not match sent value");
                 Channels[_0x3ebeb5]._0x87b3ad[3] += msg.value;
             }
         }

         emit DidLCDeposit(_0x3ebeb5, _0x6f3ae7, _0xb96ce1, _0xf4eb20);
     }


     function _0x71d20f(
         bytes32 _0x3ebeb5,
         uint256 _0x1afd5f,
         uint256[4] _0x9be93f,
         string _0xfcf0b4,
         string _0xe3db4a
     )
         public
     {


         require(Channels[_0x3ebeb5]._0x03ab9f == true);
         uint256 _0xd1ad40 = Channels[_0x3ebeb5]._0xc1afe5[0] + Channels[_0x3ebeb5]._0x87b3ad[2] + Channels[_0x3ebeb5]._0x87b3ad[3];
         uint256 _0x70fa8b = Channels[_0x3ebeb5]._0xc1afe5[1] + Channels[_0x3ebeb5]._0x9fa401[2] + Channels[_0x3ebeb5]._0x9fa401[3];
         require(_0xd1ad40 == _0x9be93f[0] + _0x9be93f[1]);
         require(_0x70fa8b == _0x9be93f[2] + _0x9be93f[3]);

         bytes32 _0x43edfd = _0xf3f497(
             abi._0x72a6f6(
                 _0x3ebeb5,
                 true,
                 _0x1afd5f,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_0x3ebeb5]._0x27735a[0],
                 Channels[_0x3ebeb5]._0x27735a[1],
                 _0x9be93f[0],
                 _0x9be93f[1],
                 _0x9be93f[2],
                 _0x9be93f[3]
             )
         );

         require(Channels[_0x3ebeb5]._0x27735a[0] == ECTools._0xe4c497(_0x43edfd, _0xfcf0b4));
         require(Channels[_0x3ebeb5]._0x27735a[1] == ECTools._0xe4c497(_0x43edfd, _0xe3db4a));

         Channels[_0x3ebeb5]._0x03ab9f = false;

         if(_0x9be93f[0] != 0 || _0x9be93f[1] != 0) {
             Channels[_0x3ebeb5]._0x27735a[0].transfer(_0x9be93f[0]);
             Channels[_0x3ebeb5]._0x27735a[1].transfer(_0x9be93f[1]);
         }

         if(_0x9be93f[2] != 0 || _0x9be93f[3] != 0) {
             require(Channels[_0x3ebeb5]._0x4977e8.transfer(Channels[_0x3ebeb5]._0x27735a[0], _0x9be93f[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_0x3ebeb5]._0x4977e8.transfer(Channels[_0x3ebeb5]._0x27735a[1], _0x9be93f[3]),"happyCloseChannel: token transfer failure");
         }

         _0xfa248f--;

         emit DidLCClose(_0x3ebeb5, _0x1afd5f, _0x9be93f[0], _0x9be93f[1], _0x9be93f[2], _0x9be93f[3]);
     }


     function _0xc0b140(
         bytes32 _0x3ebeb5,
         uint256[6] _0x898b0c,
         bytes32 _0x7b6149,
         string _0xfcf0b4,
         string _0xe3db4a
     )
         public
     {
         Channel storage _0xbfebff = Channels[_0x3ebeb5];
         require(_0xbfebff._0x03ab9f);
         require(_0xbfebff._0xeeea04 < _0x898b0c[0]);
         require(_0xbfebff._0x87b3ad[0] + _0xbfebff._0x87b3ad[1] >= _0x898b0c[2] + _0x898b0c[3]);
         require(_0xbfebff._0x9fa401[0] + _0xbfebff._0x9fa401[1] >= _0x898b0c[4] + _0x898b0c[5]);

         if(_0xbfebff._0x852092 == true) {
             require(_0xbfebff._0x0637fc > _0x63e0d4);
         }

         bytes32 _0x43edfd = _0xf3f497(
             abi._0x72a6f6(
                 _0x3ebeb5,
                 false,
                 _0x898b0c[0],
                 _0x898b0c[1],
                 _0x7b6149,
                 _0xbfebff._0x27735a[0],
                 _0xbfebff._0x27735a[1],
                 _0x898b0c[2],
                 _0x898b0c[3],
                 _0x898b0c[4],
                 _0x898b0c[5]
             )
         );

         require(_0xbfebff._0x27735a[0] == ECTools._0xe4c497(_0x43edfd, _0xfcf0b4));
         require(_0xbfebff._0x27735a[1] == ECTools._0xe4c497(_0x43edfd, _0xe3db4a));


         _0xbfebff._0xeeea04 = _0x898b0c[0];
         _0xbfebff._0x42e903 = _0x898b0c[1];
         _0xbfebff._0x87b3ad[0] = _0x898b0c[2];
         _0xbfebff._0x87b3ad[1] = _0x898b0c[3];
         _0xbfebff._0x9fa401[0] = _0x898b0c[4];
         _0xbfebff._0x9fa401[1] = _0x898b0c[5];
         _0xbfebff.VCrootHash = _0x7b6149;
         _0xbfebff._0x852092 = true;
         _0xbfebff._0x0637fc = _0x63e0d4 + _0xbfebff._0x8ccd26;


         emit DidLCUpdateState (
             _0x3ebeb5,
             _0x898b0c[0],
             _0x898b0c[1],
             _0x898b0c[2],
             _0x898b0c[3],
             _0x898b0c[4],
             _0x898b0c[5],
             _0x7b6149,
             _0xbfebff._0x0637fc
         );
     }


     function _0x510f1c(
         bytes32 _0x3ebeb5,
         bytes32 _0x407931,
         bytes _0x5439ed,
         address _0x7f1ae0,
         address _0xadf8e2,
         uint256[2] _0x4f8ef4,
         uint256[4] _0x9be93f,
         string _0x77f281
     )
         public
     {
         require(Channels[_0x3ebeb5]._0x03ab9f, "LC is closed.");

         require(!_0x9e6b3c[_0x407931]._0xc37cf2, "VC is closed.");

         require(Channels[_0x3ebeb5]._0x0637fc < _0x63e0d4, "LC timeout not over.");

         require(_0x9e6b3c[_0x407931]._0x057f87 == 0);

         bytes32 _0xf65b20 = _0xf3f497(
             abi._0x72a6f6(_0x407931, uint256(0), _0x7f1ae0, _0xadf8e2, _0x4f8ef4[0], _0x4f8ef4[1], _0x9be93f[0], _0x9be93f[1], _0x9be93f[2], _0x9be93f[3])
         );


         require(_0x7f1ae0 == ECTools._0xe4c497(_0xf65b20, _0x77f281));


         require(_0x2d1684(_0xf65b20, _0x5439ed, Channels[_0x3ebeb5].VCrootHash) == true);

         _0x9e6b3c[_0x407931]._0x9e5fdc = _0x7f1ae0;
         _0x9e6b3c[_0x407931]._0xa7a665 = _0xadf8e2;
         _0x9e6b3c[_0x407931]._0xeeea04 = uint256(0);
         _0x9e6b3c[_0x407931]._0x87b3ad[0] = _0x9be93f[0];
         _0x9e6b3c[_0x407931]._0x87b3ad[1] = _0x9be93f[1];
         _0x9e6b3c[_0x407931]._0x9fa401[0] = _0x9be93f[2];
         _0x9e6b3c[_0x407931]._0x9fa401[1] = _0x9be93f[3];
         _0x9e6b3c[_0x407931]._0x43c1b4 = _0x4f8ef4;
         _0x9e6b3c[_0x407931]._0x057f87 = _0x63e0d4 + Channels[_0x3ebeb5]._0x8ccd26;
         _0x9e6b3c[_0x407931]._0xf10698 = true;

         emit DidVCInit(_0x3ebeb5, _0x407931, _0x5439ed, uint256(0), _0x7f1ae0, _0xadf8e2, _0x9be93f[0], _0x9be93f[1]);
     }


     function _0xedc84d(
         bytes32 _0x3ebeb5,
         bytes32 _0x407931,
         uint256 _0x794e4f,
         address _0x7f1ae0,
         address _0xadf8e2,
         uint256[4] _0xb37bd9,
         string _0x77f281
     )
         public
     {
         require(Channels[_0x3ebeb5]._0x03ab9f, "LC is closed.");

         require(!_0x9e6b3c[_0x407931]._0xc37cf2, "VC is closed.");
         require(_0x9e6b3c[_0x407931]._0xeeea04 < _0x794e4f, "VC sequence is higher than update sequence.");
         require(
             _0x9e6b3c[_0x407931]._0x87b3ad[1] < _0xb37bd9[1] && _0x9e6b3c[_0x407931]._0x9fa401[1] < _0xb37bd9[3],
             "State updates may only increase recipient balance."
         );
         require(
             _0x9e6b3c[_0x407931]._0x43c1b4[0] == _0xb37bd9[0] + _0xb37bd9[1] &&
             _0x9e6b3c[_0x407931]._0x43c1b4[1] == _0xb37bd9[2] + _0xb37bd9[3],
             "Incorrect balances for bonded amount");


         require(Channels[_0x3ebeb5]._0x0637fc < _0x63e0d4);

         bytes32 _0xc10443 = _0xf3f497(
             abi._0x72a6f6(
                 _0x407931,
                 _0x794e4f,
                 _0x7f1ae0,
                 _0xadf8e2,
                 _0x9e6b3c[_0x407931]._0x43c1b4[0],
                 _0x9e6b3c[_0x407931]._0x43c1b4[1],
                 _0xb37bd9[0],
                 _0xb37bd9[1],
                 _0xb37bd9[2],
                 _0xb37bd9[3]
             )
         );


         require(_0x9e6b3c[_0x407931]._0x9e5fdc == ECTools._0xe4c497(_0xc10443, _0x77f281));


         _0x9e6b3c[_0x407931]._0xfe8bbd = msg.sender;
         _0x9e6b3c[_0x407931]._0xeeea04 = _0x794e4f;


         _0x9e6b3c[_0x407931]._0x87b3ad[0] = _0xb37bd9[0];
         _0x9e6b3c[_0x407931]._0x87b3ad[1] = _0xb37bd9[1];
         _0x9e6b3c[_0x407931]._0x9fa401[0] = _0xb37bd9[2];
         _0x9e6b3c[_0x407931]._0x9fa401[1] = _0xb37bd9[3];

         _0x9e6b3c[_0x407931]._0x057f87 = _0x63e0d4 + Channels[_0x3ebeb5]._0x8ccd26;

         emit DidVCSettle(_0x3ebeb5, _0x407931, _0x794e4f, _0xb37bd9[0], _0xb37bd9[1], msg.sender, _0x9e6b3c[_0x407931]._0x057f87);
     }

     function _0xa2fa9a(bytes32 _0x3ebeb5, bytes32 _0x407931) public {

         require(Channels[_0x3ebeb5]._0x03ab9f, "LC is closed.");
         require(_0x9e6b3c[_0x407931]._0xf10698, "VC is not in settlement state.");
         require(_0x9e6b3c[_0x407931]._0x057f87 < _0x63e0d4, "Update vc timeout has not elapsed.");
         require(!_0x9e6b3c[_0x407931]._0xc37cf2, "VC is already closed");

         Channels[_0x3ebeb5]._0x42e903--;

         _0x9e6b3c[_0x407931]._0xc37cf2 = true;


         if(_0x9e6b3c[_0x407931]._0x9e5fdc == Channels[_0x3ebeb5]._0x27735a[0]) {
             Channels[_0x3ebeb5]._0x87b3ad[0] += _0x9e6b3c[_0x407931]._0x87b3ad[0];
             Channels[_0x3ebeb5]._0x87b3ad[1] += _0x9e6b3c[_0x407931]._0x87b3ad[1];

             Channels[_0x3ebeb5]._0x9fa401[0] += _0x9e6b3c[_0x407931]._0x9fa401[0];
             Channels[_0x3ebeb5]._0x9fa401[1] += _0x9e6b3c[_0x407931]._0x9fa401[1];
         } else if (_0x9e6b3c[_0x407931]._0xa7a665 == Channels[_0x3ebeb5]._0x27735a[0]) {
             Channels[_0x3ebeb5]._0x87b3ad[0] += _0x9e6b3c[_0x407931]._0x87b3ad[1];
             Channels[_0x3ebeb5]._0x87b3ad[1] += _0x9e6b3c[_0x407931]._0x87b3ad[0];

             Channels[_0x3ebeb5]._0x9fa401[0] += _0x9e6b3c[_0x407931]._0x9fa401[1];
             Channels[_0x3ebeb5]._0x9fa401[1] += _0x9e6b3c[_0x407931]._0x9fa401[0];
         }

         emit DidVCClose(_0x3ebeb5, _0x407931, _0x9e6b3c[_0x407931]._0x9fa401[0], _0x9e6b3c[_0x407931]._0x9fa401[1]);
     }


     function _0xaaf095(bytes32 _0x3ebeb5) public {
         Channel storage _0xbfebff = Channels[_0x3ebeb5];


         require(_0xbfebff._0x03ab9f, "Channel is not open");
         require(_0xbfebff._0x852092 == true);
         require(_0xbfebff._0x42e903 == 0);
         require(_0xbfebff._0x0637fc < _0x63e0d4, "LC timeout over.");


         uint256 _0xd1ad40 = _0xbfebff._0xc1afe5[0] + _0xbfebff._0x87b3ad[2] + _0xbfebff._0x87b3ad[3];
         uint256 _0x70fa8b = _0xbfebff._0xc1afe5[1] + _0xbfebff._0x9fa401[2] + _0xbfebff._0x9fa401[3];

         uint256 _0xa740e3 = _0xbfebff._0x87b3ad[0] + _0xbfebff._0x87b3ad[1];
         uint256 _0x3be280 = _0xbfebff._0x9fa401[0] + _0xbfebff._0x9fa401[1];

         if(_0xa740e3 < _0xd1ad40) {
             _0xbfebff._0x87b3ad[0]+=_0xbfebff._0x87b3ad[2];
             _0xbfebff._0x87b3ad[1]+=_0xbfebff._0x87b3ad[3];
         } else {
             require(_0xa740e3 == _0xd1ad40);
         }

         if(_0x3be280 < _0x70fa8b) {
             _0xbfebff._0x9fa401[0]+=_0xbfebff._0x9fa401[2];
             _0xbfebff._0x9fa401[1]+=_0xbfebff._0x9fa401[3];
         } else {
             require(_0x3be280 == _0x70fa8b);
         }

         uint256 _0x1cb868 = _0xbfebff._0x87b3ad[0];
         uint256 _0x51a027 = _0xbfebff._0x87b3ad[1];
         uint256 _0x89e74d = _0xbfebff._0x9fa401[0];
         uint256 _0x82f7a7 = _0xbfebff._0x9fa401[1];

         _0xbfebff._0x87b3ad[0] = 0;
         _0xbfebff._0x87b3ad[1] = 0;
         _0xbfebff._0x9fa401[0] = 0;
         _0xbfebff._0x9fa401[1] = 0;

         if(_0x1cb868 != 0 || _0x51a027 != 0) {
             _0xbfebff._0x27735a[0].transfer(_0x1cb868);
             _0xbfebff._0x27735a[1].transfer(_0x51a027);
         }

         if(_0x89e74d != 0 || _0x82f7a7 != 0) {
             require(
                 _0xbfebff._0x4977e8.transfer(_0xbfebff._0x27735a[0], _0x89e74d),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 _0xbfebff._0x4977e8.transfer(_0xbfebff._0x27735a[1], _0x82f7a7),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         _0xbfebff._0x03ab9f = false;
         _0xfa248f--;

         emit DidLCClose(_0x3ebeb5, _0xbfebff._0xeeea04, _0x1cb868, _0x51a027, _0x89e74d, _0x82f7a7);
     }

     function _0x2d1684(bytes32 _0x4fe0bc, bytes _0x5439ed, bytes32 _0xf53724) internal pure returns (bool) {
         bytes32 _0x1c6238 = _0x4fe0bc;
         bytes32 _0x90cc19;

         for (uint256 i = 64; i <= _0x5439ed.length; i += 32) {
             assembly { _0x90cc19 := mload(add(_0x5439ed, i)) }

             if (_0x1c6238 < _0x90cc19) {
                 _0x1c6238 = _0xf3f497(abi._0x72a6f6(_0x1c6238, _0x90cc19));
             } else {
                 _0x1c6238 = _0xf3f497(abi._0x72a6f6(_0x90cc19, _0x1c6238));
             }
         }

         return _0x1c6238 == _0xf53724;
     }


     function _0xe02c8c(bytes32 _0xd5005f) public view returns (
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
         Channel memory _0xbfebff = Channels[_0xd5005f];
         return (
             _0xbfebff._0x27735a,
             _0xbfebff._0x87b3ad,
             _0xbfebff._0x9fa401,
             _0xbfebff._0xc1afe5,
             _0xbfebff._0xeeea04,
             _0xbfebff._0x8ccd26,
             _0xbfebff.VCrootHash,
             _0xbfebff.LCopenTimeout,
             _0xbfebff._0x0637fc,
             _0xbfebff._0x03ab9f,
             _0xbfebff._0x852092,
             _0xbfebff._0x42e903
         );
     }

     function _0x47a688(bytes32 _0xd5005f) public view returns(
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
         VirtualChannel memory _0xe13255 = _0x9e6b3c[_0xd5005f];
         return(
             _0xe13255._0xc37cf2,
             _0xe13255._0xf10698,
             _0xe13255._0xeeea04,
             _0xe13255._0xfe8bbd,
             _0xe13255._0x057f87,
             _0xe13255._0x9e5fdc,
             _0xe13255._0xa7a665,
             _0xe13255._0x102afa,
             _0xe13255._0x87b3ad,
             _0xe13255._0x9fa401,
             _0xe13255._0x43c1b4
         );
     }
 }