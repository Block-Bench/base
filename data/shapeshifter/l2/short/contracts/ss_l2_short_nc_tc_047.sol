pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address s, uint256 l) external returns (bool);

    function g(address k) external view returns (uint256);
}

contract PlayDappToken {
    string public q = "PlayDapp Token";
    string public m = "PLA";
    uint8 public h = 18;

    uint256 public b;

    address public n;

    mapping(address => uint256) public g;
    mapping(address => mapping(address => uint256)) public e;

    event Transfer(address indexed from, address indexed s, uint256 value);
    event Approval(
        address indexed o,
        address indexed i,
        uint256 value
    );
    event Minted(address indexed s, uint256 l);

    constructor() {
        n = msg.sender;
        p(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier c() {
        require(msg.sender == n, "Not minter");
        _;
    }

    function r(address s, uint256 l) external c {
        p(s, l);
        emit Minted(s, l);
    }

    function p(address s, uint256 l) internal {
        require(s != address(0), "Mint to zero address");

        b += l;
        g[s] += l;

        emit Transfer(address(0), s, l);
    }

    function f(address d) external c {
        n = d;
    }

    function transfer(address s, uint256 l) external returns (bool) {
        require(g[msg.sender] >= l, "Insufficient balance");
        g[msg.sender] -= l;
        g[s] += l;
        emit Transfer(msg.sender, s, l);
        return true;
    }

    function j(address i, uint256 l) external returns (bool) {
        e[msg.sender][i] = l;
        emit Approval(msg.sender, i, l);
        return true;
    }

    function a(
        address from,
        address s,
        uint256 l
    ) external returns (bool) {
        require(g[from] >= l, "Insufficient balance");
        require(
            e[from][msg.sender] >= l,
            "Insufficient allowance"
        );

        g[from] -= l;
        g[s] += l;
        e[from][msg.sender] -= l;

        emit Transfer(from, s, l);
        return true;
    }
}