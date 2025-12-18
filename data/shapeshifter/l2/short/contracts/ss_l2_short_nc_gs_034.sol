pragma solidity ^0.8.27;

import "./Wallet.sol";


contract Factory {


  error DeployFailed(address c, bytes32 f);


  function e(address c, bytes32 f) public payable returns (address d) {
    bytes memory code = abi.a(Wallet.b, uint256(uint160(c)));
    assembly {
      d := create2(callvalue(), add(code, 32), mload(code), f)
    }
    if (d == address(0)) {
      revert DeployFailed(c, f);
    }
  }

}