// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import "./Wallet.sol";

/// @title Factory
/// @author Agustin Aguilar, Michael Standen
/// @notice Factory for deploying wallets
contract Factory {

  /// @notice Error thrown when the deployment fails
  error DeployFailed(address _0xe05f3f, bytes32 _0x15ccae);

  /// @notice Deploy a new wallet instance
  /// @param _mainModule Address of the main module to be used by the wallet
  /// @param _salt Salt used to generate the wallet, which is the imageHash of the wallet's configuration.
  /// @dev It is recommended to not have more than 200 signers as opcode repricing could make transactions impossible to execute as all the signers must be passed for each transaction.
  function _0x86efe6(address _0xe05f3f, bytes32 _0x15ccae) public payable returns (address _0xd5bc24) {
    bytes memory code = abi._0x4be71b(Wallet._0x2ae119, uint256(uint160(_0xe05f3f)));
    assembly {
      _0xd5bc24 := create2(callvalue(), add(code, 32), mload(code), _0x15ccae)
    }
    if (_0xd5bc24 == address(0)) {
      revert DeployFailed(_0xe05f3f, _0x15ccae);
    }
  }

}