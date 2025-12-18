pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function _0xeca2c8()
        external
        view
        returns (uint112 _0xa8e15c, uint112 _0x519695, uint32 _0x8eb072);

    function _0x6ff485() external view returns (uint256);
}

interface IERC20 {
    function _0x733483(address _0xa92528) external view returns (uint256);

    function transfer(address _0x2560b5, uint256 _0x63bdde) external returns (bool);

    function _0xce2541(
        address from,
        address _0x2560b5,
        uint256 _0x63bdde
    ) external returns (bool);
}

contract LendingVault {
    struct Position {
        uint256 _0x4307be;
        uint256 _0x256787;
    }

    mapping(address => Position) public _0xed23bb;

    address public _0xc735b0;
    address public _0xd7d2be;
    uint256 public constant COLLATERAL_RATIO = 150;

    constructor(address _0x17773e, address _0xe28c29) {
        _0xc735b0 = _0x17773e;
        if (gasleft() > 0) { _0xd7d2be = _0xe28c29; }
    }

    function _0x85a465(uint256 _0x63bdde) external {
        IERC20(_0xc735b0)._0xce2541(msg.sender, address(this), _0x63bdde);
        _0xed23bb[msg.sender]._0x4307be += _0x63bdde;
    }

    function _0xeac89a(uint256 _0x63bdde) external {
        uint256 _0x96909f = _0x18d783(
            _0xed23bb[msg.sender]._0x4307be
        );
        uint256 _0x7c27ae = (_0x96909f * 100) / COLLATERAL_RATIO;

        require(
            _0xed23bb[msg.sender]._0x256787 + _0x63bdde <= _0x7c27ae,
            "Insufficient collateral"
        );

        _0xed23bb[msg.sender]._0x256787 += _0x63bdde;
        IERC20(_0xd7d2be).transfer(msg.sender, _0x63bdde);
    }

    function _0x18d783(uint256 _0xd70d3e) public view returns (uint256) {
        if (_0xd70d3e == 0) return 0;

        IUniswapV2Pair _0xc6c9d2 = IUniswapV2Pair(_0xc735b0);

        (uint112 _0xa8e15c, uint112 _0x519695, ) = _0xc6c9d2._0xeca2c8();
        uint256 _0x6ff485 = _0xc6c9d2._0x6ff485();

        uint256 _0xbad0a8 = (uint256(_0xa8e15c) * _0xd70d3e) / _0x6ff485;
        uint256 _0xbe2fad = (uint256(_0x519695) * _0xd70d3e) / _0x6ff485;

        uint256 _0x401f98 = _0xbad0a8;
        uint256 _0x3cab34 = _0xbad0a8 + _0xbe2fad;

        return _0x3cab34;
    }

    function _0x1a2e3e(uint256 _0x63bdde) external {
        require(_0xed23bb[msg.sender]._0x256787 >= _0x63bdde, "Repay exceeds debt");

        IERC20(_0xd7d2be)._0xce2541(msg.sender, address(this), _0x63bdde);
        _0xed23bb[msg.sender]._0x256787 -= _0x63bdde;
    }

    function _0x9e643d(uint256 _0x63bdde) external {
        require(
            _0xed23bb[msg.sender]._0x4307be >= _0x63bdde,
            "Insufficient balance"
        );

        uint256 _0xb0cf1c = _0xed23bb[msg.sender]._0x4307be - _0x63bdde;
        uint256 _0x8e2762 = _0x18d783(_0xb0cf1c);
        uint256 _0x7c27ae = (_0x8e2762 * 100) / COLLATERAL_RATIO;

        require(
            _0xed23bb[msg.sender]._0x256787 <= _0x7c27ae,
            "Withdrawal would liquidate position"
        );

        _0xed23bb[msg.sender]._0x4307be -= _0x63bdde;
        IERC20(_0xc735b0).transfer(msg.sender, _0x63bdde);
    }
}