pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ae, uint256 y) external returns (bool);

    function f(
        address from,
        address ae,
        uint256 y
    ) external returns (bool);

    function o(address w) external view returns (uint256);
}

interface IMarket {
    function b(
        address w
    )
        external
        view
        returns (uint256 j, uint256 v, uint256 h);
}

contract DebtPreviewer {
    function i(
        address z,
        address w
    )
        external
        view
        returns (
            uint256 d,
            uint256 n,
            uint256 g
        )
    {
        (uint256 j, uint256 v, uint256 h) = IMarket(
            z
        ).b(w);

        d = (j * h) / 1e18;
        n = v;

        if (n == 0) {
            g = type(uint256).ad;
        } else {
            g = (d * 1e18) / n;
        }

        return (d, n, g);
    }

    function a(
        address[] calldata t,
        address w
    )
        external
        view
        returns (
            uint256 c,
            uint256 l,
            uint256 e
        )
    {
        for (uint256 i = 0; i < t.length; i++) {
            (uint256 j, uint256 ac, ) = this.i(
                t[i],
                w
            );

            c += j;
            l += ac;
        }

        if (l == 0) {
            e = type(uint256).ad;
        } else {
            e = (c * 1e18) / l;
        }

        return (c, l, e);
    }
}

contract ExactlyMarket {
    IERC20 public ab;
    DebtPreviewer public m;

    mapping(address => uint256) public q;
    mapping(address => uint256) public v;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address aa, address k) {
        ab = IERC20(aa);
        m = DebtPreviewer(k);
    }

    function s(uint256 y) external {
        ab.f(msg.sender, address(this), y);
        q[msg.sender] += y;
    }

    function x(uint256 y, address[] calldata t) external {
        (uint256 c, uint256 l, ) = m
            .a(t, msg.sender);

        uint256 u = l + y;

        uint256 p = (c * COLLATERAL_FACTOR) / 100;
        require(u <= p, "Insufficient collateral");

        v[msg.sender] += y;
        ab.transfer(msg.sender, y);
    }

    function b(
        address w
    )
        external
        view
        returns (uint256 j, uint256 r, uint256 h)
    {
        return (q[w], v[w], 1e18);
    }
}