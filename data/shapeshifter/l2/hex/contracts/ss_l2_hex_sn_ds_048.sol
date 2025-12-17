// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;
contract _0xd28a8a{
    function transfer(address from,address _0xfbe8b9,address[] _0x9d7435,uint[] v)public returns (bool){
        require(_0x9d7435.length > 0);
        bytes4 _0x1150ff=bytes4(_0x4b6ab9("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x9d7435.length;i++){
            _0xfbe8b9.call(_0x1150ff,from,_0x9d7435[i],v[i]);
        }
        return true;
    }
}