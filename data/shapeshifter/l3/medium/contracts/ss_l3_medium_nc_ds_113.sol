contract TokenInterface {
    mapping (address => uint256) _0x22d612;
    mapping (address => mapping (address => uint256)) _0xee9abd;


    uint256 public _0x318d3a;


    function _0xe0ffdc(address _0x4fb0c8) constant returns (uint256 balance);


    function transfer(address _0xdde2c1, uint256 _0x02f499) returns (bool _0xe88010);


    function _0xa2b519(address _0x7d2b1c, address _0xdde2c1, uint256 _0x02f499) returns (bool _0xe88010);


    function _0x141b99(address _0x4ac7ce, uint256 _0x02f499) returns (bool _0xe88010);


    function _0x3736b1(
        address _0x4fb0c8,
        address _0x4ac7ce
    ) constant returns (uint256 _0x2ce94c);

    event Transfer(address indexed _0x7d2b1c, address indexed _0xdde2c1, uint256 _0x02f499);
    event Approval(
        address indexed _0x4fb0c8,
        address indexed _0x4ac7ce,
        uint256 _0x02f499
    );
}

contract Token is TokenInterface {


    modifier _0xa4b0b8() {if (msg.value > 0) throw; _;}

    function _0xe0ffdc(address _0x4fb0c8) constant returns (uint256 balance) {
        return _0x22d612[_0x4fb0c8];
    }

    function transfer(address _0xdde2c1, uint256 _0x02f499) _0xa4b0b8 returns (bool _0xe88010) {
        if (_0x22d612[msg.sender] >= _0x02f499 && _0x02f499 > 0) {
            _0x22d612[msg.sender] -= _0x02f499;
            _0x22d612[_0xdde2c1] += _0x02f499;
            Transfer(msg.sender, _0xdde2c1, _0x02f499);
            return true;
        } else {
           return false;
        }
    }

    function _0xa2b519(
        address _0x7d2b1c,
        address _0xdde2c1,
        uint256 _0x02f499
    ) _0xa4b0b8 returns (bool _0xe88010) {

        if (_0x22d612[_0x7d2b1c] >= _0x02f499
            && _0xee9abd[_0x7d2b1c][msg.sender] >= _0x02f499
            && _0x02f499 > 0) {

            _0x22d612[_0xdde2c1] += _0x02f499;
            _0x22d612[_0x7d2b1c] -= _0x02f499;
            _0xee9abd[_0x7d2b1c][msg.sender] -= _0x02f499;
            Transfer(_0x7d2b1c, _0xdde2c1, _0x02f499);
            return true;
        } else {
            return false;
        }
    }

    function _0x141b99(address _0x4ac7ce, uint256 _0x02f499) returns (bool _0xe88010) {
        _0xee9abd[msg.sender][_0x4ac7ce] = _0x02f499;
        Approval(msg.sender, _0x4ac7ce, _0x02f499);
        return true;
    }

    function _0x3736b1(address _0x4fb0c8, address _0x4ac7ce) constant returns (uint256 _0x2ce94c) {
        return _0xee9abd[_0x4fb0c8][_0x4ac7ce];
    }
}

contract ManagedAccountInterface {

    address public _0xd1872a;

    bool public _0x4dc403;

    uint public _0x04fed3;


    function _0x4c91fc(address _0xce380f, uint _0x02f499) returns (bool);

    event PayOut(address indexed _0xce380f, uint _0x02f499);
}

