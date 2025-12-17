pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public _0x3a6f30 = 1 ether;
    mapping(address => uint256) public _0x7e105f;
    mapping(address => uint256) public _0x178ba9;

    function _0xdc8585() public payable {
        _0x178ba9[msg.sender] += msg.value;
    }

    function _0x2e4fad (uint256 _0x0da442) public {
        require(_0x178ba9[msg.sender] >= _0x0da442);
        // limit the withdrawal
        require(_0x0da442 <= _0x3a6f30);
        // limit the time allowed to withdraw
        require(_0x3ae809 >= _0x7e105f[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_0x0da442)());
        _0x178ba9[msg.sender] -= _0x0da442;
        _0x7e105f[msg.sender] = _0x3ae809;
    }
 }
