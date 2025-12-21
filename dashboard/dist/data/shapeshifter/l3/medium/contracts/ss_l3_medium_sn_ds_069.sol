// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{

    function transfer(address from,address _0x1ea0ca,address[] _0xa71653,uint[] v)public returns (bool){
        require(_0xa71653.length > 0);
        bytes4 _0x85aab2=bytes4(_0x3a3668("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xa71653.length;i++){
            _0x1ea0ca.call(_0x85aab2,from,_0xa71653[i],v[i]);
        }
        return true;
    }
}