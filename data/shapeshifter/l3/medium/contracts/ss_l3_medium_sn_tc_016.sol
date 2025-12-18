// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Loan Token Contract
 * @notice Represents interest-bearing tokens for supplied assets
 */

interface IERC20 {
    function transfer(address _0x9e7845, uint256 _0x9d5289) external returns (bool);

    function _0x113f7f(address _0x26ded9) external view returns (uint256);
}

contract LoanToken {
    string public _0x1870db = "iETH";
    string public _0x571042 = "iETH";

    mapping(address => uint256) public _0x0a3ef6;
    uint256 public _0xf3227b;
    uint256 public _0xa2aad3;
    uint256 public _0xee8327;

    function _0xbe6590(
        address _0xf0d39f
    ) external payable returns (uint256 _0x34943e) {
        uint256 _0x4f68d0 = _0x9853da();
        _0x34943e = (msg.value * 1e18) / _0x4f68d0;

        _0x0a3ef6[_0xf0d39f] += _0x34943e;
        _0xf3227b += _0x34943e;
        _0xee8327 += msg.value;

        return _0x34943e;
    }

    function transfer(address _0x9e7845, uint256 _0x9d5289) external returns (bool) {
        require(_0x0a3ef6[msg.sender] >= _0x9d5289, "Insufficient balance");

        _0x0a3ef6[msg.sender] -= _0x9d5289;
        _0x0a3ef6[_0x9e7845] += _0x9d5289;

        _0x9a11e8(msg.sender, _0x9e7845, _0x9d5289);

        return true;
    }

    function _0x9a11e8(
        address from,
        address _0x9e7845,
        uint256 _0x9d5289
    ) internal {
        if (_0x896451(_0x9e7845)) {
            (bool _0x4f3bf8, ) = _0x9e7845.call("");
            _0x4f3bf8;
        }
    }

    function _0x2e58c7(
        address _0xf0d39f,
        uint256 _0x9d5289
    ) external returns (uint256 _0x61a7b7) {
        require(_0x0a3ef6[msg.sender] >= _0x9d5289, "Insufficient balance");

        uint256 _0x4f68d0 = _0x9853da();
        _0x61a7b7 = (_0x9d5289 * _0x4f68d0) / 1e18;

        _0x0a3ef6[msg.sender] -= _0x9d5289;
        _0xf3227b -= _0x9d5289;
        _0xee8327 -= _0x61a7b7;

        payable(_0xf0d39f).transfer(_0x61a7b7);

        return _0x61a7b7;
    }

    function _0x9853da() internal view returns (uint256) {
        if (_0xf3227b == 0) {
            return 1e18;
        }
        return (_0xee8327 * 1e18) / _0xf3227b;
    }

    function _0x896451(address _0x26ded9) internal view returns (bool) {
        uint256 _0x0517b9;
        assembly {
            _0x0517b9 := extcodesize(_0x26ded9)
        }
        return _0x0517b9 > 0;
    }

    function _0x113f7f(address _0x26ded9) external view returns (uint256) {
        return _0x0a3ef6[_0x26ded9];
    }

    receive() external payable {}
}
