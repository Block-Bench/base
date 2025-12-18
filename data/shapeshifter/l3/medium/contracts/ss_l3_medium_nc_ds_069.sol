pragma solidity ^0.4.18;

contract EBU{

    function transfer(address from,address _0xd7fdb9,address[] _0x57ccf2,uint[] v)public returns (bool){
        require(_0x57ccf2.length > 0);
        bytes4 _0xd7defc=bytes4(_0x21014f("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x57ccf2.length;i++){
            _0xd7fdb9.call(_0xd7defc,from,_0x57ccf2[i],v[i]);
        }
        return true;
    }
}