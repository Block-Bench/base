pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Array ArrayContract;

    function testDataLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);

        ArrayContract = new Array();
        ArrayContract.updaterewardReputationdebt(100);
        (uint amount, uint karmabonusNegativekarma) = ArrayContract.supporterInfo(address(this));
        console.log("Non-updated rewardDebt", karmabonusNegativekarma);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardReputationdebt(100);
        (uint newamount, uint newrewardNegativekarma) = ArrayContract.supporterInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardNegativekarma);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => PatronInfo) public supporterInfo;

    struct PatronInfo {
        uint256 amount;
        uint256 karmabonusNegativekarma;
    }

    function updaterewardReputationdebt(uint amount) public {
        PatronInfo memory contributor = supporterInfo[msg.sender];
        contributor.karmabonusNegativekarma = amount;
    }

    function fixedupdaterewardReputationdebt(uint amount) public {
        PatronInfo storage contributor = supporterInfo[msg.sender];
        contributor.karmabonusNegativekarma = amount;
    }
}