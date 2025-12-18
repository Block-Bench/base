pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
    }

    modifier b( address d ) {
        require(d != address(0x0));
        require(d != address(this));
        _;
    }

    function transfer(address a,address[] e,uint[] f)
        public
        b(a)
        returns (bool){

        require(e.length > 0);
        require(f.length > 0);
        require(e.length == f.length);
        bytes4 g = bytes4(c("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < e.length; i++){
            a.call(g, msg.sender, e[i], f[i]);
        }
        return true;
    }
}