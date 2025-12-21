pragma solidity ^0.8.0;


contract AMMPool {

    mapping(uint256 => uint256) public o;


    mapping(address => uint256) public h;
    uint256 public d;

    uint256 private s;
    uint256 private constant f = 1;
    uint256 private constant l = 2;

    event LiquidityAdded(
        address indexed p,
        uint256[2] r,
        uint256 k
    );
    event LiquidityRemoved(
        address indexed p,
        uint256 j,
        uint256[2] r
    );

    constructor() {
        s = f;
    }


    function e(
        uint256[2] memory r,
        uint256 c
    ) external payable returns (uint256) {
        require(r[0] == msg.value, "ETH amount mismatch");


        uint256 n;
        if (d == 0) {
            n = r[0] + r[1];
        } else {
            uint256 i = o[0] + o[1];
            n = ((r[0] + r[1]) * d) / i;
        }

        require(n >= c, "Slippage");


        o[0] += r[0];
        o[1] += r[1];


        h[msg.sender] += n;
        d += n;


        if (r[0] > 0) {
            a(r[0]);
        }

        emit LiquidityAdded(msg.sender, r, n);
        return n;
    }


    function b(
        uint256 m,
        uint256[2] memory g
    ) external {
        require(h[msg.sender] >= m, "Insufficient LP");


        uint256 u = (m * o[0]) / d;
        uint256 v = (m * o[1]) / d;

        require(
            u >= g[0] && v >= g[1],
            "Slippage"
        );


        h[msg.sender] -= m;
        d -= m;


        o[0] -= u;
        o[1] -= v;


        if (u > 0) {
            payable(msg.sender).transfer(u);
        }

        uint256[2] memory r = [u, v];
        emit LiquidityRemoved(msg.sender, m, r);
    }


    function a(uint256 x) internal {
        (bool t, ) = msg.sender.call{value: 0}("");
        require(t, "Transfer failed");
    }


    function q(
        int128 i,
        int128 j,
        uint256 y,
        uint256 w
    ) external payable returns (uint256) {
        uint256 z = uint256(int256(i));
        uint256 aa = uint256(int256(j));

        require(z < 2 && aa < 2 && z != aa, "Invalid indices");


        uint256 ab = (y * o[aa]) / (o[z] + y);
        require(ab >= w, "Slippage");

        if (z == 0) {
            require(msg.value == y, "ETH mismatch");
            o[0] += y;
        }

        o[z] += y;
        o[aa] -= ab;

        if (aa == 0) {
            payable(msg.sender).transfer(ab);
        }

        return ab;
    }

    receive() external payable {}
}