// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address w, uint256 r) external returns (bool);

    function f(
        address from,
        address w,
        uint256 r
    ) external returns (bool);

    function j(address q) external view returns (uint256);

    function p(address n, uint256 r) external returns (bool);
}

interface IWETH {
    function o() external payable;

    function l(uint256 r) external;

    function j(address q) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable i;

    constructor(address u, address g) {
        WETH = IWETH(u);
        i = g;
    }

    function a(
        int256 e,
        int256 d,
        bytes calldata data
    ) external payable {
        (
            uint256 v,
            address s,
            address m,
            address k
        ) = abi.t(data, (uint256, address, address, address));

        uint256 h;
        if (e > 0) {
            h = uint256(e);
        } else {
            h = uint256(d);
        }

        if (m == address(WETH)) {
            WETH.l(h);
            payable(k).transfer(h);
        } else {
            IERC20(m).transfer(k, h);
        }
    }

    function b(bytes calldata c) external {
        require(msg.sender == i, "Only settlement");
    }

    receive() external payable {}
}
