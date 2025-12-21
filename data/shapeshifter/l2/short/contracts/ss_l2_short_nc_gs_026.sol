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


    bytes32 public constant EXECUTOR_ROLE = ae("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = ae("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = ae("EMERGENCY_ROLE");


    IPool public au;
    IWETH public ax;
    ILiquidityBuffer public o;


    struct Init {
        address at;
        address am;
        ILiquidityBuffer o;
        IWETH ax;
        IPool au;
    }


    event Deposit(address indexed ap, uint ao, uint u);
    event Withdraw(address indexed ap, uint ao);
    event Borrow(address indexed ap, uint ao, uint ah);
    event Repay(address indexed ap, uint ao, uint ah);
    event SetUserEMode(address indexed ap, uint8 ac);

    constructor() {
        h();
    }

    function ab(Init memory av) external w {
        __AccessControlEnumerable_init();

        ax = av.ax;
        au = av.au;
        o = av.o;


        ad(DEFAULT_ADMIN_ROLE, av.at);
        ad(MANAGER_ROLE, av.am);
        ad(EXECUTOR_ROLE, address(av.o));


        ax.an(address(au), type(uint256).ay);
    }


    function ak(uint16 r) external payable override ai(EXECUTOR_ROLE) {
        if (msg.value > 0) {

            ax.ak{value: msg.value}();


            au.ak(address(ax), msg.value, address(this), r);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function aj(uint256 ao) external override ai(EXECUTOR_ROLE) {
        require(ao > 0, 'Invalid ao');


        IERC20 ar = IERC20(au.j(address(ax)));
        uint256 x = ar.ag(address(this));

        uint256 m = ao;
        if (ao == type(uint256).ay) {
            m = x;
        }

        require(m <= x, 'Insufficient balance');


        au.aj(address(ax), m, address(this));


        ax.aj(m);


        o.b{value: m}();

        emit Withdraw(msg.sender, m);
    }

    function f() external view returns (uint256) {
        IERC20 ar = IERC20(au.j(address(ax)));
        return ar.ag(address(this));
    }

    function v(uint8 ac) external override ai(MANAGER_ROLE) {

        au.v(ac);

        emit SetUserEMode(msg.sender, ac);
    }
    function t(address aq, address aw, uint256 az) external override ai(MANAGER_ROLE) {
        IERC20(aq).y(aw, az);
    }

    function aa(address aq, address aw) external override ai(MANAGER_ROLE) {
        IERC20(aq).y(aw, 0);
    }


    function n() external view returns (uint256) {
        address af = au.c(address(ax));
        return IERC20(af).ag(address(this));
    }

    function g() external view returns (uint256) {
        IERC20 ar = IERC20(au.j(address(ax)));
        return ar.ag(address(this));
    }

    function s() external view returns (uint256) {
        return au.s(address(this));
    }

    function a(address as, bool p) external ai(MANAGER_ROLE) {
        au.a(as, p);
    }

    function i(address k) external ai(MANAGER_ROLE) {
        z(EXECUTOR_ROLE, address(o));
        ad(EXECUTOR_ROLE, k);
        o = ILiquidityBuffer(k);
    }


    function d(address aq, address ba, uint256 ao) external ai(EMERGENCY_ROLE) {
        IERC20(aq).q(ba, ao);
    }


    function e(address ba, uint256 ao) external ai(EMERGENCY_ROLE) {
        l(ba, ao);
    }


    function l(address ba, uint256 value) internal {
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