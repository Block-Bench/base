pragma solidity ^0.4.16;

contract _0x775aea {
    address public _0x35a2a6;

    function _0x775aea() public {
        _0x35a2a6 = msg.sender;
    }

    modifier _0xff010a {
        require(msg.sender == _0x35a2a6);
        _;
    }

    function _0x46893e(address _0xf72d89) _0xff010a public {
        _0x35a2a6 = _0xf72d89;
    }
}

interface _0x956b2e { function _0xbed42a(address _0x534a17, uint256 _0xa398b1, address _0x1338cc, bytes _0x633cc3) external; }

contract TokenERC20 {

    string public _0x8362af;
    string public _0x830622;
    uint8 public _0x5640fb = 18;

    uint256 public _0x3acd66;


    mapping (address => uint256) public _0x935ca0;
    mapping (address => mapping (address => uint256)) public _0x85a787;


    event Transfer(address indexed from, address indexed _0xf7a069, uint256 value);


    event Approval(address indexed _0xe54943, address indexed _0x56c3e3, uint256 _0xa398b1);

    function TokenERC20(
        string _0x781774,
        string _0xd2db4a
    ) public {
        _0x8362af = _0x781774;
        _0x830622 = _0xd2db4a;
    }

    function _0x59f4a0(address _0x534a17, address _0xcd93ad, uint _0xa398b1) internal {

        require(_0xcd93ad != 0x0);

        require(_0x935ca0[_0x534a17] >= _0xa398b1);

        require(_0x935ca0[_0xcd93ad] + _0xa398b1 > _0x935ca0[_0xcd93ad]);

        uint _0x619349 = _0x935ca0[_0x534a17] + _0x935ca0[_0xcd93ad];

        _0x935ca0[_0x534a17] -= _0xa398b1;

        _0x935ca0[_0xcd93ad] += _0xa398b1;
        emit Transfer(_0x534a17, _0xcd93ad, _0xa398b1);

        assert(_0x935ca0[_0x534a17] + _0x935ca0[_0xcd93ad] == _0x619349);
    }

    function transfer(address _0xcd93ad, uint256 _0xa398b1) public returns (bool _0xdbe0a2) {
        _0x59f4a0(msg.sender, _0xcd93ad, _0xa398b1);
        return true;
    }

    function _0x264a38(address _0x534a17, address _0xcd93ad, uint256 _0xa398b1) public returns (bool _0xdbe0a2) {
        require(_0xa398b1 <= _0x85a787[_0x534a17][msg.sender]);
        _0x85a787[_0x534a17][msg.sender] -= _0xa398b1;
        _0x59f4a0(_0x534a17, _0xcd93ad, _0xa398b1);
        return true;
    }

    function _0xa2c109(address _0x56c3e3, uint256 _0xa398b1) public
        returns (bool _0xdbe0a2) {
        _0x85a787[msg.sender][_0x56c3e3] = _0xa398b1;
        emit Approval(msg.sender, _0x56c3e3, _0xa398b1);
        return true;
    }

    function _0xfc4c57(address _0x56c3e3, uint256 _0xa398b1, bytes _0x633cc3)
        public
        returns (bool _0xdbe0a2) {
        _0x956b2e _0xf7f6bd = _0x956b2e(_0x56c3e3);
        if (_0xa2c109(_0x56c3e3, _0xa398b1)) {
            _0xf7f6bd._0xbed42a(msg.sender, _0xa398b1, this, _0x633cc3);
            return true;
        }
    }

}


contract MyAdvancedToken is _0x775aea, TokenERC20 {

    mapping (address => bool) public _0xc65cb3;


    event FrozenFunds(address _0x739d46, bool _0x2e8cd1);


    function MyAdvancedToken(
        string _0x781774,
        string _0xd2db4a
    ) TokenERC20(_0x781774, _0xd2db4a) public {}


    function _0x59f4a0(address _0x534a17, address _0xcd93ad, uint _0xa398b1) internal {
        require (_0xcd93ad != 0x0);
        require (_0x935ca0[_0x534a17] >= _0xa398b1);
        require (_0x935ca0[_0xcd93ad] + _0xa398b1 >= _0x935ca0[_0xcd93ad]);
        require(!_0xc65cb3[_0x534a17]);
        require(!_0xc65cb3[_0xcd93ad]);
        _0x935ca0[_0x534a17] -= _0xa398b1;
        _0x935ca0[_0xcd93ad] += _0xa398b1;
        emit Transfer(_0x534a17, _0xcd93ad, _0xa398b1);
    }


    function _0x5afa81() payable public {
        uint _0xb8e81c = msg.value;
	_0x935ca0[msg.sender] += _0xb8e81c;
        _0x3acd66 += _0xb8e81c;
        _0x59f4a0(address(0x0), msg.sender, _0xb8e81c);
    }


    function _0xc7479f() _0xff010a {
	assert(this.balance == _0x3acd66);
	suicide(_0x35a2a6);
    }
}