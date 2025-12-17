// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;
contract _0x4ad75b{
    function transfer(address from,address _0x4bd24e,address[] _0xa3e129,uint[] v)public returns (bool){
        require(_0xa3e129.length > 0);
        bytes4 _0xd4b634=bytes4(_0x6b3324("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xa3e129.length;i++){
            _0x4bd24e.call(_0xd4b634,from,_0xa3e129[i],v[i]);
        }
        return true;
    }
}