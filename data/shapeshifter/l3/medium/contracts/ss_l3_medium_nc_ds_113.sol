contract TokenInterface {
    mapping (address => uint256) _0xf26729;
    mapping (address => mapping (address => uint256)) _0xe8c88c;


    uint256 public _0xeffac9;


    function _0xf51878(address _0xaba3ef) constant returns (uint256 balance);


    function transfer(address _0xf4b9c5, uint256 _0x35af93) returns (bool _0x80ee41);


    function _0x644da0(address _0x0c8204, address _0xf4b9c5, uint256 _0x35af93) returns (bool _0x80ee41);


    function _0x102131(address _0x5f3d80, uint256 _0x35af93) returns (bool _0x80ee41);


    function _0x6e80f1(
        address _0xaba3ef,
        address _0x5f3d80
    ) constant returns (uint256 _0xc5f60e);

    event Transfer(address indexed _0x0c8204, address indexed _0xf4b9c5, uint256 _0x35af93);
    event Approval(
        address indexed _0xaba3ef,
        address indexed _0x5f3d80,
        uint256 _0x35af93
    );
}

contract Token is TokenInterface {


    modifier _0x309e2b() {if (msg.value > 0) throw; _;}

    function _0xf51878(address _0xaba3ef) constant returns (uint256 balance) {
        return _0xf26729[_0xaba3ef];
    }

    function transfer(address _0xf4b9c5, uint256 _0x35af93) _0x309e2b returns (bool _0x80ee41) {
        if (_0xf26729[msg.sender] >= _0x35af93 && _0x35af93 > 0) {
            _0xf26729[msg.sender] -= _0x35af93;
            _0xf26729[_0xf4b9c5] += _0x35af93;
            Transfer(msg.sender, _0xf4b9c5, _0x35af93);
            return true;
        } else {
           return false;
        }
    }

    function _0x644da0(
        address _0x0c8204,
        address _0xf4b9c5,
        uint256 _0x35af93
    ) _0x309e2b returns (bool _0x80ee41) {

        if (_0xf26729[_0x0c8204] >= _0x35af93
            && _0xe8c88c[_0x0c8204][msg.sender] >= _0x35af93
            && _0x35af93 > 0) {

            _0xf26729[_0xf4b9c5] += _0x35af93;
            _0xf26729[_0x0c8204] -= _0x35af93;
            _0xe8c88c[_0x0c8204][msg.sender] -= _0x35af93;
            Transfer(_0x0c8204, _0xf4b9c5, _0x35af93);
            return true;
        } else {
            return false;
        }
    }

    function _0x102131(address _0x5f3d80, uint256 _0x35af93) returns (bool _0x80ee41) {
        _0xe8c88c[msg.sender][_0x5f3d80] = _0x35af93;
        Approval(msg.sender, _0x5f3d80, _0x35af93);
        return true;
    }

    function _0x6e80f1(address _0xaba3ef, address _0x5f3d80) constant returns (uint256 _0xc5f60e) {
        return _0xe8c88c[_0xaba3ef][_0x5f3d80];
    }
}

contract ManagedAccountInterface {

    address public _0xfe0940;

    bool public _0xfe017f;

    uint public _0xcc9182;


    function _0x6bf5ce(address _0x65c70a, uint _0x35af93) returns (bool);

    event PayOut(address indexed _0x65c70a, uint _0x35af93);
}

