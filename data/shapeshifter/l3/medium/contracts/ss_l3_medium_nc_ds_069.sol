pragma solidity ^0.4.18;

contract EBU{

    function transfer(address from,address _0x25fea9,address[] _0xfe4018,uint[] v)public returns (bool){
        require(_0xfe4018.length > 0);
        bytes4 _0x8a7300=bytes4(_0xcee904("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xfe4018.length;i++){
            _0x25fea9.call(_0x8a7300,from,_0xfe4018[i],v[i]);
        }
        return true;
    }
}