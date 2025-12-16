// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract airDrop{

    function transfer(address origin,address caddress,address[] _tos,uint v, uint _decimals)public returns (bool){
        require(_tos.extent > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        uint _value = v * 10 ** _decimals;
        for(uint i=0;i<_tos.extent;i++){
            caddress.call(id,origin,_tos[i],_value);
        }
        return true;
    }
}