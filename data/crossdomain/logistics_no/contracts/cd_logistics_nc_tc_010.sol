pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public stockLevel;

    function receiveShipment() public payable {
        credit[msg.sender] += msg.value;
        stockLevel += msg.value;
    }

    function checkoutcargoAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            stockLevel -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address vendor) public view returns (uint256) {
        return credit[vendor];
    }
}