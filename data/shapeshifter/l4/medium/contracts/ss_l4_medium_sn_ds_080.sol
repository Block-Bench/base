// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x3ea468{

    function transfer(address from,address _0x81ecf6,address[] _0xfd0423,uint v, uint _0xd6a84c)public returns (bool){
        require(_0xfd0423.length > 0);
        bytes4 _0x5f5e46=bytes4(_0x3dae0e("transferFrom(address,address,uint256)"));
        uint _0x93bfdb = v * 10 ** _0xd6a84c;
        for(uint i=0;i<_0xfd0423.length;i++){
            _0x81ecf6.call(_0x5f5e46,from,_0xfd0423[i],_0x93bfdb);
        }
        return true;
    }
}