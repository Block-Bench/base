pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0xc2ea3c = msg.sender;
    uint public _0x85786a;

    modifier _0xa19a6a {
        require(msg.sender == _0xc2ea3c);
        _;
    }

    function() public payable {
        _0x85786a++;
    }

    function _0xaf6877() public _0xa19a6a {
        _0xf13e0c(address(this).balance);
    }

    function _0xf13e0c(uint _0x3d520d) public _0xa19a6a {
        msg.sender.transfer(_0x3d520d);
    }

    function _0x93bdd3(address _0xe6ef7a, uint _0x3d520d, bytes _0x878b15) public _0xa19a6a {
        _0xe6ef7a.call.value(_0x3d520d)(_0x878b15);
    }
}