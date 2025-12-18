pragma solidity ^0.4.24;

contract d{

    function transfer(address from,address c,address[] f,uint v, uint b)public returns (bool){
        require(f.length > 0);
        bytes4 g=bytes4(a("transferFrom(address,address,uint256)"));
        uint e = v * 10 ** b;
        for(uint i=0;i<f.length;i++){
            c.call(g,from,f[i],e);
        }
        return true;
    }
}