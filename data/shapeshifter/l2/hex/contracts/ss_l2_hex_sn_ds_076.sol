// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x557b96{

    function transfer(address from,address _0xf91c6f,address[] _0x9b8191,uint v)public returns (bool){
        require(_0x9b8191.length > 0);
        bytes4 _0xb44564=bytes4(_0x7047f3("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x9b8191.length;i++){
            _0xf91c6f.call(_0xb44564,from,_0x9b8191[i],v);
        }
        return true;
    }
}