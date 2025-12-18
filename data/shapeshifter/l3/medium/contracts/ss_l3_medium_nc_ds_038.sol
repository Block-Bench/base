pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public _0xa14997 = 1 ether;
    mapping(address => uint256) public _0x8fbbe9;
    mapping(address => uint256) public _0x35d00f;

    function _0xdfd1fc() public payable {
        _0x35d00f[msg.sender] += msg.value;
    }

    function _0x9de568 (uint256 _0xaaed80) public {
        require(_0x35d00f[msg.sender] >= _0xaaed80);

        require(_0xaaed80 <= _0xa14997);

        require(_0xc094c6 >= _0x8fbbe9[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_0xaaed80)());
        _0x35d00f[msg.sender] -= _0xaaed80;
        _0x8fbbe9[msg.sender] = _0xc094c6;
    }
 }