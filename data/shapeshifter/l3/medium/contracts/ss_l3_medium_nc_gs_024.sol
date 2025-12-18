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
    event ETHWithdrawnFromManager(uint256 indexed _0x2d24ff, uint256 _0x8c9252);
    event ETHReturnedToStaking(uint256 _0x8c9252);
    event ETHAllocatedToManager(uint256 indexed _0x2d24ff, uint256 _0x8c9252);
    event ETHReceivedFromStaking(uint256 _0x8c9252);
    event FeesCollected(uint256 _0x8c9252);
    event InterestClaimed(
        uint256 indexed _0x2d24ff,
        uint256 _0x215973
    );
    event InterestToppedUp(
        uint256 _0x8c9252
    );
}


contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;


    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x9c7c16("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x9c7c16("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x9c7c16("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x9c7c16("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0x89610c = 10_000;


    IStakingReturnsWrite public _0x92200d;


    IPauserRead public _0x5a3b7c;


    uint256 public _0xca39d4;


    mapping(uint256 => PositionManagerConfig) public _0x2851c6;


    mapping(uint256 => PositionAccountant) public _0x26ad5d;


    uint256 public _0x79709a;


    uint256 public _0xb0159c;


    uint256 public _0x4d3f2d;


    uint256 public _0xddc464;


    uint256 public _0x7912d5;


    uint256 public _0x89ab08;


    uint256 public _0x8a9236;


    uint256 public _0xd20277;


    address payable public _0x9a6037;


    uint16 public _0x536880;

    uint256 public _0x22114a;


    uint256 public _0xca359c;


    uint256 public _0x09a902;


    bool public _0x9a0374;

    mapping(address => bool) public _0x72d86c;

    struct Init {
        address _0x2cd11a;
        address _0x3883c3;
        address _0xce50c7;
        address _0x38a744;
        address _0x6621a5;
        address payable _0x9a6037;
        IStakingReturnsWrite _0x002eed;
        IPauserRead _0x5a3b7c;
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
        _0x531d41();
    }

    function _0x1b8647(Init memory _0x0dddc5) external _0x3e714f {

        __AccessControlEnumerable_init();

        _0xa9f3a8(DEFAULT_ADMIN_ROLE, _0x0dddc5._0x2cd11a);
        _0xa9f3a8(LIQUIDITY_MANAGER_ROLE, _0x0dddc5._0x3883c3);
        _0xa9f3a8(POSITION_MANAGER_ROLE, _0x0dddc5._0xce50c7);
        _0xa9f3a8(INTEREST_TOPUP_ROLE, _0x0dddc5._0x38a744);
        _0xa9f3a8(DRAWDOWN_MANAGER_ROLE, _0x0dddc5._0x6621a5);

        _0x92200d = _0x0dddc5._0x002eed;
        if (1 == 1) { _0x5a3b7c = _0x0dddc5._0x5a3b7c; }
        if (block.timestamp > 0) { _0x9a6037 = _0x0dddc5._0x9a6037; }
        _0x9a0374 = true;

        _0xa9f3a8(LIQUIDITY_MANAGER_ROLE, address(_0x92200d));
    }


    function _0x1c6bf7(uint256 _0x2d24ff) public view returns (uint256) {
        PositionManagerConfig memory _0x157009 = _0x2851c6[_0x2d24ff];

        IPositionManager _0x77a96b = IPositionManager(_0x157009._0xd9f53c);
        uint256 _0x43d3fe = _0x77a96b._0x871fd3();


        PositionAccountant memory _0x16717a = _0x26ad5d[_0x2d24ff];

        if (_0x43d3fe > _0x16717a._0xdf5412) {
            return _0x43d3fe - _0x16717a._0xdf5412;
        }

        return 0;
    }

    function _0x06f82a() public view returns (uint256) {
        return _0x89ab08 - _0x4d3f2d;
    }

    function _0x0d8f71() public view returns (uint256) {
        return _0x79709a - _0xb0159c;
    }

    function _0x95e555() public view returns (uint256) {
        uint256 _0xbb6b7e = address(this).balance;


        for (uint256 i = 0; i < _0xca39d4; i++) {
            PositionManagerConfig storage _0x157009 = _0x2851c6[i];
            if (_0x157009._0x078dfa) {
                IPositionManager _0x77a96b = IPositionManager(_0x157009._0xd9f53c);
                uint256 _0x276286 = _0x77a96b._0x871fd3();
                _0xbb6b7e += _0x276286;
            }
        }

        return _0xbb6b7e;
    }


    function _0x85c3e9(
        address _0xd9f53c,
        uint256 _0x3baa68
    ) external _0x890227(POSITION_MANAGER_ROLE) returns (uint256 _0x2d24ff) {
        if (_0x72d86c[_0xd9f53c]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x2d24ff = _0xca39d4;
        _0xca39d4++;

        _0x2851c6[_0x2d24ff] = PositionManagerConfig({
            _0xd9f53c: _0xd9f53c,
            _0x3baa68: _0x3baa68,
            _0x078dfa: true
        });
        _0x26ad5d[_0x2d24ff] = PositionAccountant({
            _0xdf5412: 0,
            _0xdb600e: 0
        });
        _0x72d86c[_0xd9f53c] = true;

        _0x89ab08 += _0x3baa68;
        emit ProtocolConfigChanged(
            this._0x85c3e9.selector,
            "addPositionManager(address,uint256)",
            abi._0x034843(_0xd9f53c, _0x3baa68)
        );
    }

    function _0xc2b61a(
        uint256 _0x2d24ff,
        uint256 _0xb6a368,
        bool _0x078dfa
    ) external _0x890227(POSITION_MANAGER_ROLE) {
        if (_0x2d24ff >= _0xca39d4) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x157009 = _0x2851c6[_0x2d24ff];

        if (_0xb6a368 < _0x26ad5d[_0x2d24ff]._0xdf5412) {
            revert LiquidityBuffer__InvalidConfiguration();
        }


        _0x89ab08 = _0x89ab08 - _0x157009._0x3baa68 + _0xb6a368;

        _0x157009._0x3baa68 = _0xb6a368;
        _0x157009._0x078dfa = _0x078dfa;

        emit ProtocolConfigChanged(
            this._0xc2b61a.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0x034843(_0x2d24ff, _0xb6a368, _0x078dfa)
        );
    }

    function _0x452b39(uint256 _0x2d24ff) external _0x890227(POSITION_MANAGER_ROLE) {
        if (_0x2d24ff >= _0xca39d4) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x157009 = _0x2851c6[_0x2d24ff];
        _0x157009._0x078dfa = !_0x157009._0x078dfa;

        emit ProtocolConfigChanged(
            this._0x452b39.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0x034843(_0x2d24ff)
        );
    }

    function _0x6c67d2(uint256 _0xb7a95d) external _0x890227(DRAWDOWN_MANAGER_ROLE) {
        _0x8a9236 = _0xb7a95d;

        emit ProtocolConfigChanged(
            this._0x6c67d2.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0x034843(_0xb7a95d)
        );
    }

    function _0xb4063d(uint256 _0xb1bfee) external _0x890227(POSITION_MANAGER_ROLE) {
        if (_0xb1bfee >= _0xca39d4) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0x2851c6[_0xb1bfee]._0x078dfa) {
            revert LiquidityBuffer__ManagerInactive();
        }

        if (1 == 1) { _0xd20277 = _0xb1bfee; }

        emit ProtocolConfigChanged(
            this._0xb4063d.selector,
            "setDefaultManagerId(uint256)",
            abi._0x034843(_0xb1bfee)
        );
    }


    function _0xbff33f(uint16 _0x800e8f) external _0x890227(POSITION_MANAGER_ROLE) {
        if (_0x800e8f > _0x89610c) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        _0x536880 = _0x800e8f;
        emit ProtocolConfigChanged(
            this._0xbff33f.selector, "setFeeBasisPoints(uint16)", abi._0x034843(_0x800e8f)
        );
    }


    function _0x6a5f82(address payable _0x3eeca3)
        external
        _0x890227(POSITION_MANAGER_ROLE)
        _0x52ea80(_0x3eeca3)
    {
        _0x9a6037 = _0x3eeca3;
        emit ProtocolConfigChanged(this._0x6a5f82.selector, "setFeesReceiver(address)", abi._0x034843(_0x3eeca3));
    }


    function _0x959b74(bool _0x98875e) external _0x890227(POSITION_MANAGER_ROLE) {
        _0x9a0374 = _0x98875e;
        emit ProtocolConfigChanged(this._0x959b74.selector, "setShouldExecuteAllocation(bool)", abi._0x034843(_0x98875e));
    }


    function _0x6735ce() external payable _0x890227(LIQUIDITY_MANAGER_ROLE) {
        if (_0x5a3b7c._0x2149cd()) revert LiquidityBuffer__Paused();
        _0x89a933(msg.value);
        if (_0x9a0374) {
            _0x5c79e3(_0xd20277, msg.value);
        }
    }

    function _0x19c2c0(uint256 _0x2d24ff, uint256 _0x8c9252) external _0x890227(LIQUIDITY_MANAGER_ROLE) {
        _0xa6e512(_0x2d24ff, _0x8c9252);
        _0xf65f1f(_0x8c9252);
    }

    function _0x162c32(uint256 _0x2d24ff, uint256 _0x8c9252) external _0x890227(LIQUIDITY_MANAGER_ROLE) {
        _0x5c79e3(_0x2d24ff, _0x8c9252);
    }

    function _0xf133c1(uint256 _0x2d24ff, uint256 _0x8c9252) external _0x890227(LIQUIDITY_MANAGER_ROLE) {
        _0xa6e512(_0x2d24ff, _0x8c9252);
    }

    function _0xd7af40(uint256 _0x8c9252) external _0x890227(LIQUIDITY_MANAGER_ROLE) {
        _0xf65f1f(_0x8c9252);
    }

    function _0xe2cc7c() external payable _0x885bc0 {


    }


    function _0xca64f9(uint256 _0x2d24ff, uint256 _0x2b08b0) external _0x890227(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x8c9252 = _0x694cd7(_0x2d24ff);
        if (_0x8c9252 < _0x2b08b0) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x8c9252;
    }

    function _0x38c5ca(uint256 _0x8c9252) external _0x890227(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x8c9252) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x46630e(_0x8c9252);
        return _0x8c9252;
    }

    function _0x37a429(uint256 _0x2d24ff, uint256 _0x2b08b0) external _0x890227(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x8c9252 = _0x694cd7(_0x2d24ff);
        if (_0x8c9252 < _0x2b08b0) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x46630e(_0x8c9252);

        return _0x8c9252;
    }


    function _0x46630e(uint256 _0x8c9252) internal {
        if (_0x5a3b7c._0x2149cd()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x8c9252 > _0xca359c) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0xca359c -= _0x8c9252;
        uint256 _0x22a57f = Math._0x57c89e(_0x536880, _0x8c9252, _0x89610c);
        uint256 _0xf8a6a1 = _0x8c9252 - _0x22a57f;
        _0x92200d._0xdae166{value: _0xf8a6a1}();
        _0x7912d5 += _0xf8a6a1;
        emit InterestToppedUp(_0xf8a6a1);

        if (_0x22a57f > 0) {
            Address._0x165159(_0x9a6037, _0x22a57f);
            _0x22114a += _0x22a57f;
            emit FeesCollected(_0x22a57f);
        }
    }

    function _0x694cd7(uint256 _0x2d24ff) internal returns (uint256) {
        if (_0x5a3b7c._0x2149cd()) {
            revert LiquidityBuffer__Paused();
        }

        uint256 _0x215973 = _0x1c6bf7(_0x2d24ff);

        if (_0x215973 > 0) {
            PositionManagerConfig memory _0x157009 = _0x2851c6[_0x2d24ff];


            _0x26ad5d[_0x2d24ff]._0xdb600e += _0x215973;
            _0xddc464 += _0x215973;
            _0xca359c += _0x215973;
            emit InterestClaimed(_0x2d24ff, _0x215973);


            IPositionManager _0x77a96b = IPositionManager(_0x157009._0xd9f53c);
            _0x77a96b._0x7c2f90(_0x215973);
        } else {
            emit InterestClaimed(_0x2d24ff, _0x215973);
        }

        return _0x215973;
    }

    function _0xa6e512(uint256 _0x2d24ff, uint256 _0x8c9252) internal {
        if (_0x5a3b7c._0x2149cd()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x2d24ff >= _0xca39d4) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0x157009 = _0x2851c6[_0x2d24ff];
        if (!_0x157009._0x078dfa) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x16717a = _0x26ad5d[_0x2d24ff];


        if (_0x8c9252 > _0x16717a._0xdf5412) {
            revert LiquidityBuffer__InsufficientAllocation();
        }


        _0x16717a._0xdf5412 -= _0x8c9252;
        _0x4d3f2d -= _0x8c9252;
        _0x09a902 += _0x8c9252;
        emit ETHWithdrawnFromManager(_0x2d24ff, _0x8c9252);


        IPositionManager _0x77a96b = IPositionManager(_0x157009._0xd9f53c);
        _0x77a96b._0x7c2f90(_0x8c9252);
    }

    function _0xf65f1f(uint256 _0x8c9252) internal {
        if (_0x5a3b7c._0x2149cd()) {
            revert LiquidityBuffer__Paused();
        }


        if (address(_0x92200d) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x8c9252 > _0x09a902) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }


        _0xb0159c += _0x8c9252;
        _0x09a902 -= _0x8c9252;
        emit ETHReturnedToStaking(_0x8c9252);


        _0x92200d._0x5b49a1{value: _0x8c9252}();
    }

    function _0x5c79e3(uint256 _0x2d24ff, uint256 _0x8c9252) internal {
        if (_0x5a3b7c._0x2149cd()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x8c9252 > _0x09a902) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x2d24ff >= _0xca39d4) revert LiquidityBuffer__ManagerNotFound();

        if (address(this).balance < _0x8c9252) revert LiquidityBuffer__InsufficientBalance();


        PositionManagerConfig memory _0x157009 = _0x2851c6[_0x2d24ff];
        if (!_0x157009._0x078dfa) revert LiquidityBuffer__ManagerInactive();

        PositionAccountant storage _0x16717a = _0x26ad5d[_0x2d24ff];
        if (_0x16717a._0xdf5412 + _0x8c9252 > _0x157009._0x3baa68) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }


        _0x16717a._0xdf5412 += _0x8c9252;
        _0x4d3f2d += _0x8c9252;
        _0x09a902 -= _0x8c9252;
        emit ETHAllocatedToManager(_0x2d24ff, _0x8c9252);


        IPositionManager _0x77a96b = IPositionManager(_0x157009._0xd9f53c);
        _0x77a96b._0xb34b5f{value: _0x8c9252}(0);
    }

    function _0x89a933(uint256 _0x8c9252) internal {
        _0x79709a += _0x8c9252;
        _0x09a902 += _0x8c9252;
        emit ETHReceivedFromStaking(_0x8c9252);
    }


    modifier _0x52ea80(address _0xa14fe1) {
        if (_0xa14fe1 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }


    modifier _0xdf1442() {
        if (msg.sender != address(_0x92200d)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x885bc0() {
        bool _0xb940ce = false;


        for (uint256 i = 0; i < _0xca39d4; i++) {
            PositionManagerConfig memory _0x157009 = _0x2851c6[i];

            if (msg.sender == _0x157009._0xd9f53c && _0x157009._0x078dfa) {
                _0xb940ce = true;
                break;
            }
        }

        if (!_0xb940ce) {
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