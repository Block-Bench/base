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
    event ETHWithdrawnFromManager(uint256 indexed _0xf190d1, uint256 _0x4f7491);
    event ETHReturnedToStaking(uint256 _0x4f7491);
    event ETHAllocatedToManager(uint256 indexed _0xf190d1, uint256 _0x4f7491);
    event ETHReceivedFromStaking(uint256 _0x4f7491);
    event FeesCollected(uint256 _0x4f7491);
    event InterestClaimed(
        uint256 indexed _0xf190d1,
        uint256 _0xb81910
    );
    event InterestToppedUp(
        uint256 _0x4f7491
    );
}


contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;


    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x204379("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x204379("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x204379("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x204379("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0xa29526 = 10_000;


    IStakingReturnsWrite public _0xa29d85;


    IPauserRead public _0x7a3bb1;


    uint256 public _0x0d69b1;


    mapping(uint256 => PositionManagerConfig) public _0x777eb0;


    mapping(uint256 => PositionAccountant) public _0xfe30f8;


    uint256 public _0x6cafca;


    uint256 public _0x158b82;


    uint256 public _0x48fb79;


    uint256 public _0x0b3b4c;


    uint256 public _0x49bd88;


    uint256 public _0x565392;


    uint256 public _0xc4291a;


    uint256 public _0x9ae6f2;


    address payable public _0xd44155;


    uint16 public _0x075423;

    uint256 public _0xf50c21;


    uint256 public _0xcfd819;


    uint256 public _0x16144e;


    bool public _0x88e888;

    mapping(address => bool) public _0xfa1a71;

    struct Init {
        address _0x4224ea;
        address _0xd12f69;
        address _0x0c5c41;
        address _0x436d82;
        address _0x77f582;
        address payable _0xd44155;
        IStakingReturnsWrite _0x241082;
        IPauserRead _0x7a3bb1;
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
        _0x46614c();
    }

    function _0xa4543e(Init memory _0x93a17e) external _0x3c61c1 {

        __AccessControlEnumerable_init();

        _0x73c29a(DEFAULT_ADMIN_ROLE, _0x93a17e._0x4224ea);
        _0x73c29a(LIQUIDITY_MANAGER_ROLE, _0x93a17e._0xd12f69);
        _0x73c29a(POSITION_MANAGER_ROLE, _0x93a17e._0x0c5c41);
        _0x73c29a(INTEREST_TOPUP_ROLE, _0x93a17e._0x436d82);
        _0x73c29a(DRAWDOWN_MANAGER_ROLE, _0x93a17e._0x77f582);

        _0xa29d85 = _0x93a17e._0x241082;
        _0x7a3bb1 = _0x93a17e._0x7a3bb1;
        _0xd44155 = _0x93a17e._0xd44155;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x88e888 = true; }

        _0x73c29a(LIQUIDITY_MANAGER_ROLE, address(_0xa29d85));
    }


    function _0xb0a6a5(uint256 _0xf190d1) public view returns (uint256) {
        PositionManagerConfig memory _0xa1d3db = _0x777eb0[_0xf190d1];

        IPositionManager _0x168aa2 = IPositionManager(_0xa1d3db._0xcd8f63);
        uint256 _0x40a4bd = _0x168aa2._0xfc276f();


        PositionAccountant memory _0xa6f632 = _0xfe30f8[_0xf190d1];

        if (_0x40a4bd > _0xa6f632._0x2c7755) {
            return _0x40a4bd - _0xa6f632._0x2c7755;
        }

        return 0;
    }

    function _0x9e06e2() public view returns (uint256) {
        return _0x565392 - _0x48fb79;
    }

    function _0xbeeadc() public view returns (uint256) {
        return _0x6cafca - _0x158b82;
    }

    function _0xe766a5() public view returns (uint256) {
        uint256 _0x7e704a = address(this).balance;


        for (uint256 i = 0; i < _0x0d69b1; i++) {
            PositionManagerConfig storage _0xa1d3db = _0x777eb0[i];
            if (_0xa1d3db._0xd900e9) {
                IPositionManager _0x168aa2 = IPositionManager(_0xa1d3db._0xcd8f63);
                uint256 _0x098977 = _0x168aa2._0xfc276f();
                _0x7e704a += _0x098977;
            }
        }

        return _0x7e704a;
    }


    function _0x5cf453(
        address _0xcd8f63,
        uint256 _0x276985
    ) external _0x09369b(POSITION_MANAGER_ROLE) returns (uint256 _0xf190d1) {
        if (_0xfa1a71[_0xcd8f63]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0xf190d1 = _0x0d69b1;
        _0x0d69b1++;

        _0x777eb0[_0xf190d1] = PositionManagerConfig({
            _0xcd8f63: _0xcd8f63,
            _0x276985: _0x276985,
            _0xd900e9: true
        });
        _0xfe30f8[_0xf190d1] = PositionAccountant({
            _0x2c7755: 0,
            _0x4428ce: 0
        });
        _0xfa1a71[_0xcd8f63] = true;

        _0x565392 += _0x276985;
        emit ProtocolConfigChanged(
            this._0x5cf453.selector,
            "addPositionManager(address,uint256)",
            abi._0xb6939a(_0xcd8f63, _0x276985)
        );
    }

    function _0x55d5cd(
        uint256 _0xf190d1,
        uint256 _0x799495,
        bool _0xd900e9
    ) external _0x09369b(POSITION_MANAGER_ROLE) {
        if (_0xf190d1 >= _0x0d69b1) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xa1d3db = _0x777eb0[_0xf190d1];

        if (_0x799495 < _0xfe30f8[_0xf190d1]._0x2c7755) {
            revert LiquidityBuffer__InvalidConfiguration();
        }


        _0x565392 = _0x565392 - _0xa1d3db._0x276985 + _0x799495;

        _0xa1d3db._0x276985 = _0x799495;
        _0xa1d3db._0xd900e9 = _0xd900e9;

        emit ProtocolConfigChanged(
            this._0x55d5cd.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0xb6939a(_0xf190d1, _0x799495, _0xd900e9)
        );
    }

    function _0x649f77(uint256 _0xf190d1) external _0x09369b(POSITION_MANAGER_ROLE) {
        if (_0xf190d1 >= _0x0d69b1) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xa1d3db = _0x777eb0[_0xf190d1];
        _0xa1d3db._0xd900e9 = !_0xa1d3db._0xd900e9;

        emit ProtocolConfigChanged(
            this._0x649f77.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0xb6939a(_0xf190d1)
        );
    }

    function _0x9a7650(uint256 _0xe5a6f1) external _0x09369b(DRAWDOWN_MANAGER_ROLE) {
        _0xc4291a = _0xe5a6f1;

        emit ProtocolConfigChanged(
            this._0x9a7650.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0xb6939a(_0xe5a6f1)
        );
    }

    function _0xe9c246(uint256 _0x1ab4a8) external _0x09369b(POSITION_MANAGER_ROLE) {
        if (_0x1ab4a8 >= _0x0d69b1) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0x777eb0[_0x1ab4a8]._0xd900e9) {
            revert LiquidityBuffer__ManagerInactive();
        }

        _0x9ae6f2 = _0x1ab4a8;

        emit ProtocolConfigChanged(
            this._0xe9c246.selector,
            "setDefaultManagerId(uint256)",
            abi._0xb6939a(_0x1ab4a8)
        );
    }


    function _0xc1344a(uint16 _0xf8dfe2) external _0x09369b(POSITION_MANAGER_ROLE) {
        if (_0xf8dfe2 > _0xa29526) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        _0x075423 = _0xf8dfe2;
        emit ProtocolConfigChanged(
            this._0xc1344a.selector, "setFeeBasisPoints(uint16)", abi._0xb6939a(_0xf8dfe2)
        );
    }


    function _0xf01d74(address payable _0x12e32a)
        external
        _0x09369b(POSITION_MANAGER_ROLE)
        _0xf8af87(_0x12e32a)
    {
        _0xd44155 = _0x12e32a;
        emit ProtocolConfigChanged(this._0xf01d74.selector, "setFeesReceiver(address)", abi._0xb6939a(_0x12e32a));
    }


    function _0xc36584(bool _0x9de70d) external _0x09369b(POSITION_MANAGER_ROLE) {
        _0x88e888 = _0x9de70d;
        emit ProtocolConfigChanged(this._0xc36584.selector, "setShouldExecuteAllocation(bool)", abi._0xb6939a(_0x9de70d));
    }


    function _0x8bb875() external payable _0x09369b(LIQUIDITY_MANAGER_ROLE) {
        if (_0x7a3bb1._0xaccb16()) revert LiquidityBuffer__Paused();
        _0x72be12(msg.value);
        if (_0x88e888) {
            _0xe85dc9(_0x9ae6f2, msg.value);
        }
    }

    function _0xf4cb83(uint256 _0xf190d1, uint256 _0x4f7491) external _0x09369b(LIQUIDITY_MANAGER_ROLE) {
        _0x5e1535(_0xf190d1, _0x4f7491);
        _0x7a0d17(_0x4f7491);
    }

    function _0xd98773(uint256 _0xf190d1, uint256 _0x4f7491) external _0x09369b(LIQUIDITY_MANAGER_ROLE) {
        _0xe85dc9(_0xf190d1, _0x4f7491);
    }

    function _0x279ce5(uint256 _0xf190d1, uint256 _0x4f7491) external _0x09369b(LIQUIDITY_MANAGER_ROLE) {
        _0x5e1535(_0xf190d1, _0x4f7491);
    }

    function _0xdf5fc1(uint256 _0x4f7491) external _0x09369b(LIQUIDITY_MANAGER_ROLE) {
        _0x7a0d17(_0x4f7491);
    }

    function _0x79a699() external payable _0x4029cf {


    }


    function _0x0395f8(uint256 _0xf190d1, uint256 _0xc07848) external _0x09369b(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x4f7491 = _0x70ad99(_0xf190d1);
        if (_0x4f7491 < _0xc07848) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x4f7491;
    }

    function _0x65ebc1(uint256 _0x4f7491) external _0x09369b(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x4f7491) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x423004(_0x4f7491);
        return _0x4f7491;
    }

    function _0x88028e(uint256 _0xf190d1, uint256 _0xc07848) external _0x09369b(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x4f7491 = _0x70ad99(_0xf190d1);
        if (_0x4f7491 < _0xc07848) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x423004(_0x4f7491);

        return _0x4f7491;
    }


    function _0x423004(uint256 _0x4f7491) internal {
        if (_0x7a3bb1._0xaccb16()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x4f7491 > _0xcfd819) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0xcfd819 -= _0x4f7491;
        uint256 _0x572f71 = Math._0xdb49b7(_0x075423, _0x4f7491, _0xa29526);
        uint256 _0xb30e35 = _0x4f7491 - _0x572f71;
        _0xa29d85._0xfbc552{value: _0xb30e35}();
        _0x49bd88 += _0xb30e35;
        emit InterestToppedUp(_0xb30e35);

        if (_0x572f71 > 0) {
            Address._0xc5a886(_0xd44155, _0x572f71);
            _0xf50c21 += _0x572f71;
            emit FeesCollected(_0x572f71);
        }
    }

    function _0x70ad99(uint256 _0xf190d1) internal returns (uint256) {
        if (_0x7a3bb1._0xaccb16()) {
            revert LiquidityBuffer__Paused();
        }

        uint256 _0xb81910 = _0xb0a6a5(_0xf190d1);

        if (_0xb81910 > 0) {
            PositionManagerConfig memory _0xa1d3db = _0x777eb0[_0xf190d1];


            _0xfe30f8[_0xf190d1]._0x4428ce += _0xb81910;
            _0x0b3b4c += _0xb81910;
            _0xcfd819 += _0xb81910;
            emit InterestClaimed(_0xf190d1, _0xb81910);


            IPositionManager _0x168aa2 = IPositionManager(_0xa1d3db._0xcd8f63);
            _0x168aa2._0x2b4951(_0xb81910);
        } else {
            emit InterestClaimed(_0xf190d1, _0xb81910);
        }

        return _0xb81910;
    }

    function _0x5e1535(uint256 _0xf190d1, uint256 _0x4f7491) internal {
        if (_0x7a3bb1._0xaccb16()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xf190d1 >= _0x0d69b1) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0xa1d3db = _0x777eb0[_0xf190d1];
        if (!_0xa1d3db._0xd900e9) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0xa6f632 = _0xfe30f8[_0xf190d1];


        if (_0x4f7491 > _0xa6f632._0x2c7755) {
            revert LiquidityBuffer__InsufficientAllocation();
        }


        _0xa6f632._0x2c7755 -= _0x4f7491;
        _0x48fb79 -= _0x4f7491;
        _0x16144e += _0x4f7491;
        emit ETHWithdrawnFromManager(_0xf190d1, _0x4f7491);


        IPositionManager _0x168aa2 = IPositionManager(_0xa1d3db._0xcd8f63);
        _0x168aa2._0x2b4951(_0x4f7491);
    }

    function _0x7a0d17(uint256 _0x4f7491) internal {
        if (_0x7a3bb1._0xaccb16()) {
            revert LiquidityBuffer__Paused();
        }


        if (address(_0xa29d85) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x4f7491 > _0x16144e) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }


        _0x158b82 += _0x4f7491;
        _0x16144e -= _0x4f7491;
        emit ETHReturnedToStaking(_0x4f7491);


        _0xa29d85._0x33704e{value: _0x4f7491}();
    }

    function _0xe85dc9(uint256 _0xf190d1, uint256 _0x4f7491) internal {
        if (_0x7a3bb1._0xaccb16()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x4f7491 > _0x16144e) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0xf190d1 >= _0x0d69b1) revert LiquidityBuffer__ManagerNotFound();

        if (address(this).balance < _0x4f7491) revert LiquidityBuffer__InsufficientBalance();


        PositionManagerConfig memory _0xa1d3db = _0x777eb0[_0xf190d1];
        if (!_0xa1d3db._0xd900e9) revert LiquidityBuffer__ManagerInactive();

        PositionAccountant storage _0xa6f632 = _0xfe30f8[_0xf190d1];
        if (_0xa6f632._0x2c7755 + _0x4f7491 > _0xa1d3db._0x276985) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }


        _0xa6f632._0x2c7755 += _0x4f7491;
        _0x48fb79 += _0x4f7491;
        _0x16144e -= _0x4f7491;
        emit ETHAllocatedToManager(_0xf190d1, _0x4f7491);


        IPositionManager _0x168aa2 = IPositionManager(_0xa1d3db._0xcd8f63);
        _0x168aa2._0x35a0d0{value: _0x4f7491}(0);
    }

    function _0x72be12(uint256 _0x4f7491) internal {
        _0x6cafca += _0x4f7491;
        _0x16144e += _0x4f7491;
        emit ETHReceivedFromStaking(_0x4f7491);
    }


    modifier _0xf8af87(address _0xb750a3) {
        if (_0xb750a3 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }


    modifier _0xf5762b() {
        if (msg.sender != address(_0xa29d85)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x4029cf() {
        bool _0x237a1c = false;


        for (uint256 i = 0; i < _0x0d69b1; i++) {
            PositionManagerConfig memory _0xa1d3db = _0x777eb0[i];

            if (msg.sender == _0xa1d3db._0xcd8f63 && _0xa1d3db._0xd900e9) {
                _0x237a1c = true;
                break;
            }
        }

        if (!_0x237a1c) {
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