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


    bytes32 public constant EXECUTOR_ROLE = _0x997e63("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = _0x997e63("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = _0x997e63("EMERGENCY_ROLE");


    IPool public _0x32e764;
    IWETH public _0x56b918;
    ILiquidityBuffer public _0x43ce63;


    struct Init {
        address _0x312fb0;
        address _0xa79432;
        ILiquidityBuffer _0x43ce63;
        IWETH _0x56b918;
        IPool _0x32e764;
    }


    event Deposit(address indexed _0x3f0da2, uint _0x9bca36, uint _0xeb56af);
    event Withdraw(address indexed _0x3f0da2, uint _0x9bca36);
    event Borrow(address indexed _0x3f0da2, uint _0x9bca36, uint _0xbd85c6);
    event Repay(address indexed _0x3f0da2, uint _0x9bca36, uint _0xbd85c6);
    event SetUserEMode(address indexed _0x3f0da2, uint8 _0x1f1f0e);

    constructor() {
        _0x54f301();
    }

    function _0x378f3d(Init memory _0x2e6a07) external _0x918c9b {
        __AccessControlEnumerable_init();

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x56b918 = _0x2e6a07._0x56b918; }
        _0x32e764 = _0x2e6a07._0x32e764;
        _0x43ce63 = _0x2e6a07._0x43ce63;


        _0xb508a8(DEFAULT_ADMIN_ROLE, _0x2e6a07._0x312fb0);
        _0xb508a8(MANAGER_ROLE, _0x2e6a07._0xa79432);
        _0xb508a8(EXECUTOR_ROLE, address(_0x2e6a07._0x43ce63));


        _0x56b918._0x8395a7(address(_0x32e764), type(uint256)._0x9fbce1);
    }


    function _0xe7f4ad(uint16 _0xaafe11) external payable override _0xdcd4ec(EXECUTOR_ROLE) {
        if (msg.value > 0) {

            _0x56b918._0xe7f4ad{value: msg.value}();


            _0x32e764._0xe7f4ad(address(_0x56b918), msg.value, address(this), _0xaafe11);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function _0x602abf(uint256 _0x9bca36) external override _0xdcd4ec(EXECUTOR_ROLE) {
        require(_0x9bca36 > 0, 'Invalid _0x9bca36');


        IERC20 _0xd6cc08 = IERC20(_0x32e764._0xd3ff6b(address(_0x56b918)));
        uint256 _0xf42057 = _0xd6cc08._0x2dd9de(address(this));

        uint256 _0x1017fa = _0x9bca36;
        if (_0x9bca36 == type(uint256)._0x9fbce1) {
            _0x1017fa = _0xf42057;
        }

        require(_0x1017fa <= _0xf42057, 'Insufficient balance');


        _0x32e764._0x602abf(address(_0x56b918), _0x1017fa, address(this));


        _0x56b918._0x602abf(_0x1017fa);


        _0x43ce63._0x7152f6{value: _0x1017fa}();

        emit Withdraw(msg.sender, _0x1017fa);
    }

    function _0x466b45() external view returns (uint256) {
        IERC20 _0xd6cc08 = IERC20(_0x32e764._0xd3ff6b(address(_0x56b918)));
        return _0xd6cc08._0x2dd9de(address(this));
    }

    function _0xf206c6(uint8 _0x1f1f0e) external override _0xdcd4ec(MANAGER_ROLE) {

        _0x32e764._0xf206c6(_0x1f1f0e);

        emit SetUserEMode(msg.sender, _0x1f1f0e);
    }
    function _0x6779dc(address _0x41c144, address _0x1f3c00, uint256 _0x755ed2) external override _0xdcd4ec(MANAGER_ROLE) {
        IERC20(_0x41c144)._0xe98044(_0x1f3c00, _0x755ed2);
    }

    function _0x8e6c91(address _0x41c144, address _0x1f3c00) external override _0xdcd4ec(MANAGER_ROLE) {
        IERC20(_0x41c144)._0xe98044(_0x1f3c00, 0);
    }


    function _0x724631() external view returns (uint256) {
        address _0xad703d = _0x32e764._0xe8f9c7(address(_0x56b918));
        return IERC20(_0xad703d)._0x2dd9de(address(this));
    }

    function _0xaefa4e() external view returns (uint256) {
        IERC20 _0xd6cc08 = IERC20(_0x32e764._0xd3ff6b(address(_0x56b918)));
        return _0xd6cc08._0x2dd9de(address(this));
    }

    function _0xcf6ac4() external view returns (uint256) {
        return _0x32e764._0xcf6ac4(address(this));
    }

    function _0x67f60c(address _0x694f8a, bool _0x7ada4e) external _0xdcd4ec(MANAGER_ROLE) {
        _0x32e764._0x67f60c(_0x694f8a, _0x7ada4e);
    }

    function _0x51faf6(address _0xb82b7a) external _0xdcd4ec(MANAGER_ROLE) {
        _0xe61c17(EXECUTOR_ROLE, address(_0x43ce63));
        _0xb508a8(EXECUTOR_ROLE, _0xb82b7a);
        _0x43ce63 = ILiquidityBuffer(_0xb82b7a);
    }


    function _0xa2f21a(address _0x41c144, address _0xda379f, uint256 _0x9bca36) external _0xdcd4ec(EMERGENCY_ROLE) {
        IERC20(_0x41c144)._0xd00897(_0xda379f, _0x9bca36);
    }


    function _0x5f4883(address _0xda379f, uint256 _0x9bca36) external _0xdcd4ec(EMERGENCY_ROLE) {
        _0xbcf99e(_0xda379f, _0x9bca36);
    }


    function _0xbcf99e(address _0xda379f, uint256 value) internal {
        (bool _0xc40b29, ) = _0xda379f.call{value: value}(new bytes(0));
        require(_0xc40b29, 'ETH_TRANSFER_FAILED');
    }


    receive() external payable {
        require(msg.sender == address(_0x56b918), 'Receive not allowed');
    }


    fallback() external payable {
        revert('Fallback not allowed');
    }
}