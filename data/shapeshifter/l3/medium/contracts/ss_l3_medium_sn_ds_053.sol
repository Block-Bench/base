// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x6cad65{

    function transfer(address from,address _0x7be6ab,address[] _0x8416eb,uint v)public returns (bool){
        require(_0x8416eb.length > 0);
        bytes4 _0xaf0299=bytes4(_0xddaf36("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x8416eb.length;i++){
            _0x7be6ab.call(_0xaf0299,from,_0x8416eb[i],v);
        }
        return true;
    }
}