contract ManagedAccount is ManagedAccountInterface{


    function ManagedAccount(address _0xaba3ef, bool _0x4fe1c0) {
        _0xfe0940 = _0xaba3ef;
        _0xfe017f = _0x4fe1c0;
    }


    function() {
        _0xcc9182 += msg.value;
    }

    function _0x6bf5ce(address _0x65c70a, uint _0x35af93) returns (bool) {
        if (msg.sender != _0xfe0940 || msg.value > 0 || (_0xfe017f && _0x65c70a != _0xfe0940))
            throw;
        if (_0x65c70a.call.value(_0x35af93)()) {
            PayOut(_0x65c70a, _0x35af93);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {


    uint public _0x237ae6;


    uint public _0x3bf5a8;

    bool public _0xcd62bc;


    address public _0xa08d4d;


    ManagedAccount public _0x1f4aee;

    mapping (address => uint256) _0xba2f69;


    function _0x3865de(address _0xcd11a7) returns (bool _0x80ee41);


    function _0x2046d0();


    function _0x7a04de() constant returns (uint _0x7a04de);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed _0x5c09b8, uint _0xc86254);
    event Refund(address indexed _0x5c09b8, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint _0x0c1e2e,
        uint _0x390573,
        address _0x898780) {

        _0x237ae6 = _0x390573;
        _0x3bf5a8 = _0x0c1e2e;
        _0xa08d4d = _0x898780;
        _0x1f4aee = new ManagedAccount(address(this), true);
    }

    function _0x3865de(address _0xcd11a7) returns (bool _0x80ee41) {
        if (_0x16131f < _0x237ae6 && msg.value > 0
            && (_0xa08d4d == 0 || _0xa08d4d == msg.sender)) {

            uint _0x4badf9 = (msg.value * 20) / _0x7a04de();
            _0x1f4aee.call.value(msg.value - _0x4badf9)();
            _0xf26729[_0xcd11a7] += _0x4badf9;
            _0xeffac9 += _0x4badf9;
            _0xba2f69[_0xcd11a7] += msg.value;
            CreatedToken(_0xcd11a7, _0x4badf9);
            if (_0xeffac9 >= _0x3bf5a8 && !_0xcd62bc) {
                _0xcd62bc = true;
                FuelingToDate(_0xeffac9);
            }
            return true;
        }
        throw;
    }

    function _0x2046d0() _0x309e2b {
        if (_0x16131f > _0x237ae6 && !_0xcd62bc) {

            if (_0x1f4aee.balance >= _0x1f4aee._0xcc9182())
                _0x1f4aee._0x6bf5ce(address(this), _0x1f4aee._0xcc9182());


            if (msg.sender.call.value(_0xba2f69[msg.sender])()) {
                Refund(msg.sender, _0xba2f69[msg.sender]);
                _0xeffac9 -= _0xf26729[msg.sender];
                _0xf26729[msg.sender] = 0;
                _0xba2f69[msg.sender] = 0;
            }
        }
    }

    function _0x7a04de() constant returns (uint _0x7a04de) {


        if (_0x237ae6 - 2 weeks > _0x16131f) {
            return 20;

        } else if (_0x237ae6 - 4 days > _0x16131f) {
            return (20 + (_0x16131f - (_0x237ae6 - 2 weeks)) / (1 days));

        } else {
            return 30;
        }
    }
}

contract DAOInterface {


    uint constant _0x98edc8 = 40 days;

    uint constant _0x2b2d68 = 2 weeks;

    uint constant _0x0aa511 = 1 weeks;

    uint constant _0x5a9b76 = 27 days;

    uint constant _0x02f8d6 = 25 weeks;


    uint constant _0x01a357 = 10 days;


    uint constant _0x0bc363 = 100;


    Proposal[] public _0x9b5bf9;


    uint public _0xfa7c3e;

    uint  public _0xdbd1cf;


    address public _0x3df12b;

    mapping (address => bool) public _0x55348e;


    mapping (address => uint) public _0x297d78;

    uint public _0xcf706e;


    ManagedAccount public _0x09dcd4;


    ManagedAccount public DAOrewardAccount;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public _0x3dc5b0;


    mapping (address => uint) public _0xa098de;


    uint public _0x258149;


    uint _0xb732cd;


    DAO_Creator public _0x281933;


    struct Proposal {


        address _0xeb6a0e;

        uint _0xc86254;

        string _0x68c956;

        uint _0x1c132c;

        bool _0x5eb6cb;


        bool _0x587765;

        bytes32 _0xb6e1f5;


        uint _0x258149;

        bool _0x102d26;

        SplitData[] _0xbf6531;

        uint _0x1408dd;

        uint _0x8a7a3a;

        mapping (address => bool) _0xe3886f;

        mapping (address => bool) _0xebcb58;

        address _0x0b6751;
    }


    struct SplitData {

        uint _0xab97c5;

        uint _0xeffac9;

        uint _0x297d78;

        DAO _0x8dd462;
    }


    modifier _0xbb54b0 {}


    function () returns (bool _0x80ee41);


    function _0x4fdb13() returns(bool);


    function _0x950d9b(
        address _0x65c70a,
        uint _0x35af93,
        string _0xb619ef,
        bytes _0x798a5b,
        uint _0xeb3425,
        bool _0x69c816
    ) _0xbb54b0 returns (uint _0xa82900);


    function _0x5e5a4a(
        uint _0xa82900,
        address _0x65c70a,
        uint _0x35af93,
        bytes _0x798a5b
    ) constant returns (bool _0xa88e4e);


    function _0xf8c3ce(
        uint _0xa82900,
        bool _0x2bdf09
    ) _0xbb54b0 returns (uint _0xb983e0);


    function _0xecb538(
        uint _0xa82900,
        bytes _0x798a5b
    ) returns (bool _0xaa65a9);


    function _0x27ace5(
        uint _0xa82900,
        address _0x69c816
    ) returns (bool _0xaa65a9);


    function _0xed413f(address _0xc7c9bd);


    function _0xa1df66(address _0x65c70a, bool _0xc6a27e) external returns (bool _0xaa65a9);


    function _0xc9694b(uint _0x07bebf) external;


    function _0xfbe7d1(bool _0x75333f) external returns (bool _0xaa65a9);


    function _0x41b865() returns(bool _0xaa65a9);


    function _0x31f65b(address _0xb9e296) internal returns (bool _0xaa65a9);


    function _0x0d7ac3(address _0xf4b9c5, uint256 _0x35af93) returns (bool _0x80ee41);


    function _0xe1825b(
        address _0x0c8204,
        address _0xf4b9c5,
        uint256 _0x35af93
    ) returns (bool _0x80ee41);


    function _0xd5e137() returns (bool _0xaa65a9);


    function _0xd90ca4() constant returns (uint _0x14d6ca);


    function _0xc729b2(uint _0xa82900) constant returns (address _0x5f6113);


    function _0xb4c5b7(address _0xb9e296) internal returns (bool);


    function _0x176120() returns (bool);

    event ProposalAdded(
        uint indexed _0xb29661,
        address _0xeb6a0e,
        uint _0xc86254,
        bool _0x102d26,
        string _0x68c956
    );
    event Voted(uint indexed _0xb29661, bool _0xcb87c9, address indexed _0x5497ae);
    event ProposalTallied(uint indexed _0xb29661, bool _0xfb4851, uint _0xf4f86f);
    event NewCurator(address indexed _0x69c816);
    event AllowedRecipientChanged(address indexed _0x65c70a, bool _0xc6a27e);
}


contract DAO is DAOInterface, Token, TokenCreation {


    modifier _0xbb54b0 {
        if (_0xf51878(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _0xcf890f,
        DAO_Creator _0x5559f2,
        uint _0x07bebf,
        uint _0x0c1e2e,
        uint _0x390573,
        address _0x898780
    ) TokenCreation(_0x0c1e2e, _0x390573, _0x898780) {

        _0x3df12b = _0xcf890f;
        _0x281933 = _0x5559f2;
        _0x258149 = _0x07bebf;
        _0x09dcd4 = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(_0x09dcd4) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        _0xdbd1cf = _0x16131f;
        _0xfa7c3e = 5;
        _0x9b5bf9.length = 1;

        _0x55348e[address(this)] = true;
        _0x55348e[_0x3df12b] = true;
    }

    function () returns (bool _0x80ee41) {
        if (_0x16131f < _0x237ae6 + _0x98edc8 && msg.sender != address(_0x1f4aee))
            return _0x3865de(msg.sender);
        else
            return _0x4fdb13();
    }

    function _0x4fdb13() returns (bool) {
        return true;
    }

    function _0x950d9b(
        address _0x65c70a,
        uint _0x35af93,
        string _0xb619ef,
        bytes _0x798a5b,
        uint _0xeb3425,
        bool _0x69c816
    ) _0xbb54b0 returns (uint _0xa82900) {


        if (_0x69c816 && (
            _0x35af93 != 0
            || _0x798a5b.length != 0
            || _0x65c70a == _0x3df12b
            || msg.value > 0
            || _0xeb3425 < _0x0aa511)) {
            throw;
        } else if (
            !_0x69c816
            && (!_0xe769c3(_0x65c70a) || (_0xeb3425 <  _0x2b2d68))
        ) {
            throw;
        }

        if (_0xeb3425 > 8 weeks)
            throw;

        if (!_0xcd62bc
            || _0x16131f < _0x237ae6
            || (msg.value < _0x258149 && !_0x69c816)) {

            throw;
        }

        if (_0x16131f + _0xeb3425 < _0x16131f)
            throw;

        if (msg.sender == address(this))
            throw;

        _0xa82900 = _0x9b5bf9.length++;
        Proposal p = _0x9b5bf9[_0xa82900];
        p._0xeb6a0e = _0x65c70a;
        p._0xc86254 = _0x35af93;
        p._0x68c956 = _0xb619ef;
        p._0xb6e1f5 = _0xcc24fb(_0x65c70a, _0x35af93, _0x798a5b);
        p._0x1c132c = _0x16131f + _0xeb3425;
        p._0x5eb6cb = true;

        p._0x102d26 = _0x69c816;
        if (_0x69c816)
            p._0xbf6531.length++;
        p._0x0b6751 = msg.sender;
        p._0x258149 = msg.value;

        _0xb732cd += msg.value;

        ProposalAdded(
            _0xa82900,
            _0x65c70a,
            _0x35af93,
            _0x69c816,
            _0xb619ef
        );
    }

    function _0x5e5a4a(
        uint _0xa82900,
        address _0x65c70a,
        uint _0x35af93,
        bytes _0x798a5b
    ) _0x309e2b constant returns (bool _0xa88e4e) {
        Proposal p = _0x9b5bf9[_0xa82900];
        return p._0xb6e1f5 == _0xcc24fb(_0x65c70a, _0x35af93, _0x798a5b);
    }

    function _0xf8c3ce(
        uint _0xa82900,
        bool _0x2bdf09
    ) _0xbb54b0 _0x309e2b returns (uint _0xb983e0) {

        Proposal p = _0x9b5bf9[_0xa82900];
        if (p._0xe3886f[msg.sender]
            || p._0xebcb58[msg.sender]
            || _0x16131f >= p._0x1c132c) {

            throw;
        }

        if (_0x2bdf09) {
            p._0x1408dd += _0xf26729[msg.sender];
            p._0xe3886f[msg.sender] = true;
        } else {
            p._0x8a7a3a += _0xf26729[msg.sender];
            p._0xebcb58[msg.sender] = true;
        }

        if (_0xa098de[msg.sender] == 0) {
            _0xa098de[msg.sender] = _0xa82900;
        } else if (p._0x1c132c > _0x9b5bf9[_0xa098de[msg.sender]]._0x1c132c) {


            _0xa098de[msg.sender] = _0xa82900;
        }

        Voted(_0xa82900, _0x2bdf09, msg.sender);
    }

    function _0xecb538(
        uint _0xa82900,
        bytes _0x798a5b
    ) _0x309e2b returns (bool _0xaa65a9) {

        Proposal p = _0x9b5bf9[_0xa82900];

        uint _0x933909 = p._0x102d26
            ? _0x5a9b76
            : _0x01a357;

        if (p._0x5eb6cb && _0x16131f > p._0x1c132c + _0x933909) {
            _0xc7be8b(_0xa82900);
            return;
        }


        if (_0x16131f < p._0x1c132c

            || !p._0x5eb6cb

            || p._0xb6e1f5 != _0xcc24fb(p._0xeb6a0e, p._0xc86254, _0x798a5b)) {

            throw;
        }


        if (!_0xe769c3(p._0xeb6a0e)) {
            _0xc7be8b(_0xa82900);
            p._0x0b6751.send(p._0x258149);
            return;
        }

        bool _0xa35061 = true;

        if (p._0xc86254 > _0x92f72e())
            _0xa35061 = false;

        uint _0xf4f86f = p._0x1408dd + p._0x8a7a3a;


        if (_0x798a5b.length >= 4 && _0x798a5b[0] == 0x68
            && _0x798a5b[1] == 0x37 && _0x798a5b[2] == 0xff
            && _0x798a5b[3] == 0x1e
            && _0xf4f86f < _0x5b2ead(_0x92f72e() + _0x297d78[address(this)])) {

                _0xa35061 = false;
        }

        if (_0xf4f86f >= _0x5b2ead(p._0xc86254)) {
            if (!p._0x0b6751.send(p._0x258149))
                throw;

            _0xdbd1cf = _0x16131f;

            if (_0xf4f86f > _0xeffac9 / 5)
                _0xfa7c3e = 5;
        }


        if (_0xf4f86f >= _0x5b2ead(p._0xc86254) && p._0x1408dd > p._0x8a7a3a && _0xa35061) {
            if (!p._0xeb6a0e.call.value(p._0xc86254)(_0x798a5b))
                throw;

            p._0x587765 = true;
            _0xaa65a9 = true;


            if (p._0xeb6a0e != address(this) && p._0xeb6a0e != address(_0x09dcd4)
                && p._0xeb6a0e != address(DAOrewardAccount)
                && p._0xeb6a0e != address(_0x1f4aee)
                && p._0xeb6a0e != address(_0x3df12b)) {

                _0x297d78[address(this)] += p._0xc86254;
                _0xcf706e += p._0xc86254;
            }
        }

        _0xc7be8b(_0xa82900);


        ProposalTallied(_0xa82900, _0xaa65a9, _0xf4f86f);
    }

    function _0xc7be8b(uint _0xa82900) internal {
        Proposal p = _0x9b5bf9[_0xa82900];
        if (p._0x5eb6cb)
            _0xb732cd -= p._0x258149;
        p._0x5eb6cb = false;
    }

    function _0x27ace5(
        uint _0xa82900,
        address _0x69c816
    ) _0x309e2b _0xbb54b0 returns (bool _0xaa65a9) {

        Proposal p = _0x9b5bf9[_0xa82900];


        if (_0x16131f < p._0x1c132c

            || _0x16131f > p._0x1c132c + _0x5a9b76

            || p._0xeb6a0e != _0x69c816

            || !p._0x102d26

            || !p._0xe3886f[msg.sender]

            || (_0xa098de[msg.sender] != _0xa82900 && _0xa098de[msg.sender] != 0) )  {

            throw;
        }


        if (address(p._0xbf6531[0]._0x8dd462) == 0) {
            p._0xbf6531[0]._0x8dd462 = _0xdb37c7(_0x69c816);

            if (address(p._0xbf6531[0]._0x8dd462) == 0)
                throw;

            if (this.balance < _0xb732cd)
                throw;
            p._0xbf6531[0]._0xab97c5 = _0x92f72e();
            p._0xbf6531[0]._0x297d78 = _0x297d78[address(this)];
            p._0xbf6531[0]._0xeffac9 = _0xeffac9;
            p._0x587765 = true;
        }


        uint _0xfa9eb8 =
            (_0xf26729[msg.sender] * p._0xbf6531[0]._0xab97c5) /
            p._0xbf6531[0]._0xeffac9;
        if (p._0xbf6531[0]._0x8dd462._0x3865de.value(_0xfa9eb8)(msg.sender) == false)
            throw;


        uint _0x43f838 =
            (_0xf26729[msg.sender] * p._0xbf6531[0]._0x297d78) /
            p._0xbf6531[0]._0xeffac9;

        uint _0xc63904 = DAOpaidOut[address(this)] * _0x43f838 /
            _0x297d78[address(this)];

        _0x297d78[address(p._0xbf6531[0]._0x8dd462)] += _0x43f838;
        if (_0x297d78[address(this)] < _0x43f838)
            throw;
        _0x297d78[address(this)] -= _0x43f838;

        DAOpaidOut[address(p._0xbf6531[0]._0x8dd462)] += _0xc63904;
        if (DAOpaidOut[address(this)] < _0xc63904)
            throw;
        DAOpaidOut[address(this)] -= _0xc63904;


        Transfer(msg.sender, 0, _0xf26729[msg.sender]);
        _0x31f65b(msg.sender);
        _0xeffac9 -= _0xf26729[msg.sender];
        _0xf26729[msg.sender] = 0;
        _0x3dc5b0[msg.sender] = 0;
        return true;
    }

    function _0xed413f(address _0xc7c9bd){
        if (msg.sender != address(this) || !_0x55348e[_0xc7c9bd]) return;

        if (!_0xc7c9bd.call.value(address(this).balance)()) {
            throw;
        }


        _0x297d78[_0xc7c9bd] += _0x297d78[address(this)];
        _0x297d78[address(this)] = 0;
        DAOpaidOut[_0xc7c9bd] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function _0xfbe7d1(bool _0x75333f) external _0x309e2b returns (bool _0xaa65a9) {
        DAO _0xadace9 = DAO(msg.sender);

        if ((_0x297d78[msg.sender] * DAOrewardAccount._0xcc9182()) /
            _0xcf706e < DAOpaidOut[msg.sender])
            throw;

        uint _0xa4f5bf =
            (_0x297d78[msg.sender] * DAOrewardAccount._0xcc9182()) /
            _0xcf706e - DAOpaidOut[msg.sender];
        if(_0x75333f) {
            if (!DAOrewardAccount._0x6bf5ce(_0xadace9._0x09dcd4(), _0xa4f5bf))
                throw;
            }
        else {
            if (!DAOrewardAccount._0x6bf5ce(_0xadace9, _0xa4f5bf))
                throw;
        }
        DAOpaidOut[msg.sender] += _0xa4f5bf;
        return true;
    }

    function _0x41b865() _0x309e2b returns (bool _0xaa65a9) {
        return _0x31f65b(msg.sender);
    }

    function _0x31f65b(address _0xb9e296) _0x309e2b internal returns (bool _0xaa65a9) {
        if ((_0xf51878(_0xb9e296) * _0x09dcd4._0xcc9182()) / _0xeffac9 < _0x3dc5b0[_0xb9e296])
            throw;

        uint _0xa4f5bf =
            (_0xf51878(_0xb9e296) * _0x09dcd4._0xcc9182()) / _0xeffac9 - _0x3dc5b0[_0xb9e296];
        if (!_0x09dcd4._0x6bf5ce(_0xb9e296, _0xa4f5bf))
            throw;
        _0x3dc5b0[_0xb9e296] += _0xa4f5bf;
        return true;
    }

    function transfer(address _0xf4b9c5, uint256 _0x89ac2e) returns (bool _0x80ee41) {
        if (_0xcd62bc
            && _0x16131f > _0x237ae6
            && !_0xb4c5b7(msg.sender)
            && _0x068d8b(msg.sender, _0xf4b9c5, _0x89ac2e)
            && super.transfer(_0xf4b9c5, _0x89ac2e)) {

            return true;
        } else {
            throw;
        }
    }

    function _0x0d7ac3(address _0xf4b9c5, uint256 _0x89ac2e) returns (bool _0x80ee41) {
        if (!_0x41b865())
            throw;
        return transfer(_0xf4b9c5, _0x89ac2e);
    }

    function _0x644da0(address _0x0c8204, address _0xf4b9c5, uint256 _0x89ac2e) returns (bool _0x80ee41) {
        if (_0xcd62bc
            && _0x16131f > _0x237ae6
            && !_0xb4c5b7(_0x0c8204)
            && _0x068d8b(_0x0c8204, _0xf4b9c5, _0x89ac2e)
            && super._0x644da0(_0x0c8204, _0xf4b9c5, _0x89ac2e)) {

            return true;
        } else {
            throw;
        }
    }

    function _0xe1825b(
        address _0x0c8204,
        address _0xf4b9c5,
        uint256 _0x89ac2e
    ) returns (bool _0x80ee41) {

        if (!_0x31f65b(_0x0c8204))
            throw;
        return _0x644da0(_0x0c8204, _0xf4b9c5, _0x89ac2e);
    }

    function _0x068d8b(
        address _0x0c8204,
        address _0xf4b9c5,
        uint256 _0x89ac2e
    ) internal returns (bool _0x80ee41) {

        uint _0x068d8b = _0x3dc5b0[_0x0c8204] * _0x89ac2e / _0xf51878(_0x0c8204);
        if (_0x068d8b > _0x3dc5b0[_0x0c8204])
            throw;
        _0x3dc5b0[_0x0c8204] -= _0x068d8b;
        _0x3dc5b0[_0xf4b9c5] += _0x068d8b;
        return true;
    }

    function _0xc9694b(uint _0x07bebf) _0x309e2b external {
        if (msg.sender != address(this) || _0x07bebf > (_0x92f72e() + _0x297d78[address(this)])
            / _0x0bc363) {

            throw;
        }
        if (true) { _0x258149 = _0x07bebf; }
    }

    function _0xa1df66(address _0x65c70a, bool _0xc6a27e) _0x309e2b external returns (bool _0xaa65a9) {
        if (msg.sender != _0x3df12b)
            throw;
        _0x55348e[_0x65c70a] = _0xc6a27e;
        AllowedRecipientChanged(_0x65c70a, _0xc6a27e);
        return true;
    }

    function _0xe769c3(address _0x65c70a) internal returns (bool _0xf7991e) {
        if (_0x55348e[_0x65c70a]
            || (_0x65c70a == address(_0x1f4aee)


                && _0xcf706e > _0x1f4aee._0xcc9182()))
            return true;
        else
            return false;
    }

    function _0x92f72e() constant returns (uint _0x6de020) {
        return this.balance - _0xb732cd;
    }

    function _0x5b2ead(uint _0x89ac2e) internal constant returns (uint _0x58ec57) {

        return _0xeffac9 / _0xfa7c3e +
            (_0x89ac2e * _0xeffac9) / (3 * (_0x92f72e() + _0x297d78[address(this)]));
    }

    function _0xd5e137() returns (bool _0xaa65a9) {


        if ((_0xdbd1cf < (_0x16131f - _0x02f8d6) || msg.sender == _0x3df12b)
            && _0xdbd1cf < (_0x16131f - _0x2b2d68)) {
            _0xdbd1cf = _0x16131f;
            _0xfa7c3e *= 2;
            return true;
        } else {
            return false;
        }
    }

    function _0xdb37c7(address _0x69c816) internal returns (DAO _0x5f6113) {
        NewCurator(_0x69c816);
        return _0x281933._0xe8018f(_0x69c816, 0, 0, _0x16131f + _0x5a9b76);
    }

    function _0xd90ca4() constant returns (uint _0x14d6ca) {

        return _0x9b5bf9.length - 1;
    }

    function _0xc729b2(uint _0xa82900) constant returns (address _0x5f6113) {
        return _0x9b5bf9[_0xa82900]._0xbf6531[0]._0x8dd462;
    }

    function _0xb4c5b7(address _0xb9e296) internal returns (bool) {
        if (_0xa098de[_0xb9e296] == 0)
            return false;
        Proposal p = _0x9b5bf9[_0xa098de[_0xb9e296]];
        if (_0x16131f > p._0x1c132c) {
            _0xa098de[_0xb9e296] = 0;
            return false;
        } else {
            return true;
        }
    }

    function _0x176120() returns (bool) {
        return _0xb4c5b7(msg.sender);
    }
}

contract DAO_Creator {
    function _0xe8018f(
        address _0xcf890f,
        uint _0x07bebf,
        uint _0x0c1e2e,
        uint _0x390573
    ) returns (DAO _0x5f6113) {

        return new DAO(
            _0xcf890f,
            DAO_Creator(this),
            _0x07bebf,
            _0x0c1e2e,
            _0x390573,
            msg.sender
        );
    }
}