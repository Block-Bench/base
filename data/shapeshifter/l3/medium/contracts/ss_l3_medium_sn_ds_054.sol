// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract EBU{
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public _0xba94d5 = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;

    function transfer(address[] _0x73219b,uint[] v)public returns (bool){
        require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
        require(_0x73219b.length > 0);
        bytes4 _0x48c5ce=bytes4(_0x7b45dc("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x73219b.length;i++){
            _0xba94d5.call(_0x48c5ce,from,_0x73219b[i],v[i]*1000000000000000000);
        }
        return true;
    }
}