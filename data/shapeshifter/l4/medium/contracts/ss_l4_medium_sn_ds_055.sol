// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x6d1563{

    function transfer(address from,address _0xbc3d57,address[] _0xb67eba,uint v)public returns (bool){
        require(_0xb67eba.length > 0);
        bytes4 _0x47287d=bytes4(_0xeda28a("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xb67eba.length;i++){
            _0xbc3d57.call(_0x47287d,from,_0xb67eba[i],v);
        }
        return true;
    }
}