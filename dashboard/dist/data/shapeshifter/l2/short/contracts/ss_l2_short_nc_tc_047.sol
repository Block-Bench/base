pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address s, uint256 m) external returns (bool);

    function e(address k) external view returns (uint256);
}

contract PlayDappToken {
    string public q = "PlayDapp Token";
    string public l = "PLA";
    uint8 public h = 18;

    uint256 public b;

    address public n;

    mapping(address => uint256) public e;
    mapping(address => mapping(address => uint256)) public f;

    event Transfer(address indexed from, address indexed s, uint256 value);
    event Approval(
        address indexed o,
        address indexed i,
        uint256 value
    );
    event Minted(address indexed s, uint256 m);

    constructor() {
        n = msg.sender;
        p(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier c() {
        require(msg.sender == n, "Not minter");
        _;
    }

    function r(address s, uint256 m) external c {
        p(s, m);
        emit Minted(s, m);
    }

    function p(address s, uint256 m) internal {
        require(s != address(0), "Mint to zero address");

        b += m;
        e[s] += m;

        emit Transfer(address(0), s, m);
    }

    function g(address d) external c {
        n = d;
    }

    function transfer(address s, uint256 m) external returns (bool) {
        require(e[msg.sender] >= m, "Insufficient balance");
        e[msg.sender] -= m;
        e[s] += m;
        emit Transfer(msg.sender, s, m);
        return true;
    }

    function j(address i, uint256 m) external returns (bool) {
        f[msg.sender][i] = m;
        emit Approval(msg.sender, i, m);
        return true;
    }

    function a(
        address from,
        address s,
        uint256 m
    ) external returns (bool) {
        require(e[from] >= m, "Insufficient balance");
        require(
            f[from][msg.sender] >= m,
            "Insufficient allowance"
        );

        e[from] -= m;
        e[s] += m;
        f[from][msg.sender] -= m;

        emit Transfer(from, s, m);
        return true;
    }
}