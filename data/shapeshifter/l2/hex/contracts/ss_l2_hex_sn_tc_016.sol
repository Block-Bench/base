// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Loan Token Contract
 * @notice Represents interest-bearing tokens for supplied assets
 */

interface IERC20 {
    function transfer(address _0x442299, uint256 _0xd561a8) external returns (bool);

    function _0xe8c2d7(address _0x561431) external view returns (uint256);
}

contract LoanToken {
    string public _0xd60456 = "iETH";
    string public _0x8b2a1f = "iETH";

    mapping(address => uint256) public _0x29ea93;
    uint256 public _0xb105cb;
    uint256 public _0xd42de8;
    uint256 public _0x7d8a3c;

    function _0xfa6759(
        address _0xfbeebc
    ) external payable returns (uint256 _0xaa9c60) {
        uint256 _0xce3c6a = _0xb1f0cb();
        _0xaa9c60 = (msg.value * 1e18) / _0xce3c6a;

        _0x29ea93[_0xfbeebc] += _0xaa9c60;
        _0xb105cb += _0xaa9c60;
        _0x7d8a3c += msg.value;

        return _0xaa9c60;
    }

    function transfer(address _0x442299, uint256 _0xd561a8) external returns (bool) {
        require(_0x29ea93[msg.sender] >= _0xd561a8, "Insufficient balance");

        _0x29ea93[msg.sender] -= _0xd561a8;
        _0x29ea93[_0x442299] += _0xd561a8;

        _0x3c03b0(msg.sender, _0x442299, _0xd561a8);

        return true;
    }

    function _0x3c03b0(
        address from,
        address _0x442299,
        uint256 _0xd561a8
    ) internal {
        if (_0x9f9323(_0x442299)) {
            (bool _0xde2757, ) = _0x442299.call("");
            _0xde2757;
        }
    }

    function _0x370894(
        address _0xfbeebc,
        uint256 _0xd561a8
    ) external returns (uint256 _0x64a540) {
        require(_0x29ea93[msg.sender] >= _0xd561a8, "Insufficient balance");

        uint256 _0xce3c6a = _0xb1f0cb();
        _0x64a540 = (_0xd561a8 * _0xce3c6a) / 1e18;

        _0x29ea93[msg.sender] -= _0xd561a8;
        _0xb105cb -= _0xd561a8;
        _0x7d8a3c -= _0x64a540;

        payable(_0xfbeebc).transfer(_0x64a540);

        return _0x64a540;
    }

    function _0xb1f0cb() internal view returns (uint256) {
        if (_0xb105cb == 0) {
            return 1e18;
        }
        return (_0x7d8a3c * 1e18) / _0xb105cb;
    }

    function _0x9f9323(address _0x561431) internal view returns (bool) {
        uint256 _0x4f1b99;
        assembly {
            _0x4f1b99 := extcodesize(_0x561431)
        }
        return _0x4f1b99 > 0;
    }

    function _0xe8c2d7(address _0x561431) external view returns (uint256) {
        return _0x29ea93[_0x561431];
    }

    receive() external payable {}
}
