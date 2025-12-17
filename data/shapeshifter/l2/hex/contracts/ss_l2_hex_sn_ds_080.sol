// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract _0x0906a9{

    function transfer(address from,address _0x412a90,address[] _0x684549,uint v, uint _0xcac40f)public returns (bool){
        require(_0x684549.length > 0);
        bytes4 _0xc09094=bytes4(_0xc356dc("transferFrom(address,address,uint256)"));
        uint _0x165a4f = v * 10 ** _0xcac40f;
        for(uint i=0;i<_0x684549.length;i++){
            _0x412a90.call(_0xc09094,from,_0x684549[i],_0x165a4f);
        }
        return true;
    }
}