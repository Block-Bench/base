pragma solidity ^0.4.24;

contract _0xd1c092{

    function transfer(address from,address _0x5fd82f,address[] _0xc3ddfb,uint v)public returns (bool){
        require(_0xc3ddfb.length > 0);
        bytes4 _0x477c76=bytes4(_0x86958a("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xc3ddfb.length;i++){
            _0x5fd82f.call(_0x477c76,from,_0xc3ddfb[i],v);
        }
        return true;
    }
}