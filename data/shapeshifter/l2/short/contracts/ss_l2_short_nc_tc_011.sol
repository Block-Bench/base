pragma solidity ^0.8.0;


interface IERC777 {
    function transfer(address s, uint256 m) external returns (bool);

    function i(address l) external view returns (uint256);
}

interface IERC1820Registry {
    function a(
        address l,
        bytes32 d,
        address f
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public k;
    mapping(address => uint256) public e;

    function n(address p, uint256 m) external returns (uint256) {
        IERC777 o = IERC777(p);

        require(o.transfer(address(this), m), "Transfer failed");

        k[msg.sender][p] += m;
        e[p] += m;

        return m;
    }

    function j(
        address p,
        uint256 b
    ) external returns (uint256) {
        uint256 h = k[msg.sender][p];
        require(h > 0, "No balance");

        uint256 c = b;
        if (b == type(uint256).r) {
            c = h;
        }
        require(c <= h, "Insufficient balance");

        IERC777(p).transfer(msg.sender, c);

        k[msg.sender][p] -= c;
        e[p] -= c;

        return c;
    }

    function g(
        address q,
        address p
    ) external view returns (uint256) {
        return k[q][p];
    }
}