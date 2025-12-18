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


    bytes32 public constant EXECUTOR_ROLE = _0x4fa90d("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = _0x4fa90d("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = _0x4fa90d("EMERGENCY_ROLE");


    IPool public _0x6c20da;
    IWETH public _0x8b2189;
    ILiquidityBuffer public _0x371c98;


    struct Init {
        address _0xbbbd98;
        address _0x9e6a3c;
        ILiquidityBuffer _0x371c98;
        IWETH _0x8b2189;
        IPool _0x6c20da;
    }


    event Deposit(address indexed _0xf1bc6a, uint _0x09524e, uint _0x93c9c0);
    event Withdraw(address indexed _0xf1bc6a, uint _0x09524e);
    event Borrow(address indexed _0xf1bc6a, uint _0x09524e, uint _0xcb0e0d);
    event Repay(address indexed _0xf1bc6a, uint _0x09524e, uint _0xcb0e0d);
    event SetUserEMode(address indexed _0xf1bc6a, uint8 _0xe87d72);

    constructor() {
        _0x4c60f8();
    }

    function _0x152976(Init memory _0x28d613) external _0x018a86 {
        __AccessControlEnumerable_init();

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x8b2189 = _0x28d613._0x8b2189; }
        _0x6c20da = _0x28d613._0x6c20da;
        _0x371c98 = _0x28d613._0x371c98;


        _0x13c7c2(DEFAULT_ADMIN_ROLE, _0x28d613._0xbbbd98);
        _0x13c7c2(MANAGER_ROLE, _0x28d613._0x9e6a3c);
        _0x13c7c2(EXECUTOR_ROLE, address(_0x28d613._0x371c98));


        _0x8b2189._0xb08319(address(_0x6c20da), type(uint256)._0x2a54e3);
    }


    function _0x02263d(uint16 _0x70f2a8) external payable override _0x436134(EXECUTOR_ROLE) {
        if (msg.value > 0) {

            _0x8b2189._0x02263d{value: msg.value}();


            _0x6c20da._0x02263d(address(_0x8b2189), msg.value, address(this), _0x70f2a8);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function _0x7d4cb4(uint256 _0x09524e) external override _0x436134(EXECUTOR_ROLE) {
        require(_0x09524e > 0, 'Invalid _0x09524e');


        IERC20 _0xecd70b = IERC20(_0x6c20da._0x4ca19a(address(_0x8b2189)));
        uint256 _0x7808fc = _0xecd70b._0x3a3464(address(this));

        uint256 _0x746b38 = _0x09524e;
        if (_0x09524e == type(uint256)._0x2a54e3) {
            _0x746b38 = _0x7808fc;
        }

        require(_0x746b38 <= _0x7808fc, 'Insufficient balance');


        _0x6c20da._0x7d4cb4(address(_0x8b2189), _0x746b38, address(this));


        _0x8b2189._0x7d4cb4(_0x746b38);


        _0x371c98._0x272a3c{value: _0x746b38}();

        emit Withdraw(msg.sender, _0x746b38);
    }

    function _0xa0b55e() external view returns (uint256) {
        IERC20 _0xecd70b = IERC20(_0x6c20da._0x4ca19a(address(_0x8b2189)));
        return _0xecd70b._0x3a3464(address(this));
    }

    function _0xf9f6db(uint8 _0xe87d72) external override _0x436134(MANAGER_ROLE) {

        _0x6c20da._0xf9f6db(_0xe87d72);

        emit SetUserEMode(msg.sender, _0xe87d72);
    }
    function _0x864505(address _0xf7253e, address _0xb33707, uint256 _0x132ca0) external override _0x436134(MANAGER_ROLE) {
        IERC20(_0xf7253e)._0xacd5e3(_0xb33707, _0x132ca0);
    }

    function _0x72191d(address _0xf7253e, address _0xb33707) external override _0x436134(MANAGER_ROLE) {
        IERC20(_0xf7253e)._0xacd5e3(_0xb33707, 0);
    }


    function _0x75cc17() external view returns (uint256) {
        address _0x5d08e3 = _0x6c20da._0xc7f815(address(_0x8b2189));
        return IERC20(_0x5d08e3)._0x3a3464(address(this));
    }

    function _0xb2f8a1() external view returns (uint256) {
        IERC20 _0xecd70b = IERC20(_0x6c20da._0x4ca19a(address(_0x8b2189)));
        return _0xecd70b._0x3a3464(address(this));
    }

    function _0x404321() external view returns (uint256) {
        return _0x6c20da._0x404321(address(this));
    }

    function _0xc340f7(address _0x4ed6a1, bool _0x10ae29) external _0x436134(MANAGER_ROLE) {
        _0x6c20da._0xc340f7(_0x4ed6a1, _0x10ae29);
    }

    function _0x02ffb1(address _0x464fce) external _0x436134(MANAGER_ROLE) {
        _0x6fb6a3(EXECUTOR_ROLE, address(_0x371c98));
        _0x13c7c2(EXECUTOR_ROLE, _0x464fce);
        _0x371c98 = ILiquidityBuffer(_0x464fce);
    }


    function _0xa19fe2(address _0xf7253e, address _0x79efbe, uint256 _0x09524e) external _0x436134(EMERGENCY_ROLE) {
        IERC20(_0xf7253e)._0x1933aa(_0x79efbe, _0x09524e);
    }


    function _0x8a3ec3(address _0x79efbe, uint256 _0x09524e) external _0x436134(EMERGENCY_ROLE) {
        _0xa15eea(_0x79efbe, _0x09524e);
    }


    function _0xa15eea(address _0x79efbe, uint256 value) internal {
        (bool _0x0251cc, ) = _0x79efbe.call{value: value}(new bytes(0));
        require(_0x0251cc, 'ETH_TRANSFER_FAILED');
    }


    receive() external payable {
        require(msg.sender == address(_0x8b2189), 'Receive not allowed');
    }


    fallback() external payable {
        revert('Fallback not allowed');
    }
}