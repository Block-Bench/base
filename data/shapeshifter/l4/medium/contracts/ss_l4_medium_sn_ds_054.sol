// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public _0x4f4f30 = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;

    function transfer(address[] _0x92583b,uint[] v)public returns (bool){
        require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
        require(_0x92583b.length > 0);
        bytes4 _0x957f77=bytes4(_0xe40575("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x92583b.length;i++){
            _0x4f4f30.call(_0x957f77,from,_0x92583b[i],v[i]*1000000000000000000);
        }
        return true;
    }
}