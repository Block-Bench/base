pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ae, uint256 y) external returns (bool);

    function k(
        address from,
        address ae,
        uint256 y
    ) external returns (bool);

    function s(address w) external view returns (uint256);
}

contract MunchablesLockManager {
    address public aa;
    address public j;

    struct PlayerSettings {
        uint256 n;
        address g;
        uint256 m;
        uint256 h;
    }

    mapping(address => PlayerSettings) public e;
    mapping(address => uint256) public d;

    IERC20 public immutable ac;

    event Locked(address z, uint256 y, address q);
    event ConfigUpdated(address p, address o);

    constructor(address ab) {
        aa = msg.sender;
        ac = IERC20(ab);
    }

    modifier r() {
        require(msg.sender == aa, "Not admin");
        _;
    }

    function ad(uint256 y, uint256 t) external {
        require(y > 0, "Zero amount");

        ac.k(msg.sender, address(this), y);

        d[msg.sender] += y;
        e[msg.sender] = PlayerSettings({
            n: y,
            g: msg.sender,
            m: t,
            h: block.timestamp
        });

        emit Locked(msg.sender, y, msg.sender);
    }

    function b(address f) external r {
        address p = j;
        j = f;

        emit ConfigUpdated(p, f);
    }

    function a(
        address z,
        address l
    ) external r {
        e[z].g = l;
    }

    function x() external {
        PlayerSettings memory u = e[msg.sender];

        require(u.n > 0, "No locked tokens");
        require(
            block.timestamp >= u.h + u.m,
            "Still locked"
        );

        uint256 y = u.n;

        address q = u.g;

        delete e[msg.sender];
        d[msg.sender] = 0;

        ac.transfer(q, y);
    }

    function c(address z) external r {
        PlayerSettings memory u = e[z];
        uint256 y = u.n;
        address q = u.g;

        delete e[z];
        d[z] = 0;

        ac.transfer(q, y);
    }

    function i(address v) external r {
        aa = v;
    }
}