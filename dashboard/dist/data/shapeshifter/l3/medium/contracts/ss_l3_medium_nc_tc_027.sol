pragma solidity ^0.8.0;

interface IPair {
    function _0xf2721f() external view returns (address);
    function _0x062469() external view returns (address);
    function _0x002dbc() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {

    function _0xd56dbc(
        uint256 _0xefd64b,
        uint256 _0xa23129,
        address[] calldata _0x8f1355,
        address _0x7d9a0e,
        uint256 _0x8d160f
    ) external returns (uint[] memory _0xd4aac2) {

        _0xd4aac2 = new uint[](_0x8f1355.length);
        _0xd4aac2[0] = _0xefd64b;

        for (uint i = 0; i < _0x8f1355.length - 1; i++) {
            address _0x3e1c15 = _0xa4ae3d(_0x8f1355[i], _0x8f1355[i+1]);

            (uint112 _0x3d3ef2, uint112 _0xdef6e1,) = IPair(_0x3e1c15)._0x002dbc();

            _0xd4aac2[i+1] = _0x3dc68d(_0xd4aac2[i], _0x3d3ef2, _0xdef6e1);
        }

        return _0xd4aac2;
    }

    function _0xa4ae3d(address _0xf9def9, address _0xca4d4d) internal pure returns (address) {
        return address(uint160(uint256(_0x58b2ca(abi._0x88b248(_0xf9def9, _0xca4d4d)))));
    }

    function _0x3dc68d(uint256 _0xefd64b, uint112 _0xe1cd7d, uint112 _0x1bc7cf) internal pure returns (uint256) {
        return (_0xefd64b * uint256(_0x1bc7cf)) / uint256(_0xe1cd7d);
    }
}