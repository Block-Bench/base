pragma solidity ^0.4.23;


contract Token {

    uint256 public _0xf6a3e9;


    function _0xf12be5(address _0x0b9ebb) public constant returns (uint256 balance);


    function transfer(address _0xdb11f6, uint256 _0x3e8b02) public returns (bool _0x9f58b8);


    function _0xdf85c3(address _0xe3f596, address _0xdb11f6, uint256 _0x3e8b02) public returns (bool _0x9f58b8);


    function _0x3ae712(address _0x6e4860, uint256 _0x3e8b02) public returns (bool _0x9f58b8);


    function _0x326f09(address _0x0b9ebb, address _0x6e4860) public constant returns (uint256 _0x4de5fe);

    event Transfer(address indexed _0xe3f596, address indexed _0xdb11f6, uint256 _0x3e8b02);
    event Approval(address indexed _0x0b9ebb, address indexed _0x6e4860, uint256 _0x3e8b02);
}

library ECTools {


    function _0x9821e8(bytes32 _0xc06409, string _0x21cbc2) public pure returns (address) {
        require(_0xc06409 != 0x00);


        bytes memory _0x25e950 = "\x19Ethereum Signed Message:\n32";
        bytes32 _0xdacf81 = _0xd1f68c(abi._0x775388(_0x25e950, _0xc06409));

        if (bytes(_0x21cbc2).length != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = _0x0c24cc(_0x9f7487(_0x21cbc2, 2, 132));
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
        return _0x7c8b06(_0xdacf81, v, r, s);
    }


    function _0x8cd905(bytes32 _0xc06409, string _0x21cbc2, address _0x024306) public pure returns (bool) {
        require(_0x024306 != 0x0);

        return _0x024306 == _0x9821e8(_0xc06409, _0x21cbc2);
    }


    function _0x0c24cc(string _0x17639a) public pure returns (bytes) {
        uint _0xc20a5f = bytes(_0x17639a).length;
        require(_0xc20a5f % 2 == 0);

        bytes memory _0xcd21b9 = bytes(new string(_0xc20a5f / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < _0xc20a5f; i += 2) {
            s = _0x9f7487(_0x17639a, i, i + 1);
            r = _0x9f7487(_0x17639a, i + 1, i + 2);
            uint p = _0xdee07c(s) * 16 + _0xdee07c(r);
            _0xcd21b9[k++] = _0xd5ace1(p)[31];
        }
        return _0xcd21b9;
    }


    function _0xdee07c(string _0x78e5a4) public pure returns (uint) {
        bytes memory _0x1b693d = bytes(_0x78e5a4);

        if ((_0x1b693d[0] >= 48) && (_0x1b693d[0] <= 57)) {
            return uint(_0x1b693d[0]) - 48;
        } else if ((_0x1b693d[0] >= 65) && (_0x1b693d[0] <= 70)) {
            return uint(_0x1b693d[0]) - 55;
        } else if ((_0x1b693d[0] >= 97) && (_0x1b693d[0] <= 102)) {
            return uint(_0x1b693d[0]) - 87;
        } else {
            revert();
        }
    }


    function _0xd5ace1(uint _0x996e51) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), _0x996e51)}
    }


    function _0xb23fcb(string _0x08fcab) public pure returns (bytes32) {
        uint _0xc20a5f = bytes(_0x08fcab).length;
        require(_0xc20a5f > 0);
        bytes memory _0x25e950 = "\x19Ethereum Signed Message:\n";
        return _0xd1f68c(abi._0x775388(_0x25e950, _0x52d564(_0xc20a5f), _0x08fcab));
    }


    function _0x52d564(uint _0x996e51) public pure returns (string _0x3eeb40) {
        uint _0xc20a5f = 0;
        uint m = _0x996e51 + 0;
        while (m != 0) {
            _0xc20a5f++;
            m /= 10;
        }
        bytes memory b = new bytes(_0xc20a5f);
        uint i = _0xc20a5f - 1;
        while (_0x996e51 != 0) {
            uint _0x005fcd = _0x996e51 % 10;
            _0x996e51 = _0x996e51 / 10;
            b[i--] = byte(48 + _0x005fcd);
        }
        _0x3eeb40 = string(b);
    }


    function _0x9f7487(string _0xf29443, uint _0xd7ee56, uint _0x3db8ed) public pure returns (string) {
        bytes memory _0x2a54f1 = bytes(_0xf29443);
        require(_0xd7ee56 <= _0x3db8ed);
        require(_0xd7ee56 >= 0);
        require(_0x3db8ed <= _0x2a54f1.length);

        bytes memory _0x32433b = new bytes(_0x3db8ed - _0xd7ee56);
        for (uint i = _0xd7ee56; i < _0x3db8ed; i++) {
            _0x32433b[i - _0xd7ee56] = _0x2a54f1[i];
        }
        return string(_0x32433b);
    }
}
contract StandardToken is Token {

    function transfer(address _0xdb11f6, uint256 _0x3e8b02) public returns (bool _0x9f58b8) {


        require(_0x0d3682[msg.sender] >= _0x3e8b02);
        _0x0d3682[msg.sender] -= _0x3e8b02;
        _0x0d3682[_0xdb11f6] += _0x3e8b02;
        emit Transfer(msg.sender, _0xdb11f6, _0x3e8b02);
        return true;
    }

    function _0xdf85c3(address _0xe3f596, address _0xdb11f6, uint256 _0x3e8b02) public returns (bool _0x9f58b8) {


        require(_0x0d3682[_0xe3f596] >= _0x3e8b02 && _0x686a41[_0xe3f596][msg.sender] >= _0x3e8b02);
        _0x0d3682[_0xdb11f6] += _0x3e8b02;
        _0x0d3682[_0xe3f596] -= _0x3e8b02;
        _0x686a41[_0xe3f596][msg.sender] -= _0x3e8b02;
        emit Transfer(_0xe3f596, _0xdb11f6, _0x3e8b02);
        return true;
    }

    function _0xf12be5(address _0x0b9ebb) public constant returns (uint256 balance) {
        return _0x0d3682[_0x0b9ebb];
    }

    function _0x3ae712(address _0x6e4860, uint256 _0x3e8b02) public returns (bool _0x9f58b8) {
        _0x686a41[msg.sender][_0x6e4860] = _0x3e8b02;
        emit Approval(msg.sender, _0x6e4860, _0x3e8b02);
        return true;
    }

    function _0x326f09(address _0x0b9ebb, address _0x6e4860) public constant returns (uint256 _0x4de5fe) {
      return _0x686a41[_0x0b9ebb][_0x6e4860];
    }

    mapping (address => uint256) _0x0d3682;
    mapping (address => mapping (address => uint256)) _0x686a41;
}

