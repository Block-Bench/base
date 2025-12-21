pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ad, uint256 v) external returns (bool);

    function g(
        address from,
        address ad,
        uint256 v
    ) external returns (bool);

    function k(address u) external view returns (uint256);

    function t(address q, uint256 v) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address r;
        address m;
        uint24 ac;
        address i;
        uint256 n;
        uint256 o;
        uint256 d;
        uint160 c;
    }

    function e(
        ExactInputSingleParams calldata y
    ) external payable returns (uint256 l);
}

contract BedrockVault {
    IERC20 public immutable w;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable x;

    uint256 public b;
    uint256 public a;

    constructor(address s, address aa, address p) {
        w = IERC20(s);
        WBTC = IERC20(aa);
        x = IUniswapV3Router(p);
    }

    function ab() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 h = msg.value;

        b += msg.value;
        a += h;

        w.transfer(msg.sender, h);
    }

    function z(uint256 v) external {
        require(v > 0, "No amount specified");
        require(w.k(msg.sender) >= v, "Insufficient balance");

        w.g(msg.sender, address(this), v);

        uint256 j = v;
        require(address(this).balance >= j, "Insufficient ETH");

        payable(msg.sender).transfer(j);
    }

    function f() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}