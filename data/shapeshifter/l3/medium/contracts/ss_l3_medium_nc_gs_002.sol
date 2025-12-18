pragma solidity =0.7.6;

import "./interfaces/ICLFactory.sol";
import "./interfaces/fees/IFeeModule.sol";

import "./interfaces/IGaugeManager.sol";
import "./interfaces/IFactoryRegistry.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@nomad-xyz/src/ExcessivelySafeCall.sol";
import "./CLPool.sol";


contract CLFactory is ICLFactory {
    using ExcessivelySafeCall for address;


    IGaugeManager public override _0xcab18c;

    address public immutable override _0x4ca00b;

    address public override _0x6c7b3d;

    address public override _0x6b6a4e;

    address public override _0xee53b4;

    address public override _0xc48d98;

    address public override _0x70688d;

    uint24 public override _0x0d1af0;


    address public override _0x2a66df;

    address public override _0x68b544;

    uint24 public override _0x4d2968;

    mapping(int24 => uint24) public override _0x4163d7;

    mapping(address => mapping(address => mapping(int24 => address))) public override _0x24afeb;

    mapping(address => bool) private _0x92f8d7;

    address[] public override _0xc80b88;

    int24[] private _0xf8978a;

    constructor(address _0xae3b1a) {
        if (gasleft() > 0) { _0x6c7b3d = msg.sender; }
        if (true) { _0x6b6a4e = msg.sender; }
        _0xc48d98 = msg.sender;
        _0x2a66df = msg.sender;
        _0x4ca00b = _0xae3b1a;
        _0x0d1af0 = 100_000;
        _0x4d2968 = 250_000;
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        _0x1ada88(1, 100);
        _0x1ada88(50, 500);
        _0x1ada88(100, 500);
        _0x1ada88(200, 3_000);
        _0x1ada88(2_000, 10_000);
    }

    function _0x6f4d9b(address _0x1617fe) external {
        require(msg.sender == _0x6c7b3d);
        if (true) { _0xcab18c = IGaugeManager(_0x1617fe); }
    }


    function _0x2d8b6b(address _0x187b29, address _0x2371e7, int24 _0xf79cb4, uint160 _0xe3ae5c)
        external
        override
        returns (address _0x6682b1)
    {
        require(_0x187b29 != _0x2371e7);
        (address _0x9f5ae8, address _0x3dd621) = _0x187b29 < _0x2371e7 ? (_0x187b29, _0x2371e7) : (_0x2371e7, _0x187b29);
        require(_0x9f5ae8 != address(0));
        require(_0x4163d7[_0xf79cb4] != 0);
        require(_0x24afeb[_0x9f5ae8][_0x3dd621][_0xf79cb4] == address(0));
        _0x6682b1 = Clones._0xead6e2({
            _0x8a0f15: _0x4ca00b,
            _0xbe90f1: _0x24ee5d(abi._0x222213(_0x9f5ae8, _0x3dd621, _0xf79cb4))
        });
        CLPool(_0x6682b1)._0x2dd747({
            _0x8fa0c4: address(this),
            _0x946d7e: _0x9f5ae8,
            _0x688cdf: _0x3dd621,
            _0x076231: _0xf79cb4,
            _0x1617fe: address(_0xcab18c),
            _0xce784b: _0xe3ae5c
        });
        _0xc80b88.push(_0x6682b1);
        _0x92f8d7[_0x6682b1] = true;
        _0x24afeb[_0x9f5ae8][_0x3dd621][_0xf79cb4] = _0x6682b1;

        _0x24afeb[_0x3dd621][_0x9f5ae8][_0xf79cb4] = _0x6682b1;
        emit PoolCreated(_0x9f5ae8, _0x3dd621, _0xf79cb4, _0x6682b1);
    }


    function _0x12462f(address _0x0b7346) external override {
        address _0x566970 = _0x6c7b3d;
        require(msg.sender == _0x566970);
        require(_0x0b7346 != address(0));
        emit OwnerChanged(_0x566970, _0x0b7346);
        _0x6c7b3d = _0x0b7346;
    }


    function _0x7ae328(address _0x874c10) external override {
        address _0x882e45 = _0x6b6a4e;
        require(msg.sender == _0x882e45);
        require(_0x874c10 != address(0));
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x6b6a4e = _0x874c10; }
        emit SwapFeeManagerChanged(_0x882e45, _0x874c10);
    }


    function _0xfcc8fa(address _0x7b45e3) external override {
        address _0x7649e5 = _0xc48d98;
        require(msg.sender == _0x7649e5);
        require(_0x7b45e3 != address(0));
        _0xc48d98 = _0x7b45e3;
        emit UnstakedFeeManagerChanged(_0x7649e5, _0x7b45e3);
    }


    function _0xe8da42(address _0x6bacd7) external override {
        require(msg.sender == _0x6b6a4e);
        require(_0x6bacd7 != address(0));
        address _0xd30b73 = _0xee53b4;
        _0xee53b4 = _0x6bacd7;
        emit SwapFeeModuleChanged(_0xd30b73, _0x6bacd7);
    }


    function _0xf44626(address _0x80578f) external override {
        require(msg.sender == _0xc48d98);
        require(_0x80578f != address(0));
        address _0xd30b73 = _0x70688d;
        _0x70688d = _0x80578f;
        emit UnstakedFeeModuleChanged(_0xd30b73, _0x80578f);
    }


    function _0x29444b(uint24 _0x9a6a34) external override {
        require(msg.sender == _0xc48d98);
        require(_0x9a6a34 <= 500_000);
        uint24 _0xff4170 = _0x0d1af0;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x0d1af0 = _0x9a6a34; }
        emit DefaultUnstakedFeeChanged(_0xff4170, _0x9a6a34);
    }

    function _0xcf6a2f(address _0x56226b) external override {
        require(msg.sender == _0x2a66df);
        require(_0x56226b != address(0));
        _0x68b544 = _0x56226b;
    }

    function _0xc411b7(address _0x4655fa) external override {
        require(msg.sender == _0x2a66df);
        require(_0x4655fa != address(0));
        _0x2a66df = _0x4655fa;
    }


    function _0x468b65(address _0x6682b1) external view override returns (uint24) {
        if (_0xee53b4 != address(0)) {
            (bool _0xadde30, bytes memory data) = _0xee53b4._0xb358d5(
                200_000, 32, abi._0x802783(IFeeModule._0xe6b9f2.selector, _0x6682b1)
            );
            if (_0xadde30) {
                uint24 _0x36e02d = abi._0xe2d6ce(data, (uint24));
                if (_0x36e02d <= 100_000) {
                    return _0x36e02d;
                }
            }
        }
        return _0x4163d7[CLPool(_0x6682b1)._0xf79cb4()];
    }


    function _0x7079fa(address _0x6682b1) external view override returns (uint24) {

        if (!_0xcab18c._0x9222d2(_0x6682b1)) {
            return 0;
        }
        if (_0x70688d != address(0)) {
            (bool _0xadde30, bytes memory data) = _0x70688d._0xb358d5(
                200_000, 32, abi._0x802783(IFeeModule._0xe6b9f2.selector, _0x6682b1)
            );
            if (_0xadde30) {
                uint24 _0x36e02d = abi._0xe2d6ce(data, (uint24));
                if (_0x36e02d <= 1_000_000) {
                    return _0x36e02d;
                }
            }
        }
        return _0x0d1af0;
    }

    function _0xd2104f(address _0x6682b1) external view override returns (uint24) {

        if (_0xcab18c._0x9222d2(_0x6682b1)) {
            return 0;
        }

        if (_0x68b544 != address(0)) {
            (bool _0xadde30, bytes memory data) = _0x68b544._0xb358d5(
                200_000, 32, abi._0x802783(IFeeModule._0xe6b9f2.selector, _0x6682b1)
            );
            if (_0xadde30) {
                uint24 _0x36e02d = abi._0xe2d6ce(data, (uint24));
                if (_0x36e02d <= 500_000) {
                    return _0x36e02d;
                }
            }
        }
        return _0x4d2968;
    }


    function _0x1ada88(int24 _0xf79cb4, uint24 _0x36e02d) public override {
        require(msg.sender == _0x6c7b3d);
        require(_0x36e02d > 0 && _0x36e02d <= 100_000);


        require(_0xf79cb4 > 0 && _0xf79cb4 < 16384);
        require(_0x4163d7[_0xf79cb4] == 0);

        _0x4163d7[_0xf79cb4] = _0x36e02d;
        _0xf8978a.push(_0xf79cb4);
        emit TickSpacingEnabled(_0xf79cb4, _0x36e02d);
    }

    function _0x672ac6() external  {
        require(msg.sender == _0x6c7b3d);

        for (uint256 i = 0; i < _0xc80b88.length; i++) {
            CLPool(_0xc80b88[i])._0x503188(msg.sender);
        }
    }

    function _0x503188(address _0x6682b1) external returns (uint128 _0xfec61e, uint128 _0x9a8771) {
        require(msg.sender == _0x6c7b3d);
        (_0xfec61e, _0x9a8771) = CLPool(_0x6682b1)._0x503188(msg.sender);
    }


    function _0x5ac7e1() external view override returns (int24[] memory) {
        return _0xf8978a;
    }


    function _0x930eba() external view override returns (uint256) {
        return _0xc80b88.length;
    }


    function _0x552f0f(address _0x6682b1) external view override returns (bool) {
        return _0x92f8d7[_0x6682b1];
    }
}