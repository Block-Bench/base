// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public _0x611f4a = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;

    function transfer(address[] _0x2eb6f1,uint[] v)public returns (bool){
        require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
        require(_0x2eb6f1.length > 0);
        bytes4 _0xfcaff2=bytes4(_0x9890c0("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x2eb6f1.length;i++){
            _0x611f4a.call(_0xfcaff2,from,_0x2eb6f1[i],v[i]*1000000000000000000);
        }
        return true;
    }
}