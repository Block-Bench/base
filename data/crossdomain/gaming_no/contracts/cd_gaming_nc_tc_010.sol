pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public goldHolding;

    function cacheTreasure() public payable {
        credit[msg.sender] += msg.value;
        goldHolding += msg.value;
    }

    function redeemgoldAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            goldHolding -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address adventurer) public view returns (uint256) {
        return credit[adventurer];
    }
}