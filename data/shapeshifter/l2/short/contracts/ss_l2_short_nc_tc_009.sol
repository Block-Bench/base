pragma solidity ^0.8.0;


contract ConcentratedLiquidityPool {

    address public aq;
    address public ap;


    uint160 public q;
    int24 public v;
    uint128 public af;


    mapping(int24 => int128) public s;


    struct Position {
        uint128 af;
        int24 ad;
        int24 ag;
    }

    mapping(bytes32 => Position) public ac;

    event Swap(
        address indexed sender,
        uint256 ab,
        uint256 ai,
        uint256 x,
        uint256 z
    );

    event LiquidityAdded(
        address indexed al,
        int24 ad,
        int24 ag,
        uint128 af
    );


    function t(
        int24 ad,
        int24 ag,
        uint128 n
    ) external returns (uint256 ao, uint256 an) {
        require(ad < ag, "Invalid ticks");
        require(n > 0, "Zero liquidity");


        bytes32 w = ah(
            abi.r(msg.sender, ad, ag)
        );


        Position storage ak = ac[w];
        ak.af += n;
        ak.ad = ad;
        ak.ag = ag;


        s[ad] += int128(n);
        s[ag] -= int128(n);


        if (v >= ad && v < ag) {
            af += n;
        }


        (ao, an) = f(
            q,
            ad,
            ag,
            int128(n)
        );

        emit LiquidityAdded(msg.sender, ad, ag, n);
    }


    function ar(
        bool y,
        int256 m,
        uint160 g
    ) external returns (int256 ao, int256 an) {
        require(m != 0, "Zero amount");


        uint160 i = q;
        uint128 o = af;
        int24 aj = v;


        while (m != 0) {

            (
                uint256 am,
                uint256 ae,
                uint160 e
            ) = k(
                    i,
                    g,
                    o,
                    m
                );


            i = e;


            int24 u = a(i);
            if (u != aj) {

                int128 d = s[u];

                if (y) {
                    d = -d;
                }

                o = p(
                    o,
                    d
                );

                aj = u;
            }


            if (m > 0) {
                m -= int256(am);
            } else {
                m += int256(ae);
            }
        }


        q = i;
        af = o;
        v = aj;

        return (ao, an);
    }


    function p(
        uint128 x,
        int128 y
    ) internal pure returns (uint128 z) {
        if (y < 0) {
            z = x - uint128(-y);
        } else {
            z = x + uint128(y);
        }
    }


    function f(
        uint160 aa,
        int24 ad,
        int24 ag,
        int128 n
    ) internal pure returns (uint256 ao, uint256 an) {
        ao = uint256(uint128(n)) / 2;
        an = uint256(uint128(n)) / 2;
    }


    function k(
        uint160 b,
        uint160 c,
        uint128 j,
        int256 l
    )
        internal
        pure
        returns (uint256 am, uint256 ae, uint160 h)
    {
        am =
            uint256(l > 0 ? l : -l) /
            2;
        ae = am;
        h = b;
    }


    function a(
        uint160 q
    ) internal pure returns (int24 as) {
        return int24(int256(uint256(q >> 96)));
    }
}