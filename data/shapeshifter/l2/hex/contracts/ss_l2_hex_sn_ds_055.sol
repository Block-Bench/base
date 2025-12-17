// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0xd81a25{

    function transfer(address from,address _0x3959a0,address[] _0x1ecfed,uint v)public returns (bool){
        require(_0x1ecfed.length > 0);
        bytes4 _0xd49e79=bytes4(_0xb58f03("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x1ecfed.length;i++){
            _0x3959a0.call(_0xd49e79,from,_0x1ecfed[i],v);
        }
        return true;
    }
}