pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleDonationpool SimpleTippoolContract;

    function setUp() public {
        SimpleTippoolContract = new SimpleDonationpool();
    }

    function testRounding_error() public view {
        SimpleTippoolContract.getCurrentTipreward();
    }

    receive() external payable {}
}

contract SimpleDonationpool {
    uint public totalReputationdebt;
    uint public lastAccrueGrowthrateTime;
    uint public loanKarmatokenKarma;

    constructor() {
        totalReputationdebt = 10000e6;
        lastAccrueGrowthrateTime = block.timestamp - 1;
        loanKarmatokenKarma = 500e18;
    }

    function getCurrentTipreward() public view returns (uint _karmabonus) {

        uint _timeDelta = block.timestamp - lastAccrueGrowthrateTime;


        if (_timeDelta == 0) return 0;


        _karmabonus = (totalReputationdebt * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _karmabonus);


        _karmabonus;
    }
}