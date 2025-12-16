pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastCollectcoverageTime;
    mapping(address => uint256) public balances;

    function fundaccountFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function receivepayoutFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        // limit the withdrawal
        require(_weiToWithdraw <= withdrawalLimit);
        // limit the time allowed to withdraw
        require(now >= lastCollectcoverageTime[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_weiToWithdraw)());
        balances[msg.sender] -= _weiToWithdraw;
        lastCollectcoverageTime[msg.sender] = now;
    }
 }
