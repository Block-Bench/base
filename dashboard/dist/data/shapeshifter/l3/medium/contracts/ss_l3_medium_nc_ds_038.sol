pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public _0x17958c = 1 ether;
    mapping(address => uint256) public _0x6fcac1;
    mapping(address => uint256) public _0xf20f75;

    function _0x1fb9d5() public payable {
        _0xf20f75[msg.sender] += msg.value;
    }

    function _0x3ccece (uint256 _0x65b189) public {
        require(_0xf20f75[msg.sender] >= _0x65b189);

        require(_0x65b189 <= _0x17958c);

        require(_0x8133ba >= _0x6fcac1[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_0x65b189)());
        _0xf20f75[msg.sender] -= _0x65b189;
        _0x6fcac1[msg.sender] = _0x8133ba;
    }
 }