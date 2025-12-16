pragma solidity ^0.4.2;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SimpleDAO  is ReentrancyGuard {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function withdraw(uint amount) nonReentrant {
    if (credit[msg.sender]>= amount) {
      bool res = msg.sender.call.value(amount)();
      credit[msg.sender]-=amount;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}