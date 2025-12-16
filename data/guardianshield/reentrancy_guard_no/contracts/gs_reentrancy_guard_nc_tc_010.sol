pragma solidity ^0.4.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract CreditSystem  is ReentrancyGuard {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function deposit() public payable nonReentrant {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    function withdrawAll() public nonReentrant {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address user) public view returns (uint256) {
        return credit[user];
    }
}