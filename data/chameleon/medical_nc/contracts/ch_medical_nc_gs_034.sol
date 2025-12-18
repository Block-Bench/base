pragma solidity ^0.8.27;

import "./Wallet.sol";


contract ClinicFactory {


  error DeployFailed(address _mainModule, bytes32 _salt);


  function deploy(address _mainModule, bytes32 _salt) public payable returns (address _contract) {
    bytes memory code = abi.encodePacked(PatientAccount.creationCode, uint256(uint160(_mainModule)));
    assembly {
      _contract := create2(callvalue(), append(code, 32), mload(code), _salt)
    }
    if (_contract == address(0)) {
      revert DeployFailed(_mainModule, _salt);
    }
  }

}