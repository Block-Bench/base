// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import "./Wallet.sol";

/// @title Factory
/// @author Agustin Aguilar, Michael Standen
/// @notice Factory for deploying wallets
contract Factory {

  /// @notice Error thrown when the deployment fails
  error DeployFailed(address c, bytes32 f);

  /// @notice Deploy a new wallet instance
  /// @param _mainModule Address of the main module to be used by the wallet
  /// @param _salt Salt used to generate the wallet, which is the imageHash of the wallet's configuration.
  /// @dev It is recommended to not have more than 200 signers as opcode repricing could make transactions impossible to execute as all the signers must be passed for each transaction.
  function e(address c, bytes32 f) public payable returns (address d) {
    bytes memory code = abi.b(Wallet.a, uint256(uint160(c)));
    assembly {
      d := create2(callvalue(), add(code, 32), mload(code), f)
    }
    if (d == address(0)) {
      revert DeployFailed(c, f);
    }
  }

}