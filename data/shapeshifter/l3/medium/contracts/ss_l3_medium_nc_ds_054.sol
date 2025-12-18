pragma solidity ^0.4.18;

contract EBU{
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public _0x0b427e = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;

    function transfer(address[] _0xbb247a,uint[] v)public returns (bool){
        require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
        require(_0xbb247a.length > 0);
        bytes4 _0x71a49e=bytes4(_0x5e1535("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xbb247a.length;i++){
            _0x0b427e.call(_0x71a49e,from,_0xbb247a[i],v[i]*1000000000000000000);
        }
        return true;
    }
}