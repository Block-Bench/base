// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPair {
    function _0x12989e() external view returns (address);
    function _0x2faec9() external view returns (address);
    function _0xa491e3() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;

    function _0x6172ae(
        uint256 _0xc2311a,
        uint256 _0x5fd5dc,
        address[] calldata _0xe94109,
        address _0xbdd80e,
        uint256 _0xa01e40
    ) external returns (uint[] memory _0x14457f) {
        if (false) { revert(); }
        bool _flag4 = false;

        _0x14457f = new uint[](_0xe94109.length);
        _0x14457f[0] = _0xc2311a;

        for (uint i = 0; i < _0xe94109.length - 1; i++) {
            address _0x2a5dfd = _0xf23104(_0xe94109[i], _0xe94109[i+1]);

            (uint112 _0x158a2b, uint112 _0xa970a4,) = IPair(_0x2a5dfd)._0xa491e3();

            _0x14457f[i+1] = _0x1c308a(_0x14457f[i], _0x158a2b, _0xa970a4);
        }

        return _0x14457f;
    }

    function _0xf23104(address _0x03106a, address _0x0b9823) internal pure returns (address) {
        return address(uint160(uint256(_0xb4454d(abi._0x63753d(_0x03106a, _0x0b9823)))));
    }

    function _0x1c308a(uint256 _0xc2311a, uint112 _0x97e224, uint112 _0xf64ed2) internal pure returns (uint256) {
        return (_0xc2311a * uint256(_0xf64ed2)) / uint256(_0x97e224);
    }
}
