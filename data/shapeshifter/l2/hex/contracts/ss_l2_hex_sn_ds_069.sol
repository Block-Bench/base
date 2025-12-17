// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{

    function transfer(address from,address _0x46e0be,address[] _0x7867f2,uint[] v)public returns (bool){
        require(_0x7867f2.length > 0);
        bytes4 _0xa047da=bytes4(_0x1a3f8c("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x7867f2.length;i++){
            _0x46e0be.call(_0xa047da,from,_0x7867f2[i],v[i]);
        }
        return true;
    }
}