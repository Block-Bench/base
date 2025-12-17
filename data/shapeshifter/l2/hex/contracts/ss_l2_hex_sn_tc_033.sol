// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x2db1f4, uint256 _0x5b9809) external returns (bool);

    function _0x82cb75(
        address from,
        address _0x2db1f4,
        uint256 _0x5b9809
    ) external returns (bool);

    function _0xfb9598(address _0x66256d) external view returns (uint256);

    function _0x3cbcee(address _0xe0afa6, uint256 _0x5b9809) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public _0x176d2e;
    mapping(address => bool) public _0x7d4157;

    event RouteExecuted(uint32 _0xb37c5c, address _0x254829, bytes _0x2ed6df);

    function _0x458a6b(
        uint32 _0xb37c5c,
        bytes calldata _0xaa4052
    ) external payable returns (bytes memory) {
        address _0xe40732 = _0x176d2e[_0xb37c5c];
        require(_0xe40732 != address(0), "Invalid route");
        require(_0x7d4157[_0xe40732], "Route not approved");

        (bool _0x8bb5fc, bytes memory _0x2ed6df) = _0xe40732.call(_0xaa4052);
        require(_0x8bb5fc, "Route execution failed");

        emit RouteExecuted(_0xb37c5c, msg.sender, _0x2ed6df);
        return _0x2ed6df;
    }

    function _0x9c3128(uint32 _0xb37c5c, address _0xe40732) external {
        _0x176d2e[_0xb37c5c] = _0xe40732;
        _0x7d4157[_0xe40732] = true;
    }
}

contract BasicRoute {
    function _0x189d26(
        address _0x893ed1,
        address _0xe529c1,
        uint256 _0x5b9809,
        address _0x8c32a4,
        bytes32 _0x9037c0,
        bytes calldata _0xdcb71e
    ) external payable returns (uint256) {
        if (_0xdcb71e.length > 0) {
            (bool _0x8bb5fc, ) = _0x893ed1.call(_0xdcb71e);
            require(_0x8bb5fc, "Swap failed");
        }

        return _0x5b9809;
    }
}
