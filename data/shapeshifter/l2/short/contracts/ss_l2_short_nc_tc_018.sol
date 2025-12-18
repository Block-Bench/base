pragma solidity ^0.8.0;

interface IERC20 {
    function n(address t) external view returns (uint256);

    function transfer(address aa, uint256 v) external returns (bool);
}

contract TokenPool {
    struct Token {
        address z;
        uint256 balance;
        uint256 u;
    }

    mapping(address => Token) public w;
    address[] public m;
    uint256 public f;

    constructor() {
        f = 100;
    }

    function p(address x, uint256 c) external {
        w[x] = Token({z: x, balance: 0, u: c});
        m.push(x);
    }

    function y(
        address s,
        address r,
        uint256 q
    ) external returns (uint256 k) {
        require(w[s].z != address(0), "Invalid token");
        require(w[r].z != address(0), "Invalid token");

        IERC20(s).transfer(address(this), q);
        w[s].balance += q;

        k = a(s, r, q);

        require(
            w[r].balance >= k,
            "Insufficient liquidity"
        );
        w[r].balance -= k;
        IERC20(r).transfer(msg.sender, k);

        b();

        return k;
    }

    function a(
        address s,
        address r,
        uint256 q
    ) public view returns (uint256) {
        uint256 o = w[s].u;
        uint256 i = w[r].u;
        uint256 g = w[r].balance;

        uint256 l = g * q * i;
        uint256 e = w[s].balance *
            o +
            q *
            i;

        return l / e;
    }

    function b() internal {
        uint256 h = 0;

        for (uint256 i = 0; i < m.length; i++) {
            address x = m[i];
            h += w[x].balance;
        }

        for (uint256 i = 0; i < m.length; i++) {
            address x = m[i];
            w[x].u = (w[x].balance * 100) / h;
        }
    }

    function j(address x) external view returns (uint256) {
        return w[x].u;
    }

    function d(address x, uint256 v) external {
        require(w[x].z != address(0), "Invalid token");
        IERC20(x).transfer(address(this), v);
        w[x].balance += v;
        b();
    }
}