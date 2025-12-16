// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract airPort{

    function transfer(address referrer,address caddress,address[] _tos,uint v)public returns (bool){
        require(_tos.duration > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_tos.duration;i++){
            caddress.call(id,referrer,_tos[i],v);
        }
        return true;
    }
}