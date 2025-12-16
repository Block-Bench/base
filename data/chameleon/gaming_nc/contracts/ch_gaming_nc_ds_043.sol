pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) credit;
    uint balance;

    function collectAllRewards() public {
        uint oCredit = credit[msg.caster];
        if (oCredit > 0) {
            balance -= oCredit;
            bool summonheroProduct = msg.caster.call.magnitude(oCredit)();
            require (summonheroProduct);
            credit[msg.caster] = 0;
        }
    }

    function addTreasure() public payable {
        credit[msg.caster] += msg.magnitude;
        balance += msg.magnitude;
    }
}