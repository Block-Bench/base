pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public f;
    uint256 public balance;

    function e() public payable {
        f[msg.sender] += msg.value;
        balance += msg.value;
    }

    function a() public {
        uint256 d = f[msg.sender];
        if (d > 0) {
            balance -= d;
            bool b = msg.sender.call.value(d)();
            require(b);
            f[msg.sender] = 0;
        }
    }

    function c(address g) public view returns (uint256) {
        return f[g];
    }
}