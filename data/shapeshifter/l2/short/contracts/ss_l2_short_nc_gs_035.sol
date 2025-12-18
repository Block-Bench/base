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


    address public immutable bo;

    uint256 internal ca;

    constructor(
        bool bu,
        address bg,
        address bt,
        address bb,
        uint256 bz,
        uint32 t,
        address l,
        uint16 c,
        uint16 f
    ) Locker(bu, bg, bt, t, l, c, f) {
        bo = bb;
        ca = bz;
        (bk, br) = IV2Pool(by).bq();
    }


    function bn(address ab) external override(Locker, ILocker) ac n returns (uint256) {
        if (msg.sender != bd) revert NotFactory();

        delete bi;
        delete z;

        IERC20(by).p({cb: ab, value: ca});


        uint256 ar = IERC20(bk).ap({be: address(this)});
        if (ar > 0) IERC20(bk).p({cb: ab, value: ar});
        ar = IERC20(br).ap({be: address(this)});
        if (ar > 0) IERC20(br).p({cb: ab, value: ar});

        emit Unlocked({ak: ab});
        return ca;
    }


    function bx() external override(Locker, ILocker) n al ac aa {
        if (bi) revert AlreadyStaked();
        bi = true;

        ae({ab: bw()});

        IERC20(by).a({az: address(bv), value: ca});
        bv.ax({cc: ca});
        emit Staked();
    }


    function b(uint256 at, uint256 as, uint256 y, uint256 w)
        external
        override(ILocker, Locker)
        n
        al
        ac
        returns (uint256)
    {
        if (at == 0 && as == 0) revert ZeroAmount();

        uint256 ao = v({bj: bk, am: at});
        uint256 aj = v({bj: br, am: as});

        IERC20(bk).r({az: bo, value: at});
        IERC20(br).r({az: bo, value: as});

        (uint256 d, uint256 e, uint256 an) = IV2Router(bo).m({
            bl: bk,
            bh: br,
            bf: IV2Pool(by).bf(),
            j: at,
            i: as,
            ag: y,
            ad: w,
            cb: address(this),
            aq: block.timestamp
        });

        IERC20(bk).r({az: bo, value: 0});
        IERC20(br).r({az: bo, value: 0});

        address ak = bw();
        g({bj: bk, ab: ak, af: ao});
        g({bj: br, ab: ak, af: aj});

        if (bi) {
            IERC20(by).a({az: address(bv), value: an});
            bv.ax({cc: an});
        }

        ca += an;

        emit LiquidityIncreased({ay: d, aw: e, an: an});
        return an;
    }

    function s() internal override returns (uint256 au, uint256 av) {
        (au, av) = IV2Pool(by).ai();

        uint256 bp = o({ba: au, bj: bk});
        uint256 bm = o({ba: av, bj: br});
        au -= bp;
        av -= bm;

        if (bp > 0 || bm > 0) {
            emit FeesClaimed({ak: x, au: bp, av: bm});
        }
    }

    function h() internal override returns (uint256 bc) {
        uint256 k = IERC20(u).ap({be: address(this)});
        bv.ah({be: address(this)});
        uint256 q = IERC20(u).ap({be: address(this)});

        bc = q - k;
        uint256 bs = o({ba: bc, bj: u});
        bc -= bs;

        if (bs > 0) {
            emit RewardsClaimed({ak: x, bc: bs});
        }
    }

    function cc() public view override(ILocker, Locker) returns (uint256) {
        return ca;
    }
}