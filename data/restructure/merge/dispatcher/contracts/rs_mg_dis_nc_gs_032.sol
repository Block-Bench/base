pragma solidity ^0.8.18;

import { Calls } from "./Calls.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { IAccount, PackedUserOperation } from "./interfaces/IAccount.sol";
import { IERC1271_MAGIC_VALUE_HASH } from "./interfaces/IERC1271.sol";
import { IEntryPoint } from "./interfaces/IEntryPoint.sol";


abstract contract ERC4337v07 is ReentrancyGuard, IAccount, Calls {

  uint256 internal constant SIG_VALIDATION_FAILED = 1;

  address public immutable entrypoint;

  error InvalidEntryPoint(address _entrypoint);
  error ERC4337Disabled();

  constructor(
    address _entrypoint
  ) {
    entrypoint = _entrypoint;
  }


  function validateUserOp(
    PackedUserOperation calldata userOp,
    bytes32 userOpHash,
    uint256 missingAccountFunds
  ) external returns (uint256 validationData) {
    if (entrypoint == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != entrypoint) {
      revert InvalidEntryPoint(msg.sender);
    }


    if (missingAccountFunds != 0) {
      IEntryPoint(entrypoint).depositTo{ value: missingAccountFunds }(address(this));
    }

    if (this.isValidSignature(userOpHash, userOp.signature) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }


  function executeUserOp(
    bytes calldata _payload
  ) external nonReentrant {
    if (entrypoint == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != entrypoint) {
      revert InvalidEntryPoint(msg.sender);
    }

    this.selfExecute(_payload);
  }


    // Unified dispatcher - merged from: validateUserOp, executeUserOp
    // Selectors: validateUserOp=0, executeUserOp=1
    function execute(uint8 _selector, PackedUserOperation userOp, bytes _payload, bytes32 userOpHash, uint256 missingAccountFunds) public {
        // Original: validateUserOp()
        if (_selector == 0) {
            if (entrypoint == address(0)) {
            revert ERC4337Disabled();
            }
            if (msg.sender != entrypoint) {
            revert InvalidEntryPoint(msg.sender);
            }
            if (missingAccountFunds != 0) {
            IEntryPoint(entrypoint).depositTo{ value: missingAccountFunds }(address(this));
            }
            if (this.isValidSignature(userOpHash, userOp.signature) != IERC1271_MAGIC_VALUE_HASH) {
            return SIG_VALIDATION_FAILED;
            }
            return 0;
        }
        // Original: executeUserOp()
        else if (_selector == 1) {
            if (entrypoint == address(0)) {
            revert ERC4337Disabled();
            }
            if (msg.sender != entrypoint) {
            revert InvalidEntryPoint(msg.sender);
            }
            this.selfExecute(_payload);
        }
    }
}