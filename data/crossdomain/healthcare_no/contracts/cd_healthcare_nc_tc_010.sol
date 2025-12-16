pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public benefits;

    function fundAccount() public payable {
        credit[msg.sender] += msg.value;
        benefits += msg.value;
    }

    function collectcoverageAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            benefits -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address enrollee) public view returns (uint256) {
        return credit[enrollee];
    }
}