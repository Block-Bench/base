pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0xa03adf = msg.sender;
    uint public _0xb37b98;

    modifier _0xfddb46 {
        require(msg.sender == _0xa03adf);
        _;
    }

    function() public payable {
        _0xb37b98++;
    }

    function _0xd2a594() public _0xfddb46 {
        _0xb974a2(address(this).balance);
    }

    function _0xb974a2(uint _0x4192d1) public _0xfddb46 {
        msg.sender.transfer(_0x4192d1);
    }

    function _0x3c8924(address _0x9158bf, uint _0x4192d1) public _0xfddb46 {
        _0x9158bf.call.value(_0x4192d1)();
    }
}