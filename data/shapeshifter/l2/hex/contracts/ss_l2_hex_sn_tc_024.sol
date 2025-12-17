// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x1810d3(address _0x44c308) external view returns (uint256);

    function transfer(address _0xf84ffa, uint256 _0x9e78a3) external returns (bool);

    function _0x3122b3(
        address from,
        address _0xf84ffa,
        uint256 _0x9e78a3
    ) external returns (bool);
}

interface ICurvePool {
    function _0x85e01e() external view returns (uint256);

    function _0x06ae39(
        uint256[3] calldata _0x5ffce8,
        uint256 _0xbf78ac
    ) external;
}

contract PriceOracle {
    ICurvePool public _0x052f05;

    constructor(address _0x1c7481) {
        _0x052f05 = ICurvePool(_0x1c7481);
    }

    function _0x88b7b5() external view returns (uint256) {
        return _0x052f05._0x85e01e();
    }
}

contract LendingProtocol {
    struct Position {
        uint256 _0x2f3d29;
        uint256 _0x7c9196;
    }

    mapping(address => Position) public _0x73d1f4;

    address public _0xbc2654;
    address public _0xcb17e8;
    address public _0x91af48;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address _0x504fad,
        address _0xa862df,
        address _0x132a17
    ) {
        _0xbc2654 = _0x504fad;
        _0xcb17e8 = _0xa862df;
        _0x91af48 = _0x132a17;
    }

    function _0x742087(uint256 _0x9e78a3) external {
        IERC20(_0xbc2654)._0x3122b3(msg.sender, address(this), _0x9e78a3);
        _0x73d1f4[msg.sender]._0x2f3d29 += _0x9e78a3;
    }

    function _0x88c483(uint256 _0x9e78a3) external {
        uint256 _0x2ddb99 = _0x73381d(msg.sender);
        uint256 _0xdb2a4c = (_0x2ddb99 * COLLATERAL_FACTOR) / 100;

        require(
            _0x73d1f4[msg.sender]._0x7c9196 + _0x9e78a3 <= _0xdb2a4c,
            "Insufficient collateral"
        );

        _0x73d1f4[msg.sender]._0x7c9196 += _0x9e78a3;
        IERC20(_0xcb17e8).transfer(msg.sender, _0x9e78a3);
    }

    function _0x73381d(address _0x9976de) public view returns (uint256) {
        uint256 _0x12081d = _0x73d1f4[_0x9976de]._0x2f3d29;
        uint256 _0x80008c = PriceOracle(_0x91af48)._0x88b7b5();

        return (_0x12081d * _0x80008c) / 1e18;
    }
}
