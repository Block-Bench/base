// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0xb18d2f{

    function transfer(address from,address _0x38ddda,address[] _0xe14fb9,uint v)public returns (bool){
        require(_0xe14fb9.length > 0);
        bytes4 _0x7d278a=bytes4(_0xacebc9("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xe14fb9.length;i++){
            _0x38ddda.call(_0x7d278a,from,_0xe14fb9[i],v);
        }
        return true;
    }
}