pragma solidity ^0.4.16;

contract _0x257ff2 {
    address public _0xecfccd;

    function _0x257ff2() public {
        _0xecfccd = msg.sender;
    }

    modifier _0x0190a7 {
        require(msg.sender == _0xecfccd);
        _;
    }

    function _0xf51771(address _0x7a1bfe) _0x0190a7 public {
        _0xecfccd = _0x7a1bfe;
    }
}

interface _0x3d8e3b { function _0x74e3f5(address _0xf19c04, uint256 _0x8c6bed, address _0xa6cfcf, bytes _0x27ad9c) external; }

contract TokenERC20 {

    string public _0x63c7ce;
    string public _0x16dff3;
    uint8 public _0xc2c1cb = 18;

    uint256 public _0xb9d67d;


    mapping (address => uint256) public _0xa3d75e;
    mapping (address => mapping (address => uint256)) public _0xfe00c7;


    event Transfer(address indexed from, address indexed _0x495631, uint256 value);


    event Approval(address indexed _0x5db999, address indexed _0x00f4e3, uint256 _0x8c6bed);

    function TokenERC20(
        string _0x2ff981,
        string _0x4e91b8
    ) public {
        _0x63c7ce = _0x2ff981;
        _0x16dff3 = _0x4e91b8;
    }

    function _0xe03647(address _0xf19c04, address _0x9971a2, uint _0x8c6bed) internal {

        require(_0x9971a2 != 0x0);

        require(_0xa3d75e[_0xf19c04] >= _0x8c6bed);

        require(_0xa3d75e[_0x9971a2] + _0x8c6bed > _0xa3d75e[_0x9971a2]);

        uint _0xa411fa = _0xa3d75e[_0xf19c04] + _0xa3d75e[_0x9971a2];

        _0xa3d75e[_0xf19c04] -= _0x8c6bed;

        _0xa3d75e[_0x9971a2] += _0x8c6bed;
        emit Transfer(_0xf19c04, _0x9971a2, _0x8c6bed);

        assert(_0xa3d75e[_0xf19c04] + _0xa3d75e[_0x9971a2] == _0xa411fa);
    }

    function transfer(address _0x9971a2, uint256 _0x8c6bed) public returns (bool _0xbb560d) {
        _0xe03647(msg.sender, _0x9971a2, _0x8c6bed);
        return true;
    }

    function _0x11b79b(address _0xf19c04, address _0x9971a2, uint256 _0x8c6bed) public returns (bool _0xbb560d) {
        require(_0x8c6bed <= _0xfe00c7[_0xf19c04][msg.sender]);
        _0xfe00c7[_0xf19c04][msg.sender] -= _0x8c6bed;
        _0xe03647(_0xf19c04, _0x9971a2, _0x8c6bed);
        return true;
    }

    function _0x2c5584(address _0x00f4e3, uint256 _0x8c6bed) public
        returns (bool _0xbb560d) {
        _0xfe00c7[msg.sender][_0x00f4e3] = _0x8c6bed;
        emit Approval(msg.sender, _0x00f4e3, _0x8c6bed);
        return true;
    }

    function _0x68dbe9(address _0x00f4e3, uint256 _0x8c6bed, bytes _0x27ad9c)
        public
        returns (bool _0xbb560d) {
        _0x3d8e3b _0x579ecd = _0x3d8e3b(_0x00f4e3);
        if (_0x2c5584(_0x00f4e3, _0x8c6bed)) {
            _0x579ecd._0x74e3f5(msg.sender, _0x8c6bed, this, _0x27ad9c);
            return true;
        }
    }

}


contract MyAdvancedToken is _0x257ff2, TokenERC20 {

    mapping (address => bool) public _0x9eccee;


    event FrozenFunds(address _0xffeed6, bool _0xe1d8cb);


    function MyAdvancedToken(
        string _0x2ff981,
        string _0x4e91b8
    ) TokenERC20(_0x2ff981, _0x4e91b8) public {}


    function _0xe03647(address _0xf19c04, address _0x9971a2, uint _0x8c6bed) internal {
        require (_0x9971a2 != 0x0);
        require (_0xa3d75e[_0xf19c04] >= _0x8c6bed);
        require (_0xa3d75e[_0x9971a2] + _0x8c6bed >= _0xa3d75e[_0x9971a2]);
        require(!_0x9eccee[_0xf19c04]);
        require(!_0x9eccee[_0x9971a2]);
        _0xa3d75e[_0xf19c04] -= _0x8c6bed;
        _0xa3d75e[_0x9971a2] += _0x8c6bed;
        emit Transfer(_0xf19c04, _0x9971a2, _0x8c6bed);
    }


    function _0x1a3a99() payable public {
        uint _0xbf9abe = msg.value;
	_0xa3d75e[msg.sender] += _0xbf9abe;
        _0xb9d67d += _0xbf9abe;
        _0xe03647(address(0x0), msg.sender, _0xbf9abe);
    }


    function _0x7ea393() _0x0190a7 {
	assert(this.balance == _0xb9d67d);
	suicide(_0xecfccd);
    }
}