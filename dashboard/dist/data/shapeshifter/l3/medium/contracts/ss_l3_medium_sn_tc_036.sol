// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x87761e, uint256 _0xe0a102) external returns (bool);

    function _0x156b34(
        address from,
        address _0x87761e,
        uint256 _0xe0a102
    ) external returns (bool);

    function _0x228f37(address _0x699e34) external view returns (uint256);

    function _0xb0a4a4(address _0x835f74, uint256 _0xe0a102) external returns (bool);
}

interface IBorrowerOperations {
    function _0x7c58d6(address _0xaf3458, bool _0x03545e) external;

    function _0x3f165b(
        address _0x3c7a13,
        address _0x699e34,
        uint256 _0x768faa,
        uint256 _0x0cdfa0,
        uint256 _0x42a69b,
        address _0xca024c,
        address _0x677f7c
    ) external;

    function _0x13f7e9(address _0x3c7a13, address _0x699e34) external;
}

interface ITroveManager {
    function _0x8e48e1(
        address _0x47aeaa
    ) external view returns (uint256 _0x70b76d, uint256 _0x53bf60);

    function _0x14a066(address _0x47aeaa) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public _0x113b43;
    address public _0xb2708a;
    address public _0xc7ab25;

    constructor(address _0x55640b, address _0x38ee46, address _0x7a5484) {
        _0x113b43 = _0x55640b;
        _0xb2708a = _0x38ee46;
        _0xc7ab25 = _0x7a5484;
    }

    function _0x17720c(
        address _0x3c7a13,
        address _0x699e34,
        uint256 _0x17dc87,
        uint256 _0x2e9982,
        uint256 _0x3fa27c,
        address _0x3d2f47,
        address _0xff223e
    ) external {
        IERC20(_0xb2708a)._0x156b34(
            msg.sender,
            address(this),
            _0x2e9982
        );

        IERC20(_0xb2708a)._0xb0a4a4(address(_0x113b43), _0x2e9982);

        _0x113b43._0x3f165b(
            _0x3c7a13,
            _0x699e34,
            _0x17dc87,
            _0x2e9982,
            _0x3fa27c,
            _0x3d2f47,
            _0xff223e
        );

        IERC20(_0xc7ab25).transfer(msg.sender, _0x3fa27c);
    }

    function _0x4bc84c(address _0x3c7a13, address _0x699e34) external {
        _0x113b43._0x13f7e9(_0x3c7a13, _0x699e34);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public _0x302772;
    ITroveManager public _0x3c7a13;

    function _0x7c58d6(address _0xaf3458, bool _0x03545e) external {
        _0x302772[msg.sender][_0xaf3458] = _0x03545e;
    }

    function _0x3f165b(
        address _0x8cae3f,
        address _0x699e34,
        uint256 _0x768faa,
        uint256 _0x0cdfa0,
        uint256 _0x42a69b,
        address _0xca024c,
        address _0x677f7c
    ) external {
        require(
            msg.sender == _0x699e34 || _0x302772[_0x699e34][msg.sender],
            "Not authorized"
        );
    }

    function _0x13f7e9(address _0x8cae3f, address _0x699e34) external {
        require(
            msg.sender == _0x699e34 || _0x302772[_0x699e34][msg.sender],
            "Not authorized"
        );
    }
}
