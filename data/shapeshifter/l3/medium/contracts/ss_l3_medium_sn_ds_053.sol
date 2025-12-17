// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0xffa82b{

    function transfer(address from,address _0xf4caf9,address[] _0xb26e12,uint v)public returns (bool){
        require(_0xb26e12.length > 0);
        bytes4 _0x4fdd4b=bytes4(_0xf4b99b("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xb26e12.length;i++){
            _0xf4caf9.call(_0x4fdd4b,from,_0xb26e12[i],v);
        }
        return true;
    }
}