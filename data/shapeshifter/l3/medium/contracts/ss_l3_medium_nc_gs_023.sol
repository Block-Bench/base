pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} from "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {Address} from "openzeppelin/utils/Address.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {ILiquidityBuffer} from "./interfaces/ILiquidityBuffer.sol";
import {IPositionManager} from "./interfaces/IPositionManager.sol";
import {IStakingReturnsWrite} from "../interfaces/IStaking.sol";
import {IPauserRead} from "../interfaces/IPauser.sol";
import {ProtocolEvents} from "../interfaces/ProtocolEvents.sol";

interface LiquidityBufferEvents {
    event ETHWithdrawnFromManager(uint256 indexed _0x4ae012, uint256 _0xfe294e);
    event ETHReturnedToStaking(uint256 _0xfe294e);
    event ETHAllocatedToManager(uint256 indexed _0x4ae012, uint256 _0xfe294e);
    event ETHReceivedFromStaking(uint256 _0xfe294e);
    event FeesCollected(uint256 _0xfe294e);
    event InterestClaimed(
        uint256 indexed _0x4ae012,
        uint256 _0xab9302
    );
    event InterestToppedUp(
        uint256 _0xfe294e
    );
}


contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;


    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x6fce8e("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x6fce8e("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x6fce8e("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x6fce8e("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0xadde56 = 10_000;


    IStakingReturnsWrite public _0xda980b;


    IPauserRead public _0xeaff3a;


    uint256 public _0xf84f89;


    mapping(uint256 => PositionManagerConfig) public _0x8b1ecf;


    mapping(uint256 => PositionAccountant) public _0xf74b9d;


    uint256 public _0xc7edad;


    uint256 public _0x139757;


    uint256 public _0x3c8a2e;


    uint256 public _0xaed3b3;


    uint256 public _0x2213ce;


    uint256 public _0xf3ab03;


    uint256 public _0x9f65b4;


    uint256 public _0xcc14b6;


    address payable public _0xcc0b8f;


    uint16 public _0xf4f79b;

    uint256 public _0xdf4591;


    uint256 public _0x9c120d;


    uint256 public _0xdf5f6f;


    bool public _0x08bfe8;

    mapping(address => bool) public _0x9498d3;

    struct Init {
        address _0xd31cfe;
        address _0x3b7fae;
        address _0xa01393;
        address _0x686fb0;
        address _0xf6f097;
        address payable _0xcc0b8f;
        IStakingReturnsWrite _0x0766d4;
        IPauserRead _0xeaff3a;
    }


    error LiquidityBuffer__ManagerNotFound();
    error LiquidityBuffer__ManagerInactive();
    error LiquidityBuffer__ManagerAlreadyRegistered();
    error LiquidityBuffer__ExceedsAllocationCap();
    error LiquidityBuffer__InsufficientBalance();
    error LiquidityBuffer__InsufficientAllocation();
    error LiquidityBuffer__DoesNotReceiveETH();
    error LiquidityBuffer__Paused();
    error LiquidityBuffer__InvalidConfiguration();
    error LiquidityBuffer__ZeroAddress();
    error LiquidityBuffer__NotStakingContract();
    error LiquidityBuffer__NotPositionManagerContract();
    error LiquidityBuffer__ExceedsPendingInterest();
    error LiquidityBuffer__ExceedsPendingPrincipal();


    constructor() {
        _0x3f6a05();
    }

    function _0x6ee2f9(Init memory _0xb4bb04) external _0x9b9a2a {

        __AccessControlEnumerable_init();

        _0x58d585(DEFAULT_ADMIN_ROLE, _0xb4bb04._0xd31cfe);
        _0x58d585(LIQUIDITY_MANAGER_ROLE, _0xb4bb04._0x3b7fae);
        _0x58d585(POSITION_MANAGER_ROLE, _0xb4bb04._0xa01393);
        _0x58d585(INTEREST_TOPUP_ROLE, _0xb4bb04._0x686fb0);
        _0x58d585(DRAWDOWN_MANAGER_ROLE, _0xb4bb04._0xf6f097);

        _0xda980b = _0xb4bb04._0x0766d4;
        _0xeaff3a = _0xb4bb04._0xeaff3a;
        if (true) { _0xcc0b8f = _0xb4bb04._0xcc0b8f; }
        _0x08bfe8 = true;

        _0x58d585(LIQUIDITY_MANAGER_ROLE, address(_0xda980b));
    }


    function _0xb708ce(uint256 _0x4ae012) public view returns (uint256) {
        PositionManagerConfig memory _0x166068 = _0x8b1ecf[_0x4ae012];

        IPositionManager _0xca20e4 = IPositionManager(_0x166068._0x4aa6d8);
        uint256 _0x8049bc = _0xca20e4._0x8e2258();


        PositionAccountant memory _0x60bbf3 = _0xf74b9d[_0x4ae012];

        if (_0x8049bc > _0x60bbf3._0x49c959) {
            return _0x8049bc - _0x60bbf3._0x49c959;
        }

        return 0;
    }

    function _0x49a679() public view returns (uint256) {
        return _0xf3ab03 - _0x3c8a2e;
    }

    function _0x731c3b() public view returns (uint256) {
        return _0xc7edad - _0x139757;
    }

    function _0xa774bb() public view returns (uint256) {
        uint256 _0x0db4e7 = address(this).balance;


        for (uint256 i = 0; i < _0xf84f89; i++) {
            PositionManagerConfig storage _0x166068 = _0x8b1ecf[i];
            if (_0x166068._0x9f2bdc) {
                IPositionManager _0xca20e4 = IPositionManager(_0x166068._0x4aa6d8);
                uint256 _0x2bf01a = _0xca20e4._0x8e2258();
                _0x0db4e7 += _0x2bf01a;
            }
        }

        return _0x0db4e7;
    }


    function _0xe53918(
        address _0x4aa6d8,
        uint256 _0x2c4e94
    ) external _0xd79c58(POSITION_MANAGER_ROLE) returns (uint256 _0x4ae012) {
        if (_0x9498d3[_0x4aa6d8]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x4ae012 = _0xf84f89;
        _0xf84f89++;

        _0x8b1ecf[_0x4ae012] = PositionManagerConfig({
            _0x4aa6d8: _0x4aa6d8,
            _0x2c4e94: _0x2c4e94,
            _0x9f2bdc: true
        });
        _0xf74b9d[_0x4ae012] = PositionAccountant({
            _0x49c959: 0,
            _0xa738a7: 0
        });
        _0x9498d3[_0x4aa6d8] = true;

        _0xf3ab03 += _0x2c4e94;
        emit ProtocolConfigChanged(
            this._0xe53918.selector,
            "addPositionManager(address,uint256)",
            abi._0x4981be(_0x4aa6d8, _0x2c4e94)
        );
    }

    function _0xdef57e(
        uint256 _0x4ae012,
        uint256 _0x237adf,
        bool _0x9f2bdc
    ) external _0xd79c58(POSITION_MANAGER_ROLE) {
        if (_0x4ae012 >= _0xf84f89) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x166068 = _0x8b1ecf[_0x4ae012];

        if (_0x237adf < _0xf74b9d[_0x4ae012]._0x49c959) {
            revert LiquidityBuffer__InvalidConfiguration();
        }


        _0xf3ab03 = _0xf3ab03 - _0x166068._0x2c4e94 + _0x237adf;

        _0x166068._0x2c4e94 = _0x237adf;
        _0x166068._0x9f2bdc = _0x9f2bdc;

        emit ProtocolConfigChanged(
            this._0xdef57e.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0x4981be(_0x4ae012, _0x237adf, _0x9f2bdc)
        );
    }

    function _0xd0862f(uint256 _0x4ae012) external _0xd79c58(POSITION_MANAGER_ROLE) {
        if (_0x4ae012 >= _0xf84f89) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x166068 = _0x8b1ecf[_0x4ae012];
        _0x166068._0x9f2bdc = !_0x166068._0x9f2bdc;

        emit ProtocolConfigChanged(
            this._0xd0862f.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0x4981be(_0x4ae012)
        );
    }

    function _0x011ebb(uint256 _0xb244ae) external _0xd79c58(DRAWDOWN_MANAGER_ROLE) {
        _0x9f65b4 = _0xb244ae;

        emit ProtocolConfigChanged(
            this._0x011ebb.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0x4981be(_0xb244ae)
        );
    }

    function _0x23e841(uint256 _0x0802c2) external _0xd79c58(POSITION_MANAGER_ROLE) {
        if (_0x0802c2 >= _0xf84f89) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0x8b1ecf[_0x0802c2]._0x9f2bdc) {
            revert LiquidityBuffer__ManagerInactive();
        }

        _0xcc14b6 = _0x0802c2;

        emit ProtocolConfigChanged(
            this._0x23e841.selector,
            "setDefaultManagerId(uint256)",
            abi._0x4981be(_0x0802c2)
        );
    }


    function _0x67ab6c(uint16 _0x23a0cf) external _0xd79c58(POSITION_MANAGER_ROLE) {
        if (_0x23a0cf > _0xadde56) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        if (block.timestamp > 0) { _0xf4f79b = _0x23a0cf; }
        emit ProtocolConfigChanged(
            this._0x67ab6c.selector, "setFeeBasisPoints(uint16)", abi._0x4981be(_0x23a0cf)
        );
    }


    function _0xb6b606(address payable _0xf80005)
        external
        _0xd79c58(POSITION_MANAGER_ROLE)
        _0x7825ca(_0xf80005)
    {
        _0xcc0b8f = _0xf80005;
        emit ProtocolConfigChanged(this._0xb6b606.selector, "setFeesReceiver(address)", abi._0x4981be(_0xf80005));
    }


    function _0x8252cd(bool _0x71a805) external _0xd79c58(POSITION_MANAGER_ROLE) {
        _0x08bfe8 = _0x71a805;
        emit ProtocolConfigChanged(this._0x8252cd.selector, "setShouldExecuteAllocation(bool)", abi._0x4981be(_0x71a805));
    }


    function _0x725db3() external payable _0xd79c58(LIQUIDITY_MANAGER_ROLE) {
        if (_0xeaff3a._0xe55d37()) revert LiquidityBuffer__Paused();
        _0xca8a95(msg.value);
        if (_0x08bfe8) {
            _0xbb3269(_0xcc14b6, msg.value);
        }
    }

    function _0x9b18ca(uint256 _0x4ae012, uint256 _0xfe294e) external _0xd79c58(LIQUIDITY_MANAGER_ROLE) {
        _0xe24b66(_0x4ae012, _0xfe294e);
        _0x41e6b4(_0xfe294e);
    }

    function _0x91248a(uint256 _0x4ae012, uint256 _0xfe294e) external _0xd79c58(LIQUIDITY_MANAGER_ROLE) {
        _0xbb3269(_0x4ae012, _0xfe294e);
    }

    function _0x61f354(uint256 _0x4ae012, uint256 _0xfe294e) external _0xd79c58(LIQUIDITY_MANAGER_ROLE) {
        _0xe24b66(_0x4ae012, _0xfe294e);
    }

    function _0x62baf2(uint256 _0xfe294e) external _0xd79c58(LIQUIDITY_MANAGER_ROLE) {
        _0x41e6b4(_0xfe294e);
    }

    function _0x590de4() external payable _0x8f260d {


    }


    function _0x9b4e78(uint256 _0x4ae012, uint256 _0x4ebb07) external _0xd79c58(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0xfe294e = _0x804da3(_0x4ae012);
        if (_0xfe294e < _0x4ebb07) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0xfe294e;
    }

    function _0x13353b(uint256 _0xfe294e) external _0xd79c58(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0xfe294e) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xe371bd(_0xfe294e);
        return _0xfe294e;
    }

    function _0xd36ba7(uint256 _0x4ae012, uint256 _0x4ebb07) external _0xd79c58(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0xfe294e = _0x804da3(_0x4ae012);
        if (_0xfe294e < _0x4ebb07) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xe371bd(_0xfe294e);

        return _0xfe294e;
    }


    function _0xe371bd(uint256 _0xfe294e) internal {
        if (_0xeaff3a._0xe55d37()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xfe294e > _0x9c120d) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0x9c120d -= _0xfe294e;
        uint256 _0x5cc31a = Math._0x7aaf2c(_0xf4f79b, _0xfe294e, _0xadde56);
        uint256 _0x938ec6 = _0xfe294e - _0x5cc31a;
        _0xda980b._0xfc0c1d{value: _0x938ec6}();
        _0x2213ce += _0x938ec6;
        emit InterestToppedUp(_0x938ec6);

        if (_0x5cc31a > 0) {
            Address._0xb0ad04(_0xcc0b8f, _0x5cc31a);
            _0xdf4591 += _0x5cc31a;
            emit FeesCollected(_0x5cc31a);
        }
    }

    function _0x804da3(uint256 _0x4ae012) internal returns (uint256) {
        if (_0xeaff3a._0xe55d37()) {
            revert LiquidityBuffer__Paused();
        }

        uint256 _0xab9302 = _0xb708ce(_0x4ae012);

        if (_0xab9302 > 0) {
            PositionManagerConfig memory _0x166068 = _0x8b1ecf[_0x4ae012];


            _0xf74b9d[_0x4ae012]._0xa738a7 += _0xab9302;
            _0xaed3b3 += _0xab9302;
            _0x9c120d += _0xab9302;
            emit InterestClaimed(_0x4ae012, _0xab9302);


            IPositionManager _0xca20e4 = IPositionManager(_0x166068._0x4aa6d8);
            _0xca20e4._0xbac6e2(_0xab9302);
        } else {
            emit InterestClaimed(_0x4ae012, _0xab9302);
        }

        return _0xab9302;
    }

    function _0xe24b66(uint256 _0x4ae012, uint256 _0xfe294e) internal {
        if (_0xeaff3a._0xe55d37()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x4ae012 >= _0xf84f89) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0x166068 = _0x8b1ecf[_0x4ae012];
        if (!_0x166068._0x9f2bdc) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x60bbf3 = _0xf74b9d[_0x4ae012];


        if (_0xfe294e > _0x60bbf3._0x49c959) {
            revert LiquidityBuffer__InsufficientAllocation();
        }


        _0x60bbf3._0x49c959 -= _0xfe294e;
        _0x3c8a2e -= _0xfe294e;
        _0xdf5f6f += _0xfe294e;
        emit ETHWithdrawnFromManager(_0x4ae012, _0xfe294e);


        IPositionManager _0xca20e4 = IPositionManager(_0x166068._0x4aa6d8);
        _0xca20e4._0xbac6e2(_0xfe294e);
    }

    function _0x41e6b4(uint256 _0xfe294e) internal {
        if (_0xeaff3a._0xe55d37()) {
            revert LiquidityBuffer__Paused();
        }


        if (address(_0xda980b) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0xfe294e > _0xdf5f6f) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }


        _0x139757 += _0xfe294e;
        _0xdf5f6f -= _0xfe294e;
        emit ETHReturnedToStaking(_0xfe294e);


        _0xda980b._0x32d217{value: _0xfe294e}();
    }

    function _0xbb3269(uint256 _0x4ae012, uint256 _0xfe294e) internal {
        if (_0xeaff3a._0xe55d37()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xfe294e > _0xdf5f6f) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x4ae012 >= _0xf84f89) revert LiquidityBuffer__ManagerNotFound();

        if (address(this).balance < _0xfe294e) revert LiquidityBuffer__InsufficientBalance();


        PositionManagerConfig memory _0x166068 = _0x8b1ecf[_0x4ae012];
        if (!_0x166068._0x9f2bdc) revert LiquidityBuffer__ManagerInactive();

        PositionAccountant storage _0x60bbf3 = _0xf74b9d[_0x4ae012];
        if (_0x60bbf3._0x49c959 + _0xfe294e > _0x166068._0x2c4e94) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }


        _0x60bbf3._0x49c959 += _0xfe294e;
        _0x3c8a2e += _0xfe294e;
        _0xdf5f6f -= _0xfe294e;
        emit ETHAllocatedToManager(_0x4ae012, _0xfe294e);


        IPositionManager _0xca20e4 = IPositionManager(_0x166068._0x4aa6d8);
        _0xca20e4._0x462cd3{value: _0xfe294e}(0);
    }

    function _0xca8a95(uint256 _0xfe294e) internal {
        _0xc7edad += _0xfe294e;
        _0xdf5f6f += _0xfe294e;
        emit ETHReceivedFromStaking(_0xfe294e);
    }


    modifier _0x7825ca(address _0xdbe968) {
        if (_0xdbe968 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }


    modifier _0x2564fc() {
        if (msg.sender != address(_0xda980b)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x8f260d() {
        bool _0xba5dfb = false;


        for (uint256 i = 0; i < _0xf84f89; i++) {
            PositionManagerConfig memory _0x166068 = _0x8b1ecf[i];

            if (msg.sender == _0x166068._0x4aa6d8 && _0x166068._0x9f2bdc) {
                _0xba5dfb = true;
                break;
            }
        }

        if (!_0xba5dfb) {
            revert LiquidityBuffer__NotPositionManagerContract();
        }
        _;
    }

    receive() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }

    fallback() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }
}