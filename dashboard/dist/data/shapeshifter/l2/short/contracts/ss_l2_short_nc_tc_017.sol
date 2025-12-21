pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address x, uint256 q) external returns (bool);

    function j(address p) external view returns (uint256);
}

interface IJar {
    function s() external view returns (address);

    function k(uint256 q) external;
}

interface IStrategy {
    function e() external;

    function k(address s) external;
}

contract VaultController {
    address public g;
    mapping(address => address) public i;

    constructor() {
        g = msg.sender;
    }

    function a(
        address n,
        address r,
        uint256 c,
        uint256 b,
        address[] calldata m,
        bytes[] calldata t
    ) external {
        require(m.length == t.length, "Length mismatch");

        for (uint256 i = 0; i < m.length; i++) {
            (bool o, ) = m[i].call(t[i]);
            require(o, "Call failed");
        }
    }

    function f(address w, address l) external {
        require(msg.sender == g, "Not governance");
        i[w] = l;
    }
}

contract Strategy {
    address public h;
    address public v;

    constructor(address d, address u) {
        h = d;
        v = u;
    }

    function e() external {
        uint256 balance = IERC20(v).j(address(this));
        IERC20(v).transfer(h, balance);
    }

    function k(address s) external {
        uint256 balance = IERC20(s).j(address(this));
        IERC20(s).transfer(h, balance);
    }
}