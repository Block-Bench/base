pragma solidity 0.4.24;

contract Refunder {

address[] private a;
mapping (address => uint) public c;

    constructor() {
        a.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        a.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }


    function b() public {
        for(uint x; x < a.length; x++) {
            require(a[x].send(c[a[x]]));
        }
    }

}