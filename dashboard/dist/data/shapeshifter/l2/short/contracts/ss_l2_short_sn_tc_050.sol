// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ae, uint256 x) external returns (bool);

    function n(
        address from,
        address ae,
        uint256 x
    ) external returns (bool);

    function q(address w) external view returns (uint256);
}

contract MunchablesLockManager {
    address public ab;
    address public j;

    struct PlayerSettings {
        uint256 k;
        address i;
        uint256 m;
        uint256 g;
    }

    mapping(address => PlayerSettings) public f;
    mapping(address => uint256) public d;

    IERC20 public immutable ac;

    event Locked(address y, uint256 x, address s);
    event ConfigUpdated(address o, address r);

    constructor(address aa) {
        ab = msg.sender;
        ac = IERC20(aa);
    }

    modifier p() {
        require(msg.sender == ab, "Not admin");
        _;
    }

    function ad(uint256 x, uint256 v) external {
        require(x > 0, "Zero amount");

        ac.n(msg.sender, address(this), x);

        d[msg.sender] += x;
        f[msg.sender] = PlayerSettings({
            k: x,
            i: msg.sender,
            m: v,
            g: block.timestamp
        });

        emit Locked(msg.sender, x, msg.sender);
    }

    function b(address e) external p {
        address o = j;
        j = e;

        emit ConfigUpdated(o, e);
    }

    function a(
        address y,
        address l
    ) external p {
        f[y].i = l;
    }

    function z() external {
        PlayerSettings memory u = f[msg.sender];

        require(u.k > 0, "No locked tokens");
        require(
            block.timestamp >= u.g + u.m,
            "Still locked"
        );

        uint256 x = u.k;

        address s = u.i;

        delete f[msg.sender];
        d[msg.sender] = 0;

        ac.transfer(s, x);
    }

    function c(address y) external p {
        PlayerSettings memory u = f[y];
        uint256 x = u.k;
        address s = u.i;

        delete f[y];
        d[y] = 0;

        ac.transfer(s, x);
    }

    function h(address t) external p {
        ab = t;
    }
}
