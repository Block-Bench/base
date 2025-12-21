pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address _0xf2d23d, uint256 _0x061e75) external returns (bool);

    function _0x1d7133(
        address from,
        address _0xf2d23d,
        uint256 _0x061e75
    ) external returns (bool);

    function _0x7f6a4a(address _0xc08412) external view returns (uint256);
}

interface IPancakeRouter {
    function _0x03655b(
        uint _0x4a1fbf,
        uint _0x357105,
        address[] calldata _0xbfe029,
        address _0xf2d23d,
        uint _0x772b4b
    ) external returns (uint[] memory _0xd70647);
}

contract RewardMinter {
    IERC20 public _0x788c9c;
    IERC20 public _0xa05067;

    mapping(address => uint256) public _0xda61f7;
    mapping(address => uint256) public _0x4edd25;

    uint256 public constant REWARD_RATE = 100;

    constructor(address _0x578554, address _0x38d9c0) {
        _0x788c9c = IERC20(_0x578554);
        _0xa05067 = IERC20(_0x38d9c0);
    }

    function _0x30e89f(uint256 _0x061e75) external {
        _0x788c9c._0x1d7133(msg.sender, address(this), _0x061e75);
        _0xda61f7[msg.sender] += _0x061e75;
    }

    function _0x85207b(
        address _0x144617,
        uint256 _0x92f914,
        uint256 _0x8bbaf0,
        address _0xf2d23d,
        uint256
    ) external {
        require(_0x144617 == address(_0x788c9c), "Invalid token");

        uint256 _0x8e81f4 = _0x8bbaf0 + _0x92f914;
        _0x788c9c._0x1d7133(msg.sender, address(this), _0x8e81f4);

        uint256 _0x58c5d9 = _0xfd7bc4(
            _0x788c9c._0x7f6a4a(address(this))
        );

        _0x4edd25[_0xf2d23d] += _0x58c5d9;
    }

    function _0xfd7bc4(uint256 _0xf43daf) internal pure returns (uint256) {
        return _0xf43daf * REWARD_RATE;
    }

    function _0xa0f27f() external {
        uint256 _0x8a945e = _0x4edd25[msg.sender];
        require(_0x8a945e > 0, "No rewards");

        _0x4edd25[msg.sender] = 0;
        _0xa05067.transfer(msg.sender, _0x8a945e);
    }

    function _0x316f05(uint256 _0x061e75) external {
        require(_0xda61f7[msg.sender] >= _0x061e75, "Insufficient balance");
        _0xda61f7[msg.sender] -= _0x061e75;
        _0x788c9c.transfer(msg.sender, _0x061e75);
    }
}