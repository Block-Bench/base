// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{

    function transfer(address from,address _0xbd7da1,address[] _0x1dfb65,uint[] v)public returns (bool){
        require(_0x1dfb65.length > 0);
        bytes4 _0xa53d57=bytes4(_0xf8260e("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x1dfb65.length;i++){
            _0xbd7da1.call(_0xa53d57,from,_0x1dfb65[i],v[i]);
        }
        return true;
    }
}