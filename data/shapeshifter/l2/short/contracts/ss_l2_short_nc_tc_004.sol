pragma solidity ^0.8.0;


interface ICurvePool {
    function b(
        int128 i,
        int128 j,
        uint256 w,
        uint256 r
    ) external returns (uint256);

    function d(
        int128 i,
        int128 j,
        uint256 w
    ) external view returns (uint256);
}

contract YieldVault {
    address public e;
    ICurvePool public n;

    uint256 public k;
    mapping(address => uint256) public o;


    uint256 public f;

    event Deposit(address indexed v, uint256 s, uint256 t);
    event Withdrawal(address indexed v, uint256 t, uint256 s);

    constructor(address u, address m) {
        e = u;
        n = ICurvePool(m);
    }


    function q(uint256 s) external returns (uint256 t) {
        require(s > 0, "Zero amount");


        if (k == 0) {
            t = s;
        } else {
            uint256 l = g();
            t = (s * k) / l;
        }

        o[msg.sender] += t;
        k += t;


        h(s);

        emit Deposit(msg.sender, s, t);
        return t;
    }


    function p(uint256 t) external returns (uint256 s) {
        require(t > 0, "Zero shares");
        require(o[msg.sender] >= t, "Insufficient balance");


        uint256 l = g();
        s = (t * l) / k;

        o[msg.sender] -= t;
        k -= t;


        c(s);

        emit Withdrawal(msg.sender, t, s);
        return s;
    }


    function g() public view returns (uint256) {
        uint256 i = 0;
        uint256 j = f;

        return i + j;
    }


    function a() public view returns (uint256) {
        if (k == 0) return 1e18;
        return (g() * 1e18) / k;
    }


    function h(uint256 s) internal {
        f += s;
    }


    function c(uint256 s) internal {
        require(f >= s, "Insufficient invested");
        f -= s;
    }
}