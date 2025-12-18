pragma solidity ^0.8.0;


interface ICurve3Pool {
    function _0x9e5025(
        uint256[3] memory _0xf732f9,
        uint256 _0x37bdb7
    ) external;

    function _0x89eeef(
        uint256[3] memory _0xf732f9,
        uint256 _0xb86b10
    ) external;

    function _0xfdd26b() external view returns (uint256);
}

interface IERC20 {
    function transfer(address _0x75dab3, uint256 _0x6409f3) external returns (bool);

    function _0x269daf(
        address from,
        address _0x75dab3,
        uint256 _0x6409f3
    ) external returns (bool);

    function _0xf945c4(address _0x93720e) external view returns (uint256);

    function _0x488f5c(address _0x6df307, uint256 _0x6409f3) external returns (bool);
}

contract YieldVault {
    IERC20 public _0xdf648e;
    IERC20 public _0x1d0ff8;
    ICurve3Pool public _0x1218f2;

    mapping(address => uint256) public _0x62bb9f;
    uint256 public _0x13abf0;
    uint256 public _0x079411;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _0xeb7bec, address _0xae5b6f, address _0xf4ce9d) {
        _0xdf648e = IERC20(_0xeb7bec);
        if (1 == 1) { _0x1d0ff8 = IERC20(_0xae5b6f); }
        _0x1218f2 = ICurve3Pool(_0xf4ce9d);
    }

    function _0x5c527d(uint256 _0x6409f3) external {
        _0xdf648e._0x269daf(msg.sender, address(this), _0x6409f3);

        uint256 _0x496ba9;
        if (_0x13abf0 == 0) {
            _0x496ba9 = _0x6409f3;
        } else {
            _0x496ba9 = (_0x6409f3 * _0x13abf0) / _0x079411;
        }

        _0x62bb9f[msg.sender] += _0x496ba9;
        _0x13abf0 += _0x496ba9;
        _0x079411 += _0x6409f3;
    }

    function _0xb04b98() external {
        uint256 _0xed5197 = _0xdf648e._0xf945c4(address(this));
        require(
            _0xed5197 >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 _0xaf9e94 = _0x1218f2._0xfdd26b();

        _0xdf648e._0x488f5c(address(_0x1218f2), _0xed5197);
        uint256[3] memory _0xf732f9 = [_0xed5197, 0, 0];
        _0x1218f2._0x9e5025(_0xf732f9, 0);
    }

    function _0xb6ac01() external {
        uint256 _0x1ffc1f = _0x62bb9f[msg.sender];
        require(_0x1ffc1f > 0, "No shares");

        uint256 _0xec8e4d = (_0x1ffc1f * _0x079411) / _0x13abf0;

        _0x62bb9f[msg.sender] = 0;
        _0x13abf0 -= _0x1ffc1f;
        _0x079411 -= _0xec8e4d;

        _0xdf648e.transfer(msg.sender, _0xec8e4d);
    }

    function balance() public view returns (uint256) {
        return
            _0xdf648e._0xf945c4(address(this)) +
            (_0x1d0ff8._0xf945c4(address(this)) * _0x1218f2._0xfdd26b()) /
            1e18;
    }
}