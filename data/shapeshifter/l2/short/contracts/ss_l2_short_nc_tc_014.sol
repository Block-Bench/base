pragma solidity ^0.8.0;


interface ICurve3Pool {
    function g(
        uint256[3] memory s,
        uint256 d
    ) external;

    function a(
        uint256[3] memory s,
        uint256 c
    ) external;

    function b() external view returns (uint256);
}

interface IERC20 {
    function transfer(address ad, uint256 w) external returns (bool);

    function h(
        address from,
        address ad,
        uint256 w
    ) external returns (bool);

    function q(address u) external view returns (uint256);

    function t(address r, uint256 w) external returns (bool);
}

contract YieldVault {
    IERC20 public ac;
    IERC20 public aa;
    ICurve3Pool public p;

    mapping(address => uint256) public x;
    uint256 public k;
    uint256 public f;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address ab, address y, address l) {
        ac = IERC20(ab);
        aa = IERC20(y);
        p = ICurve3Pool(l);
    }

    function v(uint256 w) external {
        ac.h(msg.sender, address(this), w);

        uint256 m;
        if (k == 0) {
            m = w;
        } else {
            m = (w * k) / f;
        }

        x[msg.sender] += m;
        k += m;
        f += w;
    }

    function z() external {
        uint256 j = ac.q(address(this));
        require(
            j >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 i = p.b();

        ac.t(address(p), j);
        uint256[3] memory s = [j, 0, 0];
        p.g(s, 0);
    }

    function n() external {
        uint256 o = x[msg.sender];
        require(o > 0, "No shares");

        uint256 e = (o * f) / k;

        x[msg.sender] = 0;
        k -= o;
        f -= e;

        ac.transfer(msg.sender, e);
    }

    function balance() public view returns (uint256) {
        return
            ac.q(address(this)) +
            (aa.q(address(this)) * p.b()) /
            1e18;
    }
}