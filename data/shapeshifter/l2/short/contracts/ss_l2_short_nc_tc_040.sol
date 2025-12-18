pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ad, uint256 v) external returns (bool);

    function g(
        address from,
        address ad,
        uint256 v
    ) external returns (bool);

    function l(address t) external view returns (uint256);

    function s(address q, uint256 v) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address r;
        address o;
        uint24 ac;
        address i;
        uint256 m;
        uint256 n;
        uint256 d;
        uint160 b;
    }

    function e(
        ExactInputSingleParams calldata y
    ) external payable returns (uint256 j);
}

contract BedrockVault {
    IERC20 public immutable z;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable x;

    uint256 public c;
    uint256 public a;

    constructor(address u, address aa, address p) {
        z = IERC20(u);
        WBTC = IERC20(aa);
        x = IUniswapV3Router(p);
    }

    function ab() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 h = msg.value;

        c += msg.value;
        a += h;

        z.transfer(msg.sender, h);
    }

    function w(uint256 v) external {
        require(v > 0, "No amount specified");
        require(z.l(msg.sender) >= v, "Insufficient balance");

        z.g(msg.sender, address(this), v);

        uint256 k = v;
        require(address(this).balance >= k, "Insufficient ETH");

        payable(msg.sender).transfer(k);
    }

    function f() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}