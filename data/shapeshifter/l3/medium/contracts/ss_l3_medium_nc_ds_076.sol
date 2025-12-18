pragma solidity ^0.4.24;

contract _0x0aee29{

    function transfer(address from,address _0x15de54,address[] _0x89b536,uint v)public returns (bool){
        require(_0x89b536.length > 0);
        bytes4 _0x930cec=bytes4(_0x9352f6("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x89b536.length;i++){
            _0x15de54.call(_0x930cec,from,_0x89b536[i],v);
        }
        return true;
    }
}