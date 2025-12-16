pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastReceivepayoutTime;
    mapping(address => uint256) public balances;

    function addcoverageFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function collectcoverageFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);

        require(_weiToWithdraw <= withdrawalLimit);

        require(now >= lastReceivepayoutTime[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_weiToWithdraw)());
        balances[msg.sender] -= _weiToWithdraw;
        lastReceivepayoutTime[msg.sender] = now;
    }
 }