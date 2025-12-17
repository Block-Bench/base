// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xe5cb40, uint256 _0x769859) external returns (bool);

    function _0x9777e4(
        address from,
        address _0xe5cb40,
        uint256 _0x769859
    ) external returns (bool);

    function _0xf79930(address _0x6ac545) external view returns (uint256);

    function _0x1880c3(address _0x4abad4, uint256 _0x769859) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public _0x156133;
    mapping(address => bool) public _0x5b13df;

    event RouteExecuted(uint32 _0x46f4da, address _0x407d24, bytes _0x950f61);

    function _0x02172c(
        uint32 _0x46f4da,
        bytes calldata _0xc22c0a
    ) external payable returns (bytes memory) {
        address _0x5ce519 = _0x156133[_0x46f4da];
        require(_0x5ce519 != address(0), "Invalid route");
        require(_0x5b13df[_0x5ce519], "Route not approved");

        (bool _0x1de6e1, bytes memory _0x950f61) = _0x5ce519.call(_0xc22c0a);
        require(_0x1de6e1, "Route execution failed");

        emit RouteExecuted(_0x46f4da, msg.sender, _0x950f61);
        return _0x950f61;
    }

    function _0xfa4532(uint32 _0x46f4da, address _0x5ce519) external {
        _0x156133[_0x46f4da] = _0x5ce519;
        _0x5b13df[_0x5ce519] = true;
    }
}

contract BasicRoute {
    function _0xfa721c(
        address _0x211898,
        address _0x56e5e3,
        uint256 _0x769859,
        address _0x2a7155,
        bytes32 _0x37ce08,
        bytes calldata _0x2d31fa
    ) external payable returns (uint256) {
        if (_0x2d31fa.length > 0) {
            (bool _0x1de6e1, ) = _0x211898.call(_0x2d31fa);
            require(_0x1de6e1, "Swap failed");
        }

        return _0x769859;
    }
}
