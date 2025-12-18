pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address aj, uint256 ac) external returns (bool);

    function j(
        address from,
        address aj,
        uint256 ac
    ) external returns (bool);

    function q(address z) external view returns (uint256);

    function y(address x, uint256 ac) external returns (bool);
}

interface IFlashLoanReceiver {
    function b(
        address[] calldata ad,
        uint256[] calldata u,
        uint256[] calldata t,
        address o,
        bytes calldata ae
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 e;
        uint256 f;
        address h;
    }

    mapping(address => ReserveData) public s;

    function v(
        address ai,
        uint256 ac,
        address n,
        uint16 i
    ) external {
        IERC20(ai).j(msg.sender, address(this), ac);

        ReserveData storage w = s[ai];

        uint256 a = w.e;
        if (a == 0) {
            a = RAY;
        }

        w.e =
            a +
            (ac * RAY) /
            (w.f + 1);
        w.f += ac;

        uint256 k = af(ac, w.e);
        l(w.h, n, k);
    }

    function r(
        address ai,
        uint256 ac,
        address aj
    ) external returns (uint256) {
        ReserveData storage w = s[ai];

        uint256 g = af(ac, w.e);

        m(w.h, msg.sender, g);

        w.f -= ac;
        IERC20(ai).transfer(aj, ac);

        return ac;
    }

    function aa(
        address ai,
        uint256 ac,
        uint256 c,
        uint16 i,
        address n
    ) external {
        IERC20(ai).transfer(n, ac);
    }

    function p(
        address d,
        address[] calldata ad,
        uint256[] calldata u,
        uint256[] calldata ag,
        address n,
        bytes calldata ae,
        uint16 i
    ) external {
        for (uint256 i = 0; i < ad.length; i++) {
            IERC20(ad[i]).transfer(d, u[i]);
        }

        require(
            IFlashLoanReceiver(d).b(
                ad,
                u,
                new uint256[](ad.length),
                msg.sender,
                ae
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < ad.length; i++) {
            IERC20(ad[i]).j(
                d,
                address(this),
                u[i]
            );
        }
    }

    function af(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 ah = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + ah) / b;
    }

    function l(address ab, address aj, uint256 ac) internal {}

    function m(
        address ab,
        address from,
        uint256 ac
    ) internal {}
}