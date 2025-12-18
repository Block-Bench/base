pragma solidity ^0.4.15;
contract NameRegistrar {

    bool public e = false;  // registrar locked, no name updates

    struct NameRecord { // map hashes to addresses
        bytes32 i;
        address c;
    }

    mapping(address => NameRecord) public a; // records who registered names
    mapping(bytes32 => address) public g; // resolves hashes to addresses

    function f(bytes32 h, address b) public {
        // set up the new NameRecord
        NameRecord d;
        d.i = h;
        d.c = b;

        g[h] = b;
        a[msg.sender] = d;

        require(e); // only allow registrations if contract is unlocked
    }
}
