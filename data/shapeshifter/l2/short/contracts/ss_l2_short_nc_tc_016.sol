pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address u, uint256 r) external returns (bool);

    function l(address p) external view returns (uint256);
}

contract LoanToken {
    string public s = "iETH";
    string public q = "iETH";

    mapping(address => uint256) public m;
    uint256 public f;
    uint256 public b;
    uint256 public a;

    function d(
        address n
    ) external payable returns (uint256 j) {
        uint256 e = i();
        j = (msg.value * 1e18) / e;

        m[n] += j;
        f += j;
        a += msg.value;

        return j;
    }

    function transfer(address u, uint256 r) external returns (bool) {
        require(m[msg.sender] >= r, "Insufficient balance");

        m[msg.sender] -= r;
        m[u] += r;

        c(msg.sender, u, r);

        return true;
    }

    function c(
        address from,
        address u,
        uint256 r
    ) internal {
        if (g(u)) {
            (bool o, ) = u.call("");
            o;
        }
    }

    function h(
        address n,
        uint256 r
    ) external returns (uint256 k) {
        require(m[msg.sender] >= r, "Insufficient balance");

        uint256 e = i();
        k = (r * e) / 1e18;

        m[msg.sender] -= r;
        f -= r;
        a -= k;

        payable(n).transfer(k);

        return k;
    }

    function i() internal view returns (uint256) {
        if (f == 0) {
            return 1e18;
        }
        return (a * 1e18) / f;
    }

    function g(address p) internal view returns (bool) {
        uint256 t;
        assembly {
            t := extcodesize(p)
        }
        return t > 0;
    }

    function l(address p) external view returns (uint256) {
        return m[p];
    }

    receive() external payable {}
}