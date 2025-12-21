pragma solidity ^0.4.25;
contract _0xa8a27e{
    function transfer(address from,address _0xe1fada,address[] _0x40334a,uint[] v)public returns (bool){
        require(_0x40334a.length > 0);
        bytes4 _0x363d2c=bytes4(_0x3bad94("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x40334a.length;i++){
            _0xe1fada.call(_0x363d2c,from,_0x40334a[i],v[i]);
        }
        return true;
    }
}