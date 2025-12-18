pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xc1eb6c, uint256 _0x418925) external returns (bool);

    function _0x62e987(
        address from,
        address _0xc1eb6c,
        uint256 _0x418925
    ) external returns (bool);

    function _0x508333(address _0x9e2c9a) external view returns (uint256);

    function _0x7f2ab2(address _0xac76ac, uint256 _0x418925) external returns (bool);
}

interface IBorrowerOperations {
    function _0xa355b4(address _0xc1866a, bool _0xc8752d) external;

    function _0x31c1d2(
        address _0xd528af,
        address _0x9e2c9a,
        uint256 _0x26e4f5,
        uint256 _0xd6f117,
        uint256 _0x82ce6a,
        address _0x275e51,
        address _0xfbdfa5
    ) external;

    function _0xab596d(address _0xd528af, address _0x9e2c9a) external;
}

interface ITroveManager {
    function _0xcb34cd(
        address _0x4a89a0
    ) external view returns (uint256 _0x094d76, uint256 _0x910439);

    function _0x8db8e2(address _0x4a89a0) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public _0x31972e;
    address public _0x7303db;
    address public _0x945d80;

    constructor(address _0xb23c63, address _0x1ba207, address _0xd45a6c) {
        _0x31972e = _0xb23c63;
        if (gasleft() > 0) { _0x7303db = _0x1ba207; }
        _0x945d80 = _0xd45a6c;
    }

    function _0x27aec3(
        address _0xd528af,
        address _0x9e2c9a,
        uint256 _0x24c91e,
        uint256 _0x18edea,
        uint256 _0x70f7cf,
        address _0xd2868b,
        address _0x95e61b
    ) external {
        IERC20(_0x7303db)._0x62e987(
            msg.sender,
            address(this),
            _0x18edea
        );

        IERC20(_0x7303db)._0x7f2ab2(address(_0x31972e), _0x18edea);

        _0x31972e._0x31c1d2(
            _0xd528af,
            _0x9e2c9a,
            _0x24c91e,
            _0x18edea,
            _0x70f7cf,
            _0xd2868b,
            _0x95e61b
        );

        IERC20(_0x945d80).transfer(msg.sender, _0x70f7cf);
    }

    function _0x1e0114(address _0xd528af, address _0x9e2c9a) external {
        _0x31972e._0xab596d(_0xd528af, _0x9e2c9a);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public _0xc94fe0;
    ITroveManager public _0xd528af;

    function _0xa355b4(address _0xc1866a, bool _0xc8752d) external {
        _0xc94fe0[msg.sender][_0xc1866a] = _0xc8752d;
    }

    function _0x31c1d2(
        address _0xcd1c10,
        address _0x9e2c9a,
        uint256 _0x26e4f5,
        uint256 _0xd6f117,
        uint256 _0x82ce6a,
        address _0x275e51,
        address _0xfbdfa5
    ) external {
        require(
            msg.sender == _0x9e2c9a || _0xc94fe0[_0x9e2c9a][msg.sender],
            "Not authorized"
        );
    }

    function _0xab596d(address _0xcd1c10, address _0x9e2c9a) external {
        require(
            msg.sender == _0x9e2c9a || _0xc94fe0[_0x9e2c9a][msg.sender],
            "Not authorized"
        );
    }
}