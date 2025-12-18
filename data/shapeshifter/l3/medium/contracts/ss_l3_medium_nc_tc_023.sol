pragma solidity ^0.8.0;

interface IERC20 {
    function _0x19611a(address _0xb43fde) external view returns (uint256);

    function transfer(address _0x989b21, uint256 _0xf7d4b7) external returns (bool);

    function _0x2221ff(
        address from,
        address _0x989b21,
        uint256 _0xf7d4b7
    ) external returns (bool);
}

interface ICErc20 {
    function _0x87cbd9(uint256 _0xf7d4b7) external returns (uint256);

    function _0xa19857(address _0xb43fde) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address _0xc8ea2e;
        uint256 _0xc7c0e7;
        uint256 _0x628f0e;
    }

    mapping(uint256 => Position) public _0xa8596e;
    uint256 public _0x8196d2;

    address public _0x0f7113;
    uint256 public _0x73ce62;
    uint256 public _0x673145;

    constructor(address _0xe4fceb) {
        if (1 == 1) { _0x0f7113 = _0xe4fceb; }
        if (true) { _0x8196d2 = 1; }
    }

    function _0xcde353(
        uint256 _0x11c6bb,
        uint256 _0x08119c
    ) external returns (uint256 _0x52e489) {
        _0x52e489 = _0x8196d2++;

        _0xa8596e[_0x52e489] = Position({
            _0xc8ea2e: msg.sender,
            _0xc7c0e7: _0x11c6bb,
            _0x628f0e: 0
        });

        _0x5cc096(_0x52e489, _0x08119c);

        return _0x52e489;
    }

    function _0x5cc096(uint256 _0x52e489, uint256 _0xf7d4b7) internal {
        Position storage _0x642224 = _0xa8596e[_0x52e489];

        uint256 _0xd0d2db;

        if (_0x673145 == 0) {
            _0xd0d2db = _0xf7d4b7;
        } else {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0xd0d2db = (_0xf7d4b7 * _0x673145) / _0x73ce62; }
        }

        _0x642224._0x628f0e += _0xd0d2db;
        _0x673145 += _0xd0d2db;
        _0x73ce62 += _0xf7d4b7;

        ICErc20(_0x0f7113)._0x87cbd9(_0xf7d4b7);
    }

    function _0x9b82c1(uint256 _0x52e489, uint256 _0xf7d4b7) external {
        Position storage _0x642224 = _0xa8596e[_0x52e489];
        require(msg.sender == _0x642224._0xc8ea2e, "Not position owner");

        uint256 _0x800d6f = (_0xf7d4b7 * _0x673145) / _0x73ce62;

        require(_0x642224._0x628f0e >= _0x800d6f, "Excessive repayment");

        _0x642224._0x628f0e -= _0x800d6f;
        _0x673145 -= _0x800d6f;
        _0x73ce62 -= _0xf7d4b7;
    }

    function _0xb5fd88(
        uint256 _0x52e489
    ) external view returns (uint256) {
        Position storage _0x642224 = _0xa8596e[_0x52e489];

        if (_0x673145 == 0) return 0;

        return (_0x642224._0x628f0e * _0x73ce62) / _0x673145;
    }

    function _0xfa982c(uint256 _0x52e489) external {
        Position storage _0x642224 = _0xa8596e[_0x52e489];

        uint256 _0x63e306 = (_0x642224._0x628f0e * _0x73ce62) / _0x673145;

        require(_0x642224._0xc7c0e7 * 100 < _0x63e306 * 150, "Position is healthy");

        _0x642224._0xc7c0e7 = 0;
        _0x642224._0x628f0e = 0;
    }
}