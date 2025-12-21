// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x881a1e, uint256 _0x812f0f) external returns (bool);

    function _0x366227(address _0x10c19a) external view returns (uint256);
}

contract PlayDappToken {
    string public _0x1ea2ce = "PlayDapp Token";
    string public _0x17e8e1 = "PLA";
    uint8 public _0xab45ca = 18;

    uint256 public _0x32249b;

    address public _0x4d52a2;

    mapping(address => uint256) public _0x366227;
    mapping(address => mapping(address => uint256)) public _0x9d9c58;

    event Transfer(address indexed from, address indexed _0x881a1e, uint256 value);
    event Approval(
        address indexed _0xe13648,
        address indexed _0xcbc9f6,
        uint256 value
    );
    event Minted(address indexed _0x881a1e, uint256 _0x812f0f);

    constructor() {
        _0x4d52a2 = msg.sender;
        _0xa06b30(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier _0xa7895e() {
        require(msg.sender == _0x4d52a2, "Not minter");
        _;
    }

    function _0x0d3826(address _0x881a1e, uint256 _0x812f0f) external _0xa7895e {
        _0xa06b30(_0x881a1e, _0x812f0f);
        emit Minted(_0x881a1e, _0x812f0f);
    }

    function _0xa06b30(address _0x881a1e, uint256 _0x812f0f) internal {
        require(_0x881a1e != address(0), "Mint to zero address");

        _0x32249b += _0x812f0f;
        _0x366227[_0x881a1e] += _0x812f0f;

        emit Transfer(address(0), _0x881a1e, _0x812f0f);
    }

    function _0x88875f(address _0xc3560d) external _0xa7895e {
        _0x4d52a2 = _0xc3560d;
    }

    function transfer(address _0x881a1e, uint256 _0x812f0f) external returns (bool) {
        require(_0x366227[msg.sender] >= _0x812f0f, "Insufficient balance");
        _0x366227[msg.sender] -= _0x812f0f;
        _0x366227[_0x881a1e] += _0x812f0f;
        emit Transfer(msg.sender, _0x881a1e, _0x812f0f);
        return true;
    }

    function _0x61ce84(address _0xcbc9f6, uint256 _0x812f0f) external returns (bool) {
        _0x9d9c58[msg.sender][_0xcbc9f6] = _0x812f0f;
        emit Approval(msg.sender, _0xcbc9f6, _0x812f0f);
        return true;
    }

    function _0xb9f5aa(
        address from,
        address _0x881a1e,
        uint256 _0x812f0f
    ) external returns (bool) {
        require(_0x366227[from] >= _0x812f0f, "Insufficient balance");
        require(
            _0x9d9c58[from][msg.sender] >= _0x812f0f,
            "Insufficient allowance"
        );

        _0x366227[from] -= _0x812f0f;
        _0x366227[_0x881a1e] += _0x812f0f;
        _0x9d9c58[from][msg.sender] -= _0x812f0f;

        emit Transfer(from, _0x881a1e, _0x812f0f);
        return true;
    }
}
