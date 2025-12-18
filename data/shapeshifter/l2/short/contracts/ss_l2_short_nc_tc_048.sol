pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address z, uint256 t) external returns (bool);

    function f(
        address from,
        address z,
        uint256 t
    ) external returns (bool);

    function o(address r) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public l;

    string public w = "Sonne WETH";
    string public s = "soWETH";
    uint8 public q = 8;

    uint256 public j;
    mapping(address => uint256) public o;

    uint256 public g;
    uint256 public d;

    event Mint(address v, uint256 n, uint256 m);
    event Redeem(address p, uint256 i, uint256 e);

    constructor(address k) {
        l = IERC20(k);
    }

    function h() public view returns (uint256) {
        if (j == 0) {
            return 1e18;
        }

        uint256 x = l.o(address(this));

        uint256 c = x + g - d;

        return (c * 1e18) / j;
    }

    function y(uint256 n) external returns (uint256) {
        require(n > 0, "Zero mint");

        uint256 a = h();

        uint256 m = (n * 1e18) / a;

        j += m;
        o[msg.sender] += m;

        l.f(msg.sender, address(this), n);

        emit Mint(msg.sender, n, m);
        return m;
    }

    function u(uint256 e) external returns (uint256) {
        require(o[msg.sender] >= e, "Insufficient balance");

        uint256 a = h();

        uint256 i = (e * a) / 1e18;

        o[msg.sender] -= e;
        j -= e;

        l.transfer(msg.sender, i);

        emit Redeem(msg.sender, i, e);
        return i;
    }

    function b(
        address r
    ) external view returns (uint256) {
        uint256 a = h();

        return (o[r] * a) / 1e18;
    }
}