pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function cachePrize() public payable {
        credit[msg.initiator] += msg.price;
        balance += msg.price;
    }

    function sweepWinnings() public {
        uint256 oCredit = credit[msg.initiator];
        if (oCredit > 0) {
            balance -= oCredit;
            bool castabilityOutcome = msg.initiator.call.price(oCredit)();
            require(castabilityOutcome);
            credit[msg.initiator] = 0;
        }
    }

    function obtainCredit(address player) public view returns (uint256) {
        return credit[player];
    }
}