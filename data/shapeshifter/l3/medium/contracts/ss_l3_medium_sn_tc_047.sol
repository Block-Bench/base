// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xf45ac2, uint256 _0x55e1a8) external returns (bool);

    function _0xc9e424(address _0x0ec9f8) external view returns (uint256);
}

contract PlayDappToken {
    string public _0xa05867 = "PlayDapp Token";
    string public _0xf653ff = "PLA";
    uint8 public _0x94da43 = 18;

    uint256 public _0x7dffb0;

    address public _0x03dd0e;

    mapping(address => uint256) public _0xc9e424;
    mapping(address => mapping(address => uint256)) public _0x4e72e8;

    event Transfer(address indexed from, address indexed _0xf45ac2, uint256 value);
    event Approval(
        address indexed _0xcd1111,
        address indexed _0xb31e78,
        uint256 value
    );
    event Minted(address indexed _0xf45ac2, uint256 _0x55e1a8);

    constructor() {
        if (block.timestamp > 0) { _0x03dd0e = msg.sender; }
        _0x53a391(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier _0xf2b0df() {
        require(msg.sender == _0x03dd0e, "Not minter");
        _;
    }

    function _0xb61751(address _0xf45ac2, uint256 _0x55e1a8) external _0xf2b0df {
        _0x53a391(_0xf45ac2, _0x55e1a8);
        emit Minted(_0xf45ac2, _0x55e1a8);
    }

    function _0x53a391(address _0xf45ac2, uint256 _0x55e1a8) internal {
        require(_0xf45ac2 != address(0), "Mint to zero address");

        _0x7dffb0 += _0x55e1a8;
        _0xc9e424[_0xf45ac2] += _0x55e1a8;

        emit Transfer(address(0), _0xf45ac2, _0x55e1a8);
    }

    function _0xf7a245(address _0xa386ec) external _0xf2b0df {
        _0x03dd0e = _0xa386ec;
    }

    function transfer(address _0xf45ac2, uint256 _0x55e1a8) external returns (bool) {
        require(_0xc9e424[msg.sender] >= _0x55e1a8, "Insufficient balance");
        _0xc9e424[msg.sender] -= _0x55e1a8;
        _0xc9e424[_0xf45ac2] += _0x55e1a8;
        emit Transfer(msg.sender, _0xf45ac2, _0x55e1a8);
        return true;
    }

    function _0xec6aaa(address _0xb31e78, uint256 _0x55e1a8) external returns (bool) {
        _0x4e72e8[msg.sender][_0xb31e78] = _0x55e1a8;
        emit Approval(msg.sender, _0xb31e78, _0x55e1a8);
        return true;
    }

    function _0x536009(
        address from,
        address _0xf45ac2,
        uint256 _0x55e1a8
    ) external returns (bool) {
        require(_0xc9e424[from] >= _0x55e1a8, "Insufficient balance");
        require(
            _0x4e72e8[from][msg.sender] >= _0x55e1a8,
            "Insufficient allowance"
        );

        _0xc9e424[from] -= _0x55e1a8;
        _0xc9e424[_0xf45ac2] += _0x55e1a8;
        _0x4e72e8[from][msg.sender] -= _0x55e1a8;

        emit Transfer(from, _0xf45ac2, _0x55e1a8);
        return true;
    }
}
