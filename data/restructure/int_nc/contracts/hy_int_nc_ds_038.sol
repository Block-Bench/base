pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawFunds (uint256 _weiToWithdraw) public {
        _performWithdrawFundsHandler(msg.sender, _weiToWithdraw);
    }

    function _performWithdrawFundsHandler(address _sender, uint256 _weiToWithdraw) internal {
        require(balances[_sender] >= _weiToWithdraw);
        require(_weiToWithdraw <= withdrawalLimit);
        require(now >= lastWithdrawTime[_sender] + 1 weeks);
        require(_sender.call.value(_weiToWithdraw)());
        balances[_sender] -= _weiToWithdraw;
        lastWithdrawTime[_sender] = now;
    }
 }