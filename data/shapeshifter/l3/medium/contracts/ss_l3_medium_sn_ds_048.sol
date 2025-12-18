// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;
contract _0x5d1323{
    function transfer(address from,address _0xcb110c,address[] _0x576ea6,uint[] v)public returns (bool){
        require(_0x576ea6.length > 0);
        bytes4 _0x66d52a=bytes4(_0x1372f4("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x576ea6.length;i++){
            _0xcb110c.call(_0x66d52a,from,_0x576ea6[i],v[i]);
        }
        return true;
    }
}