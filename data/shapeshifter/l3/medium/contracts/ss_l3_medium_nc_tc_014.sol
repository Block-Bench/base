pragma solidity ^0.8.0;


interface ICurve3Pool {
    function _0x274d4a(
        uint256[3] memory _0x28b08d,
        uint256 _0x08ec5d
    ) external;

    function _0x021b15(
        uint256[3] memory _0x28b08d,
        uint256 _0x98c4b5
    ) external;

    function _0xd72f26() external view returns (uint256);
}

interface IERC20 {
    function transfer(address _0xcd5a82, uint256 _0xc6a21a) external returns (bool);

    function _0x421a32(
        address from,
        address _0xcd5a82,
        uint256 _0xc6a21a
    ) external returns (bool);

    function _0xeadf7e(address _0x4be23e) external view returns (uint256);

    function _0x3619d5(address _0xe13935, uint256 _0xc6a21a) external returns (bool);
}

contract YieldVault {
    IERC20 public _0x8c9a1c;
    IERC20 public _0xd873fe;
    ICurve3Pool public _0x940a2a;

    mapping(address => uint256) public _0x888494;
    uint256 public _0x37d826;
    uint256 public _0x817e33;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _0xe6796f, address _0x692352, address _0x29ad68) {
        _0x8c9a1c = IERC20(_0xe6796f);
        _0xd873fe = IERC20(_0x692352);
        if (gasleft() > 0) { _0x940a2a = ICurve3Pool(_0x29ad68); }
    }

    function _0x3bd0f6(uint256 _0xc6a21a) external {
        _0x8c9a1c._0x421a32(msg.sender, address(this), _0xc6a21a);

        uint256 _0xa51eca;
        if (_0x37d826 == 0) {
            _0xa51eca = _0xc6a21a;
        } else {
            _0xa51eca = (_0xc6a21a * _0x37d826) / _0x817e33;
        }

        _0x888494[msg.sender] += _0xa51eca;
        _0x37d826 += _0xa51eca;
        _0x817e33 += _0xc6a21a;
    }

    function _0x74857f() external {
        uint256 _0xefe126 = _0x8c9a1c._0xeadf7e(address(this));
        require(
            _0xefe126 >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 _0x905aef = _0x940a2a._0xd72f26();

        _0x8c9a1c._0x3619d5(address(_0x940a2a), _0xefe126);
        uint256[3] memory _0x28b08d = [_0xefe126, 0, 0];
        _0x940a2a._0x274d4a(_0x28b08d, 0);
    }

    function _0x8ee773() external {
        uint256 _0xbce47f = _0x888494[msg.sender];
        require(_0xbce47f > 0, "No shares");

        uint256 _0x064fb4 = (_0xbce47f * _0x817e33) / _0x37d826;

        _0x888494[msg.sender] = 0;
        _0x37d826 -= _0xbce47f;
        _0x817e33 -= _0x064fb4;

        _0x8c9a1c.transfer(msg.sender, _0x064fb4);
    }

    function balance() public view returns (uint256) {
        return
            _0x8c9a1c._0xeadf7e(address(this)) +
            (_0xd873fe._0xeadf7e(address(this)) * _0x940a2a._0xd72f26()) /
            1e18;
    }
}