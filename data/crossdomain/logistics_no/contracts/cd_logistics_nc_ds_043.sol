pragma solidity ^0.4.19;

contract CommunityStoragevault {
    mapping (address => uint) credit;
    uint goodsOnHand;

    function dispatchshipmentAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            goodsOnHand -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function receiveShipment() public payable {
        credit[msg.sender] += msg.value;
        goodsOnHand += msg.value;
    }
}