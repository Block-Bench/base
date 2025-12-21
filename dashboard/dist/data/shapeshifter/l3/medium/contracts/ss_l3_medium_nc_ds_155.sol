pragma solidity 0.4.24;

contract Refunder {

address[] private _0x49fb8b;
mapping (address => uint) public _0x47e675;

    constructor() {
        _0x49fb8b.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        _0x49fb8b.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }


    function _0x2b0682() public {
        for(uint x; x < _0x49fb8b.length; x++) {
            require(_0x49fb8b[x].send(_0x47e675[_0x49fb8b[x]]));
        }
    }

}