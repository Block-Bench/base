// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address aj, uint256 ac) external returns (bool);

    function j(
        address from,
        address aj,
        uint256 ac
    ) external returns (bool);

    function p(address y) external view returns (uint256);

    function w(address u, uint256 ac) external returns (bool);
}

interface IFlashLoanReceiver {
    function c(
        address[] calldata aa,
        uint256[] calldata x,
        uint256[] calldata t,
        address q,
        bytes calldata ab
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 f;
        uint256 e;
        address g;
    }

    mapping(address => ReserveData) public s;

    function v(
        address ag,
        uint256 ac,
        address n,
        uint16 i
    ) external {
        IERC20(ag).j(msg.sender, address(this), ac);

        ReserveData storage z = s[ag];

        uint256 a = z.f;
        if (a == 0) {
            a = RAY;
        }

        z.f =
            a +
            (ac * RAY) /
            (z.e + 1);
        z.e += ac;

        uint256 k = af(ac, z.f);
        m(z.g, n, k);
    }

    function r(
        address ag,
        uint256 ac,
        address aj
    ) external returns (uint256) {
        ReserveData storage z = s[ag];

        uint256 h = af(ac, z.f);

        l(z.g, msg.sender, h);

        z.e -= ac;
        IERC20(ag).transfer(aj, ac);

        return ac;
    }

    function ae(
        address ag,
        uint256 ac,
        uint256 b,
        uint16 i,
        address n
    ) external {
        IERC20(ag).transfer(n, ac);
    }

    function o(
        address d,
        address[] calldata aa,
        uint256[] calldata x,
        uint256[] calldata ai,
        address n,
        bytes calldata ab,
        uint16 i
    ) external {
        for (uint256 i = 0; i < aa.length; i++) {
            IERC20(aa[i]).transfer(d, x[i]);
        }

        require(
            IFlashLoanReceiver(d).c(
                aa,
                x,
                new uint256[](aa.length),
                msg.sender,
                ab
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < aa.length; i++) {
            IERC20(aa[i]).j(
                d,
                address(this),
                x[i]
            );
        }
    }

    function af(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 ah = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + ah) / b;
    }

    function m(address ad, address aj, uint256 ac) internal {}

    function l(
        address ad,
        address from,
        uint256 ac
    ) internal {}
}
