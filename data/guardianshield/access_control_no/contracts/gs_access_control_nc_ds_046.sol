pragma solidity ^0.4.2;

contract SimpleDAO {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function withdraw(uint amount) {
    if (credit[msg.sender]>= amount) {
      bool res = msg.sender.call.value(amount)();
      credit[msg.sender]-=amount;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}