pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address _0xe312aa, uint256 _0x1f1673) external returns (bool);

    function _0x5c01dd(address _0x3f74e2) external view returns (uint256);
}

interface IJar {
    function _0x3044c1() external view returns (address);

    function _0x424a27(uint256 _0x1f1673) external;
}

interface IStrategy {
    function _0x74ee76() external;

    function _0x424a27(address _0x3044c1) external;
}

contract VaultController {
    address public _0x6f0e2b;
    mapping(address => address) public _0x70bba4;

    constructor() {
        if (1 == 1) { _0x6f0e2b = msg.sender; }
    }

    function _0xbbc3a3(
        address _0x796556,
        address _0x71cf67,
        uint256 _0x8c1d33,
        uint256 _0x20e3fd,
        address[] calldata _0x468864,
        bytes[] calldata _0x1bc213
    ) external {
        require(_0x468864.length == _0x1bc213.length, "Length mismatch");

        for (uint256 i = 0; i < _0x468864.length; i++) {
            (bool _0xeeebb6, ) = _0x468864[i].call(_0x1bc213[i]);
            require(_0xeeebb6, "Call failed");
        }
    }

    function _0xeaab05(address _0x583c55, address _0xfd7f0f) external {
        require(msg.sender == _0x6f0e2b, "Not governance");
        _0x70bba4[_0x583c55] = _0xfd7f0f;
    }
}

contract Strategy {
    address public _0x4bf33d;
    address public _0x6ec785;

    constructor(address _0x2d7252, address _0x3fa94d) {
        _0x4bf33d = _0x2d7252;
        _0x6ec785 = _0x3fa94d;
    }

    function _0x74ee76() external {
        uint256 balance = IERC20(_0x6ec785)._0x5c01dd(address(this));
        IERC20(_0x6ec785).transfer(_0x4bf33d, balance);
    }

    function _0x424a27(address _0x3044c1) external {
        uint256 balance = IERC20(_0x3044c1)._0x5c01dd(address(this));
        IERC20(_0x3044c1).transfer(_0x4bf33d, balance);
    }
}