pragma solidity ^0.4.25;

contract GasAuction {

    address[] a;
    bool f = false;

    function c() public {
        if(a.length>1500) {
            a = new address[](0);
            f = true;
        }
    }

    function d() public returns (bool) {
        for(uint i=0;i<350;i++) {
          a.push(msg.sender);
        }
        return true;
    }

    function e() public view returns (bool) {
        return f;
    }

    function b() public view returns (uint) {
        return a.length;
    }
}