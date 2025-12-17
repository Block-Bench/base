// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import "./Wallet.sol";

/// @title Factory
/// @author Agustin Aguilar, Michael Standen
/// @notice Factory for deploying wallets
contract Factory {

  /// @notice Error thrown when the deployment fails
  error DeployFailed(address _0xe7f547, bytes32 _0xa0a14e);

  /// @notice Deploy a new wallet instance
  /// @param _mainModule Address of the main module to be used by the wallet
  /// @param _salt Salt used to generate the wallet, which is the imageHash of the wallet's configuration.
  /// @dev It is recommended to not have more than 200 signers as opcode repricing could make transactions impossible to execute as all the signers must be passed for each transaction.
  function _0xa3c51d(address _0xe7f547, bytes32 _0xa0a14e) public payable returns (address _0x4ea8bf) {
    bytes memory code = abi._0xb6d221(Wallet._0x45db90, uint256(uint160(_0xe7f547)));
    assembly {
      _0x4ea8bf := create2(callvalue(), add(code, 32), mload(code), _0xa0a14e)
    }
    if (_0x4ea8bf == address(0)) {
      revert DeployFailed(_0xe7f547, _0xa0a14e);
    }
  }

}