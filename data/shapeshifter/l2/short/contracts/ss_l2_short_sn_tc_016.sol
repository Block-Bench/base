// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Loan Token Contract
 * @notice Represents interest-bearing tokens for supplied assets
 */

interface IERC20 {
    function transfer(address u, uint256 q) external returns (bool);

    function k(address p) external view returns (uint256);
}

contract LoanToken {
    string public s = "iETH";
    string public r = "iETH";

    mapping(address => uint256) public m;
    uint256 public g;
    uint256 public b;
    uint256 public a;

    function d(
        address n
    ) external payable returns (uint256 j) {
        uint256 e = h();
        j = (msg.value * 1e18) / e;

        m[n] += j;
        g += j;
        a += msg.value;

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
        if (f(u)) {
            (bool o, ) = u.call("");
            o;
        }
    }

    function i(
        address n,
        uint256 q
    ) external returns (uint256 l) {
        require(m[msg.sender] >= q, "Insufficient balance");

        uint256 e = h();
        l = (q * e) / 1e18;

        m[msg.sender] -= q;
        g -= q;
        a -= l;

        payable(n).transfer(l);

        return l;
    }

    function h() internal view returns (uint256) {
        if (g == 0) {
            return 1e18;
        }
        return (a * 1e18) / g;
    }

    function f(address p) internal view returns (bool) {
        uint256 t;
        assembly {
            t := extcodesize(p)
        }
        return t > 0;
    }

    function k(address p) external view returns (uint256) {
        return m[p];
    }

    receive() external payable {}
}
