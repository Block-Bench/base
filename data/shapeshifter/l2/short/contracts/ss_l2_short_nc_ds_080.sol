pragma solidity ^0.4.24;

contract d{

    function transfer(address from,address c,address[] f,uint v, uint a)public returns (bool){
        require(f.length > 0);
        bytes4 g=bytes4(b("transferFrom(address,address,uint256)"));
        uint e = v * 10 ** a;
        for(uint i=0;i<f.length;i++){
            c.call(g,from,f[i],e);
        }
        return true;
    }
}