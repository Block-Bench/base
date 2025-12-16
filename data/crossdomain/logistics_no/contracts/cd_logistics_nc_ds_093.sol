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
        ArrayContract.updaterewardUnpaidstorage(100);
        (uint amount, uint performancebonusOutstandingfees) = ArrayContract.consigneeInfo(address(this));
        console.log("Non-updated rewardDebt", performancebonusOutstandingfees);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardUnpaidstorage(100);
        (uint newamount, uint newrewardUnpaidstorage) = ArrayContract.consigneeInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardUnpaidstorage);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => ShipperInfo) public consigneeInfo;

    struct ShipperInfo {
        uint256 amount;
        uint256 performancebonusOutstandingfees;
    }

    function updaterewardUnpaidstorage(uint amount) public {
        ShipperInfo memory vendor = consigneeInfo[msg.sender];
        vendor.performancebonusOutstandingfees = amount;
    }

    function fixedupdaterewardUnpaidstorage(uint amount) public {
        ShipperInfo storage vendor = consigneeInfo[msg.sender];
        vendor.performancebonusOutstandingfees = amount;
    }
}