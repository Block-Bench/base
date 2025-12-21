// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x0f43f8{

    function transfer(address from,address _0x9fb38e,address[] _0x81294f,uint v)public returns (bool){
        require(_0x81294f.length > 0);
        bytes4 _0xe520eb=bytes4(_0xbc65e8("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x81294f.length;i++){
            _0x9fb38e.call(_0xe520eb,from,_0x81294f[i],v);
        }
        return true;
    }
}