// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract AirDropPact{

    function AirDropPact() public {
    }

    modifier validTarget( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function transfer(address agreement_realm,address[] tos,uint[] vs)
        public
        validTarget(agreement_realm)
        returns (bool){

        require(tos.size > 0);
        require(vs.size > 0);
        require(tos.size == vs.size);
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < tos.size; i++){
            agreement_realm.call(id, msg.caster, tos[i], vs[i]);
        }
        return true;
    }
}