pragma solidity ^0.4.15;

contract Alice {
    function assign(uint);
    function collectionV2(int);
}

contract Bob {
    function assign(Alice c){
        c.assign(42);
    }

    function collectionV2(Alice c){
        c.collectionV2(42);
    }
}