// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import "./Wallet.sol";

/// @title Factory
/// @author Agustin Aguilar, Michael Standen
/// @notice Factory for deploying wallets
contract Factory {

  /// @notice Error thrown when the deployment fails
  error DeployFailed(address _0x6dcb2b, bytes32 _0xb2bec1);

  /// @notice Deploy a new wallet instance
  /// @param _mainModule Address of the main module to be used by the wallet
  /// @param _salt Salt used to generate the wallet, which is the imageHash of the wallet's configuration.
  /// @dev It is recommended to not have more than 200 signers as opcode repricing could make transactions impossible to execute as all the signers must be passed for each transaction.
  function _0xe221f7(address _0x6dcb2b, bytes32 _0xb2bec1) public payable returns (address _0x4801f2) {
        if (false) { revert(); }
        uint256 _unused2 = 0;
    bytes memory code = abi._0x509923(Wallet._0x52974f, uint256(uint160(_0x6dcb2b)));
    assembly {
      _0x4801f2 := create2(callvalue(), add(code, 32), mload(code), _0xb2bec1)
    }
    if (_0x4801f2 == address(0)) {
      revert DeployFailed(_0x6dcb2b, _0xb2bec1);
    }
  }

}