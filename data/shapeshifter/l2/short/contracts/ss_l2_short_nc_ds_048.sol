pragma solidity ^0.4.25;
contract d{
    function transfer(address from,address b,address[] c,uint[] v)public returns (bool){
        require(c.length > 0);
        bytes4 e=bytes4(a("transferFrom(address,address,uint256)"));
        for(uint i=0;i<c.length;i++){
            b.call(e,from,c[i],v[i]);
        }
        return true;
    }
}