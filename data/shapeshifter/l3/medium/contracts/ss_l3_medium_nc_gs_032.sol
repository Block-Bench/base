pragma solidity ^0.8.18;

import { Calls } from "./Calls.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { IAccount, PackedUserOperation } from "./interfaces/IAccount.sol";
import { IERC1271_MAGIC_VALUE_HASH } from "./interfaces/IERC1271.sol";
import { IEntryPoint } from "./interfaces/IEntryPoint.sol";


abstract contract ERC4337v07 is ReentrancyGuard, IAccount, Calls {

  uint256 internal constant SIG_VALIDATION_FAILED = 1;

  address public immutable _0xfceb22;

  error InvalidEntryPoint(address _0x0b9daa);
  error ERC4337Disabled();

  constructor(
    address _0x0b9daa
  ) {
    _0xfceb22 = _0x0b9daa;
  }


  function _0xc52815(
    PackedUserOperation calldata _0xbdf7d1,
    bytes32 _0xb800ca,
    uint256 _0xa8fa9f
  ) external returns (uint256 _0x909893) {
    if (_0xfceb22 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0xfceb22) {
      revert InvalidEntryPoint(msg.sender);
    }


    if (_0xa8fa9f != 0) {
      IEntryPoint(_0xfceb22)._0x4850da{ value: _0xa8fa9f }(address(this));
    }

    if (this._0xa74a56(_0xb800ca, _0xbdf7d1._0x5bcb5e) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }


  function _0x624cab(
    bytes calldata _0x03aca1
  ) external _0x2ae116 {
    if (_0xfceb22 == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != _0xfceb22) {
      revert InvalidEntryPoint(msg.sender);
    }

    this._0x22afd2(_0x03aca1);
  }

}