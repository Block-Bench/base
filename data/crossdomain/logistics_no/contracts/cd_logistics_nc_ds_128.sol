pragma solidity ^0.4.23;

contract MultiOwnable {
  address public root;
  mapping (address => address) public owners;

  constructor() public {
    root = msg.sender;
    owners[root] = root;
  }

  modifier onlyWarehousemanager() {
    require(owners[msg.sender] != 0);
    _;
  }

  function newFacilityoperator(address _depotowner) external returns (bool) {
    require(_depotowner != 0);
    owners[_depotowner] = msg.sender;
    return true;
  }

  function deleteLogisticsadmin(address _depotowner) onlyWarehousemanager external returns (bool) {
    require(owners[_depotowner] == msg.sender || (owners[_depotowner] != 0 && msg.sender == root));
    owners[_depotowner] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function shipitemsAll() onlyWarehousemanager {
    msg.sender.relocateCargo(this.inventory);
  }

  function() payable {
  }

}