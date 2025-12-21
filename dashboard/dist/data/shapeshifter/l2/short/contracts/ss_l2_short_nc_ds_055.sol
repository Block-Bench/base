pragma solidity ^0.4.24;

contract c{

    function transfer(address from,address b,address[] d,uint v)public returns (bool){
        require(d.length > 0);
        bytes4 e=bytes4(a("transferFrom(address,address,uint256)"));
        for(uint i=0;i<d.length;i++){
            b.call(e,from,d[i],v);
        }
        return true;
    }
}