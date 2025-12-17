// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xd43dd8, uint256 _0xd42a91) external returns (bool);

    function _0x4d122e(
        address from,
        address _0xd43dd8,
        uint256 _0xd42a91
    ) external returns (bool);

    function _0xf050e9(address _0x83ffcc) external view returns (uint256);
}

interface IMarket {
    function _0x23473f(
        address _0x83ffcc
    )
        external
        view
        returns (uint256 _0x37e7e0, uint256 _0x068fe4, uint256 _0x4fc2f0);
}

contract DebtPreviewer {
    function _0xe95f02(
        address _0x51bdea,
        address _0x83ffcc
    )
        external
        view
        returns (
            uint256 _0xb5b141,
            uint256 _0x37cdc5,
            uint256 _0xcd1523
        )
    {
        (uint256 _0x37e7e0, uint256 _0x068fe4, uint256 _0x4fc2f0) = IMarket(
            _0x51bdea
        )._0x23473f(_0x83ffcc);

        _0xb5b141 = (_0x37e7e0 * _0x4fc2f0) / 1e18;
        _0x37cdc5 = _0x068fe4;

        if (_0x37cdc5 == 0) {
            _0xcd1523 = type(uint256)._0xcc9ad9;
        } else {
            _0xcd1523 = (_0xb5b141 * 1e18) / _0x37cdc5;
        }

        return (_0xb5b141, _0x37cdc5, _0xcd1523);
    }

    function _0xc4c9c4(
        address[] calldata _0x750dae,
        address _0x83ffcc
    )
        external
        view
        returns (
            uint256 _0xef7823,
            uint256 _0xf6f5a1,
            uint256 _0xac4167
        )
    {
        for (uint256 i = 0; i < _0x750dae.length; i++) {
            (uint256 _0x37e7e0, uint256 _0xe4d452, ) = this._0xe95f02(
                _0x750dae[i],
                _0x83ffcc
            );

            _0xef7823 += _0x37e7e0;
            _0xf6f5a1 += _0xe4d452;
        }

        if (_0xf6f5a1 == 0) {
            _0xac4167 = type(uint256)._0xcc9ad9;
        } else {
            _0xac4167 = (_0xef7823 * 1e18) / _0xf6f5a1;
        }

        return (_0xef7823, _0xf6f5a1, _0xac4167);
    }
}

contract ExactlyMarket {
    IERC20 public _0x7fa789;
    DebtPreviewer public _0x6ef423;

    mapping(address => uint256) public _0x5c44a3;
    mapping(address => uint256) public _0x068fe4;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address _0x1bc43f, address _0x9df4d4) {
        _0x7fa789 = IERC20(_0x1bc43f);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x6ef423 = DebtPreviewer(_0x9df4d4); }
    }

    function _0xa1b452(uint256 _0xd42a91) external {
        _0x7fa789._0x4d122e(msg.sender, address(this), _0xd42a91);
        _0x5c44a3[msg.sender] += _0xd42a91;
    }

    function _0xba9026(uint256 _0xd42a91, address[] calldata _0x750dae) external {
        (uint256 _0xef7823, uint256 _0xf6f5a1, ) = _0x6ef423
            ._0xc4c9c4(_0x750dae, msg.sender);

        uint256 _0xf53ca3 = _0xf6f5a1 + _0xd42a91;

        uint256 _0xeaeabd = (_0xef7823 * COLLATERAL_FACTOR) / 100;
        require(_0xf53ca3 <= _0xeaeabd, "Insufficient collateral");

        _0x068fe4[msg.sender] += _0xd42a91;
        _0x7fa789.transfer(msg.sender, _0xd42a91);
    }

    function _0x23473f(
        address _0x83ffcc
    )
        external
        view
        returns (uint256 _0x37e7e0, uint256 _0x8e9956, uint256 _0x4fc2f0)
    {
        return (_0x5c44a3[_0x83ffcc], _0x068fe4[_0x83ffcc], 1e18);
    }
}
