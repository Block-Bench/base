pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public supervisor;
    bool public claimed;
    uint public benefitPayout;

    function EthTxOrderDependenceMinimal() public {
        supervisor = msg.sender;
    }

    function setCoveragereward() public payable {
        require (!claimed);

        require(msg.sender == supervisor);
        supervisor.transferBenefit(benefitPayout);
        benefitPayout = msg.value;
    }

    function requestbenefitBenefitpayout(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.transferBenefit(benefitPayout);
        claimed = true;
    }
}