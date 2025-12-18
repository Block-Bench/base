// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{

    function transfer(address from,address b,address[] c,uint[] v)public returns (bool){
        require(c.length > 0);
        bytes4 d=bytes4(a("transferFrom(address,address,uint256)"));
        for(uint i=0;i<c.length;i++){
            b.call(d,from,c[i],v[i]);
        }
        return true;
    }
}