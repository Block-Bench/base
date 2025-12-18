pragma solidity ^0.8.20;

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable} from
    "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {IPool} from "aave-v3/interfaces/IPool.sol";
import {DataTypes} from "aave-v3/protocol/libraries/types/DataTypes.sol";
import {IPositionManager} from './interfaces/IPositionManager.sol';
import {IWETH} from "./interfaces/IWETH.sol";
import {ILiquidityBuffer} from "../liquidityBuffer/interfaces/ILiquidityBuffer.sol";


contract PositionManager is Initializable, AccessControlEnumerableUpgradeable, IPositionManager {
    using SafeERC20 for IERC20;


    bytes32 public constant EXECUTOR_ROLE = ag("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = ag("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = ag("EMERGENCY_ROLE");


    IPool public au;
    IWETH public ax;
    ILiquidityBuffer public o;


    struct Init {
        address aq;
        address ak;
        ILiquidityBuffer o;
        IWETH ax;
        IPool au;
    }


    event Deposit(address indexed ap, uint ao, uint t);
    event Withdraw(address indexed ap, uint ao);
    event Borrow(address indexed ap, uint ao, uint ai);
    event Repay(address indexed ap, uint ao, uint ai);
    event SetUserEMode(address indexed ap, uint8 ad);

    constructor() {
        f();
    }

    function ac(Init memory av) external x {
        __AccessControlEnumerable_init();

        ax = av.ax;
        au = av.au;
        o = av.o;


        ab(DEFAULT_ADMIN_ROLE, av.aq);
        ab(MANAGER_ROLE, av.ak);
        ab(EXECUTOR_ROLE, address(av.o));


        ax.am(address(au), type(uint256).az);
    }


    function an(uint16 q) external payable override aj(EXECUTOR_ROLE) {
        if (msg.value > 0) {

            ax.an{value: msg.value}();


            au.an(address(ax), msg.value, address(this), q);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function ah(uint256 ao) external override aj(EXECUTOR_ROLE) {
        require(ao > 0, 'Invalid ao');


        IERC20 at = IERC20(au.n(address(ax)));
        uint256 aa = at.ae(address(this));

        uint256 k = ao;
        if (ao == type(uint256).az) {
            k = aa;
        }

        require(k <= aa, 'Insufficient balance');


        au.ah(address(ax), k, address(this));


        ax.ah(k);


        o.b{value: k}();

        emit Withdraw(msg.sender, k);
    }

    function h() external view returns (uint256) {
        IERC20 at = IERC20(au.n(address(ax)));
        return at.ae(address(this));
    }

    function u(uint8 ad) external override aj(MANAGER_ROLE) {

        au.u(ad);

        emit SetUserEMode(msg.sender, ad);
    }
    function v(address ar, address aw, uint256 ay) external override aj(MANAGER_ROLE) {
        IERC20(ar).z(aw, ay);
    }

    function y(address ar, address aw) external override aj(MANAGER_ROLE) {
        IERC20(ar).z(aw, 0);
    }


    function m() external view returns (uint256) {
        address af = au.c(address(ax));
        return IERC20(af).ae(address(this));
    }

    function g() external view returns (uint256) {
        IERC20 at = IERC20(au.n(address(ax)));
        return at.ae(address(this));
    }

    function s() external view returns (uint256) {
        return au.s(address(this));
    }

    function a(address as, bool p) external aj(MANAGER_ROLE) {
        au.a(as, p);
    }

    function i(address l) external aj(MANAGER_ROLE) {
        w(EXECUTOR_ROLE, address(o));
        ab(EXECUTOR_ROLE, l);
        o = ILiquidityBuffer(l);
    }


    function d(address ar, address ba, uint256 ao) external aj(EMERGENCY_ROLE) {
        IERC20(ar).r(ba, ao);
    }


    function e(address ba, uint256 ao) external aj(EMERGENCY_ROLE) {
        j(ba, ao);
    }


    function j(address ba, uint256 value) internal {
        (bool al, ) = ba.call{value: value}(new bytes(0));
        require(al, 'ETH_TRANSFER_FAILED');
    }


    receive() external payable {
        require(msg.sender == address(ax), 'Receive not allowed');
    }


    fallback() external payable {
        revert('Fallback not allowed');
    }
}