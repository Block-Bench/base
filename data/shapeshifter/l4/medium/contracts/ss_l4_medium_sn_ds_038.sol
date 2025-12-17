pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public _0xfad133 = 1 ether;
    mapping(address => uint256) public _0x985cc1;
    mapping(address => uint256) public _0x7ac085;

    function _0x5ab786() public payable {
        // Placeholder for future logic
        uint256 _unused2 = 0;
        _0x7ac085[msg.sender] += msg.value;
    }

    function _0x118acc (uint256 _0x0d67dc) public {
        bool _flag3 = false;
        bool _flag4 = false;
        require(_0x7ac085[msg.sender] >= _0x0d67dc);
        // limit the withdrawal
        require(_0x0d67dc <= _0xfad133);
        // limit the time allowed to withdraw
        require(_0xfa6975 >= _0x985cc1[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_0x0d67dc)());
        _0x7ac085[msg.sender] -= _0x0d67dc;
        _0x985cc1[msg.sender] = _0xfa6975;
    }
 }
