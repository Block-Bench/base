pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x61a1dd, uint256 _0x12430d) external returns (bool);

    function _0xd1f704(
        address from,
        address _0x61a1dd,
        uint256 _0x12430d
    ) external returns (bool);

    function _0xf27774(address _0x7ce23c) external view returns (uint256);

    function _0x8ccb30(address _0x5c9cae, uint256 _0x12430d) external returns (bool);
}

interface IBorrowerOperations {
    function _0x1ccf95(address _0xde6ea6, bool _0x601da8) external;

    function _0x287ac0(
        address _0x3f01e1,
        address _0x7ce23c,
        uint256 _0xabe17f,
        uint256 _0x17d9a0,
        uint256 _0xc15cdd,
        address _0x9d7ff4,
        address _0xeda20e
    ) external;

    function _0xf6238e(address _0x3f01e1, address _0x7ce23c) external;
}

interface ITroveManager {
    function _0x627663(
        address _0x0b158f
    ) external view returns (uint256 _0x80ff15, uint256 _0x188ab2);

    function _0x17ea1a(address _0x0b158f) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public _0x0f36fe;
    address public _0x654b36;
    address public _0x26ad84;

    constructor(address _0xcb03fd, address _0x7779d5, address _0xc4ce7d) {
        _0x0f36fe = _0xcb03fd;
        _0x654b36 = _0x7779d5;
        _0x26ad84 = _0xc4ce7d;
    }

    function _0x703180(
        address _0x3f01e1,
        address _0x7ce23c,
        uint256 _0x71b6e9,
        uint256 _0x7d7390,
        uint256 _0x1bf859,
        address _0x69a402,
        address _0x49eaf7
    ) external {
        IERC20(_0x654b36)._0xd1f704(
            msg.sender,
            address(this),
            _0x7d7390
        );

        IERC20(_0x654b36)._0x8ccb30(address(_0x0f36fe), _0x7d7390);

        _0x0f36fe._0x287ac0(
            _0x3f01e1,
            _0x7ce23c,
            _0x71b6e9,
            _0x7d7390,
            _0x1bf859,
            _0x69a402,
            _0x49eaf7
        );

        IERC20(_0x26ad84).transfer(msg.sender, _0x1bf859);
    }

    function _0xa246fb(address _0x3f01e1, address _0x7ce23c) external {
        _0x0f36fe._0xf6238e(_0x3f01e1, _0x7ce23c);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public _0xcd7948;
    ITroveManager public _0x3f01e1;

    function _0x1ccf95(address _0xde6ea6, bool _0x601da8) external {
        _0xcd7948[msg.sender][_0xde6ea6] = _0x601da8;
    }

    function _0x287ac0(
        address _0xa6c730,
        address _0x7ce23c,
        uint256 _0xabe17f,
        uint256 _0x17d9a0,
        uint256 _0xc15cdd,
        address _0x9d7ff4,
        address _0xeda20e
    ) external {
        require(
            msg.sender == _0x7ce23c || _0xcd7948[_0x7ce23c][msg.sender],
            "Not authorized"
        );
    }

    function _0xf6238e(address _0xa6c730, address _0x7ce23c) external {
        require(
            msg.sender == _0x7ce23c || _0xcd7948[_0x7ce23c][msg.sender],
            "Not authorized"
        );
    }
}