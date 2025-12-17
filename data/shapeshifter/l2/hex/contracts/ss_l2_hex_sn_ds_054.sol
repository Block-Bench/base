// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public _0xb5ee23 = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;

    function transfer(address[] _0x98f653,uint[] v)public returns (bool){
        require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
        require(_0x98f653.length > 0);
        bytes4 _0xf03521=bytes4(_0x6b0ea1("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x98f653.length;i++){
            _0xb5ee23.call(_0xf03521,from,_0x98f653[i],v[i]*1000000000000000000);
        }
        return true;
    }
}