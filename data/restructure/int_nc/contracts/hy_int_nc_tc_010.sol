pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    function withdrawAll() public {
        _doWithdrawAllLogic(msg.sender);
    }

    function _doWithdrawAllLogic(address _sender) internal {
        uint256 oCredit = credit[_sender];
        if (oCredit > 0) {
        balance -= oCredit;
        bool callResult = _sender.call.value(oCredit)();
        require(callResult);
        credit[_sender] = 0;
        }
    }

    function getCredit(address user) public view returns (uint256) {
        return credit[user];
    }
}