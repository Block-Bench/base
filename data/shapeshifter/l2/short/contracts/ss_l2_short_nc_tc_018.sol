pragma solidity ^0.8.0;

interface IERC20 {
    function l(address t) external view returns (uint256);

    function transfer(address aa, uint256 v) external returns (bool);
}

contract TokenPool {
    struct Token {
        address y;
        uint256 balance;
        uint256 u;
    }

    mapping(address => Token) public w;
    address[] public j;
    uint256 public f;

    constructor() {
        f = 100;
    }

    function p(address x, uint256 c) external {
        w[x] = Token({y: x, balance: 0, u: c});
        j.push(x);
    }

    function z(
        address s,
        address o,
        uint256 r
    ) external returns (uint256 m) {
        require(w[s].y != address(0), "Invalid token");
        require(w[o].y != address(0), "Invalid token");

        IERC20(s).transfer(address(this), r);
        w[s].balance += r;

        m = a(s, o, r);

        require(
            w[o].balance >= m,
            "Insufficient liquidity"
        );
        w[o].balance -= m;
        IERC20(o).transfer(msg.sender, m);

        b();

        return m;
    }

    function a(
        address s,
        address o,
        uint256 r
    ) public view returns (uint256) {
        uint256 q = w[s].u;
        uint256 n = w[o].u;
        uint256 g = w[o].balance;

        uint256 i = g * r * n;
        uint256 e = w[s].balance *
            q +
            r *
            n;

        return i / e;
    }

    function b() internal {
        uint256 h = 0;

        for (uint256 i = 0; i < j.length; i++) {
            address x = j[i];
            h += w[x].balance;
        }

        for (uint256 i = 0; i < j.length; i++) {
            address x = j[i];
            w[x].u = (w[x].balance * 100) / h;
        }
    }

    function k(address x) external view returns (uint256) {
        return w[x].u;
    }

    function d(address x, uint256 v) external {
        require(w[x].y != address(0), "Invalid token");
        IERC20(x).transfer(address(this), v);
        w[x].balance += v;
        b();
    }
}