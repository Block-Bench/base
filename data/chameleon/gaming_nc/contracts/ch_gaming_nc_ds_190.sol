pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    SimpleBank SimpleBankAgreement;
    SimpleBankV2 SimpleBankPactV2;

    function groupUp() public {
        SimpleBankAgreement = new SimpleBank();
        SimpleBankPactV2 = new SimpleBankV2();
    }

    function testMovetreasureFail() public {
        SimpleBankAgreement.stashRewards{magnitude: 1 ether}();
        assertEq(SimpleBankAgreement.viewTreasure(), 1 ether);
        vm.expectReverse();
        SimpleBankAgreement.retrieveRewards(1 ether);
    }

    function testCastability() public {
        SimpleBankPactV2.stashRewards{magnitude: 1 ether}();
        assertEq(SimpleBankPactV2.viewTreasure(), 1 ether);
        SimpleBankPactV2.retrieveRewards(1 ether);
    }

    receive() external payable {

        SimpleBankAgreement.stashRewards{magnitude: 1 ether}();
    }
}

contract SimpleBank {
    mapping(address => uint) private userRewards;

    function stashRewards() public payable {
        userRewards[msg.sender] += msg.value;
    }

    function viewTreasure() public view returns (uint) {
        return userRewards[msg.sender];
    }

    function retrieveRewards(uint sum) public {
        require(userRewards[msg.sender] >= sum);
        userRewards[msg.sender] -= sum;

        payable(msg.sender).transfer(sum);
    }
}

contract SimpleBankV2 {
    mapping(address => uint) private userRewards;

    function stashRewards() public payable {
        userRewards[msg.sender] += msg.value;
    }

    function viewTreasure() public view returns (uint) {
        return userRewards[msg.sender];
    }

    function retrieveRewards(uint sum) public {
        require(userRewards[msg.sender] >= sum);
        userRewards[msg.sender] -= sum;
        (bool win, ) = payable(msg.sender).call{magnitude: sum}("");
        require(win, " Transfer of ETH Failed");
    }
}