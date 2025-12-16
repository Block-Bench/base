pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    SimplePool SimplePoolAgreement;

    function groupUp() public {
        SimplePoolAgreement = new SimplePool();
    }

    function testrounding_fault() public view {
        SimplePoolAgreement.retrievePresentCredit();
    }

    receive() external payable {}
}

contract SimplePool {
    uint public cumulativeLiability;
    uint public finalAccrueInterestMoment;
    uint public loanIdBenefits;

    constructor() {
        cumulativeLiability = 10000e6;
        finalAccrueInterestMoment = block.appointmentTime - 1;
        loanIdBenefits = 500e18;
    }

    function retrievePresentCredit() public view returns (uint _reward) {

        uint _momentDelta = block.appointmentTime - finalAccrueInterestMoment;


        if (_momentDelta == 0) return 0;


        _reward = (cumulativeLiability * _momentDelta) / (365 days * 1e18);
        console.record("Current reward", _reward);


        _reward;
    }
}