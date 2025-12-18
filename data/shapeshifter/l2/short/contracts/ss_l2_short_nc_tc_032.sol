pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address aj, uint256 ac) external returns (bool);

    function k(
        address from,
        address aj,
        uint256 ac
    ) external returns (bool);

    function o(address y) external view returns (uint256);

    function x(address u, uint256 ac) external returns (bool);
}

interface IFlashLoanReceiver {
    function b(
        address[] calldata aa,
        uint256[] calldata v,
        uint256[] calldata s,
        address q,
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

    mapping(address => ReserveData) public t;

    function z(
        address ag,
        uint256 ac,
        address n,
        uint16 i
    ) external {
        IERC20(ag).k(msg.sender, address(this), ac);

        ReserveData storage w = t[ag];

        uint256 a = w.e;
        if (a == 0) {
            a = RAY;
        }

        w.e =
            a +
            (ac * RAY) /
            (w.f + 1);
        w.f += ac;

        uint256 j = af(ac, w.e);
        l(w.h, n, j);
    }

    function r(
        address ag,
        uint256 ac,
        address aj
    ) external returns (uint256) {
        ReserveData storage w = t[ag];

        uint256 g = af(ac, w.e);

        m(w.h, msg.sender, g);

        w.f -= ac;
        IERC20(ag).transfer(aj, ac);

        return ac;
    }

    function ad(
        address ag,
        uint256 ac,
        uint256 c,
        uint16 i,
        address n
    ) external {
        IERC20(ag).transfer(n, ac);
    }

    function p(
        address d,
        address[] calldata aa,
        uint256[] calldata v,
        uint256[] calldata ah,
        address n,
        bytes calldata ae,
        uint16 i
    ) external {
        for (uint256 i = 0; i < aa.length; i++) {
            IERC20(aa[i]).transfer(d, v[i]);
        }

        require(
            IFlashLoanReceiver(d).b(
                aa,
                v,
                new uint256[](aa.length),
                msg.sender,
                ae
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < aa.length; i++) {
            IERC20(aa[i]).k(
                d,
                address(this),
                v[i]
            );
        }
    }

    function af(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 ai = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + ai) / b;
    }

    function l(address ab, address aj, uint256 ac) internal {}

    function m(
        address ab,
        address from,
        uint256 ac
    ) internal {}
}