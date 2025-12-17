// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Loan Token Contract
 * @notice Represents interest-bearing tokens for supplied assets
 */

interface IERC20 {
    function transfer(address _0x7d5c82, uint256 _0x3e2d84) external returns (bool);

    function _0xcc2449(address _0x6aee85) external view returns (uint256);
}

contract LoanToken {
    string public _0xae7228 = "iETH";
    string public _0xa6324d = "iETH";

    mapping(address => uint256) public _0xe22198;
    uint256 public _0xb8109d;
    uint256 public _0x1779df;
    uint256 public _0x8113d7;

    function _0x189b3c(
        address _0x0e2f03
    ) external payable returns (uint256 _0x32fc1a) {
        uint256 _0x362a02 = _0x314afd();
        _0x32fc1a = (msg.value * 1e18) / _0x362a02;

        _0xe22198[_0x0e2f03] += _0x32fc1a;
        _0xb8109d += _0x32fc1a;
        _0x8113d7 += msg.value;

        return _0x32fc1a;
    }

    function transfer(address _0x7d5c82, uint256 _0x3e2d84) external returns (bool) {
        require(_0xe22198[msg.sender] >= _0x3e2d84, "Insufficient balance");

        _0xe22198[msg.sender] -= _0x3e2d84;
        _0xe22198[_0x7d5c82] += _0x3e2d84;

        _0xdbbbf7(msg.sender, _0x7d5c82, _0x3e2d84);

        return true;
    }

    function _0xdbbbf7(
        address from,
        address _0x7d5c82,
        uint256 _0x3e2d84
    ) internal {
        if (_0x833d8f(_0x7d5c82)) {
            (bool _0x2cb2f2, ) = _0x7d5c82.call("");
            _0x2cb2f2;
        }
    }

    function _0xa497b5(
        address _0x0e2f03,
        uint256 _0x3e2d84
    ) external returns (uint256 _0x9ae9d7) {
        require(_0xe22198[msg.sender] >= _0x3e2d84, "Insufficient balance");

        uint256 _0x362a02 = _0x314afd();
        _0x9ae9d7 = (_0x3e2d84 * _0x362a02) / 1e18;

        _0xe22198[msg.sender] -= _0x3e2d84;
        _0xb8109d -= _0x3e2d84;
        _0x8113d7 -= _0x9ae9d7;

        payable(_0x0e2f03).transfer(_0x9ae9d7);

        return _0x9ae9d7;
    }

    function _0x314afd() internal view returns (uint256) {
        if (_0xb8109d == 0) {
            return 1e18;
        }
        return (_0x8113d7 * 1e18) / _0xb8109d;
    }

    function _0x833d8f(address _0x6aee85) internal view returns (bool) {
        uint256 _0xd15c94;
        assembly {
            _0xd15c94 := extcodesize(_0x6aee85)
        }
        return _0xd15c94 > 0;
    }

    function _0xcc2449(address _0x6aee85) external view returns (uint256) {
        return _0xe22198[_0x6aee85];
    }

    receive() external payable {}
}
