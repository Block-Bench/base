pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public _0xc6d741 = 1 ether;
    mapping(address => uint256) public _0x7e19b0;
    mapping(address => uint256) public _0x951409;

    function _0xf0aed4() public payable {
        _0x951409[msg.sender] += msg.value;
    }

    function _0x6c2c98 (uint256 _0xc0c6cf) public {
        require(_0x951409[msg.sender] >= _0xc0c6cf);
        // limit the withdrawal
        require(_0xc0c6cf <= _0xc6d741);
        // limit the time allowed to withdraw
        require(_0xf2cfda >= _0x7e19b0[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_0xc0c6cf)());
        _0x951409[msg.sender] -= _0xc0c6cf;
        _0x7e19b0[msg.sender] = _0xf2cfda;
    }
 }
