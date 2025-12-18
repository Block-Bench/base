pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address s, uint256 p) external returns (bool);

    function e(
        address from,
        address s,
        uint256 p
    ) external returns (bool);

    function i(address m) external view returns (uint256);

    function l(address k, uint256 p) external returns (bool);
}

interface IPendleMarket {
    function c() external view returns (address[] memory);

    function a() external returns (uint256[] memory);

    function g(address r) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public f;
    mapping(address => uint256) public h;

    function o(address q, uint256 p) external {
        IERC20(q).e(msg.sender, address(this), p);
        f[q][msg.sender] += p;
        h[q] += p;
    }

    function g(address q, address r) external {
        uint256[] memory n = IPendleMarket(q).g(r);

        for (uint256 i = 0; i < n.length; i++) {}
    }

    function j(address q, uint256 p) external {
        require(
            f[q][msg.sender] >= p,
            "Insufficient balance"
        );

        f[q][msg.sender] -= p;
        h[q] -= p;

        IERC20(q).transfer(msg.sender, p);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public b;

    function d(address q) external {
        b[q] = true;
    }
}