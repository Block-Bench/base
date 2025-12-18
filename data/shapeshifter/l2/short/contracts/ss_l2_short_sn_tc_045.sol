// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address s, uint256 q) external returns (bool);

    function g(
        address from,
        address s,
        uint256 q
    ) external returns (bool);

    function i(address o) external view returns (uint256);

    function m(address k, uint256 q) external returns (bool);
}

interface IPendleMarket {
    function c() external view returns (address[] memory);

    function a() external returns (uint256[] memory);

    function e(address r) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public f;
    mapping(address => uint256) public h;

    function l(address p, uint256 q) external {
        IERC20(p).g(msg.sender, address(this), q);
        f[p][msg.sender] += q;
        h[p] += q;
    }

    function e(address p, address r) external {
        uint256[] memory n = IPendleMarket(p).e(r);

        for (uint256 i = 0; i < n.length; i++) {}
    }

    function j(address p, uint256 q) external {
        require(
            f[p][msg.sender] >= q,
            "Insufficient balance"
        );

        f[p][msg.sender] -= q;
        h[p] -= q;

        IERC20(p).transfer(msg.sender, q);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public b;

    function d(address p) external {
        b[p] = true;
    }
}
