pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public e = false;

    struct NameRecord {
        bytes32 i;
        address c;
    }

    mapping(address => NameRecord) public a;
    mapping(bytes32 => address) public g;

    function f(bytes32 h, address b) public {

        NameRecord d;
        d.i = h;
        d.c = b;

        g[h] = b;
        a[msg.sender] = d;

        require(e);
    }
}