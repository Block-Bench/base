pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastCashoutTime;
    mapping(address => uint256) public balances;

    function tipFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function redeemkarmaFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);

        require(_weiToWithdraw <= withdrawalLimit);

        require(now >= lastCashoutTime[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_weiToWithdraw)());
        balances[msg.sender] -= _weiToWithdraw;
        lastCashoutTime[msg.sender] = now;
    }
 }