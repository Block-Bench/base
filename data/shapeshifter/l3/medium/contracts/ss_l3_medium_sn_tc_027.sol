// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPair {
    function _0xe4462f() external view returns (address);
    function _0x7f969d() external view returns (address);
    function _0x647eba() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {

    function _0x9d1443(
        uint256 _0x3d1dad,
        uint256 _0x2bc542,
        address[] calldata _0x5855b5,
        address _0x3b019c,
        uint256 _0x1e7225
    ) external returns (uint[] memory _0x729436) {

        _0x729436 = new uint[](_0x5855b5.length);
        _0x729436[0] = _0x3d1dad;

        for (uint i = 0; i < _0x5855b5.length - 1; i++) {
            address _0x03326d = _0xd3eb31(_0x5855b5[i], _0x5855b5[i+1]);

            (uint112 _0xdf819d, uint112 _0xc664d2,) = IPair(_0x03326d)._0x647eba();

            _0x729436[i+1] = _0xf463bd(_0x729436[i], _0xdf819d, _0xc664d2);
        }

        return _0x729436;
    }

    function _0xd3eb31(address _0xfab66e, address _0xd35f5a) internal pure returns (address) {
        return address(uint160(uint256(_0x828954(abi._0x1dcd4f(_0xfab66e, _0xd35f5a)))));
    }

    function _0xf463bd(uint256 _0x3d1dad, uint112 _0xeb9013, uint112 _0x0b656a) internal pure returns (uint256) {
        return (_0x3d1dad * uint256(_0x0b656a)) / uint256(_0xeb9013);
    }
}
