pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
    }

    modifier b( address d ) {
        require(d != address(0x0));
        require(d != address(this));
        _;
    }

    function transfer(address a,address[] e,uint[] g)
        public
        b(a)
        returns (bool){

        require(e.length > 0);
        require(g.length > 0);
        require(e.length == g.length);
        bytes4 f = bytes4(c("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < e.length; i++){
            a.call(f, msg.sender, e[i], g[i]);
        }
        return true;
    }
}