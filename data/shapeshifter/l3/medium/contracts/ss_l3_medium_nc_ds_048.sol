pragma solidity ^0.4.25;
contract _0xc7f00d{
    function transfer(address from,address _0x192960,address[] _0xec79a3,uint[] v)public returns (bool){
        require(_0xec79a3.length > 0);
        bytes4 _0xe16d75=bytes4(_0xcdacbd("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xec79a3.length;i++){
            _0x192960.call(_0xe16d75,from,_0xec79a3[i],v[i]);
        }
        return true;
    }
}