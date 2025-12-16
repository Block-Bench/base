pragma solidity ^0.4.19;

contract CommunityLootvault {
    mapping (address => uint) credit;
    uint gemTotal;

    function collecttreasureAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            gemTotal -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function cacheTreasure() public payable {
        credit[msg.sender] += msg.value;
        gemTotal += msg.value;
    }
}