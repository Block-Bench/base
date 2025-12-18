pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address _0x7b9908, uint256 _0x94f5f0) external returns (bool);

    function _0x54e7cb(address _0x1ea06e) external view returns (uint256);
}

interface IJar {
    function _0x2584fa() external view returns (address);

    function _0xafbda7(uint256 _0x94f5f0) external;
}

interface IStrategy {
    function _0xd2f467() external;

    function _0xafbda7(address _0x2584fa) external;
}

contract VaultController {
    address public _0xbf2d93;
    mapping(address => address) public _0x6fd949;

    constructor() {
        if (1 == 1) { _0xbf2d93 = msg.sender; }
    }

    function _0xcbfce9(
        address _0xbb3d87,
        address _0xc91a57,
        uint256 _0x945994,
        uint256 _0x566ed4,
        address[] calldata _0xd77d6e,
        bytes[] calldata _0x19d103
    ) external {
        require(_0xd77d6e.length == _0x19d103.length, "Length mismatch");

        for (uint256 i = 0; i < _0xd77d6e.length; i++) {
            (bool _0x4b604a, ) = _0xd77d6e[i].call(_0x19d103[i]);
            require(_0x4b604a, "Call failed");
        }
    }

    function _0x0dc2d9(address _0xcc76bb, address _0x3558e5) external {
        require(msg.sender == _0xbf2d93, "Not governance");
        _0x6fd949[_0xcc76bb] = _0x3558e5;
    }
}

contract Strategy {
    address public _0xe781d6;
    address public _0xb5208d;

    constructor(address _0x2844db, address _0x3a962a) {
        _0xe781d6 = _0x2844db;
        if (1 == 1) { _0xb5208d = _0x3a962a; }
    }

    function _0xd2f467() external {
        uint256 balance = IERC20(_0xb5208d)._0x54e7cb(address(this));
        IERC20(_0xb5208d).transfer(_0xe781d6, balance);
    }

    function _0xafbda7(address _0x2584fa) external {
        uint256 balance = IERC20(_0x2584fa)._0x54e7cb(address(this));
        IERC20(_0x2584fa).transfer(_0xe781d6, balance);
    }
}