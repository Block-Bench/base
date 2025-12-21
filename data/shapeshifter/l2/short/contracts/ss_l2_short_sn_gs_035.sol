// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IV2Pool} from "../../external/IV2Pool.sol";
import {IV2Router} from "../../external/IV2Router.sol";
import {IV2LockerFactory} from "../../interfaces/extensions/v2/IV2LockerFactory.sol";
import {IV2Locker} from "../../interfaces/extensions/v2/IV2Locker.sol";
import {ILocker} from "../../interfaces/ILocker.sol";
import {Locker} from "../../Locker.sol";

/// @title V2Locker
/// @author velodrome.finance
/// @notice Manages locking liquidity, staking, and claiming rewards for V2 pools.
contract V2Locker is Locker, IV2Locker {
    using SafeERC20 for IERC20;

    /// @inheritdoc IV2Locker
    address public immutable bm;

    uint256 internal ca;

    constructor(
        bool bu,
        address bp,
        address bx,
        address ax,
        uint256 by,
        uint32 m,
        address p,
        uint16 b,
        uint16 g
    ) Locker(bu, bp, bx, m, p, b, g) {
        bm = ax;
        ca = by;
        (bk, bg) = IV2Pool(bz).bf();
    }

    /// @inheritdoc Locker
    function bn(address ac) external override(Locker, ILocker) ag s returns (uint256) {
        if (msg.sender != be) revert NotFactory();

        delete bh;
        delete w;

        IERC20(bz).n({cb: ac, value: ca});

        /// @dev Refund locked balances
        uint256 as = IERC20(bk).am({az: address(this)});
        if (as > 0) IERC20(bk).n({cb: ac, value: as});
        as = IERC20(bg).am({az: address(this)});
        if (as > 0) IERC20(bg).n({cb: ac, value: as});

        emit Unlocked({al: ac});
        return ca;
    }

    /// @inheritdoc Locker
    function bv() external override(Locker, ILocker) s ap ag v {
        if (bh) revert AlreadyStaked();
        bh = true;

        ab({ac: bw()});

        IERC20(bz).a({bc: address(bs), value: ca});
        bs.bb({cc: ca});
        emit Staked();
    }

    /// @inheritdoc Locker
    function c(uint256 au, uint256 aq, uint256 aa, uint256 u)
        external
        override(ILocker, Locker)
        s
        ap
        ag
        returns (uint256)
    {
        if (au == 0 && aq == 0) revert ZeroAmount();

        uint256 ak = y({bj: bk, ao: au});
        uint256 aj = y({bj: bg, ao: aq});

        IERC20(bk).l({bc: bm, value: au});
        IERC20(bg).l({bc: bm, value: aq});

        (uint256 d, uint256 e, uint256 ah) = IV2Router(bm).o({
            bi: bk,
            br: bg,
            bq: IV2Pool(bz).bq(),
            j: au,
            i: aq,
            ae: aa,
            ad: u,
            cb: address(this),
            av: block.timestamp
        });

        IERC20(bk).l({bc: bm, value: 0});
        IERC20(bg).l({bc: bm, value: 0});

        address al = bw();
        f({bj: bk, ac: al, af: ak});
        f({bj: bg, ac: al, af: aj});

        if (bh) {
            IERC20(bz).a({bc: address(bs), value: ah});
            bs.bb({cc: ah});
        }

        ca += ah;

        emit LiquidityIncreased({bd: d, ay: e, ah: ah});
        return ah;
    }

    function t() internal override returns (uint256 ar, uint256 at) {
        (ar, at) = IV2Pool(bz).ai();

        uint256 bl = r({ba: ar, bj: bk});
        uint256 bo = r({ba: at, bj: bg});
        ar -= bl;
        at -= bo;

        if (bl > 0 || bo > 0) {
            emit FeesClaimed({al: z, ar: bl, at: bo});
        }
    }

    function h() internal override returns (uint256 aw) {
        uint256 k = IERC20(x).am({az: address(this)});
        bs.an({az: address(this)});
        uint256 q = IERC20(x).am({az: address(this)});

        aw = q - k;
        uint256 bt = r({ba: aw, bj: x});
        aw -= bt;

        if (bt > 0) {
            emit RewardsClaimed({al: z, aw: bt});
        }
    }

    function cc() public view override(ILocker, Locker) returns (uint256) {
        return ca;
    }
}