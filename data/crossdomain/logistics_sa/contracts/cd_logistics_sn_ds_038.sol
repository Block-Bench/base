pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastCheckoutcargoTime;
    mapping(address => uint256) public balances;

    function receiveshipmentFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function dispatchshipmentFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        // limit the withdrawal
        require(_weiToWithdraw <= withdrawalLimit);
        // limit the time allowed to withdraw
        require(now >= lastCheckoutcargoTime[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_weiToWithdraw)());
        balances[msg.sender] -= _weiToWithdraw;
        lastCheckoutcargoTime[msg.sender] = now;
    }
 }
