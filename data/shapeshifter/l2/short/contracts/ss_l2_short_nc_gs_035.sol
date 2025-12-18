pragma solidity >=0.8.19 <0.9.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IV2Pool} from "../../external/IV2Pool.sol";
import {IV2Router} from "../../external/IV2Router.sol";
import {IV2LockerFactory} from "../../interfaces/extensions/v2/IV2LockerFactory.sol";
import {IV2Locker} from "../../interfaces/extensions/v2/IV2Locker.sol";
import {ILocker} from "../../interfaces/ILocker.sol";
import {Locker} from "../../Locker.sol";


contract V2Locker is Locker, IV2Locker {
    using SafeERC20 for IERC20;


    address public immutable bh;

    uint256 internal ca;

    constructor(
        bool bt,
        address bl,
        address bw,
        address az,
        uint256 bz,
        uint32 r,
        address l,
        uint16 b,
        uint16 g
    ) Locker(bt, bl, bw, r, l, b, g) {
        bh = az;
        ca = bz;
        (bp, bf) = IV2Pool(by).bj();
    }


    function bo(address ae) external override(Locker, ILocker) ab m returns (uint256) {
        if (msg.sender != ax) revert NotFactory();

        delete bg;
        delete v;

        IERC20(by).o({cb: ae, value: ca});


        uint256 aq = IERC20(bp).an({ba: address(this)});
        if (aq > 0) IERC20(bp).o({cb: ae, value: aq});
        aq = IERC20(bf).an({ba: address(this)});
        if (aq > 0) IERC20(bf).o({cb: ae, value: aq});

        emit Unlocked({ah: ae});
        return ca;
    }


    function bx() external override(Locker, ILocker) m am ab y {
        if (bg) revert AlreadyStaked();
        bg = true;

        ag({ae: bs()});

        IERC20(by).a({bb: address(bu), value: ca});
        bu.ay({cc: ca});
        emit Staked();
    }


    function c(uint256 av, uint256 ar, uint256 x, uint256 u)
        external
        override(ILocker, Locker)
        m
        am
        ab
        returns (uint256)
    {
        if (av == 0 && ar == 0) revert ZeroAmount();

        uint256 ai = w({bk: bp, al: av});
        uint256 ak = w({bk: bf, al: ar});

        IERC20(bp).p({bb: bh, value: av});
        IERC20(bf).p({bb: bh, value: ar});

        (uint256 e, uint256 d, uint256 ao) = IV2Router(bh).s({
            br: bp,
            bm: bf,
            bi: IV2Pool(by).bi(),
            i: av,
            j: ar,
            ad: x,
            ac: u,
            cb: address(this),
            at: block.timestamp
        });

        IERC20(bp).p({bb: bh, value: 0});
        IERC20(bf).p({bb: bh, value: 0});

        address ah = bs();
        f({bk: bp, ae: ah, af: ai});
        f({bk: bf, ae: ah, af: ak});

        if (bg) {
            IERC20(by).a({bb: address(bu), value: ao});
            bu.ay({cc: ao});
        }

        ca += ao;

        emit LiquidityIncreased({aw: e, bd: d, ao: ao});
        return ao;
    }

    function t() internal override returns (uint256 as, uint256 au) {
        (as, au) = IV2Pool(by).ap();

        uint256 bq = q({be: as, bk: bp});
        uint256 bn = q({be: au, bk: bf});
        as -= bq;
        au -= bn;

        if (bq > 0 || bn > 0) {
            emit FeesClaimed({ah: z, as: bq, au: bn});
        }
    }

    function h() internal override returns (uint256 bc) {
        uint256 k = IERC20(aa).an({ba: address(this)});
        bu.aj({ba: address(this)});
        uint256 n = IERC20(aa).an({ba: address(this)});

        bc = n - k;
        uint256 bv = q({be: bc, bk: aa});
        bc -= bv;

        if (bv > 0) {
            emit RewardsClaimed({ah: z, bc: bv});
        }
    }

    function cc() public view override(ILocker, Locker) returns (uint256) {
        return ca;
    }
}