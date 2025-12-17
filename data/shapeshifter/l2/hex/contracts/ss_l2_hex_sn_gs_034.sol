// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import "./Wallet.sol";

/// @title Factory
/// @author Agustin Aguilar, Michael Standen
/// @notice Factory for deploying wallets
contract Factory {

  /// @notice Error thrown when the deployment fails
  error DeployFailed(address _0xfea8f7, bytes32 _0x89c81f);

  /// @notice Deploy a new wallet instance
  /// @param _mainModule Address of the main module to be used by the wallet
  /// @param _salt Salt used to generate the wallet, which is the imageHash of the wallet's configuration.
  /// @dev It is recommended to not have more than 200 signers as opcode repricing could make transactions impossible to execute as all the signers must be passed for each transaction.
  function _0xfed844(address _0xfea8f7, bytes32 _0x89c81f) public payable returns (address _0xd8134d) {
    bytes memory code = abi._0x61d24e(Wallet._0x5916df, uint256(uint160(_0xfea8f7)));
    assembly {
      _0xd8134d := create2(callvalue(), add(code, 32), mload(code), _0x89c81f)
    }
    if (_0xd8134d == address(0)) {
      revert DeployFailed(_0xfea8f7, _0x89c81f);
    }
  }

}