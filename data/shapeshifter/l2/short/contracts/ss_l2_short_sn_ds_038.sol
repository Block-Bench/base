pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public b = 1 ether;
    mapping(address => uint256) public a;
    mapping(address => uint256) public f;

    function e() public payable {
        f[msg.sender] += msg.value;
    }

    function d (uint256 c) public {
        require(f[msg.sender] >= c);
        // limit the withdrawal
        require(c <= b);
        // limit the time allowed to withdraw
        require(g >= a[msg.sender] + 1 weeks);
        require(msg.sender.call.value(c)());
        f[msg.sender] -= c;
        a[msg.sender] = g;
    }
 }