contract HumanStandardToken is StandardToken {


    string public _0x7e0d6c;
    uint8 public _0x2e452b;
    string public _0x82b695;
    string public _0x956e89 = 'H0.1';

    constructor(
        uint256 _0xbeb5e6,
        string _0xe05d09,
        uint8 _0xfb2206,
        string _0x3b6d37
        ) public {
        _0x0d3682[msg.sender] = _0xbeb5e6;
        _0xf6a3e9 = _0xbeb5e6;
        _0x7e0d6c = _0xe05d09;
        _0x2e452b = _0xfb2206;
        _0x82b695 = _0x3b6d37;
    }


    function _0xcbae96(address _0x6e4860, uint256 _0x3e8b02, bytes _0xb1dfa8) public returns (bool _0x9f58b8) {
        _0x686a41[msg.sender][_0x6e4860] = _0x3e8b02;
        emit Approval(msg.sender, _0x6e4860, _0x3e8b02);


        require(_0x6e4860.call(bytes4(bytes32(_0xd1f68c("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x3e8b02, this, _0xb1dfa8));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant VERSION = "0.0.1";

    uint256 public _0xf1c9ea = 0;

    event DidLCOpen (
        bytes32 indexed _0x879898,
        address indexed _0xd7a0d9,
        address indexed _0x0d1810,
        uint256 _0x90d3b4,
        address _0x4554a7,
        uint256 _0x9dfa3a,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed _0x879898,
        uint256 _0xca1900,
        uint256 _0x966241
    );

    event DidLCDeposit (
        bytes32 indexed _0x879898,
        address indexed _0x98aed8,
        uint256 _0x4f1ce8,
        bool _0x3cad99
    );

    event DidLCUpdateState (
        bytes32 indexed _0x879898,
        uint256 _0x1fc253,
        uint256 _0x8b9b1e,
        uint256 _0x90d3b4,
        uint256 _0x9dfa3a,
        uint256 _0xca1900,
        uint256 _0x966241,
        bytes32 _0x3e751e,
        uint256 _0x55c6df
    );

    event DidLCClose (
        bytes32 indexed _0x879898,
        uint256 _0x1fc253,
        uint256 _0x90d3b4,
        uint256 _0x9dfa3a,
        uint256 _0xca1900,
        uint256 _0x966241
    );

    event DidVCInit (
        bytes32 indexed _0x9186d2,
        bytes32 indexed _0xabd17f,
        bytes _0xedcf15,
        uint256 _0x1fc253,
        address _0xd7a0d9,
        address _0xbc7ea6,
        uint256 _0x02db5c,
        uint256 _0x6866bb
    );

    event DidVCSettle (
        bytes32 indexed _0x9186d2,
        bytes32 indexed _0xabd17f,
        uint256 _0xfa270b,
        uint256 _0xb47c24,
        uint256 _0x0da523,
        address _0xd816db,
        uint256 _0x724326
    );

    event DidVCClose(
        bytes32 indexed _0x9186d2,
        bytes32 indexed _0xabd17f,
        uint256 _0x02db5c,
        uint256 _0x6866bb
    );

    struct Channel {

        address[2] _0x295095;
        uint256[4] _0xb634bd;
        uint256[4] _0x51e490;
        uint256[2] _0xf4e552;
        uint256 _0x1fc253;
        uint256 _0x008331;
        bytes32 VCrootHash;
        uint256 LCopenTimeout;
        uint256 _0x55c6df;
        bool _0x95d438;
        bool _0xa9f4fd;
        uint256 _0xbd32e3;
        HumanStandardToken _0x4554a7;
    }


    struct VirtualChannel {
        bool _0x5b0383;
        bool _0xd21cf2;
        uint256 _0x1fc253;
        address _0xd816db;
        uint256 _0x724326;

        address _0xd7a0d9;
        address _0xbc7ea6;
        address _0x0d1810;
        uint256[2] _0xb634bd;
        uint256[2] _0x51e490;
        uint256[2] _0x832e46;
        HumanStandardToken _0x4554a7;
    }

    mapping(bytes32 => VirtualChannel) public _0x1a6c3f;
    mapping(bytes32 => Channel) public Channels;

    function _0x22b681(
        bytes32 _0x42b88e,
        address _0x4fdae7,
        uint256 _0xb9e2bf,
        address _0x930ca6,
        uint256[2] _0x92c3a3
    )
        public
        payable
    {
        require(Channels[_0x42b88e]._0x295095[0] == address(0), "Channel has already been created.");
        require(_0x4fdae7 != 0x0, "No partyI address provided to LC creation");
        require(_0x92c3a3[0] >= 0 && _0x92c3a3[1] >= 0, "Balances cannot be negative");


        Channels[_0x42b88e]._0x295095[0] = msg.sender;
        Channels[_0x42b88e]._0x295095[1] = _0x4fdae7;

        if(_0x92c3a3[0] != 0) {
            require(msg.value == _0x92c3a3[0], "Eth balance does not match sent value");
            Channels[_0x42b88e]._0xb634bd[0] = msg.value;
        }
        if(_0x92c3a3[1] != 0) {
            Channels[_0x42b88e]._0x4554a7 = HumanStandardToken(_0x930ca6);
            require(Channels[_0x42b88e]._0x4554a7._0xdf85c3(msg.sender, this, _0x92c3a3[1]),"CreateChannel: token transfer failure");
            Channels[_0x42b88e]._0x51e490[0] = _0x92c3a3[1];
        }

        Channels[_0x42b88e]._0x1fc253 = 0;
        Channels[_0x42b88e]._0x008331 = _0xb9e2bf;


        Channels[_0x42b88e].LCopenTimeout = _0xc76ddc + _0xb9e2bf;
        Channels[_0x42b88e]._0xf4e552 = _0x92c3a3;

        emit DidLCOpen(_0x42b88e, msg.sender, _0x4fdae7, _0x92c3a3[0], _0x930ca6, _0x92c3a3[1], Channels[_0x42b88e].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _0x42b88e) public {
        require(msg.sender == Channels[_0x42b88e]._0x295095[0] && Channels[_0x42b88e]._0x95d438 == false);
        require(_0xc76ddc > Channels[_0x42b88e].LCopenTimeout);

        if(Channels[_0x42b88e]._0xf4e552[0] != 0) {
            Channels[_0x42b88e]._0x295095[0].transfer(Channels[_0x42b88e]._0xb634bd[0]);
        }
        if(Channels[_0x42b88e]._0xf4e552[1] != 0) {
            require(Channels[_0x42b88e]._0x4554a7.transfer(Channels[_0x42b88e]._0x295095[0], Channels[_0x42b88e]._0x51e490[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_0x42b88e, 0, Channels[_0x42b88e]._0xb634bd[0], Channels[_0x42b88e]._0x51e490[0], 0, 0);


        delete Channels[_0x42b88e];
    }

    function _0x891b68(bytes32 _0x42b88e, uint256[2] _0x92c3a3) public payable {

        require(Channels[_0x42b88e]._0x95d438 == false);
        require(msg.sender == Channels[_0x42b88e]._0x295095[1]);

        if(_0x92c3a3[0] != 0) {
            require(msg.value == _0x92c3a3[0], "state balance does not match sent value");
            Channels[_0x42b88e]._0xb634bd[1] = msg.value;
        }
        if(_0x92c3a3[1] != 0) {
            require(Channels[_0x42b88e]._0x4554a7._0xdf85c3(msg.sender, this, _0x92c3a3[1]),"joinChannel: token transfer failure");
            Channels[_0x42b88e]._0x51e490[1] = _0x92c3a3[1];
        }

        Channels[_0x42b88e]._0xf4e552[0]+=_0x92c3a3[0];
        Channels[_0x42b88e]._0xf4e552[1]+=_0x92c3a3[1];

        Channels[_0x42b88e]._0x95d438 = true;
        _0xf1c9ea++;

        emit DidLCJoin(_0x42b88e, _0x92c3a3[0], _0x92c3a3[1]);
    }


    function _0x4f1ce8(bytes32 _0x42b88e, address _0x98aed8, uint256 _0x417083, bool _0x3cad99) public payable {
        require(Channels[_0x42b88e]._0x95d438 == true, "Tried adding funds to a closed channel");
        require(_0x98aed8 == Channels[_0x42b88e]._0x295095[0] || _0x98aed8 == Channels[_0x42b88e]._0x295095[1]);


        if (Channels[_0x42b88e]._0x295095[0] == _0x98aed8) {
            if(_0x3cad99) {
                require(Channels[_0x42b88e]._0x4554a7._0xdf85c3(msg.sender, this, _0x417083),"deposit: token transfer failure");
                Channels[_0x42b88e]._0x51e490[2] += _0x417083;
            } else {
                require(msg.value == _0x417083, "state balance does not match sent value");
                Channels[_0x42b88e]._0xb634bd[2] += msg.value;
            }
        }

        if (Channels[_0x42b88e]._0x295095[1] == _0x98aed8) {
            if(_0x3cad99) {
                require(Channels[_0x42b88e]._0x4554a7._0xdf85c3(msg.sender, this, _0x417083),"deposit: token transfer failure");
                Channels[_0x42b88e]._0x51e490[3] += _0x417083;
            } else {
                require(msg.value == _0x417083, "state balance does not match sent value");
                Channels[_0x42b88e]._0xb634bd[3] += msg.value;
            }
        }

        emit DidLCDeposit(_0x42b88e, _0x98aed8, _0x417083, _0x3cad99);
    }


    function _0xed49db(
        bytes32 _0x42b88e,
        uint256 _0x972f67,
        uint256[4] _0x92c3a3,
        string _0x953058,
        string _0xf13d90
    )
        public
    {


        require(Channels[_0x42b88e]._0x95d438 == true);
        uint256 _0x7076f0 = Channels[_0x42b88e]._0xf4e552[0] + Channels[_0x42b88e]._0xb634bd[2] + Channels[_0x42b88e]._0xb634bd[3];
        uint256 _0x2ca2f5 = Channels[_0x42b88e]._0xf4e552[1] + Channels[_0x42b88e]._0x51e490[2] + Channels[_0x42b88e]._0x51e490[3];
        require(_0x7076f0 == _0x92c3a3[0] + _0x92c3a3[1]);
        require(_0x2ca2f5 == _0x92c3a3[2] + _0x92c3a3[3]);

        bytes32 _0x1421b3 = _0xd1f68c(
            abi._0x775388(
                _0x42b88e,
                true,
                _0x972f67,
                uint256(0),
                bytes32(0x0),
                Channels[_0x42b88e]._0x295095[0],
                Channels[_0x42b88e]._0x295095[1],
                _0x92c3a3[0],
                _0x92c3a3[1],
                _0x92c3a3[2],
                _0x92c3a3[3]
            )
        );

        require(Channels[_0x42b88e]._0x295095[0] == ECTools._0x9821e8(_0x1421b3, _0x953058));
        require(Channels[_0x42b88e]._0x295095[1] == ECTools._0x9821e8(_0x1421b3, _0xf13d90));

        Channels[_0x42b88e]._0x95d438 = false;

        if(_0x92c3a3[0] != 0 || _0x92c3a3[1] != 0) {
            Channels[_0x42b88e]._0x295095[0].transfer(_0x92c3a3[0]);
            Channels[_0x42b88e]._0x295095[1].transfer(_0x92c3a3[1]);
        }

        if(_0x92c3a3[2] != 0 || _0x92c3a3[3] != 0) {
            require(Channels[_0x42b88e]._0x4554a7.transfer(Channels[_0x42b88e]._0x295095[0], _0x92c3a3[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_0x42b88e]._0x4554a7.transfer(Channels[_0x42b88e]._0x295095[1], _0x92c3a3[3]),"happyCloseChannel: token transfer failure");
        }

        _0xf1c9ea--;

        emit DidLCClose(_0x42b88e, _0x972f67, _0x92c3a3[0], _0x92c3a3[1], _0x92c3a3[2], _0x92c3a3[3]);
    }


    function _0xbcef4c(
        bytes32 _0x42b88e,
        uint256[6] _0x67327b,
        bytes32 _0xf039fe,
        string _0x953058,
        string _0xf13d90
    )
        public
    {
        Channel storage _0x372d7a = Channels[_0x42b88e];
        require(_0x372d7a._0x95d438);
        require(_0x372d7a._0x1fc253 < _0x67327b[0]);
        require(_0x372d7a._0xb634bd[0] + _0x372d7a._0xb634bd[1] >= _0x67327b[2] + _0x67327b[3]);
        require(_0x372d7a._0x51e490[0] + _0x372d7a._0x51e490[1] >= _0x67327b[4] + _0x67327b[5]);

        if(_0x372d7a._0xa9f4fd == true) {
            require(_0x372d7a._0x55c6df > _0xc76ddc);
        }

        bytes32 _0x1421b3 = _0xd1f68c(
            abi._0x775388(
                _0x42b88e,
                false,
                _0x67327b[0],
                _0x67327b[1],
                _0xf039fe,
                _0x372d7a._0x295095[0],
                _0x372d7a._0x295095[1],
                _0x67327b[2],
                _0x67327b[3],
                _0x67327b[4],
                _0x67327b[5]
            )
        );

        require(_0x372d7a._0x295095[0] == ECTools._0x9821e8(_0x1421b3, _0x953058));
        require(_0x372d7a._0x295095[1] == ECTools._0x9821e8(_0x1421b3, _0xf13d90));


        _0x372d7a._0x1fc253 = _0x67327b[0];
        _0x372d7a._0xbd32e3 = _0x67327b[1];
        _0x372d7a._0xb634bd[0] = _0x67327b[2];
        _0x372d7a._0xb634bd[1] = _0x67327b[3];
        _0x372d7a._0x51e490[0] = _0x67327b[4];
        _0x372d7a._0x51e490[1] = _0x67327b[5];
        _0x372d7a.VCrootHash = _0xf039fe;
        _0x372d7a._0xa9f4fd = true;
        _0x372d7a._0x55c6df = _0xc76ddc + _0x372d7a._0x008331;


        emit DidLCUpdateState (
            _0x42b88e,
            _0x67327b[0],
            _0x67327b[1],
            _0x67327b[2],
            _0x67327b[3],
            _0x67327b[4],
            _0x67327b[5],
            _0xf039fe,
            _0x372d7a._0x55c6df
        );
    }


    function _0x10cff7(
        bytes32 _0x42b88e,
        bytes32 _0x3d6929,
        bytes _0xe00797,
        address _0xaf90df,
        address _0xb45901,
        uint256[2] _0xaecb95,
        uint256[4] _0x92c3a3,
        string _0x465684
    )
        public
    {
        require(Channels[_0x42b88e]._0x95d438, "LC is closed.");

        require(!_0x1a6c3f[_0x3d6929]._0x5b0383, "VC is closed.");

        require(Channels[_0x42b88e]._0x55c6df < _0xc76ddc, "LC timeout not over.");

        require(_0x1a6c3f[_0x3d6929]._0x724326 == 0);

        bytes32 _0x7e006f = _0xd1f68c(
            abi._0x775388(_0x3d6929, uint256(0), _0xaf90df, _0xb45901, _0xaecb95[0], _0xaecb95[1], _0x92c3a3[0], _0x92c3a3[1], _0x92c3a3[2], _0x92c3a3[3])
        );


        require(_0xaf90df == ECTools._0x9821e8(_0x7e006f, _0x465684));


        require(_0x18077b(_0x7e006f, _0xe00797, Channels[_0x42b88e].VCrootHash) == true);

        _0x1a6c3f[_0x3d6929]._0xd7a0d9 = _0xaf90df;
        _0x1a6c3f[_0x3d6929]._0xbc7ea6 = _0xb45901;
        _0x1a6c3f[_0x3d6929]._0x1fc253 = uint256(0);
        _0x1a6c3f[_0x3d6929]._0xb634bd[0] = _0x92c3a3[0];
        _0x1a6c3f[_0x3d6929]._0xb634bd[1] = _0x92c3a3[1];
        _0x1a6c3f[_0x3d6929]._0x51e490[0] = _0x92c3a3[2];
        _0x1a6c3f[_0x3d6929]._0x51e490[1] = _0x92c3a3[3];
        _0x1a6c3f[_0x3d6929]._0x832e46 = _0xaecb95;
        _0x1a6c3f[_0x3d6929]._0x724326 = _0xc76ddc + Channels[_0x42b88e]._0x008331;
        _0x1a6c3f[_0x3d6929]._0xd21cf2 = true;

        emit DidVCInit(_0x42b88e, _0x3d6929, _0xe00797, uint256(0), _0xaf90df, _0xb45901, _0x92c3a3[0], _0x92c3a3[1]);
    }


    function _0xd0ddc1(
        bytes32 _0x42b88e,
        bytes32 _0x3d6929,
        uint256 _0xfa270b,
        address _0xaf90df,
        address _0xb45901,
        uint256[4] _0xf37f9f,
        string _0x465684
    )
        public
    {
        require(Channels[_0x42b88e]._0x95d438, "LC is closed.");

        require(!_0x1a6c3f[_0x3d6929]._0x5b0383, "VC is closed.");
        require(_0x1a6c3f[_0x3d6929]._0x1fc253 < _0xfa270b, "VC sequence is higher than update sequence.");
        require(
            _0x1a6c3f[_0x3d6929]._0xb634bd[1] < _0xf37f9f[1] && _0x1a6c3f[_0x3d6929]._0x51e490[1] < _0xf37f9f[3],
            "State updates may only increase recipient balance."
        );
        require(
            _0x1a6c3f[_0x3d6929]._0x832e46[0] == _0xf37f9f[0] + _0xf37f9f[1] &&
            _0x1a6c3f[_0x3d6929]._0x832e46[1] == _0xf37f9f[2] + _0xf37f9f[3],
            "Incorrect balances for bonded amount");


        require(Channels[_0x42b88e]._0x55c6df < _0xc76ddc);

        bytes32 _0x28cad4 = _0xd1f68c(
            abi._0x775388(
                _0x3d6929,
                _0xfa270b,
                _0xaf90df,
                _0xb45901,
                _0x1a6c3f[_0x3d6929]._0x832e46[0],
                _0x1a6c3f[_0x3d6929]._0x832e46[1],
                _0xf37f9f[0],
                _0xf37f9f[1],
                _0xf37f9f[2],
                _0xf37f9f[3]
            )
        );


        require(_0x1a6c3f[_0x3d6929]._0xd7a0d9 == ECTools._0x9821e8(_0x28cad4, _0x465684));


        _0x1a6c3f[_0x3d6929]._0xd816db = msg.sender;
        _0x1a6c3f[_0x3d6929]._0x1fc253 = _0xfa270b;


        _0x1a6c3f[_0x3d6929]._0xb634bd[0] = _0xf37f9f[0];
        _0x1a6c3f[_0x3d6929]._0xb634bd[1] = _0xf37f9f[1];
        _0x1a6c3f[_0x3d6929]._0x51e490[0] = _0xf37f9f[2];
        _0x1a6c3f[_0x3d6929]._0x51e490[1] = _0xf37f9f[3];

        _0x1a6c3f[_0x3d6929]._0x724326 = _0xc76ddc + Channels[_0x42b88e]._0x008331;

        emit DidVCSettle(_0x42b88e, _0x3d6929, _0xfa270b, _0xf37f9f[0], _0xf37f9f[1], msg.sender, _0x1a6c3f[_0x3d6929]._0x724326);
    }

    function _0x84a040(bytes32 _0x42b88e, bytes32 _0x3d6929) public {

        require(Channels[_0x42b88e]._0x95d438, "LC is closed.");
        require(_0x1a6c3f[_0x3d6929]._0xd21cf2, "VC is not in settlement state.");
        require(_0x1a6c3f[_0x3d6929]._0x724326 < _0xc76ddc, "Update vc timeout has not elapsed.");
        require(!_0x1a6c3f[_0x3d6929]._0x5b0383, "VC is already closed");

        Channels[_0x42b88e]._0xbd32e3--;

        _0x1a6c3f[_0x3d6929]._0x5b0383 = true;


        if(_0x1a6c3f[_0x3d6929]._0xd7a0d9 == Channels[_0x42b88e]._0x295095[0]) {
            Channels[_0x42b88e]._0xb634bd[0] += _0x1a6c3f[_0x3d6929]._0xb634bd[0];
            Channels[_0x42b88e]._0xb634bd[1] += _0x1a6c3f[_0x3d6929]._0xb634bd[1];

            Channels[_0x42b88e]._0x51e490[0] += _0x1a6c3f[_0x3d6929]._0x51e490[0];
            Channels[_0x42b88e]._0x51e490[1] += _0x1a6c3f[_0x3d6929]._0x51e490[1];
        } else if (_0x1a6c3f[_0x3d6929]._0xbc7ea6 == Channels[_0x42b88e]._0x295095[0]) {
            Channels[_0x42b88e]._0xb634bd[0] += _0x1a6c3f[_0x3d6929]._0xb634bd[1];
            Channels[_0x42b88e]._0xb634bd[1] += _0x1a6c3f[_0x3d6929]._0xb634bd[0];

            Channels[_0x42b88e]._0x51e490[0] += _0x1a6c3f[_0x3d6929]._0x51e490[1];
            Channels[_0x42b88e]._0x51e490[1] += _0x1a6c3f[_0x3d6929]._0x51e490[0];
        }

        emit DidVCClose(_0x42b88e, _0x3d6929, _0x1a6c3f[_0x3d6929]._0x51e490[0], _0x1a6c3f[_0x3d6929]._0x51e490[1]);
    }


    function _0x8068a4(bytes32 _0x42b88e) public {
        Channel storage _0x372d7a = Channels[_0x42b88e];


        require(_0x372d7a._0x95d438, "Channel is not open");
        require(_0x372d7a._0xa9f4fd == true);
        require(_0x372d7a._0xbd32e3 == 0);
        require(_0x372d7a._0x55c6df < _0xc76ddc, "LC timeout over.");


        uint256 _0x7076f0 = _0x372d7a._0xf4e552[0] + _0x372d7a._0xb634bd[2] + _0x372d7a._0xb634bd[3];
        uint256 _0x2ca2f5 = _0x372d7a._0xf4e552[1] + _0x372d7a._0x51e490[2] + _0x372d7a._0x51e490[3];

        uint256 _0x2e1a9f = _0x372d7a._0xb634bd[0] + _0x372d7a._0xb634bd[1];
        uint256 _0x8844de = _0x372d7a._0x51e490[0] + _0x372d7a._0x51e490[1];

        if(_0x2e1a9f < _0x7076f0) {
            _0x372d7a._0xb634bd[0]+=_0x372d7a._0xb634bd[2];
            _0x372d7a._0xb634bd[1]+=_0x372d7a._0xb634bd[3];
        } else {
            require(_0x2e1a9f == _0x7076f0);
        }

        if(_0x8844de < _0x2ca2f5) {
            _0x372d7a._0x51e490[0]+=_0x372d7a._0x51e490[2];
            _0x372d7a._0x51e490[1]+=_0x372d7a._0x51e490[3];
        } else {
            require(_0x8844de == _0x2ca2f5);
        }

        uint256 _0xda1a87 = _0x372d7a._0xb634bd[0];
        uint256 _0xd694b5 = _0x372d7a._0xb634bd[1];
        uint256 _0xda6a51 = _0x372d7a._0x51e490[0];
        uint256 _0x42828d = _0x372d7a._0x51e490[1];

        _0x372d7a._0xb634bd[0] = 0;
        _0x372d7a._0xb634bd[1] = 0;
        _0x372d7a._0x51e490[0] = 0;
        _0x372d7a._0x51e490[1] = 0;

        if(_0xda1a87 != 0 || _0xd694b5 != 0) {
            _0x372d7a._0x295095[0].transfer(_0xda1a87);
            _0x372d7a._0x295095[1].transfer(_0xd694b5);
        }

        if(_0xda6a51 != 0 || _0x42828d != 0) {
            require(
                _0x372d7a._0x4554a7.transfer(_0x372d7a._0x295095[0], _0xda6a51),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                _0x372d7a._0x4554a7.transfer(_0x372d7a._0x295095[1], _0x42828d),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        _0x372d7a._0x95d438 = false;
        _0xf1c9ea--;

        emit DidLCClose(_0x42b88e, _0x372d7a._0x1fc253, _0xda1a87, _0xd694b5, _0xda6a51, _0x42828d);
    }

    function _0x18077b(bytes32 _0x0d7044, bytes _0xe00797, bytes32 _0x1e75c3) internal pure returns (bool) {
        bytes32 _0x83c714 = _0x0d7044;
        bytes32 _0x0b730c;

        for (uint256 i = 64; i <= _0xe00797.length; i += 32) {
            assembly { _0x0b730c := mload(add(_0xe00797, i)) }

            if (_0x83c714 < _0x0b730c) {
                if (1 == 1) { _0x83c714 = _0xd1f68c(abi._0x775388(_0x83c714, _0x0b730c)); }
            } else {
                _0x83c714 = _0xd1f68c(abi._0x775388(_0x0b730c, _0x83c714));
            }
        }

        return _0x83c714 == _0x1e75c3;
    }


    function _0x877f03(bytes32 _0x4b1638) public view returns (
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
        Channel memory _0x372d7a = Channels[_0x4b1638];
        return (
            _0x372d7a._0x295095,
            _0x372d7a._0xb634bd,
            _0x372d7a._0x51e490,
            _0x372d7a._0xf4e552,
            _0x372d7a._0x1fc253,
            _0x372d7a._0x008331,
            _0x372d7a.VCrootHash,
            _0x372d7a.LCopenTimeout,
            _0x372d7a._0x55c6df,
            _0x372d7a._0x95d438,
            _0x372d7a._0xa9f4fd,
            _0x372d7a._0xbd32e3
        );
    }

    function _0x793119(bytes32 _0x4b1638) public view returns(
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
        VirtualChannel memory _0x2e23e3 = _0x1a6c3f[_0x4b1638];
        return(
            _0x2e23e3._0x5b0383,
            _0x2e23e3._0xd21cf2,
            _0x2e23e3._0x1fc253,
            _0x2e23e3._0xd816db,
            _0x2e23e3._0x724326,
            _0x2e23e3._0xd7a0d9,
            _0x2e23e3._0xbc7ea6,
            _0x2e23e3._0x0d1810,
            _0x2e23e3._0xb634bd,
            _0x2e23e3._0x51e490,
            _0x2e23e3._0x832e46
        );
    }
}