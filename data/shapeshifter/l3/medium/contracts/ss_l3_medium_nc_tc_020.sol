pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function _0xf09dcc()
        external
        view
        returns (uint112 _0x632c30, uint112 _0x2f8e46, uint32 _0xef55f3);

    function _0xbf731a() external view returns (uint256);
}

interface IERC20 {
    function _0x2fb7ba(address _0x59cb49) external view returns (uint256);

    function transfer(address _0x0f9f2e, uint256 _0x63f56d) external returns (bool);

    function _0x9f9be6(
        address from,
        address _0x0f9f2e,
        uint256 _0x63f56d
    ) external returns (bool);
}

contract LendingVault {
    struct Position {
        uint256 _0x48e935;
        uint256 _0x462734;
    }

    mapping(address => Position) public _0xc0f91c;

    address public _0xe485e8;
    address public _0x2fab70;
    uint256 public constant COLLATERAL_RATIO = 150;

    constructor(address _0x0d47e6, address _0x16d71a) {
        _0xe485e8 = _0x0d47e6;
        _0x2fab70 = _0x16d71a;
    }

    function _0xe15c5e(uint256 _0x63f56d) external {
        IERC20(_0xe485e8)._0x9f9be6(msg.sender, address(this), _0x63f56d);
        _0xc0f91c[msg.sender]._0x48e935 += _0x63f56d;
    }

    function _0x422da2(uint256 _0x63f56d) external {
        uint256 _0x28dabd = _0xa43055(
            _0xc0f91c[msg.sender]._0x48e935
        );
        uint256 _0x19b363 = (_0x28dabd * 100) / COLLATERAL_RATIO;

        require(
            _0xc0f91c[msg.sender]._0x462734 + _0x63f56d <= _0x19b363,
            "Insufficient collateral"
        );

        _0xc0f91c[msg.sender]._0x462734 += _0x63f56d;
        IERC20(_0x2fab70).transfer(msg.sender, _0x63f56d);
    }

    function _0xa43055(uint256 _0xfc6159) public view returns (uint256) {
        if (_0xfc6159 == 0) return 0;

        IUniswapV2Pair _0xdf667d = IUniswapV2Pair(_0xe485e8);

        (uint112 _0x632c30, uint112 _0x2f8e46, ) = _0xdf667d._0xf09dcc();
        uint256 _0xbf731a = _0xdf667d._0xbf731a();

        uint256 _0x7de926 = (uint256(_0x632c30) * _0xfc6159) / _0xbf731a;
        uint256 _0xe655cb = (uint256(_0x2f8e46) * _0xfc6159) / _0xbf731a;

        uint256 _0x40f19b = _0x7de926;
        uint256 _0x4e136d = _0x7de926 + _0xe655cb;

        return _0x4e136d;
    }

    function _0x0e847e(uint256 _0x63f56d) external {
        require(_0xc0f91c[msg.sender]._0x462734 >= _0x63f56d, "Repay exceeds debt");

        IERC20(_0x2fab70)._0x9f9be6(msg.sender, address(this), _0x63f56d);
        _0xc0f91c[msg.sender]._0x462734 -= _0x63f56d;
    }

    function _0x5e093a(uint256 _0x63f56d) external {
        require(
            _0xc0f91c[msg.sender]._0x48e935 >= _0x63f56d,
            "Insufficient balance"
        );

        uint256 _0x6cbf5b = _0xc0f91c[msg.sender]._0x48e935 - _0x63f56d;
        uint256 _0x3887fc = _0xa43055(_0x6cbf5b);
        uint256 _0x19b363 = (_0x3887fc * 100) / COLLATERAL_RATIO;

        require(
            _0xc0f91c[msg.sender]._0x462734 <= _0x19b363,
            "Withdrawal would liquidate position"
        );

        _0xc0f91c[msg.sender]._0x48e935 -= _0x63f56d;
        IERC20(_0xe485e8).transfer(msg.sender, _0x63f56d);
    }
}