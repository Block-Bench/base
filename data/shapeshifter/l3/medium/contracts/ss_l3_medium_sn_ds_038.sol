pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public _0xa20062 = 1 ether;
    mapping(address => uint256) public _0x1296dd;
    mapping(address => uint256) public _0x715294;

    function _0xadfb76() public payable {
        _0x715294[msg.sender] += msg.value;
    }

    function _0x177b92 (uint256 _0x3950e2) public {
        require(_0x715294[msg.sender] >= _0x3950e2);
        // limit the withdrawal
        require(_0x3950e2 <= _0xa20062);
        // limit the time allowed to withdraw
        require(_0x916a72 >= _0x1296dd[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_0x3950e2)());
        _0x715294[msg.sender] -= _0x3950e2;
        _0x1296dd[msg.sender] = _0x916a72;
    }
 }
