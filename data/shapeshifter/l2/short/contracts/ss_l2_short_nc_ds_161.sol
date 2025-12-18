pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public f = false;

    struct NameRecord {
        bytes32 i;
        address c;
    }

    mapping(address => NameRecord) public a;
    mapping(bytes32 => address) public g;

    function e(bytes32 h, address b) public {

        NameRecord d;
        d.i = h;
        d.c = b;

        g[h] = b;
        a[msg.sender] = d;

        require(f);
    }
}