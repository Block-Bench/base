pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    SimplePool SimplePoolAgreement;

    function collectionUp() public {
        SimplePoolAgreement = new SimplePool();
    }

    function testrounding_fault() public view {
        SimplePoolAgreement.retrievePresentBounty();
    }

    receive() external payable {}
}

contract SimplePool {
    uint public completeObligation;
    uint public finalAccrueInterestInstant;
    uint public loanMedalLootbalance;

    constructor() {
        completeObligation = 10000e6;
        finalAccrueInterestInstant = block.timestamp - 1;
        loanMedalLootbalance = 500e18;
    }

    function retrievePresentBounty() public view returns (uint _reward) {

        uint _instantDelta = block.timestamp - finalAccrueInterestInstant;


        if (_instantDelta == 0) return 0;


        _reward = (completeObligation * _instantDelta) / (365 days * 1e18);
        console.record("Current reward", _reward);


        _reward;
    }
}