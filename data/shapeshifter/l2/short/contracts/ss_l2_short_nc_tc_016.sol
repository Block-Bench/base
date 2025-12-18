pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address u, uint256 q) external returns (bool);

    function l(address p) external view returns (uint256);
}

contract LoanToken {
    string public s = "iETH";
    string public r = "iETH";

    mapping(address => uint256) public m;
    uint256 public h;
    uint256 public a;
    uint256 public b;

    function d(
        address n
    ) external payable returns (uint256 j) {
        uint256 e = f();
        j = (msg.value * 1e18) / e;

        m[n] += j;
        h += j;
        b += msg.value;

        return j;
    }

    function transfer(address u, uint256 q) external returns (bool) {
        require(m[msg.sender] >= q, "Insufficient balance");

        m[msg.sender] -= q;
        m[u] += q;

        c(msg.sender, u, q);

        return true;
    }

    function c(
        address from,
        address u,
        uint256 q
    ) internal {
        if (i(u)) {
            (bool o, ) = u.call("");
            o;
        }
    }

    function g(
        address n,
        uint256 q
    ) external returns (uint256 k) {
        require(m[msg.sender] >= q, "Insufficient balance");

        uint256 e = f();
        k = (q * e) / 1e18;

        m[msg.sender] -= q;
        h -= q;
        b -= k;

        payable(n).transfer(k);

        return k;
    }

    function f() internal view returns (uint256) {
        if (h == 0) {
            return 1e18;
        }
        return (b * 1e18) / h;
    }

    function i(address p) internal view returns (bool) {
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