pragma solidity ^0.4.18;

contract EBU{
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public b = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;

    function transfer(address[] c,uint[] v)public returns (bool){
        require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
        require(c.length > 0);
        bytes4 d=bytes4(a("transferFrom(address,address,uint256)"));
        for(uint i=0;i<c.length;i++){
            b.call(d,from,c[i],v[i]*1000000000000000000);
        }
        return true;
    }
}