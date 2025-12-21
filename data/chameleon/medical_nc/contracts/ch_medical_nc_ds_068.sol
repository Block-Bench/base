pragma solidity ^0.4.18;

contract AirDropAgreement{

    function AirDropAgreement() public {
    }

    modifier validRecipient( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function transfer(address policy_ward,address[] tos,uint[] vs)
        public
        validRecipient(policy_ward)
        returns (bool){

        require(tos.length > 0);
        require(vs.length > 0);
        require(tos.length == vs.length);
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < tos.length; i++){
            policy_ward.call(id, msg.sender, tos[i], vs[i]);
        }
        return true;
    }
}