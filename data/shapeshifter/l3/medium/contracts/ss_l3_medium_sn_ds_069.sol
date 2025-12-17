// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{

    function transfer(address from,address _0x4a8dfa,address[] _0xd01126,uint[] v)public returns (bool){
        require(_0xd01126.length > 0);
        bytes4 _0x041af8=bytes4(_0x40b5ab("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xd01126.length;i++){
            _0x4a8dfa.call(_0x041af8,from,_0xd01126[i],v[i]);
        }
        return true;
    }
}