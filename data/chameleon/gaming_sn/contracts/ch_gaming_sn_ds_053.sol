// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract airdrop{

    function transfer(address origin,address caddress,address[] _tos,uint v)public returns (bool){
        require(_tos.size > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_tos.size;i++){
            caddress.call(id,origin,_tos[i],v);
        }
        return true;
    }
}