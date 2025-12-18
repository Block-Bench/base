pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address w, uint256 r) external returns (bool);

    function d(
        address from,
        address w,
        uint256 r
    ) external returns (bool);

    function k(address p) external view returns (uint256);

    function o(address m, uint256 r) external returns (bool);
}

interface IWETH {
    function q() external payable;

    function l(uint256 r) external;

    function k(address p) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable i;

    constructor(address v, address h) {
        WETH = IWETH(v);
        i = h;
    }

    function a(
        int256 e,
        int256 f,
        bytes calldata data
    ) external payable {
        (
            uint256 u,
            address s,
            address n,
            address j
        ) = abi.t(data, (uint256, address, address, address));

        uint256 g;
        if (e > 0) {
            g = uint256(e);
        } else {
            g = uint256(f);
        }

        if (n == address(WETH)) {
            WETH.l(g);
            payable(j).transfer(g);
        } else {
            IERC20(n).transfer(j, g);
        }
    }

    function b(bytes calldata c) external {
        require(msg.sender == i, "Only settlement");
    }

    receive() external payable {}
}