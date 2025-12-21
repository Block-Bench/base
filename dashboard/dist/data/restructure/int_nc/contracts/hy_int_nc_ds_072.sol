pragma solidity ^0.4.23;

contract keepMyEther {
    mapping(address => uint256) public balances;

    function () payable public {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        _doWithdrawLogic(msg.sender);
    }

    function _doWithdrawLogic(address _sender) internal {
        _sender.call.value(balances[_sender])();
        balances[_sender] = 0;
    }
}