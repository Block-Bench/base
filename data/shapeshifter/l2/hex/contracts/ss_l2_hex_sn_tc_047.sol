// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x2c9b43, uint256 _0x311831) external returns (bool);

    function _0x7b33db(address _0xc25eda) external view returns (uint256);
}

contract PlayDappToken {
    string public _0x184528 = "PlayDapp Token";
    string public _0x58fb98 = "PLA";
    uint8 public _0xd86ab5 = 18;

    uint256 public _0xa6eb3c;

    address public _0x774da9;

    mapping(address => uint256) public _0x7b33db;
    mapping(address => mapping(address => uint256)) public _0xd812dc;

    event Transfer(address indexed from, address indexed _0x2c9b43, uint256 value);
    event Approval(
        address indexed _0xbf6be4,
        address indexed _0x71acea,
        uint256 value
    );
    event Minted(address indexed _0x2c9b43, uint256 _0x311831);

    constructor() {
        _0x774da9 = msg.sender;
        _0x632e3f(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier _0x0c61ed() {
        require(msg.sender == _0x774da9, "Not minter");
        _;
    }

    function _0x5899c9(address _0x2c9b43, uint256 _0x311831) external _0x0c61ed {
        _0x632e3f(_0x2c9b43, _0x311831);
        emit Minted(_0x2c9b43, _0x311831);
    }

    function _0x632e3f(address _0x2c9b43, uint256 _0x311831) internal {
        require(_0x2c9b43 != address(0), "Mint to zero address");

        _0xa6eb3c += _0x311831;
        _0x7b33db[_0x2c9b43] += _0x311831;

        emit Transfer(address(0), _0x2c9b43, _0x311831);
    }

    function _0x9f8380(address _0x610ddd) external _0x0c61ed {
        _0x774da9 = _0x610ddd;
    }

    function transfer(address _0x2c9b43, uint256 _0x311831) external returns (bool) {
        require(_0x7b33db[msg.sender] >= _0x311831, "Insufficient balance");
        _0x7b33db[msg.sender] -= _0x311831;
        _0x7b33db[_0x2c9b43] += _0x311831;
        emit Transfer(msg.sender, _0x2c9b43, _0x311831);
        return true;
    }

    function _0x6a29b4(address _0x71acea, uint256 _0x311831) external returns (bool) {
        _0xd812dc[msg.sender][_0x71acea] = _0x311831;
        emit Approval(msg.sender, _0x71acea, _0x311831);
        return true;
    }

    function _0x5432e7(
        address from,
        address _0x2c9b43,
        uint256 _0x311831
    ) external returns (bool) {
        require(_0x7b33db[from] >= _0x311831, "Insufficient balance");
        require(
            _0xd812dc[from][msg.sender] >= _0x311831,
            "Insufficient allowance"
        );

        _0x7b33db[from] -= _0x311831;
        _0x7b33db[_0x2c9b43] += _0x311831;
        _0xd812dc[from][msg.sender] -= _0x311831;

        emit Transfer(from, _0x2c9b43, _0x311831);
        return true;
    }
}
