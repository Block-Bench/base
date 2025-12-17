// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x9654e3{

    function transfer(address from,address _0x33abc6,address[] _0x4a65aa,uint v)public returns (bool){
        require(_0x4a65aa.length > 0);
        bytes4 _0x93add9=bytes4(_0xb91902("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x4a65aa.length;i++){
            _0x33abc6.call(_0x93add9,from,_0x4a65aa[i],v);
        }
        return true;
    }
}