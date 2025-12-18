pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address x, uint256 r) external returns (bool);

    function j(address p) external view returns (uint256);
}

interface IJar {
    function s() external view returns (address);

    function k(uint256 r) external;
}

interface IStrategy {
    function d() external;

    function k(address s) external;
}

contract VaultController {
    address public i;
    mapping(address => address) public g;

    constructor() {
        i = msg.sender;
    }

    function a(
        address l,
        address q,
        uint256 c,
        uint256 b,
        address[] calldata n,
        bytes[] calldata t
    ) external {
        require(n.length == t.length, "Length mismatch");

        for (uint256 i = 0; i < n.length; i++) {
            (bool o, ) = n[i].call(t[i]);
            require(o, "Call failed");
        }
    }

    function e(address w, address m) external {
        require(msg.sender == i, "Not governance");
        g[w] = m;
    }
}

contract Strategy {
    address public h;
    address public v;

    constructor(address f, address u) {
        h = f;
        v = u;
    }

    function d() external {
        uint256 balance = IERC20(v).j(address(this));
        IERC20(v).transfer(h, balance);
    }

    function k(address s) external {
        uint256 balance = IERC20(s).j(address(this));
        IERC20(s).transfer(h, balance);
    }
}