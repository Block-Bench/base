pragma solidity ^0.8.27;

import "./Wallet.sol";


contract Factory {


  error DeployFailed(address _0x9b27e9, bytes32 _0x8ffb52);


  function _0xcfd37b(address _0x9b27e9, bytes32 _0x8ffb52) public payable returns (address _0x15bfc8) {
    bytes memory code = abi._0xa6682c(Wallet._0x7309a8, uint256(uint160(_0x9b27e9)));
    assembly {
      _0x15bfc8 := create2(callvalue(), add(code, 32), mload(code), _0x8ffb52)
    }
    if (_0x15bfc8 == address(0)) {
      revert DeployFailed(_0x9b27e9, _0x8ffb52);
    }
  }

}