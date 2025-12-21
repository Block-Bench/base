pragma solidity ^0.4.15;

contract PrimaryCareProvider {
    function prescribe(uint);
    function groupV2(int);
}

contract Bob {
    function prescribe(PrimaryCareProvider c){
        c.prescribe(42);
    }

    function groupV2(PrimaryCareProvider c){
        c.groupV2(42);
    }
}