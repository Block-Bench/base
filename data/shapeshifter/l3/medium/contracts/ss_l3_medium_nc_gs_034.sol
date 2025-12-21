pragma solidity ^0.8.27;

import "./Wallet.sol";


contract Factory {


  error DeployFailed(address _0x7893d6, bytes32 _0xdcdd1c);


  function _0xa57ada(address _0x7893d6, bytes32 _0xdcdd1c) public payable returns (address _0x4c13a9) {
    bytes memory code = abi._0x0db0b2(Wallet._0x6c0fd9, uint256(uint160(_0x7893d6)));
    assembly {
      _0x4c13a9 := create2(callvalue(), add(code, 32), mload(code), _0xdcdd1c)
    }
    if (_0x4c13a9 == address(0)) {
      revert DeployFailed(_0x7893d6, _0xdcdd1c);
    }
  }

}