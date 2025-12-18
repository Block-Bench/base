pragma solidity ^0.8.18;

import { Calls } from "./Calls.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { IAccount, PackedUserOperation } from "./interfaces/IAccount.sol";
import { IERC1271_MAGIC_VALUE_HASH } from "./interfaces/IERC1271.sol";
import { IEntryPoint } from "./interfaces/IEntryPoint.sol";


abstract contract ERC4337v07 is ReentrancyGuard, IAccount, Calls {

  uint256 internal constant SIG_VALIDATION_FAILED = 1;

  address public immutable j;

  error InvalidEntryPoint(address h);
  error ERC4337Disabled();

  constructor(
    address h
  ) {
    j = h;
  }


  function d(
    PackedUserOperation calldata n,
    bytes32 i,
    uint256 a
  ) external returns (uint256 c) {
    if (j == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != j) {
      revert InvalidEntryPoint(msg.sender);
    }


    if (a != 0) {
      IEntryPoint(j).l{ value: a }(address(this));
    }

    if (this.b(i, n.k) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }


  function e(
    bytes calldata m
  ) external f {
    if (j == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != j) {
      revert InvalidEntryPoint(msg.sender);
    }

    this.g(m);
  }

}