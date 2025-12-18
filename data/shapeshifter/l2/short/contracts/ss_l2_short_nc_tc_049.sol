pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ae, uint256 y) external returns (bool);

    function g(
        address from,
        address ae,
        uint256 y
    ) external returns (bool);

    function n(address u) external view returns (uint256);
}

interface IMarket {
    function b(
        address u
    )
        external
        view
        returns (uint256 j, uint256 s, uint256 f);
}

contract DebtPreviewer {
    function i(
        address aa,
        address u
    )
        external
        view
        returns (
            uint256 c,
            uint256 m,
            uint256 h
        )
    {
        (uint256 j, uint256 s, uint256 f) = IMarket(
            aa
        ).b(u);

        c = (j * f) / 1e18;
        m = s;

        if (m == 0) {
            h = type(uint256).ad;
        } else {
            h = (c * 1e18) / m;
        }

        return (c, m, h);
    }

    function a(
        address[] calldata v,
        address u
    )
        external
        view
        returns (
            uint256 d,
            uint256 l,
            uint256 e
        )
    {
        for (uint256 i = 0; i < v.length; i++) {
            (uint256 j, uint256 ac, ) = this.i(
                v[i],
                u
            );

            d += j;
            l += ac;
        }

        if (l == 0) {
            e = type(uint256).ad;
        } else {
            e = (d * 1e18) / l;
        }

        return (d, l, e);
    }
}

contract ExactlyMarket {
    IERC20 public ab;
    DebtPreviewer public p;

    mapping(address => uint256) public r;
    mapping(address => uint256) public s;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address x, address k) {
        ab = IERC20(x);
        p = DebtPreviewer(k);
    }

    function w(uint256 y) external {
        ab.g(msg.sender, address(this), y);
        r[msg.sender] += y;
    }

    function z(uint256 y, address[] calldata v) external {
        (uint256 d, uint256 l, ) = p
            .a(v, msg.sender);

        uint256 t = l + y;

        uint256 o = (d * COLLATERAL_FACTOR) / 100;
        require(t <= o, "Insufficient collateral");

        s[msg.sender] += y;
        ab.transfer(msg.sender, y);
    }

    function b(
        address u
    )
        external
        view
        returns (uint256 j, uint256 q, uint256 f)
    {
        return (r[u], s[u], 1e18);
    }
}