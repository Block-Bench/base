pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function transferOwner(address _owner) public onlyOwner { Owner = _owner; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract VaultProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            deposit();
        }
    }

    function deposit() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function withdraw(uint256 amount) public onlyOwner {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.transfer(amount);
        }
    }

    // Unified dispatcher - merged from: proxy, transferOwner, Vault
    // Selectors: proxy=0, transferOwner=1, Vault=2
    function execute(uint8 _selector, address _owner, address target, bytes data) public payable {
        // Original: proxy()
        if (_selector == 0) {
            target.call.value(msg.value)(data);
        }
        // Original: transferOwner()
        else if (_selector == 1) {
            Owner = _owner;
        }
        // Original: Vault()
        else if (_selector == 2) {
            if (msg.sender == tx.origin) {
            Owner = msg.sender;
            deposit();
            }
        }
    }
}