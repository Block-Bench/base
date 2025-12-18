pragma solidity ^0.8.0;


contract AMMPool {

    mapping(uint256 => uint256) public p;


    mapping(address => uint256) public i;
    uint256 public d;

    uint256 private t;
    uint256 private constant f = 1;
    uint256 private constant q = 2;

    event LiquidityAdded(
        address indexed o,
        uint256[2] s,
        uint256 n
    );
    event LiquidityRemoved(
        address indexed o,
        uint256 l,
        uint256[2] s
    );

    constructor() {
        t = f;
    }


    function e(
        uint256[2] memory s,
        uint256 c
    ) external payable returns (uint256) {
        require(s[0] == msg.value, "ETH amount mismatch");


        uint256 j;
        if (d == 0) {
            j = s[0] + s[1];
        } else {
            uint256 h = p[0] + p[1];
            j = ((s[0] + s[1]) * d) / h;
        }

        require(j >= c, "Slippage");


        p[0] += s[0];
        p[1] += s[1];


        i[msg.sender] += j;
        d += j;


        if (s[0] > 0) {
            a(s[0]);
        }

        emit LiquidityAdded(msg.sender, s, j);
        return j;
    }


    function b(
        uint256 m,
        uint256[2] memory g
    ) external {
        require(i[msg.sender] >= m, "Insufficient LP");


        uint256 v = (m * p[0]) / d;
        uint256 u = (m * p[1]) / d;

        require(
            v >= g[0] && u >= g[1],
            "Slippage"
        );


        i[msg.sender] -= m;
        d -= m;


        p[0] -= v;
        p[1] -= u;


        if (v > 0) {
            payable(msg.sender).transfer(v);
        }

        uint256[2] memory s = [v, u];
        emit LiquidityRemoved(msg.sender, m, s);
    }


    function a(uint256 w) internal {
        (bool r, ) = msg.sender.call{value: 0}("");
        require(r, "Transfer failed");
    }


    function k(
        int128 i,
        int128 j,
        uint256 aa,
        uint256 x
    ) external payable returns (uint256) {
        uint256 y = uint256(int256(i));
        uint256 z = uint256(int256(j));

        require(y < 2 && z < 2 && y != z, "Invalid indices");


        uint256 ab = (aa * p[z]) / (p[y] + aa);
        require(ab >= x, "Slippage");

        if (y == 0) {
            require(msg.value == aa, "ETH mismatch");
            p[0] += aa;
        }

        p[y] += aa;
        p[z] -= ab;

        if (z == 0) {
            payable(msg.sender).transfer(ab);
        }

        return ab;
    }

    receive() external payable {}
}