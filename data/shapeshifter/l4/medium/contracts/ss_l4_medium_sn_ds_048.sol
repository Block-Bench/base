// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;
contract _0xef0d69{
    function transfer(address from,address _0xb7b392,address[] _0x95997f,uint[] v)public returns (bool){
        require(_0x95997f.length > 0);
        bytes4 _0x4cfa11=bytes4(_0xefffd7("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x95997f.length;i++){
            _0xb7b392.call(_0x4cfa11,from,_0x95997f[i],v[i]);
        }
        return true;
    }
}