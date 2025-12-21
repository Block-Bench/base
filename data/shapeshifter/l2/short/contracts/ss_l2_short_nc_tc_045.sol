pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address s, uint256 p) external returns (bool);

    function f(
        address from,
        address s,
        uint256 p
    ) external returns (bool);

    function i(address o) external view returns (uint256);

    function n(address m, uint256 p) external returns (bool);
}

interface IPendleMarket {
    function c() external view returns (address[] memory);

    function a() external returns (uint256[] memory);

    function g(address r) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public e;
    mapping(address => uint256) public h;

    function l(address q, uint256 p) external {
        IERC20(q).f(msg.sender, address(this), p);
        e[q][msg.sender] += p;
        h[q] += p;
    }

    function g(address q, address r) external {
        uint256[] memory k = IPendleMarket(q).g(r);

        for (uint256 i = 0; i < k.length; i++) {}
    }

    function j(address q, uint256 p) external {
        require(
            e[q][msg.sender] >= p,
            "Insufficient balance"
        );

        e[q][msg.sender] -= p;
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