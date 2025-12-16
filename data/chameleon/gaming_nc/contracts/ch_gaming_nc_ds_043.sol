pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) credit;
    uint balance;

    function collectAllRewards() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool summonheroProduct = msg.sender.call.magnitude(oCredit)();
            require (summonheroProduct);
            credit[msg.sender] = 0;
        }
    }

    function addTreasure() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }
}