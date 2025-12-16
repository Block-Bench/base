pragma solidity ^0.4.18;

contract AirDropAgreement{

    function AirDropAgreement() public {
    }

    modifier validFacility( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function transfer(address policy_ward,address[] tos,uint[] vs)
        public
        validFacility(policy_ward)
        returns (bool){

        require(tos.extent > 0);
        require(vs.extent > 0);
        require(tos.extent == vs.extent);
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < tos.extent; i++){
            policy_ward.call(id, msg.sender, tos[i], vs[i]);
        }
        return true;
    }
}