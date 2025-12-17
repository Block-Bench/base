// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x2ce139{

    function transfer(address from,address _0x325a44,address[] _0xb9148c,uint v)public returns (bool){
        require(_0xb9148c.length > 0);
        bytes4 _0xd6d50c=bytes4(_0x660e08("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xb9148c.length;i++){
            _0x325a44.call(_0xd6d50c,from,_0xb9148c[i],v);
        }
        return true;
    }
}