pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address aj, uint256 aa) external returns (bool);

    function h(
        address from,
        address aj,
        uint256 aa
    ) external returns (bool);

    function o(address z) external view returns (uint256);

    function y(address x, uint256 aa) external returns (bool);
}

interface IUniswapV3Pool {
    function ai(
        address n,
        bool k,
        int256 c,
        uint160 a,
        bytes calldata data
    ) external returns (int256 v, int256 w);

    function ag(
        address n,
        uint256 v,
        uint256 w,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public ae;
    IERC20 public af;
    IUniswapV3Pool public ah;

    uint256 public j;
    mapping(address => uint256) public o;

    struct Position {
        uint128 m;
        int24 p;
        int24 q;
    }

    Position public i;
    Position public g;

    function u(
        uint256 r,
        uint256 t,
        address aj
    ) external returns (uint256 ab) {
        uint256 ac = ae.o(address(this));
        uint256 ad = af.o(address(this));

        ae.h(msg.sender, address(this), r);
        af.h(msg.sender, address(this), t);

        if (j == 0) {
            ab = r + t;
        } else {
            uint256 e = ac + r;
            uint256 d = ad + t;

            ab = (j * (r + t)) / (ac + ad);
        }

        o[aj] += ab;
        j += ab;

        f(r, t);
    }

    function s(
        uint256 ab,
        address aj
    ) external returns (uint256 v, uint256 w) {
        require(o[msg.sender] >= ab, "Insufficient balance");

        uint256 ac = ae.o(address(this));
        uint256 ad = af.o(address(this));

        v = (ab * ac) / j;
        w = (ab * ad) / j;

        o[msg.sender] -= ab;
        j -= ab;

        ae.transfer(aj, v);
        af.transfer(aj, w);
    }

    function l() external {
        b(i.m);

        f(
            ae.o(address(this)),
            af.o(address(this))
        );
    }

    function f(uint256 v, uint256 w) internal {}

    function b(uint128 m) internal {}
}