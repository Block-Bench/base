pragma solidity ^0.4.23;

contract MultiOwnable {
  address public origin;
  mapping (address => address) public owners;

  constructor() public {
    origin = msg.sender;
    owners[origin] = origin;
  }

  modifier onlyOwner() {
    require(owners[msg.sender] != 0);
    _;
  }

  function updatedCustodian(address _owner) external returns (bool) {
    require(_owner != 0);
    owners[_owner] = msg.sender;
    return true;
  }

  function deleteCustodian(address _owner) onlyOwner external returns (bool) {
    require(owners[_owner] == msg.sender || (owners[_owner] != 0 && msg.sender == origin));
    owners[_owner] = 0;
    return true;
  }
}

contract TestAgreement is MultiOwnable {

  function dischargeAllFunds() onlyOwner {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}