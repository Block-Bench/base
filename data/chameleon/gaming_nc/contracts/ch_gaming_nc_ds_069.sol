pragma solidity ^0.4.18;

contract EBU{

    function transfer(address origin,address caddress,address[] _tos,uint[] v)public returns (bool){
        require(_tos.extent > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_tos.extent;i++){
            caddress.call(id,origin,_tos[i],v[i]);
        }
        return true;
    }
}