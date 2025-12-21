// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0xec66d4{

    function transfer(address from,address _0x1b3b1a,address[] _0x5f8318,uint v, uint _0x638d0e)public returns (bool){
        require(_0x5f8318.length > 0);
        bytes4 _0x20b8c7=bytes4(_0x838024("transferFrom(address,address,uint256)"));
        uint _0xf818ff = v * 10 ** _0x638d0e;
        for(uint i=0;i<_0x5f8318.length;i++){
            _0x1b3b1a.call(_0x20b8c7,from,_0x5f8318[i],_0xf818ff);
        }
        return true;
    }
}