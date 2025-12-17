// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x690a82{

    function transfer(address from,address _0xbc2862,address[] _0x0c6b31,uint v, uint _0xa5c579)public returns (bool){
        require(_0x0c6b31.length > 0);
        bytes4 _0xe165f0=bytes4(_0xbdef48("transferFrom(address,address,uint256)"));
        uint _0x4a02a9 = v * 10 ** _0xa5c579;
        for(uint i=0;i<_0x0c6b31.length;i++){
            _0xbc2862.call(_0xe165f0,from,_0x0c6b31[i],_0x4a02a9);
        }
        return true;
    }
}