contract ManagedAccount is ManagedAccountInterface{


    function ManagedAccount(address _0x4fb0c8, bool _0x14e0b1) {
        _0xd1872a = _0x4fb0c8;
        _0x4dc403 = _0x14e0b1;
    }


    function() {
        _0x04fed3 += msg.value;
    }

    function _0x4c91fc(address _0xce380f, uint _0x02f499) returns (bool) {
        if (msg.sender != _0xd1872a || msg.value > 0 || (_0x4dc403 && _0xce380f != _0xd1872a))
            throw;
        if (_0xce380f.call.value(_0x02f499)()) {
            PayOut(_0xce380f, _0x02f499);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {


    uint public _0x28ea27;


    uint public _0xbb3057;

    bool public _0x927dcf;


    address public _0x8f57a6;


    ManagedAccount public _0xecc9bb;

    mapping (address => uint256) _0x19c791;


    function _0xda1ab8(address _0x460a6d) returns (bool _0xe88010);


    function _0x18f362();


    function _0xb30f31() constant returns (uint _0xb30f31);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed _0x92dc79, uint _0x5d4a1a);
    event Refund(address indexed _0x92dc79, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint _0xb87fbe,
        uint _0xd93c92,
        address _0x53ca54) {

        _0x28ea27 = _0xd93c92;
        _0xbb3057 = _0xb87fbe;
        _0x8f57a6 = _0x53ca54;
        _0xecc9bb = new ManagedAccount(address(this), true);
    }

    function _0xda1ab8(address _0x460a6d) returns (bool _0xe88010) {
        if (_0xa6133a < _0x28ea27 && msg.value > 0
            && (_0x8f57a6 == 0 || _0x8f57a6 == msg.sender)) {

            uint _0xce5813 = (msg.value * 20) / _0xb30f31();
            _0xecc9bb.call.value(msg.value - _0xce5813)();
            _0x22d612[_0x460a6d] += _0xce5813;
            _0x318d3a += _0xce5813;
            _0x19c791[_0x460a6d] += msg.value;
            CreatedToken(_0x460a6d, _0xce5813);
            if (_0x318d3a >= _0xbb3057 && !_0x927dcf) {
                _0x927dcf = true;
                FuelingToDate(_0x318d3a);
            }
            return true;
        }
        throw;
    }

    function _0x18f362() _0xa4b0b8 {
        if (_0xa6133a > _0x28ea27 && !_0x927dcf) {

            if (_0xecc9bb.balance >= _0xecc9bb._0x04fed3())
                _0xecc9bb._0x4c91fc(address(this), _0xecc9bb._0x04fed3());


            if (msg.sender.call.value(_0x19c791[msg.sender])()) {
                Refund(msg.sender, _0x19c791[msg.sender]);
                _0x318d3a -= _0x22d612[msg.sender];
                _0x22d612[msg.sender] = 0;
                _0x19c791[msg.sender] = 0;
            }
        }
    }

    function _0xb30f31() constant returns (uint _0xb30f31) {


        if (_0x28ea27 - 2 weeks > _0xa6133a) {
            return 20;

        } else if (_0x28ea27 - 4 days > _0xa6133a) {
            return (20 + (_0xa6133a - (_0x28ea27 - 2 weeks)) / (1 days));

        } else {
            return 30;
        }
    }
}

contract DAOInterface {


    uint constant _0x5c0352 = 40 days;

    uint constant _0x7da85e = 2 weeks;

    uint constant _0xa47fb5 = 1 weeks;

    uint constant _0x4904fd = 27 days;

    uint constant _0xed6add = 25 weeks;


    uint constant _0x93009b = 10 days;


    uint constant _0x1c175b = 100;


    Proposal[] public _0xd073cf;


    uint public _0xdfbfbc;

    uint  public _0xd4d731;


    address public _0x3e4559;

    mapping (address => bool) public _0x0f9e0f;


    mapping (address => uint) public _0x71c0fd;

    uint public _0x905903;


    ManagedAccount public _0xa21521;


    ManagedAccount public DAOrewardAccount;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public _0x2ae6c1;


    mapping (address => uint) public _0x530f77;


    uint public _0xe78ee9;


    uint _0xed62f3;


    DAO_Creator public _0x4dada0;


    struct Proposal {


        address _0x6b611f;

        uint _0x5d4a1a;

        string _0x07bbce;

        uint _0x93e1a2;

        bool _0x731501;


        bool _0xa7a5a2;

        bytes32 _0x2896c9;


        uint _0xe78ee9;

        bool _0x9806c1;

        SplitData[] _0xf86fae;

        uint _0xc7e808;

        uint _0xdee2e2;

        mapping (address => bool) _0xf94261;

        mapping (address => bool) _0xa3cc19;

        address _0x380e35;
    }


    struct SplitData {

        uint _0x11181b;

        uint _0x318d3a;

        uint _0x71c0fd;

        DAO _0xdc8536;
    }


    modifier _0xe98ba6 {}


    function () returns (bool _0xe88010);


    function _0x3cb4a1() returns(bool);


    function _0xfa4a70(
        address _0xce380f,
        uint _0x02f499,
        string _0x382dff,
        bytes _0x9ee5a8,
        uint _0x408348,
        bool _0x837f54
    ) _0xe98ba6 returns (uint _0x790a8f);


    function _0x9dc802(
        uint _0x790a8f,
        address _0xce380f,
        uint _0x02f499,
        bytes _0x9ee5a8
    ) constant returns (bool _0xc67964);


    function _0x72190f(
        uint _0x790a8f,
        bool _0x7e7a42
    ) _0xe98ba6 returns (uint _0xaa6821);


    function _0x994c2c(
        uint _0x790a8f,
        bytes _0x9ee5a8
    ) returns (bool _0xe4d384);


    function _0x5bda1a(
        uint _0x790a8f,
        address _0x837f54
    ) returns (bool _0xe4d384);


    function _0x41da1c(address _0xd65127);


    function _0x2f982f(address _0xce380f, bool _0xc6bc6e) external returns (bool _0xe4d384);


    function _0x30d290(uint _0xf7dc95) external;


    function _0x6ac791(bool _0xa207c8) external returns (bool _0xe4d384);


    function _0xb3ea4a() returns(bool _0xe4d384);


    function _0x27e88b(address _0xd46a67) internal returns (bool _0xe4d384);


    function _0xbc260d(address _0xdde2c1, uint256 _0x02f499) returns (bool _0xe88010);


    function _0xbfe377(
        address _0x7d2b1c,
        address _0xdde2c1,
        uint256 _0x02f499
    ) returns (bool _0xe88010);


    function _0x3b8429() returns (bool _0xe4d384);


    function _0x7094e0() constant returns (uint _0xd4beac);


    function _0xa010f2(uint _0x790a8f) constant returns (address _0x31f299);


    function _0xcac281(address _0xd46a67) internal returns (bool);


    function _0x8e4c52() returns (bool);

    event ProposalAdded(
        uint indexed _0xf31b45,
        address _0x6b611f,
        uint _0x5d4a1a,
        bool _0x9806c1,
        string _0x07bbce
    );
    event Voted(uint indexed _0xf31b45, bool _0xfb1738, address indexed _0x74d967);
    event ProposalTallied(uint indexed _0xf31b45, bool _0x38ead3, uint _0x1d89c5);
    event NewCurator(address indexed _0x837f54);
    event AllowedRecipientChanged(address indexed _0xce380f, bool _0xc6bc6e);
}


contract DAO is DAOInterface, Token, TokenCreation {


    modifier _0xe98ba6 {
        if (_0xe0ffdc(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _0xdba3ea,
        DAO_Creator _0xebbe17,
        uint _0xf7dc95,
        uint _0xb87fbe,
        uint _0xd93c92,
        address _0x53ca54
    ) TokenCreation(_0xb87fbe, _0xd93c92, _0x53ca54) {

        _0x3e4559 = _0xdba3ea;
        _0x4dada0 = _0xebbe17;
        _0xe78ee9 = _0xf7dc95;
        _0xa21521 = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(_0xa21521) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        _0xd4d731 = _0xa6133a;
        _0xdfbfbc = 5;
        _0xd073cf.length = 1;

        _0x0f9e0f[address(this)] = true;
        _0x0f9e0f[_0x3e4559] = true;
    }

    function () returns (bool _0xe88010) {
        if (_0xa6133a < _0x28ea27 + _0x5c0352 && msg.sender != address(_0xecc9bb))
            return _0xda1ab8(msg.sender);
        else
            return _0x3cb4a1();
    }

    function _0x3cb4a1() returns (bool) {
        return true;
    }

    function _0xfa4a70(
        address _0xce380f,
        uint _0x02f499,
        string _0x382dff,
        bytes _0x9ee5a8,
        uint _0x408348,
        bool _0x837f54
    ) _0xe98ba6 returns (uint _0x790a8f) {


        if (_0x837f54 && (
            _0x02f499 != 0
            || _0x9ee5a8.length != 0
            || _0xce380f == _0x3e4559
            || msg.value > 0
            || _0x408348 < _0xa47fb5)) {
            throw;
        } else if (
            !_0x837f54
            && (!_0x9262bf(_0xce380f) || (_0x408348 <  _0x7da85e))
        ) {
            throw;
        }

        if (_0x408348 > 8 weeks)
            throw;

        if (!_0x927dcf
            || _0xa6133a < _0x28ea27
            || (msg.value < _0xe78ee9 && !_0x837f54)) {

            throw;
        }

        if (_0xa6133a + _0x408348 < _0xa6133a)
            throw;

        if (msg.sender == address(this))
            throw;

        _0x790a8f = _0xd073cf.length++;
        Proposal p = _0xd073cf[_0x790a8f];
        p._0x6b611f = _0xce380f;
        p._0x5d4a1a = _0x02f499;
        p._0x07bbce = _0x382dff;
        p._0x2896c9 = _0xe84e2d(_0xce380f, _0x02f499, _0x9ee5a8);
        p._0x93e1a2 = _0xa6133a + _0x408348;
        p._0x731501 = true;

        p._0x9806c1 = _0x837f54;
        if (_0x837f54)
            p._0xf86fae.length++;
        p._0x380e35 = msg.sender;
        p._0xe78ee9 = msg.value;

        _0xed62f3 += msg.value;

        ProposalAdded(
            _0x790a8f,
            _0xce380f,
            _0x02f499,
            _0x837f54,
            _0x382dff
        );
    }

    function _0x9dc802(
        uint _0x790a8f,
        address _0xce380f,
        uint _0x02f499,
        bytes _0x9ee5a8
    ) _0xa4b0b8 constant returns (bool _0xc67964) {
        Proposal p = _0xd073cf[_0x790a8f];
        return p._0x2896c9 == _0xe84e2d(_0xce380f, _0x02f499, _0x9ee5a8);
    }

    function _0x72190f(
        uint _0x790a8f,
        bool _0x7e7a42
    ) _0xe98ba6 _0xa4b0b8 returns (uint _0xaa6821) {

        Proposal p = _0xd073cf[_0x790a8f];
        if (p._0xf94261[msg.sender]
            || p._0xa3cc19[msg.sender]
            || _0xa6133a >= p._0x93e1a2) {

            throw;
        }

        if (_0x7e7a42) {
            p._0xc7e808 += _0x22d612[msg.sender];
            p._0xf94261[msg.sender] = true;
        } else {
            p._0xdee2e2 += _0x22d612[msg.sender];
            p._0xa3cc19[msg.sender] = true;
        }

        if (_0x530f77[msg.sender] == 0) {
            _0x530f77[msg.sender] = _0x790a8f;
        } else if (p._0x93e1a2 > _0xd073cf[_0x530f77[msg.sender]]._0x93e1a2) {


            _0x530f77[msg.sender] = _0x790a8f;
        }

        Voted(_0x790a8f, _0x7e7a42, msg.sender);
    }

    function _0x994c2c(
        uint _0x790a8f,
        bytes _0x9ee5a8
    ) _0xa4b0b8 returns (bool _0xe4d384) {

        Proposal p = _0xd073cf[_0x790a8f];

        uint _0xb5bd69 = p._0x9806c1
            ? _0x4904fd
            : _0x93009b;

        if (p._0x731501 && _0xa6133a > p._0x93e1a2 + _0xb5bd69) {
            _0x2e198f(_0x790a8f);
            return;
        }


        if (_0xa6133a < p._0x93e1a2

            || !p._0x731501

            || p._0x2896c9 != _0xe84e2d(p._0x6b611f, p._0x5d4a1a, _0x9ee5a8)) {

            throw;
        }


        if (!_0x9262bf(p._0x6b611f)) {
            _0x2e198f(_0x790a8f);
            p._0x380e35.send(p._0xe78ee9);
            return;
        }

        bool _0xb955b1 = true;

        if (p._0x5d4a1a > _0xa392d0())
            _0xb955b1 = false;

        uint _0x1d89c5 = p._0xc7e808 + p._0xdee2e2;


        if (_0x9ee5a8.length >= 4 && _0x9ee5a8[0] == 0x68
            && _0x9ee5a8[1] == 0x37 && _0x9ee5a8[2] == 0xff
            && _0x9ee5a8[3] == 0x1e
            && _0x1d89c5 < _0x875a1f(_0xa392d0() + _0x71c0fd[address(this)])) {

                _0xb955b1 = false;
        }

        if (_0x1d89c5 >= _0x875a1f(p._0x5d4a1a)) {
            if (!p._0x380e35.send(p._0xe78ee9))
                throw;

            _0xd4d731 = _0xa6133a;

            if (_0x1d89c5 > _0x318d3a / 5)
                _0xdfbfbc = 5;
        }


        if (_0x1d89c5 >= _0x875a1f(p._0x5d4a1a) && p._0xc7e808 > p._0xdee2e2 && _0xb955b1) {
            if (!p._0x6b611f.call.value(p._0x5d4a1a)(_0x9ee5a8))
                throw;

            p._0xa7a5a2 = true;
            _0xe4d384 = true;


            if (p._0x6b611f != address(this) && p._0x6b611f != address(_0xa21521)
                && p._0x6b611f != address(DAOrewardAccount)
                && p._0x6b611f != address(_0xecc9bb)
                && p._0x6b611f != address(_0x3e4559)) {

                _0x71c0fd[address(this)] += p._0x5d4a1a;
                _0x905903 += p._0x5d4a1a;
            }
        }

        _0x2e198f(_0x790a8f);


        ProposalTallied(_0x790a8f, _0xe4d384, _0x1d89c5);
    }

    function _0x2e198f(uint _0x790a8f) internal {
        Proposal p = _0xd073cf[_0x790a8f];
        if (p._0x731501)
            _0xed62f3 -= p._0xe78ee9;
        p._0x731501 = false;
    }

    function _0x5bda1a(
        uint _0x790a8f,
        address _0x837f54
    ) _0xa4b0b8 _0xe98ba6 returns (bool _0xe4d384) {

        Proposal p = _0xd073cf[_0x790a8f];


        if (_0xa6133a < p._0x93e1a2

            || _0xa6133a > p._0x93e1a2 + _0x4904fd

            || p._0x6b611f != _0x837f54

            || !p._0x9806c1

            || !p._0xf94261[msg.sender]

            || (_0x530f77[msg.sender] != _0x790a8f && _0x530f77[msg.sender] != 0) )  {

            throw;
        }


        if (address(p._0xf86fae[0]._0xdc8536) == 0) {
            p._0xf86fae[0]._0xdc8536 = _0x520bd9(_0x837f54);

            if (address(p._0xf86fae[0]._0xdc8536) == 0)
                throw;

            if (this.balance < _0xed62f3)
                throw;
            p._0xf86fae[0]._0x11181b = _0xa392d0();
            p._0xf86fae[0]._0x71c0fd = _0x71c0fd[address(this)];
            p._0xf86fae[0]._0x318d3a = _0x318d3a;
            p._0xa7a5a2 = true;
        }


        uint _0x1e6256 =
            (_0x22d612[msg.sender] * p._0xf86fae[0]._0x11181b) /
            p._0xf86fae[0]._0x318d3a;
        if (p._0xf86fae[0]._0xdc8536._0xda1ab8.value(_0x1e6256)(msg.sender) == false)
            throw;


        uint _0xb7c1a5 =
            (_0x22d612[msg.sender] * p._0xf86fae[0]._0x71c0fd) /
            p._0xf86fae[0]._0x318d3a;

        uint _0xeaf670 = DAOpaidOut[address(this)] * _0xb7c1a5 /
            _0x71c0fd[address(this)];

        _0x71c0fd[address(p._0xf86fae[0]._0xdc8536)] += _0xb7c1a5;
        if (_0x71c0fd[address(this)] < _0xb7c1a5)
            throw;
        _0x71c0fd[address(this)] -= _0xb7c1a5;

        DAOpaidOut[address(p._0xf86fae[0]._0xdc8536)] += _0xeaf670;
        if (DAOpaidOut[address(this)] < _0xeaf670)
            throw;
        DAOpaidOut[address(this)] -= _0xeaf670;


        Transfer(msg.sender, 0, _0x22d612[msg.sender]);
        _0x27e88b(msg.sender);
        _0x318d3a -= _0x22d612[msg.sender];
        _0x22d612[msg.sender] = 0;
        _0x2ae6c1[msg.sender] = 0;
        return true;
    }

    function _0x41da1c(address _0xd65127){
        if (msg.sender != address(this) || !_0x0f9e0f[_0xd65127]) return;

        if (!_0xd65127.call.value(address(this).balance)()) {
            throw;
        }


        _0x71c0fd[_0xd65127] += _0x71c0fd[address(this)];
        _0x71c0fd[address(this)] = 0;
        DAOpaidOut[_0xd65127] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function _0x6ac791(bool _0xa207c8) external _0xa4b0b8 returns (bool _0xe4d384) {
        DAO _0xd7a97b = DAO(msg.sender);

        if ((_0x71c0fd[msg.sender] * DAOrewardAccount._0x04fed3()) /
            _0x905903 < DAOpaidOut[msg.sender])
            throw;

        uint _0xafff75 =
            (_0x71c0fd[msg.sender] * DAOrewardAccount._0x04fed3()) /
            _0x905903 - DAOpaidOut[msg.sender];
        if(_0xa207c8) {
            if (!DAOrewardAccount._0x4c91fc(_0xd7a97b._0xa21521(), _0xafff75))
                throw;
            }
        else {
            if (!DAOrewardAccount._0x4c91fc(_0xd7a97b, _0xafff75))
                throw;
        }
        DAOpaidOut[msg.sender] += _0xafff75;
        return true;
    }

    function _0xb3ea4a() _0xa4b0b8 returns (bool _0xe4d384) {
        return _0x27e88b(msg.sender);
    }

    function _0x27e88b(address _0xd46a67) _0xa4b0b8 internal returns (bool _0xe4d384) {
        if ((_0xe0ffdc(_0xd46a67) * _0xa21521._0x04fed3()) / _0x318d3a < _0x2ae6c1[_0xd46a67])
            throw;

        uint _0xafff75 =
            (_0xe0ffdc(_0xd46a67) * _0xa21521._0x04fed3()) / _0x318d3a - _0x2ae6c1[_0xd46a67];
        if (!_0xa21521._0x4c91fc(_0xd46a67, _0xafff75))
            throw;
        _0x2ae6c1[_0xd46a67] += _0xafff75;
        return true;
    }

    function transfer(address _0xdde2c1, uint256 _0x606d67) returns (bool _0xe88010) {
        if (_0x927dcf
            && _0xa6133a > _0x28ea27
            && !_0xcac281(msg.sender)
            && _0x78bcb1(msg.sender, _0xdde2c1, _0x606d67)
            && super.transfer(_0xdde2c1, _0x606d67)) {

            return true;
        } else {
            throw;
        }
    }

    function _0xbc260d(address _0xdde2c1, uint256 _0x606d67) returns (bool _0xe88010) {
        if (!_0xb3ea4a())
            throw;
        return transfer(_0xdde2c1, _0x606d67);
    }

    function _0xa2b519(address _0x7d2b1c, address _0xdde2c1, uint256 _0x606d67) returns (bool _0xe88010) {
        if (_0x927dcf
            && _0xa6133a > _0x28ea27
            && !_0xcac281(_0x7d2b1c)
            && _0x78bcb1(_0x7d2b1c, _0xdde2c1, _0x606d67)
            && super._0xa2b519(_0x7d2b1c, _0xdde2c1, _0x606d67)) {

            return true;
        } else {
            throw;
        }
    }

    function _0xbfe377(
        address _0x7d2b1c,
        address _0xdde2c1,
        uint256 _0x606d67
    ) returns (bool _0xe88010) {

        if (!_0x27e88b(_0x7d2b1c))
            throw;
        return _0xa2b519(_0x7d2b1c, _0xdde2c1, _0x606d67);
    }

    function _0x78bcb1(
        address _0x7d2b1c,
        address _0xdde2c1,
        uint256 _0x606d67
    ) internal returns (bool _0xe88010) {

        uint _0x78bcb1 = _0x2ae6c1[_0x7d2b1c] * _0x606d67 / _0xe0ffdc(_0x7d2b1c);
        if (_0x78bcb1 > _0x2ae6c1[_0x7d2b1c])
            throw;
        _0x2ae6c1[_0x7d2b1c] -= _0x78bcb1;
        _0x2ae6c1[_0xdde2c1] += _0x78bcb1;
        return true;
    }

    function _0x30d290(uint _0xf7dc95) _0xa4b0b8 external {
        if (msg.sender != address(this) || _0xf7dc95 > (_0xa392d0() + _0x71c0fd[address(this)])
            / _0x1c175b) {

            throw;
        }
        if (1 == 1) { _0xe78ee9 = _0xf7dc95; }
    }

    function _0x2f982f(address _0xce380f, bool _0xc6bc6e) _0xa4b0b8 external returns (bool _0xe4d384) {
        if (msg.sender != _0x3e4559)
            throw;
        _0x0f9e0f[_0xce380f] = _0xc6bc6e;
        AllowedRecipientChanged(_0xce380f, _0xc6bc6e);
        return true;
    }

    function _0x9262bf(address _0xce380f) internal returns (bool _0x3ab064) {
        if (_0x0f9e0f[_0xce380f]
            || (_0xce380f == address(_0xecc9bb)


                && _0x905903 > _0xecc9bb._0x04fed3()))
            return true;
        else
            return false;
    }

    function _0xa392d0() constant returns (uint _0x7379a1) {
        return this.balance - _0xed62f3;
    }

    function _0x875a1f(uint _0x606d67) internal constant returns (uint _0x35d7bb) {

        return _0x318d3a / _0xdfbfbc +
            (_0x606d67 * _0x318d3a) / (3 * (_0xa392d0() + _0x71c0fd[address(this)]));
    }

    function _0x3b8429() returns (bool _0xe4d384) {


        if ((_0xd4d731 < (_0xa6133a - _0xed6add) || msg.sender == _0x3e4559)
            && _0xd4d731 < (_0xa6133a - _0x7da85e)) {
            _0xd4d731 = _0xa6133a;
            _0xdfbfbc *= 2;
            return true;
        } else {
            return false;
        }
    }

    function _0x520bd9(address _0x837f54) internal returns (DAO _0x31f299) {
        NewCurator(_0x837f54);
        return _0x4dada0._0x03c84a(_0x837f54, 0, 0, _0xa6133a + _0x4904fd);
    }

    function _0x7094e0() constant returns (uint _0xd4beac) {

        return _0xd073cf.length - 1;
    }

    function _0xa010f2(uint _0x790a8f) constant returns (address _0x31f299) {
        return _0xd073cf[_0x790a8f]._0xf86fae[0]._0xdc8536;
    }

    function _0xcac281(address _0xd46a67) internal returns (bool) {
        if (_0x530f77[_0xd46a67] == 0)
            return false;
        Proposal p = _0xd073cf[_0x530f77[_0xd46a67]];
        if (_0xa6133a > p._0x93e1a2) {
            _0x530f77[_0xd46a67] = 0;
            return false;
        } else {
            return true;
        }
    }

    function _0x8e4c52() returns (bool) {
        return _0xcac281(msg.sender);
    }
}

contract DAO_Creator {
    function _0x03c84a(
        address _0xdba3ea,
        uint _0xf7dc95,
        uint _0xb87fbe,
        uint _0xd93c92
    ) returns (DAO _0x31f299) {

        return new DAO(
            _0xdba3ea,
            DAO_Creator(this),
            _0xf7dc95,
            _0xb87fbe,
            _0xd93c92,
            msg.sender
        );
    }
}