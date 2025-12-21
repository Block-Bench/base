// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ae, uint256 z) external returns (bool);

    function g(
        address from,
        address ae,
        uint256 z
    ) external returns (bool);

    function l(address w) external view returns (uint256);
}

interface IMarket {
    function b(
        address w
    )
        external
        view
        returns (uint256 j, uint256 t, uint256 h);
}

contract DebtPreviewer {
    function i(
        address y,
        address w
    )
        external
        view
        returns (
            uint256 d,
            uint256 n,
            uint256 f
        )
    {
        (uint256 j, uint256 t, uint256 h) = IMarket(
            y
        ).b(w);

        d = (j * h) / 1e18;
        n = t;

        if (n == 0) {
            f = type(uint256).ad;
        } else {
            f = (d * 1e18) / n;
        }

        return (d, n, f);
    }

    function a(
        address[] calldata v,
        address w
    )
        external
        view
        returns (
            uint256 c,
            uint256 p,
            uint256 e
        )
    {
        for (uint256 i = 0; i < v.length; i++) {
            (uint256 j, uint256 ac, ) = this.i(
                v[i],
                w
            );

            c += j;
            p += ac;
        }

        if (p == 0) {
            e = type(uint256).ad;
        } else {
            e = (c * 1e18) / p;
        }

        return (c, p, e);
    }
}

contract ExactlyMarket {
    IERC20 public ab;
    DebtPreviewer public m;

    mapping(address => uint256) public q;
    mapping(address => uint256) public t;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address x, address k) {
        ab = IERC20(x);
        m = DebtPreviewer(k);
    }

    function u(uint256 z) external {
        ab.g(msg.sender, address(this), z);
        q[msg.sender] += z;
    }

    function aa(uint256 z, address[] calldata v) external {
        (uint256 c, uint256 p, ) = m
            .a(v, msg.sender);

        uint256 s = p + z;

        uint256 o = (c * COLLATERAL_FACTOR) / 100;
        require(s <= o, "Insufficient collateral");

        t[msg.sender] += z;
        ab.transfer(msg.sender, z);
    }

    function b(
        address w
    )
        external
        view
        returns (uint256 j, uint256 r, uint256 h)
    {
        return (q[w], t[w], 1e18);
    }
}
