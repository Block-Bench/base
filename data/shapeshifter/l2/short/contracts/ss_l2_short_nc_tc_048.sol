pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address z, uint256 s) external returns (bool);

    function g(
        address from,
        address z,
        uint256 s
    ) external returns (bool);

    function o(address r) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public m;

    string public w = "Sonne WETH";
    string public u = "soWETH";
    uint8 public q = 8;

    uint256 public j;
    mapping(address => uint256) public o;

    uint256 public h;
    uint256 public d;

    event Mint(address v, uint256 n, uint256 l);
    event Redeem(address p, uint256 i, uint256 f);

    constructor(address k) {
        m = IERC20(k);
    }

    function e() public view returns (uint256) {
        if (j == 0) {
            return 1e18;
        }

        uint256 x = m.o(address(this));

        uint256 c = x + h - d;

        return (c * 1e18) / j;
    }

    function y(uint256 n) external returns (uint256) {
        require(n > 0, "Zero mint");

        uint256 a = e();

        uint256 l = (n * 1e18) / a;

        j += l;
        o[msg.sender] += l;

        m.g(msg.sender, address(this), n);

        emit Mint(msg.sender, n, l);
        return l;
    }

    function t(uint256 f) external returns (uint256) {
        require(o[msg.sender] >= f, "Insufficient balance");

        uint256 a = e();

        uint256 i = (f * a) / 1e18;

        o[msg.sender] -= f;
        j -= f;

        m.transfer(msg.sender, i);

        emit Redeem(msg.sender, i, f);
        return i;
    }

    function b(
        address r
    ) external view returns (uint256) {
        uint256 a = e();

        return (o[r] * a) / 1e18;
    }
}