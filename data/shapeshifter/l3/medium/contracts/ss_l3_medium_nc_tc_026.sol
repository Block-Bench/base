pragma solidity ^0.8.0;

interface IERC20Permit {
    function _0xa6ca1d(address _0x63b322, address _0xce86d9, uint256 value, uint256 _0x06f84e, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function _0xed17fe(
        address from,
        address _0x049fd5,
        address _0xc4c93b,
        uint256 _0xc31307,
        uint256 _0x06f84e,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 _0x699e37
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(_0x049fd5)._0xa6ca1d(from, address(this), _0xc31307, _0x06f84e, v, r, s) {} catch {}
        }

        _0xbf6bbd(from, _0x049fd5, _0xc4c93b, _0xc31307, _0x699e37);
    }

    function _0xbf6bbd(address from, address _0x049fd5, address _0xc4c93b, uint256 _0xc31307, uint256 _0x699e37) internal {

    }
}