pragma solidity ^0.8.18;

import { Calls } from "./Calls.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { IAccount, PackedUserOperation } from "./interfaces/IAccount.sol";
import { IERC1271_MAGIC_VALUE_HASH } from "./interfaces/IERC1271.sol";
import { IEntryPoint } from "./interfaces/IEntryPoint.sol";


abstract contract ERC4337v07 is ReentrancyGuard, IAccount, Calls {

  uint256 internal constant SIG_VALIDATION_FAILED = 1;

  address public immutable _0x54ece1;

  error InvalidEntryPoint(address _0x7b75df);
  error ERC4337Disabled();

  constructor(
    address _0x7b75df
  ) {
    _0x54ece1 = _0x7b75df;
  }


  function _0x680ef1(
    PackedUserOperation calldata _0x5a934c,
    bytes32 _0x4a6b57,
    uint256 _0xaf2a90
  ) external returns (uint256 _0xf7a5a6) {
    if (_0x54ece1 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0x54ece1) {
      revert InvalidEntryPoint(msg.sender);
    }


    if (_0xaf2a90 != 0) {
      IEntryPoint(_0x54ece1)._0xf9020b{ value: _0xaf2a90 }(address(this));
    }

    if (this._0xc1f6a8(_0x4a6b57, _0x5a934c._0x09e918) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }


  function _0x81588f(
    bytes calldata _0xf77f6c
  ) external _0x29061a {
    if (_0x54ece1 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0x54ece1) {
      revert InvalidEntryPoint(msg.sender);
    }

    this._0xa86a9f(_0xf77f6c);
  }

}