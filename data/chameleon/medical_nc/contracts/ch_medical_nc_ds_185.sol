pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    SimplePool SimplePoolAgreement;

    function groupUp() public {
        SimplePoolAgreement = new SimplePool();
    }

    function testrounding_complication() public view {
        SimplePoolAgreement.acquireActiveCredit();
    }

    receive() external payable {}
}

contract SimplePool {
    uint public cumulativeLiability;
    uint public finalAccrueInterestMoment;
    uint public loanIdCredits;

    constructor() {
        cumulativeLiability = 10000e6;
        finalAccrueInterestMoment = block.timestamp - 1;
        loanIdCredits = 500e18;
    }

    function acquireActiveCredit() public view returns (uint _reward) {

        uint _momentDelta = block.timestamp - finalAccrueInterestMoment;


        if (_momentDelta == 0) return 0;


        _reward = (cumulativeLiability * _momentDelta) / (365 days * 1e18);
        console.chart("Current reward", _reward);


        _reward;
    }
}