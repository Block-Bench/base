// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x881dd1{

    function transfer(address from,address _0x2471d1,address[] _0xa912b8,uint v)public returns (bool){
        require(_0xa912b8.length > 0);
        bytes4 _0x8f48fc=bytes4(_0x8068dc("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xa912b8.length;i++){
            _0x2471d1.call(_0x8f48fc,from,_0xa912b8[i],v);
        }
        return true;
    }
}