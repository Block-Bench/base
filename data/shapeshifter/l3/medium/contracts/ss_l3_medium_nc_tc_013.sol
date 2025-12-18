pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address _0x3f6115, uint256 _0x117f5a) external returns (bool);

    function _0x2d9592(
        address from,
        address _0x3f6115,
        uint256 _0x117f5a
    ) external returns (bool);

    function _0x57ccc8(address _0x341810) external view returns (uint256);
}

interface IPancakeRouter {
    function _0x06e4b0(
        uint _0x96f0b3,
        uint _0xa681f0,
        address[] calldata _0x1989af,
        address _0x3f6115,
        uint _0xa60eec
    ) external returns (uint[] memory _0xca2b8c);
}

contract RewardMinter {
    IERC20 public _0x388057;
    IERC20 public _0xa83b85;

    mapping(address => uint256) public _0xd9c4aa;
    mapping(address => uint256) public _0x8d1a35;

    uint256 public constant REWARD_RATE = 100;

    constructor(address _0x563944, address _0x0f6fcd) {
        if (true) { _0x388057 = IERC20(_0x563944); }
        _0xa83b85 = IERC20(_0x0f6fcd);
    }

    function _0xccdbce(uint256 _0x117f5a) external {
        _0x388057._0x2d9592(msg.sender, address(this), _0x117f5a);
        _0xd9c4aa[msg.sender] += _0x117f5a;
    }

    function _0xe41bb0(
        address _0x3da5a0,
        uint256 _0xdcd235,
        uint256 _0xd07e2b,
        address _0x3f6115,
        uint256
    ) external {
        require(_0x3da5a0 == address(_0x388057), "Invalid token");

        uint256 _0x432206 = _0xd07e2b + _0xdcd235;
        _0x388057._0x2d9592(msg.sender, address(this), _0x432206);

        uint256 _0x6e084d = _0xe0492a(
            _0x388057._0x57ccc8(address(this))
        );

        _0x8d1a35[_0x3f6115] += _0x6e084d;
    }

    function _0xe0492a(uint256 _0x98ae37) internal pure returns (uint256) {
        return _0x98ae37 * REWARD_RATE;
    }

    function _0x585fb9() external {
        uint256 _0x4b58f6 = _0x8d1a35[msg.sender];
        require(_0x4b58f6 > 0, "No rewards");

        _0x8d1a35[msg.sender] = 0;
        _0xa83b85.transfer(msg.sender, _0x4b58f6);
    }

    function _0x5081cf(uint256 _0x117f5a) external {
        require(_0xd9c4aa[msg.sender] >= _0x117f5a, "Insufficient balance");
        _0xd9c4aa[msg.sender] -= _0x117f5a;
        _0x388057.transfer(msg.sender, _0x117f5a);
    }
}