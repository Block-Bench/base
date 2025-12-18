pragma solidity ^0.8.0;


interface ICurvePool {
    function b(
        int128 i,
        int128 j,
        uint256 w,
        uint256 s
    ) external returns (uint256);

    function d(
        int128 i,
        int128 j,
        uint256 w
    ) external view returns (uint256);
}

contract YieldVault {
    address public f;
    ICurvePool public o;

    uint256 public k;
    mapping(address => uint256) public n;


    uint256 public e;

    event Deposit(address indexed v, uint256 r, uint256 t);
    event Withdrawal(address indexed v, uint256 t, uint256 r);

    constructor(address u, address m) {
        f = u;
        o = ICurvePool(m);
    }


    function q(uint256 r) external returns (uint256 t) {
        require(r > 0, "Zero amount");


        if (k == 0) {
            t = r;
        } else {
            uint256 l = h();
            t = (r * k) / l;
        }

        n[msg.sender] += t;
        k += t;


        g(r);

        emit Deposit(msg.sender, r, t);
        return t;
    }


    function p(uint256 t) external returns (uint256 r) {
        require(t > 0, "Zero shares");
        require(n[msg.sender] >= t, "Insufficient balance");


        uint256 l = h();
        r = (t * l) / k;

        n[msg.sender] -= t;
        k -= t;


        c(r);

        emit Withdrawal(msg.sender, t, r);
        return r;
    }


    function h() public view returns (uint256) {
        uint256 j = 0;
        uint256 i = e;

        return j + i;
    }


    function a() public view returns (uint256) {
        if (k == 0) return 1e18;
        return (h() * 1e18) / k;
    }


    function g(uint256 r) internal {
        e += r;
    }


    function c(uint256 r) internal {
        require(e >= r, "Insufficient invested");
        e -= r;
    }
}