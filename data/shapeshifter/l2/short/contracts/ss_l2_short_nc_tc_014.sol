pragma solidity ^0.8.0;


interface ICurve3Pool {
    function g(
        uint256[3] memory r,
        uint256 d
    ) external;

    function a(
        uint256[3] memory r,
        uint256 c
    ) external;

    function b() external view returns (uint256);
}

interface IERC20 {
    function transfer(address ad, uint256 w) external returns (bool);

    function j(
        address from,
        address ad,
        uint256 w
    ) external returns (bool);

    function q(address v) external view returns (uint256);

    function u(address t, uint256 w) external returns (bool);
}

contract YieldVault {
    IERC20 public ac;
    IERC20 public ab;
    ICurve3Pool public o;

    mapping(address => uint256) public x;
    uint256 public n;
    uint256 public f;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address aa, address y, address l) {
        ac = IERC20(aa);
        ab = IERC20(y);
        o = ICurve3Pool(l);
    }

    function s(uint256 w) external {
        ac.j(msg.sender, address(this), w);

        uint256 m;
        if (n == 0) {
            m = w;
        } else {
            m = (w * n) / f;
        }

        x[msg.sender] += m;
        n += m;
        f += w;
    }

    function z() external {
        uint256 h = ac.q(address(this));
        require(
            h >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 i = o.b();

        ac.u(address(o), h);
        uint256[3] memory r = [h, 0, 0];
        o.g(r, 0);
    }

    function k() external {
        uint256 p = x[msg.sender];
        require(p > 0, "No shares");

        uint256 e = (p * f) / n;

        x[msg.sender] = 0;
        n -= p;
        f -= e;

        ac.transfer(msg.sender, e);
    }

    function balance() public view returns (uint256) {
        return
            ac.q(address(this)) +
            (ab.q(address(this)) * o.b()) /
            1e18;
    }
}