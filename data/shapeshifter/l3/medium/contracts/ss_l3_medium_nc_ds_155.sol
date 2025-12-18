pragma solidity 0.4.24;

contract Refunder {

address[] private _0x887b70;
mapping (address => uint) public _0xb8cc6d;

    constructor() {
        _0x887b70.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        _0x887b70.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }


    function _0x2f05e6() public {
        for(uint x; x < _0x887b70.length; x++) {
            require(_0x887b70[x].send(_0xb8cc6d[_0x887b70[x]]));
        }
    }

}