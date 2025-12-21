pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);

        require(_weiToWithdraw <= withdrawalLimit);

        require(now >= lastWithdrawTime[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_weiToWithdraw)());
        balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = now;
    }
 
    // Unified dispatcher - merged from: withdrawFunds, depositFunds
    // Selectors: withdrawFunds=0, depositFunds=1
    function execute(uint8 _selector, uint256 _weiToWithdraw) public payable {
        // Original: withdrawFunds()
        if (_selector == 0) {
            require(balances[msg.sender] >= _weiToWithdraw);
            require(_weiToWithdraw <= withdrawalLimit);
            require(now >= lastWithdrawTime[msg.sender] + 1 weeks);
            require(msg.sender.call.value(_weiToWithdraw)());
            balances[msg.sender] -= _weiToWithdraw;
            lastWithdrawTime[msg.sender] = now;
        }
        // Original: depositFunds()
        else if (_selector == 1) {
            balances[msg.sender] += msg.value;
        }
    }
}