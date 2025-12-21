pragma solidity ^0.4.23;


contract Token {

    uint256 public _0x57b6a4;


    function _0x220d7a(address _0x744f14) public constant returns (uint256 balance);


    function transfer(address _0x5776bc, uint256 _0x75a0a0) public returns (bool _0xa0acc5);


    function _0xc35c4e(address _0x53a9c5, address _0x5776bc, uint256 _0x75a0a0) public returns (bool _0xa0acc5);


    function _0x3ed7a6(address _0x2ebbf9, uint256 _0x75a0a0) public returns (bool _0xa0acc5);


    function _0x5f048b(address _0x744f14, address _0x2ebbf9) public constant returns (uint256 _0x85d04b);

    event Transfer(address indexed _0x53a9c5, address indexed _0x5776bc, uint256 _0x75a0a0);
    event Approval(address indexed _0x744f14, address indexed _0x2ebbf9, uint256 _0x75a0a0);
}

library ECTools {


    function _0xc2923b(bytes32 _0x442bde, string _0xc5733f) public pure returns (address) {
        require(_0x442bde != 0x00);


        bytes memory _0x36b59a = "\x19Ethereum Signed Message:\n32";
        bytes32 _0xe31ae8 = _0xd5a3bb(abi._0xbc5339(_0x36b59a, _0x442bde));

        if (bytes(_0xc5733f).length != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = _0x148dd2(_0x1ff6d6(_0xc5733f, 2, 132));
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
        return _0x5d6021(_0xe31ae8, v, r, s);
    }


    function _0xe9e073(bytes32 _0x442bde, string _0xc5733f, address _0x0934f3) public pure returns (bool) {
        require(_0x0934f3 != 0x0);

        return _0x0934f3 == _0xc2923b(_0x442bde, _0xc5733f);
    }


    function _0x148dd2(string _0x12b87e) public pure returns (bytes) {
        uint _0x95c84c = bytes(_0x12b87e).length;
        require(_0x95c84c % 2 == 0);

        bytes memory _0x29e199 = bytes(new string(_0x95c84c / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < _0x95c84c; i += 2) {
            s = _0x1ff6d6(_0x12b87e, i, i + 1);
            r = _0x1ff6d6(_0x12b87e, i + 1, i + 2);
            uint p = _0x9e6c62(s) * 16 + _0x9e6c62(r);
            _0x29e199[k++] = _0x7f3864(p)[31];
        }
        return _0x29e199;
    }


    function _0x9e6c62(string _0x7b5c10) public pure returns (uint) {
        bytes memory _0x583623 = bytes(_0x7b5c10);

        if ((_0x583623[0] >= 48) && (_0x583623[0] <= 57)) {
            return uint(_0x583623[0]) - 48;
        } else if ((_0x583623[0] >= 65) && (_0x583623[0] <= 70)) {
            return uint(_0x583623[0]) - 55;
        } else if ((_0x583623[0] >= 97) && (_0x583623[0] <= 102)) {
            return uint(_0x583623[0]) - 87;
        } else {
            revert();
        }
    }


    function _0x7f3864(uint _0xbc4824) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), _0xbc4824)}
    }


    function _0x82f58e(string _0x0d7908) public pure returns (bytes32) {
        uint _0x95c84c = bytes(_0x0d7908).length;
        require(_0x95c84c > 0);
        bytes memory _0x36b59a = "\x19Ethereum Signed Message:\n";
        return _0xd5a3bb(abi._0xbc5339(_0x36b59a, _0x950fd8(_0x95c84c), _0x0d7908));
    }


    function _0x950fd8(uint _0xbc4824) public pure returns (string _0xd30f41) {
        uint _0x95c84c = 0;
        uint m = _0xbc4824 + 0;
        while (m != 0) {
            _0x95c84c++;
            m /= 10;
        }
        bytes memory b = new bytes(_0x95c84c);
        uint i = _0x95c84c - 1;
        while (_0xbc4824 != 0) {
            uint _0xd3e5b8 = _0xbc4824 % 10;
            if (block.timestamp > 0) { _0xbc4824 = _0xbc4824 / 10; }
            b[i--] = byte(48 + _0xd3e5b8);
        }
        _0xd30f41 = string(b);
    }


    function _0x1ff6d6(string _0xa3a7cd, uint _0xd8da64, uint _0x8b0eb4) public pure returns (string) {
        bytes memory _0x063600 = bytes(_0xa3a7cd);
        require(_0xd8da64 <= _0x8b0eb4);
        require(_0xd8da64 >= 0);
        require(_0x8b0eb4 <= _0x063600.length);

        bytes memory _0x95f17e = new bytes(_0x8b0eb4 - _0xd8da64);
        for (uint i = _0xd8da64; i < _0x8b0eb4; i++) {
            _0x95f17e[i - _0xd8da64] = _0x063600[i];
        }
        return string(_0x95f17e);
    }
}
contract StandardToken is Token {

    function transfer(address _0x5776bc, uint256 _0x75a0a0) public returns (bool _0xa0acc5) {


        require(_0xabf965[msg.sender] >= _0x75a0a0);
        _0xabf965[msg.sender] -= _0x75a0a0;
        _0xabf965[_0x5776bc] += _0x75a0a0;
        emit Transfer(msg.sender, _0x5776bc, _0x75a0a0);
        return true;
    }

    function _0xc35c4e(address _0x53a9c5, address _0x5776bc, uint256 _0x75a0a0) public returns (bool _0xa0acc5) {


        require(_0xabf965[_0x53a9c5] >= _0x75a0a0 && _0x8e1981[_0x53a9c5][msg.sender] >= _0x75a0a0);
        _0xabf965[_0x5776bc] += _0x75a0a0;
        _0xabf965[_0x53a9c5] -= _0x75a0a0;
        _0x8e1981[_0x53a9c5][msg.sender] -= _0x75a0a0;
        emit Transfer(_0x53a9c5, _0x5776bc, _0x75a0a0);
        return true;
    }

    function _0x220d7a(address _0x744f14) public constant returns (uint256 balance) {
        return _0xabf965[_0x744f14];
    }

    function _0x3ed7a6(address _0x2ebbf9, uint256 _0x75a0a0) public returns (bool _0xa0acc5) {
        _0x8e1981[msg.sender][_0x2ebbf9] = _0x75a0a0;
        emit Approval(msg.sender, _0x2ebbf9, _0x75a0a0);
        return true;
    }

    function _0x5f048b(address _0x744f14, address _0x2ebbf9) public constant returns (uint256 _0x85d04b) {
      return _0x8e1981[_0x744f14][_0x2ebbf9];
    }

    mapping (address => uint256) _0xabf965;
    mapping (address => mapping (address => uint256)) _0x8e1981;
}

