// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function _0x837e1d()
        external
        view
        returns (uint112 _0x57d92a, uint112 _0xcd3d47, uint32 _0x7293c0);

    function _0x94f8eb() external view returns (uint256);
}

interface IERC20 {
    function _0x413e8e(address _0x793ec2) external view returns (uint256);

    function transfer(address _0x00b8e7, uint256 _0x1d7a06) external returns (bool);

    function _0x214748(
        address from,
        address _0x00b8e7,
        uint256 _0x1d7a06
    ) external returns (bool);
}

contract LendingVault {
    struct Position {
        uint256 _0x9fff3e;
        uint256 _0x39ece6;
    }

    mapping(address => Position) public _0x0edd97;

    address public _0x9b2a21;
    address public _0xd756e6;
    uint256 public constant COLLATERAL_RATIO = 150;

    constructor(address _0xda8993, address _0x46f4c2) {
        _0x9b2a21 = _0xda8993;
        _0xd756e6 = _0x46f4c2;
    }

    function _0x68fbd9(uint256 _0x1d7a06) external {
        IERC20(_0x9b2a21)._0x214748(msg.sender, address(this), _0x1d7a06);
        _0x0edd97[msg.sender]._0x9fff3e += _0x1d7a06;
    }

    function _0x4e2328(uint256 _0x1d7a06) external {
        uint256 _0x6a2478 = _0xd7e67b(
            _0x0edd97[msg.sender]._0x9fff3e
        );
        uint256 _0xa2cb62 = (_0x6a2478 * 100) / COLLATERAL_RATIO;

        require(
            _0x0edd97[msg.sender]._0x39ece6 + _0x1d7a06 <= _0xa2cb62,
            "Insufficient collateral"
        );

        _0x0edd97[msg.sender]._0x39ece6 += _0x1d7a06;
        IERC20(_0xd756e6).transfer(msg.sender, _0x1d7a06);
    }

    function _0xd7e67b(uint256 _0x774609) public view returns (uint256) {
        if (_0x774609 == 0) return 0;

        IUniswapV2Pair _0xde3e2e = IUniswapV2Pair(_0x9b2a21);

        (uint112 _0x57d92a, uint112 _0xcd3d47, ) = _0xde3e2e._0x837e1d();
        uint256 _0x94f8eb = _0xde3e2e._0x94f8eb();

        uint256 _0x06e9b5 = (uint256(_0x57d92a) * _0x774609) / _0x94f8eb;
        uint256 _0x4784dd = (uint256(_0xcd3d47) * _0x774609) / _0x94f8eb;

        uint256 _0x87500b = _0x06e9b5;
        uint256 _0x431a37 = _0x06e9b5 + _0x4784dd;

        return _0x431a37;
    }

    function _0x3c27b7(uint256 _0x1d7a06) external {
        require(_0x0edd97[msg.sender]._0x39ece6 >= _0x1d7a06, "Repay exceeds debt");

        IERC20(_0xd756e6)._0x214748(msg.sender, address(this), _0x1d7a06);
        _0x0edd97[msg.sender]._0x39ece6 -= _0x1d7a06;
    }

    function _0xc72f79(uint256 _0x1d7a06) external {
        require(
            _0x0edd97[msg.sender]._0x9fff3e >= _0x1d7a06,
            "Insufficient balance"
        );

        uint256 _0x259ff5 = _0x0edd97[msg.sender]._0x9fff3e - _0x1d7a06;
        uint256 _0xebe078 = _0xd7e67b(_0x259ff5);
        uint256 _0xa2cb62 = (_0xebe078 * 100) / COLLATERAL_RATIO;

        require(
            _0x0edd97[msg.sender]._0x39ece6 <= _0xa2cb62,
            "Withdrawal would liquidate position"
        );

        _0x0edd97[msg.sender]._0x9fff3e -= _0x1d7a06;
        IERC20(_0x9b2a21).transfer(msg.sender, _0x1d7a06);
    }
}
