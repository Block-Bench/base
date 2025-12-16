pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public karma;

    function back() public payable {
        credit[msg.sender] += msg.value;
        karma += msg.value;
    }

    function cashoutAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            karma -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address supporter) public view returns (uint256) {
        return credit[supporter];
    }
}