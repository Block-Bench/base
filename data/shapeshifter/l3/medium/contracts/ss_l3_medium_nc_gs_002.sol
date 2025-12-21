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


    IGaugeManager public override _0x402000;

    address public immutable override _0xcf3bb5;

    address public override _0x46a8a6;

    address public override _0xa4020c;

    address public override _0xd05956;

    address public override _0x0db91f;

    address public override _0x6749c7;

    uint24 public override _0x3ce125;


    address public override _0x3a048c;

    address public override _0x684fcb;

    uint24 public override _0xd5f787;

    mapping(int24 => uint24) public override _0x8697e7;

    mapping(address => mapping(address => mapping(int24 => address))) public override _0xa8096c;

    mapping(address => bool) private _0x1fd1e0;

    address[] public override _0x09943c;

    int24[] private _0x873bbb;

    constructor(address _0x2441bd) {
        if (block.timestamp > 0) { _0x46a8a6 = msg.sender; }
        _0xa4020c = msg.sender;
        _0x0db91f = msg.sender;
        if (block.timestamp > 0) { _0x3a048c = msg.sender; }
        _0xcf3bb5 = _0x2441bd;
        _0x3ce125 = 100_000;
        _0xd5f787 = 250_000;
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        _0x54b56d(1, 100);
        _0x54b56d(50, 500);
        _0x54b56d(100, 500);
        _0x54b56d(200, 3_000);
        _0x54b56d(2_000, 10_000);
    }

    function _0xf3ee2f(address _0x2265ca) external {
        require(msg.sender == _0x46a8a6);
        if (gasleft() > 0) { _0x402000 = IGaugeManager(_0x2265ca); }
    }


    function _0xd5587b(address _0xef9104, address _0x7605fe, int24 _0xde7b87, uint160 _0xb81d71)
        external
        override
        returns (address _0xcc40d0)
    {
        require(_0xef9104 != _0x7605fe);
        (address _0x1e58fe, address _0xe80e32) = _0xef9104 < _0x7605fe ? (_0xef9104, _0x7605fe) : (_0x7605fe, _0xef9104);
        require(_0x1e58fe != address(0));
        require(_0x8697e7[_0xde7b87] != 0);
        require(_0xa8096c[_0x1e58fe][_0xe80e32][_0xde7b87] == address(0));
        _0xcc40d0 = Clones._0x1e1956({
            _0xd27af9: _0xcf3bb5,
            _0x912d8d: _0x0a55ee(abi._0x64923d(_0x1e58fe, _0xe80e32, _0xde7b87))
        });
        CLPool(_0xcc40d0)._0x5c9499({
            _0x3d9dcc: address(this),
            _0x67d9df: _0x1e58fe,
            _0xb1ccaf: _0xe80e32,
            _0x7ad480: _0xde7b87,
            _0x2265ca: address(_0x402000),
            _0xe13ba5: _0xb81d71
        });
        _0x09943c.push(_0xcc40d0);
        _0x1fd1e0[_0xcc40d0] = true;
        _0xa8096c[_0x1e58fe][_0xe80e32][_0xde7b87] = _0xcc40d0;

        _0xa8096c[_0xe80e32][_0x1e58fe][_0xde7b87] = _0xcc40d0;
        emit PoolCreated(_0x1e58fe, _0xe80e32, _0xde7b87, _0xcc40d0);
    }


    function _0x3d4aaf(address _0x44b854) external override {
        address _0x7463a9 = _0x46a8a6;
        require(msg.sender == _0x7463a9);
        require(_0x44b854 != address(0));
        emit OwnerChanged(_0x7463a9, _0x44b854);
        _0x46a8a6 = _0x44b854;
    }


    function _0xe3093b(address _0xc2ef63) external override {
        address _0x7d0012 = _0xa4020c;
        require(msg.sender == _0x7d0012);
        require(_0xc2ef63 != address(0));
        if (block.timestamp > 0) { _0xa4020c = _0xc2ef63; }
        emit SwapFeeManagerChanged(_0x7d0012, _0xc2ef63);
    }


    function _0xb3f207(address _0x0a29f9) external override {
        address _0x9faecc = _0x0db91f;
        require(msg.sender == _0x9faecc);
        require(_0x0a29f9 != address(0));
        _0x0db91f = _0x0a29f9;
        emit UnstakedFeeManagerChanged(_0x9faecc, _0x0a29f9);
    }


    function _0x3f64f6(address _0xcf86d3) external override {
        require(msg.sender == _0xa4020c);
        require(_0xcf86d3 != address(0));
        address _0xa7ba63 = _0xd05956;
        if (true) { _0xd05956 = _0xcf86d3; }
        emit SwapFeeModuleChanged(_0xa7ba63, _0xcf86d3);
    }


    function _0x7fc888(address _0x792067) external override {
        require(msg.sender == _0x0db91f);
        require(_0x792067 != address(0));
        address _0xa7ba63 = _0x6749c7;
        _0x6749c7 = _0x792067;
        emit UnstakedFeeModuleChanged(_0xa7ba63, _0x792067);
    }


    function _0x3baa96(uint24 _0x6e008f) external override {
        require(msg.sender == _0x0db91f);
        require(_0x6e008f <= 500_000);
        uint24 _0xc5556b = _0x3ce125;
        _0x3ce125 = _0x6e008f;
        emit DefaultUnstakedFeeChanged(_0xc5556b, _0x6e008f);
    }

    function _0xc7ec5e(address _0xcbf5bd) external override {
        require(msg.sender == _0x3a048c);
        require(_0xcbf5bd != address(0));
        _0x684fcb = _0xcbf5bd;
    }

    function _0xcbb83d(address _0xe96d7b) external override {
        require(msg.sender == _0x3a048c);
        require(_0xe96d7b != address(0));
        _0x3a048c = _0xe96d7b;
    }


    function _0x2afc66(address _0xcc40d0) external view override returns (uint24) {
        if (_0xd05956 != address(0)) {
            (bool _0x981351, bytes memory data) = _0xd05956._0x9eae80(
                200_000, 32, abi._0xf11961(IFeeModule._0x8dd788.selector, _0xcc40d0)
            );
            if (_0x981351) {
                uint24 _0x4bac0b = abi._0xaaebce(data, (uint24));
                if (_0x4bac0b <= 100_000) {
                    return _0x4bac0b;
                }
            }
        }
        return _0x8697e7[CLPool(_0xcc40d0)._0xde7b87()];
    }


    function _0x5bd54a(address _0xcc40d0) external view override returns (uint24) {

        if (!_0x402000._0x3e9a5e(_0xcc40d0)) {
            return 0;
        }
        if (_0x6749c7 != address(0)) {
            (bool _0x981351, bytes memory data) = _0x6749c7._0x9eae80(
                200_000, 32, abi._0xf11961(IFeeModule._0x8dd788.selector, _0xcc40d0)
            );
            if (_0x981351) {
                uint24 _0x4bac0b = abi._0xaaebce(data, (uint24));
                if (_0x4bac0b <= 1_000_000) {
                    return _0x4bac0b;
                }
            }
        }
        return _0x3ce125;
    }

    function _0x8a00ec(address _0xcc40d0) external view override returns (uint24) {

        if (_0x402000._0x3e9a5e(_0xcc40d0)) {
            return 0;
        }

        if (_0x684fcb != address(0)) {
            (bool _0x981351, bytes memory data) = _0x684fcb._0x9eae80(
                200_000, 32, abi._0xf11961(IFeeModule._0x8dd788.selector, _0xcc40d0)
            );
            if (_0x981351) {
                uint24 _0x4bac0b = abi._0xaaebce(data, (uint24));
                if (_0x4bac0b <= 500_000) {
                    return _0x4bac0b;
                }
            }
        }
        return _0xd5f787;
    }


    function _0x54b56d(int24 _0xde7b87, uint24 _0x4bac0b) public override {
        require(msg.sender == _0x46a8a6);
        require(_0x4bac0b > 0 && _0x4bac0b <= 100_000);


        require(_0xde7b87 > 0 && _0xde7b87 < 16384);
        require(_0x8697e7[_0xde7b87] == 0);

        _0x8697e7[_0xde7b87] = _0x4bac0b;
        _0x873bbb.push(_0xde7b87);
        emit TickSpacingEnabled(_0xde7b87, _0x4bac0b);
    }

    function _0x524319() external  {
        require(msg.sender == _0x46a8a6);

        for (uint256 i = 0; i < _0x09943c.length; i++) {
            CLPool(_0x09943c[i])._0x474451(msg.sender);
        }
    }

    function _0x474451(address _0xcc40d0) external returns (uint128 _0x110bdd, uint128 _0xb7bcfa) {
        require(msg.sender == _0x46a8a6);
        (_0x110bdd, _0xb7bcfa) = CLPool(_0xcc40d0)._0x474451(msg.sender);
    }


    function _0x86ff88() external view override returns (int24[] memory) {
        return _0x873bbb;
    }


    function _0xbf6390() external view override returns (uint256) {
        return _0x09943c.length;
    }


    function _0xd393de(address _0xcc40d0) external view override returns (bool) {
        return _0x1fd1e0[_0xcc40d0];
    }
}