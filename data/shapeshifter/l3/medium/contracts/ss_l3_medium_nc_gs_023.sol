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
    event ETHWithdrawnFromManager(uint256 indexed _0x5f7cd8, uint256 _0x869d47);
    event ETHReturnedToStaking(uint256 _0x869d47);
    event ETHAllocatedToManager(uint256 indexed _0x5f7cd8, uint256 _0x869d47);
    event ETHReceivedFromStaking(uint256 _0x869d47);
    event FeesCollected(uint256 _0x869d47);
    event InterestClaimed(
        uint256 indexed _0x5f7cd8,
        uint256 _0xe1cf99
    );
    event InterestToppedUp(
        uint256 _0x869d47
    );
}


contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;


    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x38eec4("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x38eec4("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x38eec4("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x38eec4("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0xabad26 = 10_000;


    IStakingReturnsWrite public _0x2a44ce;


    IPauserRead public _0x2b5bb3;


    uint256 public _0x8036ae;


    mapping(uint256 => PositionManagerConfig) public _0x14d30d;


    mapping(uint256 => PositionAccountant) public _0x58c955;


    uint256 public _0x5d4b63;


    uint256 public _0xa943ea;


    uint256 public _0x52a6d5;


    uint256 public _0x2a1cda;


    uint256 public _0xbd89b6;


    uint256 public _0xc75283;


    uint256 public _0x20c61e;


    uint256 public _0xa96d0a;


    address payable public _0xacc1a3;


    uint16 public _0x632822;

    uint256 public _0xb7c7d3;


    uint256 public _0x984a34;


    uint256 public _0x1e3688;


    bool public _0xd3ebd9;

    mapping(address => bool) public _0x8960bb;

    struct Init {
        address _0x0f8136;
        address _0xa3df5a;
        address _0xbb1812;
        address _0xdd2d88;
        address _0x3153f2;
        address payable _0xacc1a3;
        IStakingReturnsWrite _0x78fc4c;
        IPauserRead _0x2b5bb3;
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
        _0x8f8b98();
    }

    function _0xaf6096(Init memory _0x1d6e4c) external _0xe9c8f4 {

        __AccessControlEnumerable_init();

        _0xe02e49(DEFAULT_ADMIN_ROLE, _0x1d6e4c._0x0f8136);
        _0xe02e49(LIQUIDITY_MANAGER_ROLE, _0x1d6e4c._0xa3df5a);
        _0xe02e49(POSITION_MANAGER_ROLE, _0x1d6e4c._0xbb1812);
        _0xe02e49(INTEREST_TOPUP_ROLE, _0x1d6e4c._0xdd2d88);
        _0xe02e49(DRAWDOWN_MANAGER_ROLE, _0x1d6e4c._0x3153f2);

        _0x2a44ce = _0x1d6e4c._0x78fc4c;
        if (gasleft() > 0) { _0x2b5bb3 = _0x1d6e4c._0x2b5bb3; }
        if (true) { _0xacc1a3 = _0x1d6e4c._0xacc1a3; }
        _0xd3ebd9 = true;

        _0xe02e49(LIQUIDITY_MANAGER_ROLE, address(_0x2a44ce));
    }


    function _0xb5a959(uint256 _0x5f7cd8) public view returns (uint256) {
        PositionManagerConfig memory _0x3553f9 = _0x14d30d[_0x5f7cd8];

        IPositionManager _0x879612 = IPositionManager(_0x3553f9._0x67100d);
        uint256 _0x7de6d7 = _0x879612._0x99ec5e();


        PositionAccountant memory _0x2767d9 = _0x58c955[_0x5f7cd8];

        if (_0x7de6d7 > _0x2767d9._0x73d1f0) {
            return _0x7de6d7 - _0x2767d9._0x73d1f0;
        }

        return 0;
    }

    function _0xcad022() public view returns (uint256) {
        return _0xc75283 - _0x52a6d5;
    }

    function _0x931dc5() public view returns (uint256) {
        return _0x5d4b63 - _0xa943ea;
    }

    function _0x964c49() public view returns (uint256) {
        uint256 _0x4e7eee = address(this).balance;


        for (uint256 i = 0; i < _0x8036ae; i++) {
            PositionManagerConfig storage _0x3553f9 = _0x14d30d[i];
            if (_0x3553f9._0x973bdf) {
                IPositionManager _0x879612 = IPositionManager(_0x3553f9._0x67100d);
                uint256 _0x7dbf41 = _0x879612._0x99ec5e();
                _0x4e7eee += _0x7dbf41;
            }
        }

        return _0x4e7eee;
    }


    function _0xf3cd00(
        address _0x67100d,
        uint256 _0xb136a4
    ) external _0xcfaa5b(POSITION_MANAGER_ROLE) returns (uint256 _0x5f7cd8) {
        if (_0x8960bb[_0x67100d]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x5f7cd8 = _0x8036ae;
        _0x8036ae++;

        _0x14d30d[_0x5f7cd8] = PositionManagerConfig({
            _0x67100d: _0x67100d,
            _0xb136a4: _0xb136a4,
            _0x973bdf: true
        });
        _0x58c955[_0x5f7cd8] = PositionAccountant({
            _0x73d1f0: 0,
            _0xeb890d: 0
        });
        _0x8960bb[_0x67100d] = true;

        _0xc75283 += _0xb136a4;
        emit ProtocolConfigChanged(
            this._0xf3cd00.selector,
            "addPositionManager(address,uint256)",
            abi._0x6c435d(_0x67100d, _0xb136a4)
        );
    }

    function _0x167282(
        uint256 _0x5f7cd8,
        uint256 _0xf2916a,
        bool _0x973bdf
    ) external _0xcfaa5b(POSITION_MANAGER_ROLE) {
        if (_0x5f7cd8 >= _0x8036ae) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x3553f9 = _0x14d30d[_0x5f7cd8];

        if (_0xf2916a < _0x58c955[_0x5f7cd8]._0x73d1f0) {
            revert LiquidityBuffer__InvalidConfiguration();
        }


        _0xc75283 = _0xc75283 - _0x3553f9._0xb136a4 + _0xf2916a;

        _0x3553f9._0xb136a4 = _0xf2916a;
        _0x3553f9._0x973bdf = _0x973bdf;

        emit ProtocolConfigChanged(
            this._0x167282.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0x6c435d(_0x5f7cd8, _0xf2916a, _0x973bdf)
        );
    }

    function _0xa18188(uint256 _0x5f7cd8) external _0xcfaa5b(POSITION_MANAGER_ROLE) {
        if (_0x5f7cd8 >= _0x8036ae) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x3553f9 = _0x14d30d[_0x5f7cd8];
        _0x3553f9._0x973bdf = !_0x3553f9._0x973bdf;

        emit ProtocolConfigChanged(
            this._0xa18188.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0x6c435d(_0x5f7cd8)
        );
    }

    function _0xa27e17(uint256 _0xc668b7) external _0xcfaa5b(DRAWDOWN_MANAGER_ROLE) {
        _0x20c61e = _0xc668b7;

        emit ProtocolConfigChanged(
            this._0xa27e17.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0x6c435d(_0xc668b7)
        );
    }

    function _0x6ee213(uint256 _0xaba0c4) external _0xcfaa5b(POSITION_MANAGER_ROLE) {
        if (_0xaba0c4 >= _0x8036ae) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0x14d30d[_0xaba0c4]._0x973bdf) {
            revert LiquidityBuffer__ManagerInactive();
        }

        if (gasleft() > 0) { _0xa96d0a = _0xaba0c4; }

        emit ProtocolConfigChanged(
            this._0x6ee213.selector,
            "setDefaultManagerId(uint256)",
            abi._0x6c435d(_0xaba0c4)
        );
    }


    function _0xdcc280(uint16 _0x04679e) external _0xcfaa5b(POSITION_MANAGER_ROLE) {
        if (_0x04679e > _0xabad26) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        if (block.timestamp > 0) { _0x632822 = _0x04679e; }
        emit ProtocolConfigChanged(
            this._0xdcc280.selector, "setFeeBasisPoints(uint16)", abi._0x6c435d(_0x04679e)
        );
    }


    function _0xfe6604(address payable _0x0dbacb)
        external
        _0xcfaa5b(POSITION_MANAGER_ROLE)
        _0xedaf24(_0x0dbacb)
    {
        _0xacc1a3 = _0x0dbacb;
        emit ProtocolConfigChanged(this._0xfe6604.selector, "setFeesReceiver(address)", abi._0x6c435d(_0x0dbacb));
    }


    function _0x914f1e(bool _0xfa570b) external _0xcfaa5b(POSITION_MANAGER_ROLE) {
        _0xd3ebd9 = _0xfa570b;
        emit ProtocolConfigChanged(this._0x914f1e.selector, "setShouldExecuteAllocation(bool)", abi._0x6c435d(_0xfa570b));
    }


    function _0xd44ef3() external payable _0xcfaa5b(LIQUIDITY_MANAGER_ROLE) {
        if (_0x2b5bb3._0x205df8()) revert LiquidityBuffer__Paused();
        _0xeefffb(msg.value);
        if (_0xd3ebd9) {
            _0x8b27a5(_0xa96d0a, msg.value);
        }
    }

    function _0xc8317b(uint256 _0x5f7cd8, uint256 _0x869d47) external _0xcfaa5b(LIQUIDITY_MANAGER_ROLE) {
        _0x214e8e(_0x5f7cd8, _0x869d47);
        _0xd4df3e(_0x869d47);
    }

    function _0x445c0b(uint256 _0x5f7cd8, uint256 _0x869d47) external _0xcfaa5b(LIQUIDITY_MANAGER_ROLE) {
        _0x8b27a5(_0x5f7cd8, _0x869d47);
    }

    function _0xfc671f(uint256 _0x5f7cd8, uint256 _0x869d47) external _0xcfaa5b(LIQUIDITY_MANAGER_ROLE) {
        _0x214e8e(_0x5f7cd8, _0x869d47);
    }

    function _0x294578(uint256 _0x869d47) external _0xcfaa5b(LIQUIDITY_MANAGER_ROLE) {
        _0xd4df3e(_0x869d47);
    }

    function _0x509389() external payable _0x2cc7eb {


    }


    function _0x5c73bd(uint256 _0x5f7cd8, uint256 _0x085fb1) external _0xcfaa5b(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x869d47 = _0xe9a489(_0x5f7cd8);
        if (_0x869d47 < _0x085fb1) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x869d47;
    }

    function _0x9ce7e7(uint256 _0x869d47) external _0xcfaa5b(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x869d47) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x7ef6e1(_0x869d47);
        return _0x869d47;
    }

    function _0xb41e32(uint256 _0x5f7cd8, uint256 _0x085fb1) external _0xcfaa5b(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x869d47 = _0xe9a489(_0x5f7cd8);
        if (_0x869d47 < _0x085fb1) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x7ef6e1(_0x869d47);

        return _0x869d47;
    }


    function _0x7ef6e1(uint256 _0x869d47) internal {
        if (_0x2b5bb3._0x205df8()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x869d47 > _0x984a34) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0x984a34 -= _0x869d47;
        uint256 _0x4ea7b1 = Math._0xb1926d(_0x632822, _0x869d47, _0xabad26);
        uint256 _0x4882b9 = _0x869d47 - _0x4ea7b1;
        _0x2a44ce._0x8dd2f0{value: _0x4882b9}();
        _0xbd89b6 += _0x4882b9;
        emit InterestToppedUp(_0x4882b9);

        if (_0x4ea7b1 > 0) {
            Address._0x60122a(_0xacc1a3, _0x4ea7b1);
            _0xb7c7d3 += _0x4ea7b1;
            emit FeesCollected(_0x4ea7b1);
        }
    }

    function _0xe9a489(uint256 _0x5f7cd8) internal returns (uint256) {
        if (_0x2b5bb3._0x205df8()) {
            revert LiquidityBuffer__Paused();
        }

        uint256 _0xe1cf99 = _0xb5a959(_0x5f7cd8);

        if (_0xe1cf99 > 0) {
            PositionManagerConfig memory _0x3553f9 = _0x14d30d[_0x5f7cd8];


            _0x58c955[_0x5f7cd8]._0xeb890d += _0xe1cf99;
            _0x2a1cda += _0xe1cf99;
            _0x984a34 += _0xe1cf99;
            emit InterestClaimed(_0x5f7cd8, _0xe1cf99);


            IPositionManager _0x879612 = IPositionManager(_0x3553f9._0x67100d);
            _0x879612._0x1dcac8(_0xe1cf99);
        } else {
            emit InterestClaimed(_0x5f7cd8, _0xe1cf99);
        }

        return _0xe1cf99;
    }

    function _0x214e8e(uint256 _0x5f7cd8, uint256 _0x869d47) internal {
        if (_0x2b5bb3._0x205df8()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x5f7cd8 >= _0x8036ae) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0x3553f9 = _0x14d30d[_0x5f7cd8];
        if (!_0x3553f9._0x973bdf) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x2767d9 = _0x58c955[_0x5f7cd8];


        if (_0x869d47 > _0x2767d9._0x73d1f0) {
            revert LiquidityBuffer__InsufficientAllocation();
        }


        _0x2767d9._0x73d1f0 -= _0x869d47;
        _0x52a6d5 -= _0x869d47;
        _0x1e3688 += _0x869d47;
        emit ETHWithdrawnFromManager(_0x5f7cd8, _0x869d47);


        IPositionManager _0x879612 = IPositionManager(_0x3553f9._0x67100d);
        _0x879612._0x1dcac8(_0x869d47);
    }

    function _0xd4df3e(uint256 _0x869d47) internal {
        if (_0x2b5bb3._0x205df8()) {
            revert LiquidityBuffer__Paused();
        }


        if (address(_0x2a44ce) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x869d47 > _0x1e3688) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }


        _0xa943ea += _0x869d47;
        _0x1e3688 -= _0x869d47;
        emit ETHReturnedToStaking(_0x869d47);


        _0x2a44ce._0x39e313{value: _0x869d47}();
    }

    function _0x8b27a5(uint256 _0x5f7cd8, uint256 _0x869d47) internal {
        if (_0x2b5bb3._0x205df8()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x869d47 > _0x1e3688) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x5f7cd8 >= _0x8036ae) revert LiquidityBuffer__ManagerNotFound();

        if (address(this).balance < _0x869d47) revert LiquidityBuffer__InsufficientBalance();


        PositionManagerConfig memory _0x3553f9 = _0x14d30d[_0x5f7cd8];
        if (!_0x3553f9._0x973bdf) revert LiquidityBuffer__ManagerInactive();

        PositionAccountant storage _0x2767d9 = _0x58c955[_0x5f7cd8];
        if (_0x2767d9._0x73d1f0 + _0x869d47 > _0x3553f9._0xb136a4) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }


        _0x2767d9._0x73d1f0 += _0x869d47;
        _0x52a6d5 += _0x869d47;
        _0x1e3688 -= _0x869d47;
        emit ETHAllocatedToManager(_0x5f7cd8, _0x869d47);


        IPositionManager _0x879612 = IPositionManager(_0x3553f9._0x67100d);
        _0x879612._0x4d3be0{value: _0x869d47}(0);
    }

    function _0xeefffb(uint256 _0x869d47) internal {
        _0x5d4b63 += _0x869d47;
        _0x1e3688 += _0x869d47;
        emit ETHReceivedFromStaking(_0x869d47);
    }


    modifier _0xedaf24(address _0xc77df4) {
        if (_0xc77df4 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }


    modifier _0xaa17d2() {
        if (msg.sender != address(_0x2a44ce)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x2cc7eb() {
        bool _0xf7b42b = false;


        for (uint256 i = 0; i < _0x8036ae; i++) {
            PositionManagerConfig memory _0x3553f9 = _0x14d30d[i];

            if (msg.sender == _0x3553f9._0x67100d && _0x3553f9._0x973bdf) {
                _0xf7b42b = true;
                break;
            }
        }

        if (!_0xf7b42b) {
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