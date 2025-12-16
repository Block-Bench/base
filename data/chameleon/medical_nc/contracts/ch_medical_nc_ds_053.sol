pragma solidity ^0.4.24;

contract airdrop{

    function transfer(address source,address caddress,address[] _tos,uint v)public returns (bool){
        require(_tos.extent > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_tos.extent;i++){
            caddress.call(id,source,_tos[i],v);
        }
        return true;
    }
}