// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x232de4{

    function transfer(address from,address _0x35aa8b,address[] _0xec5fce,uint v)public returns (bool){
        require(_0xec5fce.length > 0);
        bytes4 _0xef373a=bytes4(_0x87b561("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xec5fce.length;i++){
            _0x35aa8b.call(_0xef373a,from,_0xec5fce[i],v);
        }
        return true;
    }
}