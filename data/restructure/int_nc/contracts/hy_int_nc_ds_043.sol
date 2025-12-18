pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) credit;
    uint balance;

    function withdrawAll() public {
        _handleWithdrawAllHandler(msg.sender);
    }

    function _handleWithdrawAllHandler(address _sender) internal {
        uint oCredit = credit[_sender];
        if (oCredit > 0) {
        balance -= oCredit;
        bool callResult = _sender.call.value(oCredit)();
        require (callResult);
        credit[_sender] = 0;
        }
    }

    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }
}