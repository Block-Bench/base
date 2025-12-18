pragma solidity ^0.8.0;


contract ConcentratedLiquidityPool {

    address public ap;
    address public aq;


    uint160 public r;
    int24 public v;
    uint128 public ae;


    mapping(int24 => int128) public s;


    struct Position {
        uint128 ae;
        int24 ah;
        int24 ai;
    }

    mapping(bytes32 => Position) public aa;

    event Swap(
        address indexed sender,
        uint256 ab,
        uint256 ac,
        uint256 y,
        uint256 z
    );

    event LiquidityAdded(
        address indexed am,
        int24 ah,
        int24 ai,
        uint128 ae
    );


    function t(
        int24 ah,
        int24 ai,
        uint128 n
    ) external returns (uint256 an, uint256 ao) {
        require(ah < ai, "Invalid ticks");
        require(n > 0, "Zero liquidity");


        bytes32 u = ad(
            abi.q(msg.sender, ah, ai)
        );


        Position storage aj = aa[u];
        aj.ae += n;
        aj.ah = ah;
        aj.ai = ai;


        s[ah] += int128(n);
        s[ai] -= int128(n);


        if (v >= ah && v < ai) {
            ae += n;
        }


        (an, ao) = f(
            r,
            ah,
            ai,
            int128(n)
        );

        emit LiquidityAdded(msg.sender, ah, ai, n);
    }


    function ar(
        bool x,
        int256 m,
        uint160 g
    ) external returns (int256 an, int256 ao) {
        require(m != 0, "Zero amount");


        uint160 i = r;
        uint128 p = ae;
        int24 ak = v;


        while (m != 0) {

            (
                uint256 al,
                uint256 ag,
                uint160 d
            ) = j(
                    i,
                    g,
                    p,
                    m
                );


            i = d;


            int24 w = b(i);
            if (w != ak) {

                int128 e = s[w];

                if (x) {
                    e = -e;
                }

                p = o(
                    p,
                    e
                );

                ak = w;
            }


            if (m > 0) {
                m -= int256(al);
            } else {
                m += int256(ag);
            }
        }


        r = i;
        ae = p;
        v = ak;

        return (an, ao);
    }


    function o(
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
        uint160 af,
        int24 ah,
        int24 ai,
        int128 n
    ) internal pure returns (uint256 an, uint256 ao) {
        an = uint256(uint128(n)) / 2;
        ao = uint256(uint128(n)) / 2;
    }


    function j(
        uint160 a,
        uint160 c,
        uint128 k,
        int256 l
    )
        internal
        pure
        returns (uint256 al, uint256 ag, uint160 h)
    {
        al =
            uint256(l > 0 ? l : -l) /
            2;
        ag = al;
        h = a;
    }


    function b(
        uint160 r
    ) internal pure returns (int24 as) {
        return int24(int256(uint256(r >> 96)));
    }
}