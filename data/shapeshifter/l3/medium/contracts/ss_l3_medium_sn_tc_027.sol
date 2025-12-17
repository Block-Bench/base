// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPair {
    function _0x0faaf8() external view returns (address);
    function _0x5ebb54() external view returns (address);
    function _0x95b8fa() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {

    function _0xf57efe(
        uint256 _0x1fd265,
        uint256 _0x6e8596,
        address[] calldata _0xf236d8,
        address _0x7fabaa,
        uint256 _0x20eae9
    ) external returns (uint[] memory _0x2c3ac1) {

        _0x2c3ac1 = new uint[](_0xf236d8.length);
        _0x2c3ac1[0] = _0x1fd265;

        for (uint i = 0; i < _0xf236d8.length - 1; i++) {
            address _0x17b92e = _0x6c0e75(_0xf236d8[i], _0xf236d8[i+1]);

            (uint112 _0x34dc58, uint112 _0xc590ae,) = IPair(_0x17b92e)._0x95b8fa();

            _0x2c3ac1[i+1] = _0x73c2ac(_0x2c3ac1[i], _0x34dc58, _0xc590ae);
        }

        return _0x2c3ac1;
    }

    function _0x6c0e75(address _0xc2b47f, address _0x12a9b0) internal pure returns (address) {
        return address(uint160(uint256(_0x430132(abi._0xd09748(_0xc2b47f, _0x12a9b0)))));
    }

    function _0x73c2ac(uint256 _0x1fd265, uint112 _0xf6abd5, uint112 _0x0489e5) internal pure returns (uint256) {
        return (_0x1fd265 * uint256(_0x0489e5)) / uint256(_0xf6abd5);
    }
}
