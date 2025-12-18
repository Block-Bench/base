// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x778fa6{

    function transfer(address from,address _0xc6b292,address[] _0xa29650,uint v)public returns (bool){
        require(_0xa29650.length > 0);
        bytes4 _0x6c3dcf=bytes4(_0x4b57f7("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xa29650.length;i++){
            _0xc6b292.call(_0x6c3dcf,from,_0xa29650[i],v);
        }
        return true;
    }
}