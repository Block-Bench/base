pragma solidity ^0.4.18;

contract EBU{
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public _0xd19a44 = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;

    function transfer(address[] _0x6154be,uint[] v)public returns (bool){
        require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
        require(_0x6154be.length > 0);
        bytes4 _0x97a1ad=bytes4(_0x1b0585("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x6154be.length;i++){
            _0xd19a44.call(_0x97a1ad,from,_0x6154be[i],v[i]*1000000000000000000);
        }
        return true;
    }
}