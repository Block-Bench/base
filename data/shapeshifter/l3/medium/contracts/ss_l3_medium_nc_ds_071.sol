pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0x3b3208 = msg.sender;
    uint public _0x6e660a;

    modifier _0x8bc7fb {
        require(msg.sender == _0x3b3208);
        _;
    }

    function() public payable {
        _0x6e660a++;
    }

    function _0x3b523a() public _0x8bc7fb {
        _0x8ae689(address(this).balance);
    }

    function _0x8ae689(uint _0x082326) public _0x8bc7fb {
        msg.sender.transfer(_0x082326);
    }

    function _0xef36b1(address _0x90f494, uint _0x082326) public _0x8bc7fb {
        _0x90f494.call.value(_0x082326)();
    }
}