contract HumanStandardToken is StandardToken {


    string public _0xccb298;
    uint8 public _0x3d7fa7;
    string public _0x675897;
    string public _0xd12be9 = 'H0.1';

    constructor(
        uint256 _0x89acc0,
        string _0x1bc106,
        uint8 _0x28ea0a,
        string _0x84c91d
        ) public {
        _0xabf965[msg.sender] = _0x89acc0;
        _0x57b6a4 = _0x89acc0;
        _0xccb298 = _0x1bc106;
        _0x3d7fa7 = _0x28ea0a;
        _0x675897 = _0x84c91d;
    }


    function _0xe3553f(address _0x2ebbf9, uint256 _0x75a0a0, bytes _0x51548a) public returns (bool _0xa0acc5) {
        _0x8e1981[msg.sender][_0x2ebbf9] = _0x75a0a0;
        emit Approval(msg.sender, _0x2ebbf9, _0x75a0a0);


        require(_0x2ebbf9.call(bytes4(bytes32(_0xd5a3bb("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x75a0a0, this, _0x51548a));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant VERSION = "0.0.1";

    uint256 public _0xdb7286 = 0;

    event DidLCOpen (
        bytes32 indexed _0xf9c8fb,
        address indexed _0x5a06ea,
        address indexed _0xe7fb41,
        uint256 _0x3cc081,
        address _0x6f60f7,
        uint256 _0xeb09f6,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed _0xf9c8fb,
        uint256 _0xa7e09b,
        uint256 _0xeda463
    );

    event DidLCDeposit (
        bytes32 indexed _0xf9c8fb,
        address indexed _0xabd654,
        uint256 _0x9345e8,
        bool _0xca1fbb
    );

    event DidLCUpdateState (
        bytes32 indexed _0xf9c8fb,
        uint256 _0xdc533e,
        uint256 _0x3035c0,
        uint256 _0x3cc081,
        uint256 _0xeb09f6,
        uint256 _0xa7e09b,
        uint256 _0xeda463,
        bytes32 _0x4508f6,
        uint256 _0xc6219e
    );

    event DidLCClose (
        bytes32 indexed _0xf9c8fb,
        uint256 _0xdc533e,
        uint256 _0x3cc081,
        uint256 _0xeb09f6,
        uint256 _0xa7e09b,
        uint256 _0xeda463
    );

    event DidVCInit (
        bytes32 indexed _0x0b9612,
        bytes32 indexed _0xda359f,
        bytes _0x5f9106,
        uint256 _0xdc533e,
        address _0x5a06ea,
        address _0xc9a2b3,
        uint256 _0x75879c,
        uint256 _0xf39803
    );

    event DidVCSettle (
        bytes32 indexed _0x0b9612,
        bytes32 indexed _0xda359f,
        uint256 _0x530828,
        uint256 _0x6fea4f,
        uint256 _0x649376,
        address _0xf9e852,
        uint256 _0xd97d9f
    );

    event DidVCClose(
        bytes32 indexed _0x0b9612,
        bytes32 indexed _0xda359f,
        uint256 _0x75879c,
        uint256 _0xf39803
    );

    struct Channel {

        address[2] _0x85a883;
        uint256[4] _0x6648c3;
        uint256[4] _0xbc1ac0;
        uint256[2] _0xbc32c7;
        uint256 _0xdc533e;
        uint256 _0xe3c505;
        bytes32 VCrootHash;
        uint256 LCopenTimeout;
        uint256 _0xc6219e;
        bool _0x8229e2;
        bool _0xba6120;
        uint256 _0xa7ec24;
        HumanStandardToken _0x6f60f7;
    }


    struct VirtualChannel {
        bool _0xab1f97;
        bool _0x61fa15;
        uint256 _0xdc533e;
        address _0xf9e852;
        uint256 _0xd97d9f;

        address _0x5a06ea;
        address _0xc9a2b3;
        address _0xe7fb41;
        uint256[2] _0x6648c3;
        uint256[2] _0xbc1ac0;
        uint256[2] _0x061339;
        HumanStandardToken _0x6f60f7;
    }

    mapping(bytes32 => VirtualChannel) public _0xf6f2aa;
    mapping(bytes32 => Channel) public Channels;

    function _0xef4d06(
        bytes32 _0x59ef6c,
        address _0xd03074,
        uint256 _0x9c95e5,
        address _0xff58d1,
        uint256[2] _0xc04b85
    )
        public
        payable
    {
        require(Channels[_0x59ef6c]._0x85a883[0] == address(0), "Channel has already been created.");
        require(_0xd03074 != 0x0, "No partyI address provided to LC creation");
        require(_0xc04b85[0] >= 0 && _0xc04b85[1] >= 0, "Balances cannot be negative");


        Channels[_0x59ef6c]._0x85a883[0] = msg.sender;
        Channels[_0x59ef6c]._0x85a883[1] = _0xd03074;

        if(_0xc04b85[0] != 0) {
            require(msg.value == _0xc04b85[0], "Eth balance does not match sent value");
            Channels[_0x59ef6c]._0x6648c3[0] = msg.value;
        }
        if(_0xc04b85[1] != 0) {
            Channels[_0x59ef6c]._0x6f60f7 = HumanStandardToken(_0xff58d1);
            require(Channels[_0x59ef6c]._0x6f60f7._0xc35c4e(msg.sender, this, _0xc04b85[1]),"CreateChannel: token transfer failure");
            Channels[_0x59ef6c]._0xbc1ac0[0] = _0xc04b85[1];
        }

        Channels[_0x59ef6c]._0xdc533e = 0;
        Channels[_0x59ef6c]._0xe3c505 = _0x9c95e5;


        Channels[_0x59ef6c].LCopenTimeout = _0x6b265e + _0x9c95e5;
        Channels[_0x59ef6c]._0xbc32c7 = _0xc04b85;

        emit DidLCOpen(_0x59ef6c, msg.sender, _0xd03074, _0xc04b85[0], _0xff58d1, _0xc04b85[1], Channels[_0x59ef6c].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _0x59ef6c) public {
        require(msg.sender == Channels[_0x59ef6c]._0x85a883[0] && Channels[_0x59ef6c]._0x8229e2 == false);
        require(_0x6b265e > Channels[_0x59ef6c].LCopenTimeout);

        if(Channels[_0x59ef6c]._0xbc32c7[0] != 0) {
            Channels[_0x59ef6c]._0x85a883[0].transfer(Channels[_0x59ef6c]._0x6648c3[0]);
        }
        if(Channels[_0x59ef6c]._0xbc32c7[1] != 0) {
            require(Channels[_0x59ef6c]._0x6f60f7.transfer(Channels[_0x59ef6c]._0x85a883[0], Channels[_0x59ef6c]._0xbc1ac0[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_0x59ef6c, 0, Channels[_0x59ef6c]._0x6648c3[0], Channels[_0x59ef6c]._0xbc1ac0[0], 0, 0);


        delete Channels[_0x59ef6c];
    }

    function _0x10ede6(bytes32 _0x59ef6c, uint256[2] _0xc04b85) public payable {

        require(Channels[_0x59ef6c]._0x8229e2 == false);
        require(msg.sender == Channels[_0x59ef6c]._0x85a883[1]);

        if(_0xc04b85[0] != 0) {
            require(msg.value == _0xc04b85[0], "state balance does not match sent value");
            Channels[_0x59ef6c]._0x6648c3[1] = msg.value;
        }
        if(_0xc04b85[1] != 0) {
            require(Channels[_0x59ef6c]._0x6f60f7._0xc35c4e(msg.sender, this, _0xc04b85[1]),"joinChannel: token transfer failure");
            Channels[_0x59ef6c]._0xbc1ac0[1] = _0xc04b85[1];
        }

        Channels[_0x59ef6c]._0xbc32c7[0]+=_0xc04b85[0];
        Channels[_0x59ef6c]._0xbc32c7[1]+=_0xc04b85[1];

        Channels[_0x59ef6c]._0x8229e2 = true;
        _0xdb7286++;

        emit DidLCJoin(_0x59ef6c, _0xc04b85[0], _0xc04b85[1]);
    }


    function _0x9345e8(bytes32 _0x59ef6c, address _0xabd654, uint256 _0x658d35, bool _0xca1fbb) public payable {
        require(Channels[_0x59ef6c]._0x8229e2 == true, "Tried adding funds to a closed channel");
        require(_0xabd654 == Channels[_0x59ef6c]._0x85a883[0] || _0xabd654 == Channels[_0x59ef6c]._0x85a883[1]);


        if (Channels[_0x59ef6c]._0x85a883[0] == _0xabd654) {
            if(_0xca1fbb) {
                require(Channels[_0x59ef6c]._0x6f60f7._0xc35c4e(msg.sender, this, _0x658d35),"deposit: token transfer failure");
                Channels[_0x59ef6c]._0xbc1ac0[2] += _0x658d35;
            } else {
                require(msg.value == _0x658d35, "state balance does not match sent value");
                Channels[_0x59ef6c]._0x6648c3[2] += msg.value;
            }
        }

        if (Channels[_0x59ef6c]._0x85a883[1] == _0xabd654) {
            if(_0xca1fbb) {
                require(Channels[_0x59ef6c]._0x6f60f7._0xc35c4e(msg.sender, this, _0x658d35),"deposit: token transfer failure");
                Channels[_0x59ef6c]._0xbc1ac0[3] += _0x658d35;
            } else {
                require(msg.value == _0x658d35, "state balance does not match sent value");
                Channels[_0x59ef6c]._0x6648c3[3] += msg.value;
            }
        }

        emit DidLCDeposit(_0x59ef6c, _0xabd654, _0x658d35, _0xca1fbb);
    }


    function _0xe5c812(
        bytes32 _0x59ef6c,
        uint256 _0x7bea40,
        uint256[4] _0xc04b85,
        string _0xfb0f3d,
        string _0x277065
    )
        public
    {


        require(Channels[_0x59ef6c]._0x8229e2 == true);
        uint256 _0x9c6a1d = Channels[_0x59ef6c]._0xbc32c7[0] + Channels[_0x59ef6c]._0x6648c3[2] + Channels[_0x59ef6c]._0x6648c3[3];
        uint256 _0xd13c7f = Channels[_0x59ef6c]._0xbc32c7[1] + Channels[_0x59ef6c]._0xbc1ac0[2] + Channels[_0x59ef6c]._0xbc1ac0[3];
        require(_0x9c6a1d == _0xc04b85[0] + _0xc04b85[1]);
        require(_0xd13c7f == _0xc04b85[2] + _0xc04b85[3]);

        bytes32 _0x6861ac = _0xd5a3bb(
            abi._0xbc5339(
                _0x59ef6c,
                true,
                _0x7bea40,
                uint256(0),
                bytes32(0x0),
                Channels[_0x59ef6c]._0x85a883[0],
                Channels[_0x59ef6c]._0x85a883[1],
                _0xc04b85[0],
                _0xc04b85[1],
                _0xc04b85[2],
                _0xc04b85[3]
            )
        );

        require(Channels[_0x59ef6c]._0x85a883[0] == ECTools._0xc2923b(_0x6861ac, _0xfb0f3d));
        require(Channels[_0x59ef6c]._0x85a883[1] == ECTools._0xc2923b(_0x6861ac, _0x277065));

        Channels[_0x59ef6c]._0x8229e2 = false;

        if(_0xc04b85[0] != 0 || _0xc04b85[1] != 0) {
            Channels[_0x59ef6c]._0x85a883[0].transfer(_0xc04b85[0]);
            Channels[_0x59ef6c]._0x85a883[1].transfer(_0xc04b85[1]);
        }

        if(_0xc04b85[2] != 0 || _0xc04b85[3] != 0) {
            require(Channels[_0x59ef6c]._0x6f60f7.transfer(Channels[_0x59ef6c]._0x85a883[0], _0xc04b85[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_0x59ef6c]._0x6f60f7.transfer(Channels[_0x59ef6c]._0x85a883[1], _0xc04b85[3]),"happyCloseChannel: token transfer failure");
        }

        _0xdb7286--;

        emit DidLCClose(_0x59ef6c, _0x7bea40, _0xc04b85[0], _0xc04b85[1], _0xc04b85[2], _0xc04b85[3]);
    }


    function _0x9005ca(
        bytes32 _0x59ef6c,
        uint256[6] _0x348f19,
        bytes32 _0x304cc5,
        string _0xfb0f3d,
        string _0x277065
    )
        public
    {
        Channel storage _0x8950c5 = Channels[_0x59ef6c];
        require(_0x8950c5._0x8229e2);
        require(_0x8950c5._0xdc533e < _0x348f19[0]);
        require(_0x8950c5._0x6648c3[0] + _0x8950c5._0x6648c3[1] >= _0x348f19[2] + _0x348f19[3]);
        require(_0x8950c5._0xbc1ac0[0] + _0x8950c5._0xbc1ac0[1] >= _0x348f19[4] + _0x348f19[5]);

        if(_0x8950c5._0xba6120 == true) {
            require(_0x8950c5._0xc6219e > _0x6b265e);
        }

        bytes32 _0x6861ac = _0xd5a3bb(
            abi._0xbc5339(
                _0x59ef6c,
                false,
                _0x348f19[0],
                _0x348f19[1],
                _0x304cc5,
                _0x8950c5._0x85a883[0],
                _0x8950c5._0x85a883[1],
                _0x348f19[2],
                _0x348f19[3],
                _0x348f19[4],
                _0x348f19[5]
            )
        );

        require(_0x8950c5._0x85a883[0] == ECTools._0xc2923b(_0x6861ac, _0xfb0f3d));
        require(_0x8950c5._0x85a883[1] == ECTools._0xc2923b(_0x6861ac, _0x277065));


        _0x8950c5._0xdc533e = _0x348f19[0];
        _0x8950c5._0xa7ec24 = _0x348f19[1];
        _0x8950c5._0x6648c3[0] = _0x348f19[2];
        _0x8950c5._0x6648c3[1] = _0x348f19[3];
        _0x8950c5._0xbc1ac0[0] = _0x348f19[4];
        _0x8950c5._0xbc1ac0[1] = _0x348f19[5];
        _0x8950c5.VCrootHash = _0x304cc5;
        _0x8950c5._0xba6120 = true;
        _0x8950c5._0xc6219e = _0x6b265e + _0x8950c5._0xe3c505;


        emit DidLCUpdateState (
            _0x59ef6c,
            _0x348f19[0],
            _0x348f19[1],
            _0x348f19[2],
            _0x348f19[3],
            _0x348f19[4],
            _0x348f19[5],
            _0x304cc5,
            _0x8950c5._0xc6219e
        );
    }


    function _0xf8f3aa(
        bytes32 _0x59ef6c,
        bytes32 _0xbd3f37,
        bytes _0x9c31f3,
        address _0xa43bc6,
        address _0x74d569,
        uint256[2] _0x2609a4,
        uint256[4] _0xc04b85,
        string _0x778490
    )
        public
    {
        require(Channels[_0x59ef6c]._0x8229e2, "LC is closed.");

        require(!_0xf6f2aa[_0xbd3f37]._0xab1f97, "VC is closed.");

        require(Channels[_0x59ef6c]._0xc6219e < _0x6b265e, "LC timeout not over.");

        require(_0xf6f2aa[_0xbd3f37]._0xd97d9f == 0);

        bytes32 _0xa4679b = _0xd5a3bb(
            abi._0xbc5339(_0xbd3f37, uint256(0), _0xa43bc6, _0x74d569, _0x2609a4[0], _0x2609a4[1], _0xc04b85[0], _0xc04b85[1], _0xc04b85[2], _0xc04b85[3])
        );


        require(_0xa43bc6 == ECTools._0xc2923b(_0xa4679b, _0x778490));


        require(_0x1bd1df(_0xa4679b, _0x9c31f3, Channels[_0x59ef6c].VCrootHash) == true);

        _0xf6f2aa[_0xbd3f37]._0x5a06ea = _0xa43bc6;
        _0xf6f2aa[_0xbd3f37]._0xc9a2b3 = _0x74d569;
        _0xf6f2aa[_0xbd3f37]._0xdc533e = uint256(0);
        _0xf6f2aa[_0xbd3f37]._0x6648c3[0] = _0xc04b85[0];
        _0xf6f2aa[_0xbd3f37]._0x6648c3[1] = _0xc04b85[1];
        _0xf6f2aa[_0xbd3f37]._0xbc1ac0[0] = _0xc04b85[2];
        _0xf6f2aa[_0xbd3f37]._0xbc1ac0[1] = _0xc04b85[3];
        _0xf6f2aa[_0xbd3f37]._0x061339 = _0x2609a4;
        _0xf6f2aa[_0xbd3f37]._0xd97d9f = _0x6b265e + Channels[_0x59ef6c]._0xe3c505;
        _0xf6f2aa[_0xbd3f37]._0x61fa15 = true;

        emit DidVCInit(_0x59ef6c, _0xbd3f37, _0x9c31f3, uint256(0), _0xa43bc6, _0x74d569, _0xc04b85[0], _0xc04b85[1]);
    }


    function _0x91ce74(
        bytes32 _0x59ef6c,
        bytes32 _0xbd3f37,
        uint256 _0x530828,
        address _0xa43bc6,
        address _0x74d569,
        uint256[4] _0x3a12f8,
        string _0x778490
    )
        public
    {
        require(Channels[_0x59ef6c]._0x8229e2, "LC is closed.");

        require(!_0xf6f2aa[_0xbd3f37]._0xab1f97, "VC is closed.");
        require(_0xf6f2aa[_0xbd3f37]._0xdc533e < _0x530828, "VC sequence is higher than update sequence.");
        require(
            _0xf6f2aa[_0xbd3f37]._0x6648c3[1] < _0x3a12f8[1] && _0xf6f2aa[_0xbd3f37]._0xbc1ac0[1] < _0x3a12f8[3],
            "State updates may only increase recipient balance."
        );
        require(
            _0xf6f2aa[_0xbd3f37]._0x061339[0] == _0x3a12f8[0] + _0x3a12f8[1] &&
            _0xf6f2aa[_0xbd3f37]._0x061339[1] == _0x3a12f8[2] + _0x3a12f8[3],
            "Incorrect balances for bonded amount");


        require(Channels[_0x59ef6c]._0xc6219e < _0x6b265e);

        bytes32 _0x7ce6b0 = _0xd5a3bb(
            abi._0xbc5339(
                _0xbd3f37,
                _0x530828,
                _0xa43bc6,
                _0x74d569,
                _0xf6f2aa[_0xbd3f37]._0x061339[0],
                _0xf6f2aa[_0xbd3f37]._0x061339[1],
                _0x3a12f8[0],
                _0x3a12f8[1],
                _0x3a12f8[2],
                _0x3a12f8[3]
            )
        );


        require(_0xf6f2aa[_0xbd3f37]._0x5a06ea == ECTools._0xc2923b(_0x7ce6b0, _0x778490));


        _0xf6f2aa[_0xbd3f37]._0xf9e852 = msg.sender;
        _0xf6f2aa[_0xbd3f37]._0xdc533e = _0x530828;


        _0xf6f2aa[_0xbd3f37]._0x6648c3[0] = _0x3a12f8[0];
        _0xf6f2aa[_0xbd3f37]._0x6648c3[1] = _0x3a12f8[1];
        _0xf6f2aa[_0xbd3f37]._0xbc1ac0[0] = _0x3a12f8[2];
        _0xf6f2aa[_0xbd3f37]._0xbc1ac0[1] = _0x3a12f8[3];

        _0xf6f2aa[_0xbd3f37]._0xd97d9f = _0x6b265e + Channels[_0x59ef6c]._0xe3c505;

        emit DidVCSettle(_0x59ef6c, _0xbd3f37, _0x530828, _0x3a12f8[0], _0x3a12f8[1], msg.sender, _0xf6f2aa[_0xbd3f37]._0xd97d9f);
    }

    function _0x16892f(bytes32 _0x59ef6c, bytes32 _0xbd3f37) public {

        require(Channels[_0x59ef6c]._0x8229e2, "LC is closed.");
        require(_0xf6f2aa[_0xbd3f37]._0x61fa15, "VC is not in settlement state.");
        require(_0xf6f2aa[_0xbd3f37]._0xd97d9f < _0x6b265e, "Update vc timeout has not elapsed.");
        require(!_0xf6f2aa[_0xbd3f37]._0xab1f97, "VC is already closed");

        Channels[_0x59ef6c]._0xa7ec24--;

        _0xf6f2aa[_0xbd3f37]._0xab1f97 = true;


        if(_0xf6f2aa[_0xbd3f37]._0x5a06ea == Channels[_0x59ef6c]._0x85a883[0]) {
            Channels[_0x59ef6c]._0x6648c3[0] += _0xf6f2aa[_0xbd3f37]._0x6648c3[0];
            Channels[_0x59ef6c]._0x6648c3[1] += _0xf6f2aa[_0xbd3f37]._0x6648c3[1];

            Channels[_0x59ef6c]._0xbc1ac0[0] += _0xf6f2aa[_0xbd3f37]._0xbc1ac0[0];
            Channels[_0x59ef6c]._0xbc1ac0[1] += _0xf6f2aa[_0xbd3f37]._0xbc1ac0[1];
        } else if (_0xf6f2aa[_0xbd3f37]._0xc9a2b3 == Channels[_0x59ef6c]._0x85a883[0]) {
            Channels[_0x59ef6c]._0x6648c3[0] += _0xf6f2aa[_0xbd3f37]._0x6648c3[1];
            Channels[_0x59ef6c]._0x6648c3[1] += _0xf6f2aa[_0xbd3f37]._0x6648c3[0];

            Channels[_0x59ef6c]._0xbc1ac0[0] += _0xf6f2aa[_0xbd3f37]._0xbc1ac0[1];
            Channels[_0x59ef6c]._0xbc1ac0[1] += _0xf6f2aa[_0xbd3f37]._0xbc1ac0[0];
        }

        emit DidVCClose(_0x59ef6c, _0xbd3f37, _0xf6f2aa[_0xbd3f37]._0xbc1ac0[0], _0xf6f2aa[_0xbd3f37]._0xbc1ac0[1]);
    }


    function _0x05c48f(bytes32 _0x59ef6c) public {
        Channel storage _0x8950c5 = Channels[_0x59ef6c];


        require(_0x8950c5._0x8229e2, "Channel is not open");
        require(_0x8950c5._0xba6120 == true);
        require(_0x8950c5._0xa7ec24 == 0);
        require(_0x8950c5._0xc6219e < _0x6b265e, "LC timeout over.");


        uint256 _0x9c6a1d = _0x8950c5._0xbc32c7[0] + _0x8950c5._0x6648c3[2] + _0x8950c5._0x6648c3[3];
        uint256 _0xd13c7f = _0x8950c5._0xbc32c7[1] + _0x8950c5._0xbc1ac0[2] + _0x8950c5._0xbc1ac0[3];

        uint256 _0x74b5e6 = _0x8950c5._0x6648c3[0] + _0x8950c5._0x6648c3[1];
        uint256 _0x33ef07 = _0x8950c5._0xbc1ac0[0] + _0x8950c5._0xbc1ac0[1];

        if(_0x74b5e6 < _0x9c6a1d) {
            _0x8950c5._0x6648c3[0]+=_0x8950c5._0x6648c3[2];
            _0x8950c5._0x6648c3[1]+=_0x8950c5._0x6648c3[3];
        } else {
            require(_0x74b5e6 == _0x9c6a1d);
        }

        if(_0x33ef07 < _0xd13c7f) {
            _0x8950c5._0xbc1ac0[0]+=_0x8950c5._0xbc1ac0[2];
            _0x8950c5._0xbc1ac0[1]+=_0x8950c5._0xbc1ac0[3];
        } else {
            require(_0x33ef07 == _0xd13c7f);
        }

        uint256 _0xd0568f = _0x8950c5._0x6648c3[0];
        uint256 _0xdb868c = _0x8950c5._0x6648c3[1];
        uint256 _0xd0965e = _0x8950c5._0xbc1ac0[0];
        uint256 _0x848252 = _0x8950c5._0xbc1ac0[1];

        _0x8950c5._0x6648c3[0] = 0;
        _0x8950c5._0x6648c3[1] = 0;
        _0x8950c5._0xbc1ac0[0] = 0;
        _0x8950c5._0xbc1ac0[1] = 0;

        if(_0xd0568f != 0 || _0xdb868c != 0) {
            _0x8950c5._0x85a883[0].transfer(_0xd0568f);
            _0x8950c5._0x85a883[1].transfer(_0xdb868c);
        }

        if(_0xd0965e != 0 || _0x848252 != 0) {
            require(
                _0x8950c5._0x6f60f7.transfer(_0x8950c5._0x85a883[0], _0xd0965e),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                _0x8950c5._0x6f60f7.transfer(_0x8950c5._0x85a883[1], _0x848252),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        _0x8950c5._0x8229e2 = false;
        _0xdb7286--;

        emit DidLCClose(_0x59ef6c, _0x8950c5._0xdc533e, _0xd0568f, _0xdb868c, _0xd0965e, _0x848252);
    }

    function _0x1bd1df(bytes32 _0xd49839, bytes _0x9c31f3, bytes32 _0xb0ff18) internal pure returns (bool) {
        bytes32 _0x0c7748 = _0xd49839;
        bytes32 _0x5ff9db;

        for (uint256 i = 64; i <= _0x9c31f3.length; i += 32) {
            assembly { _0x5ff9db := mload(add(_0x9c31f3, i)) }

            if (_0x0c7748 < _0x5ff9db) {
                _0x0c7748 = _0xd5a3bb(abi._0xbc5339(_0x0c7748, _0x5ff9db));
            } else {
                if (msg.sender != address(0) || msg.sender == address(0)) { _0x0c7748 = _0xd5a3bb(abi._0xbc5339(_0x5ff9db, _0x0c7748)); }
            }
        }

        return _0x0c7748 == _0xb0ff18;
    }


    function _0x3a5a5d(bytes32 _0x798dee) public view returns (
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
        Channel memory _0x8950c5 = Channels[_0x798dee];
        return (
            _0x8950c5._0x85a883,
            _0x8950c5._0x6648c3,
            _0x8950c5._0xbc1ac0,
            _0x8950c5._0xbc32c7,
            _0x8950c5._0xdc533e,
            _0x8950c5._0xe3c505,
            _0x8950c5.VCrootHash,
            _0x8950c5.LCopenTimeout,
            _0x8950c5._0xc6219e,
            _0x8950c5._0x8229e2,
            _0x8950c5._0xba6120,
            _0x8950c5._0xa7ec24
        );
    }

    function _0x29dbfd(bytes32 _0x798dee) public view returns(
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
        VirtualChannel memory _0x823c82 = _0xf6f2aa[_0x798dee];
        return(
            _0x823c82._0xab1f97,
            _0x823c82._0x61fa15,
            _0x823c82._0xdc533e,
            _0x823c82._0xf9e852,
            _0x823c82._0xd97d9f,
            _0x823c82._0x5a06ea,
            _0x823c82._0xc9a2b3,
            _0x823c82._0xe7fb41,
            _0x823c82._0x6648c3,
            _0x823c82._0xbc1ac0,
            _0x823c82._0x061339
        );
    }
}