// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x881516(address _0x706ad4) external view returns (uint256);

    function transfer(address _0x20c1ed, uint256 _0x53c998) external returns (bool);

    function _0xcfaa43(
        address from,
        address _0x20c1ed,
        uint256 _0x53c998
    ) external returns (bool);
}

interface ICurvePool {
    function _0x9c3784() external view returns (uint256);

    function _0xafa10f(
        uint256[3] calldata _0xce053e,
        uint256 _0x3515f2
    ) external;
}

contract PriceOracle {
    ICurvePool public _0x9c2179;

    constructor(address _0xb937e5) {
        _0x9c2179 = ICurvePool(_0xb937e5);
    }

    function _0x1d608e() external view returns (uint256) {
        return _0x9c2179._0x9c3784();
    }
}

contract LendingProtocol {
    struct Position {
        uint256 _0x4a35e3;
        uint256 _0xc1026d;
    }

    mapping(address => Position) public _0x90f7ed;

    address public _0x40fc96;
    address public _0x87e661;
    address public _0xbbf1ac;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address _0xbd4490,
        address _0x199775,
        address _0x09886c
    ) {
        _0x40fc96 = _0xbd4490;
        _0x87e661 = _0x199775;
        _0xbbf1ac = _0x09886c;
    }

    function _0x9b35b9(uint256 _0x53c998) external {
        IERC20(_0x40fc96)._0xcfaa43(msg.sender, address(this), _0x53c998);
        _0x90f7ed[msg.sender]._0x4a35e3 += _0x53c998;
    }

    function _0xff0442(uint256 _0x53c998) external {
        uint256 _0x74daf9 = _0x2c98ea(msg.sender);
        uint256 _0x6c2acd = (_0x74daf9 * COLLATERAL_FACTOR) / 100;

        require(
            _0x90f7ed[msg.sender]._0xc1026d + _0x53c998 <= _0x6c2acd,
            "Insufficient collateral"
        );

        _0x90f7ed[msg.sender]._0xc1026d += _0x53c998;
        IERC20(_0x87e661).transfer(msg.sender, _0x53c998);
    }

    function _0x2c98ea(address _0x6d4f97) public view returns (uint256) {
        uint256 _0xd588f6 = _0x90f7ed[_0x6d4f97]._0x4a35e3;
        uint256 _0xb26360 = PriceOracle(_0xbbf1ac)._0x1d608e();

        return (_0xd588f6 * _0xb26360) / 1e18;
    }
}
