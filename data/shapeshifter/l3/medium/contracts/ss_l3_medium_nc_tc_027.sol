pragma solidity ^0.8.0;

interface IPair {
    function _0xe94bca() external view returns (address);
    function _0x038484() external view returns (address);
    function _0x27d204() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {

    function _0x65c471(
        uint256 _0xa13eff,
        uint256 _0x7f8ac7,
        address[] calldata _0xdd2170,
        address _0xe10d49,
        uint256 _0xfd6d49
    ) external returns (uint[] memory _0x5020ec) {

        _0x5020ec = new uint[](_0xdd2170.length);
        _0x5020ec[0] = _0xa13eff;

        for (uint i = 0; i < _0xdd2170.length - 1; i++) {
            address _0x38dc7d = _0x24e9f1(_0xdd2170[i], _0xdd2170[i+1]);

            (uint112 _0xa3c327, uint112 _0x595f86,) = IPair(_0x38dc7d)._0x27d204();

            _0x5020ec[i+1] = _0x23057d(_0x5020ec[i], _0xa3c327, _0x595f86);
        }

        return _0x5020ec;
    }

    function _0x24e9f1(address _0x136c6a, address _0x5acbe1) internal pure returns (address) {
        return address(uint160(uint256(_0xb28383(abi._0xdd69c1(_0x136c6a, _0x5acbe1)))));
    }

    function _0x23057d(uint256 _0xa13eff, uint112 _0xd70d34, uint112 _0xface4e) internal pure returns (uint256) {
        return (_0xa13eff * uint256(_0xface4e)) / uint256(_0xd70d34);
    }
}