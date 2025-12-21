pragma solidity ^0.4.18;

contract EBU{

    function transfer(address referrer,address caddress,address[] _tos,uint[] v)public returns (bool){
        require(_tos.length > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_tos.length;i++){
            caddress.call(id,referrer,_tos[i],v[i]);
        }
        return true;
    }
}