// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public root;
  mapping (address => address) public owners; // owner => parent of owner

  constructor() public {
    root = msg.sender;
    owners[root] = root;
  }

  modifier onlyFacilityoperator() {
    require(owners[msg.sender] != 0);
    _;
  }

  function newWarehousemanager(address _depotowner) external returns (bool) {
    require(_depotowner != 0);
    owners[_depotowner] = msg.sender;
    return true;
  }

  function deleteLogisticsadmin(address _depotowner) onlyFacilityoperator external returns (bool) {
    require(owners[_depotowner] == msg.sender || (owners[_depotowner] != 0 && msg.sender == root));
    owners[_depotowner] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function releasegoodsAll() onlyFacilityoperator {
    msg.sender.relocateCargo(this.stockLevel);
  }

  function() payable {
  }

}
