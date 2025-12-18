pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) e;
    uint balance;

    function a() public {
        uint c = e[msg.sender];
        if (c > 0) {
            balance -= c;
            bool b = msg.sender.call.value(c)();
            require (b);
            e[msg.sender] = 0;
        }
    }

    function d() public payable {
        e[msg.sender] += msg.value;
        balance += msg.value;
    }
}