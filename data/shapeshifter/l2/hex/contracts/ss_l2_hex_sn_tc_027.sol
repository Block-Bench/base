// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPair {
    function _0x38b5ea() external view returns (address);
    function _0xd3a850() external view returns (address);
    function _0x023c37() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {

    function _0x7c7aac(
        uint256 _0xc311b5,
        uint256 _0xfb5e5b,
        address[] calldata _0xc7826d,
        address _0xf81ac6,
        uint256 _0xb84428
    ) external returns (uint[] memory _0x76eefd) {

        _0x76eefd = new uint[](_0xc7826d.length);
        _0x76eefd[0] = _0xc311b5;

        for (uint i = 0; i < _0xc7826d.length - 1; i++) {
            address _0x05e6f6 = _0x2aedfc(_0xc7826d[i], _0xc7826d[i+1]);

            (uint112 _0x92ed0a, uint112 _0x97a2fb,) = IPair(_0x05e6f6)._0x023c37();

            _0x76eefd[i+1] = _0x651503(_0x76eefd[i], _0x92ed0a, _0x97a2fb);
        }

        return _0x76eefd;
    }

    function _0x2aedfc(address _0xa9907a, address _0xeab492) internal pure returns (address) {
        return address(uint160(uint256(_0xb598b0(abi._0x495bf6(_0xa9907a, _0xeab492)))));
    }

    function _0x651503(uint256 _0xc311b5, uint112 _0xc5ac12, uint112 _0x591ceb) internal pure returns (uint256) {
        return (_0xc311b5 * uint256(_0x591ceb)) / uint256(_0xc5ac12);
    }
}
