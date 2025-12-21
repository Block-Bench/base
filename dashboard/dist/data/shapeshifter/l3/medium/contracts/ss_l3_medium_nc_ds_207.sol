pragma solidity ^0.4.16;


contract ERC20 {
    function _0x47ff52() constant returns (uint _0x47ff52);
    function _0x7f7a8c(address _0x5deade) constant returns (uint balance);
    function transfer(address _0xce90fd, uint _0x4b4c33) returns (bool _0x120dba);
    function _0x58b17a(address _0xd969a0, address _0xce90fd, uint _0x4b4c33) returns (bool _0x120dba);
    function _0x2e501e(address _0x5aad8c, uint _0x4b4c33) returns (bool _0x120dba);
    function _0x496a80(address _0x5deade, address _0x5aad8c) constant returns (uint _0x44cd7d);
    event Transfer(address indexed _0xd969a0, address indexed _0xce90fd, uint _0x4b4c33);
    event Approval(address indexed _0x5deade, address indexed _0x5aad8c, uint _0x4b4c33);
}

contract TokenExchange{
    address private _0x42aa32;
    uint public _0x824ae3;
    ERC20 _0x044d6a;

    function TokenExchange(uint _0xa5006e, ERC20 _0x4f299a)
        public
    {
        _0x42aa32 = msg.sender;
        _0x824ae3 = _0xa5006e;
        _0x044d6a = _0x4f299a;
    }


    function _0xac2e4d(uint _0xefab3f) payable
        public
    {
        require(msg.value >= _0x824ae3);


        _0x044d6a._0x58b17a(msg.sender, _0x42aa32, _0x824ae3);

        _0x824ae3 = _0xefab3f;
        _0x42aa32 = msg.sender;
    }

    function _0xcb2229(uint _0xefab3f){
        require(msg.sender == _0x42aa32);
        if (block.timestamp > 0) { _0x824ae3 = _0xefab3f; }
    }

}