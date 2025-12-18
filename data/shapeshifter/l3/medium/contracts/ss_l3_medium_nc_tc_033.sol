pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x0844f4, uint256 _0x39656a) external returns (bool);

    function _0x6c0d40(
        address from,
        address _0x0844f4,
        uint256 _0x39656a
    ) external returns (bool);

    function _0x863fdc(address _0x795e0e) external view returns (uint256);

    function _0xd628a9(address _0x60df5f, uint256 _0x39656a) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public _0xf5fd67;
    mapping(address => bool) public _0xb80209;

    event RouteExecuted(uint32 _0x821e0d, address _0xf4c476, bytes _0x22dcbb);

    function _0x56e6a7(
        uint32 _0x821e0d,
        bytes calldata _0xefbc21
    ) external payable returns (bytes memory) {
        address _0x72efe9 = _0xf5fd67[_0x821e0d];
        require(_0x72efe9 != address(0), "Invalid route");
        require(_0xb80209[_0x72efe9], "Route not approved");

        (bool _0xc85c4a, bytes memory _0x22dcbb) = _0x72efe9.call(_0xefbc21);
        require(_0xc85c4a, "Route execution failed");

        emit RouteExecuted(_0x821e0d, msg.sender, _0x22dcbb);
        return _0x22dcbb;
    }

    function _0x5b1452(uint32 _0x821e0d, address _0x72efe9) external {
        _0xf5fd67[_0x821e0d] = _0x72efe9;
        _0xb80209[_0x72efe9] = true;
    }
}

contract BasicRoute {
    function _0x7827d3(
        address _0x213413,
        address _0x155deb,
        uint256 _0x39656a,
        address _0x733326,
        bytes32 _0xc8ff37,
        bytes calldata _0x198651
    ) external payable returns (uint256) {
        if (_0x198651.length > 0) {
            (bool _0xc85c4a, ) = _0x213413.call(_0x198651);
            require(_0xc85c4a, "Swap failed");
        }

        return _0x39656a;
    }
}