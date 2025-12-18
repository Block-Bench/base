pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x384d8e, uint256 _0xb0b853) external returns (bool);

    function _0x1adaac(
        address from,
        address _0x384d8e,
        uint256 _0xb0b853
    ) external returns (bool);

    function _0xe4d147(address _0x5e0116) external view returns (uint256);

    function _0x3cf8a2(address _0x5a1a37, uint256 _0xb0b853) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public _0x43d60e;
    mapping(address => bool) public _0xeb0aee;

    event RouteExecuted(uint32 _0x5cac82, address _0x84cc0b, bytes _0x923289);

    function _0x0ec379(
        uint32 _0x5cac82,
        bytes calldata _0x5025bd
    ) external payable returns (bytes memory) {
        address _0xd7605f = _0x43d60e[_0x5cac82];
        require(_0xd7605f != address(0), "Invalid route");
        require(_0xeb0aee[_0xd7605f], "Route not approved");

        (bool _0xac841b, bytes memory _0x923289) = _0xd7605f.call(_0x5025bd);
        require(_0xac841b, "Route execution failed");

        emit RouteExecuted(_0x5cac82, msg.sender, _0x923289);
        return _0x923289;
    }

    function _0x7fc7f7(uint32 _0x5cac82, address _0xd7605f) external {
        _0x43d60e[_0x5cac82] = _0xd7605f;
        _0xeb0aee[_0xd7605f] = true;
    }
}

contract BasicRoute {
    function _0xe8e2a8(
        address _0x6253e7,
        address _0x6f9430,
        uint256 _0xb0b853,
        address _0x65e8da,
        bytes32 _0xa73292,
        bytes calldata _0xeb0ee5
    ) external payable returns (uint256) {
        if (_0xeb0ee5.length > 0) {
            (bool _0xac841b, ) = _0x6253e7.call(_0xeb0ee5);
            require(_0xac841b, "Swap failed");
        }

        return _0xb0b853;
    }
}