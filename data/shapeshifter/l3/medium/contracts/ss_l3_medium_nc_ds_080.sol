pragma solidity ^0.4.24;

contract _0x2e6315{

    function transfer(address from,address _0x20ec0f,address[] _0xfc02fe,uint v, uint _0x263d6f)public returns (bool){
        require(_0xfc02fe.length > 0);
        bytes4 _0xd587ba=bytes4(_0x0698ff("transferFrom(address,address,uint256)"));
        uint _0x4e053a = v * 10 ** _0x263d6f;
        for(uint i=0;i<_0xfc02fe.length;i++){
            _0x20ec0f.call(_0xd587ba,from,_0xfc02fe[i],_0x4e053a);
        }
        return true;
    }
}