pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
 import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import '../interfaces/IGaugeFactoryCL.sol';
import '../interfaces/IGaugeManager.sol';
import './interface/ICLPool.sol';
import './interface/ICLFactory.sol';
import './interface/INonfungiblePositionManager.sol';
import '../interfaces/IBribe.sol';
import '../interfaces/IRHYBR.sol';
import {HybraTimeLibrary} from "../libraries/HybraTimeLibrary.sol";
import {FullMath} from "./libraries/FullMath.sol";
import {FixedPoint128} from "./libraries/FixedPoint128.sol";
import '../interfaces/IRHYBR.sol';

contract GaugeCL is ReentrancyGuard, Ownable, IERC721Receiver {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeCast for uint128;
    IERC20 public immutable _0x5deb8a;
    address public immutable _0x12aa4e;
    address public VE;
    address public DISTRIBUTION;
    address public _0xdebf24;
    address public _0x70d304;

    uint256 public DURATION;
    uint256 internal _0x4d9235;
    uint256 public _0x485476;
    ICLPool public _0x86ac98;
    address public _0x354108;
    INonfungiblePositionManager public _0x323db7;

    bool public _0xd52d96;
    bool public immutable _0xdb57b0;
    address immutable _0x835570;

    mapping(uint256 => uint256) public  _0xb1a810;
    mapping(address => EnumerableSet.UintSet) internal _0x19b6ab;
    mapping(uint256 => uint256) public  _0x2825a7;

    mapping(uint256 => uint256) public  _0xe38dda;

    mapping(uint256 => uint256) public  _0xebeeaf;

    event RewardAdded(uint256 _0x3d1655);
    event Deposit(address indexed _0x838b2c, uint256 _0x98c271);
    event Withdraw(address indexed _0x838b2c, uint256 _0x98c271);
    event Harvest(address indexed _0x838b2c, uint256 _0x3d1655);
    event ClaimFees(address indexed from, uint256 _0x629e04, uint256 _0xa9afe7);
    event EmergencyActivated(address indexed _0xded2f1, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0xded2f1, uint256 timestamp);

    constructor(address _0x8e5f9f, address _0x4899d9, address _0xe2180c, address _0x4cac60, address _0x3eea07, address _0x733d3d,
        address _0x40f901, bool _0xdf7f38, address _0x1c0840,  address _0x59abcc) {
        _0x835570 = _0x59abcc;
        _0x5deb8a = IERC20(_0x8e5f9f);
        _0x12aa4e = _0x4899d9;
        VE = _0xe2180c;
        _0x354108 = _0x4cac60;
        _0x86ac98 = ICLPool(_0x4cac60);
        DISTRIBUTION = _0x3eea07;
        DURATION = HybraTimeLibrary.WEEK;

        _0xdebf24 = _0x733d3d;
        _0x70d304 = _0x40f901;
        _0xdb57b0 = _0xdf7f38;
        _0x323db7 = INonfungiblePositionManager(_0x1c0840);
        _0xd52d96 = false;
    }

    modifier _0xf1a89b() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0xc92217() {
        require(_0xd52d96 == false, "emergency");
        _;
    }

    function _0xe7491d(uint256 _0x443b5c, int24 _0xaa9a5e, int24 _0x6e38e1) internal {
        if (_0xebeeaf[_0x443b5c] == block.timestamp) return;
        _0x86ac98._0xfd5cf8();
        _0xebeeaf[_0x443b5c] = block.timestamp;
        _0xe38dda[_0x443b5c] += _0x31c153(_0x443b5c);
        _0x2825a7[_0x443b5c] = _0x86ac98._0x6b7231(_0xaa9a5e, _0x6e38e1, 0);
    }

    function _0x31b75a() external _0x4ffb3c {
        require(_0xd52d96 == false, "emergency");
        _0xd52d96 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0xf1baf5() external _0x4ffb3c {

        require(_0xd52d96 == true,"emergency");

        _0xd52d96 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0x506a34(uint256 _0x443b5c) external view returns (uint256) {
        (,,,,,,,uint128 _0x9aff2b,,,,) = _0x323db7._0x95f0a5(_0x443b5c);
        return _0x9aff2b;
    }

    function _0x446af1(address _0x159d78, address _0x2b27e8, int24 _0x86f355) internal view returns (address) {
        return ICLFactory(_0x323db7._0x835570())._0xb90215(_0x159d78, _0x2b27e8, _0x86f355);
    }

    function _0x87715b(uint256 _0x443b5c) external view returns (uint256 _0x3d1655) {
        require(_0x19b6ab[msg.sender]._0x5d9200(_0x443b5c), "NA");

        uint256 _0x3d1655 = _0x31c153(_0x443b5c);
        return (_0x3d1655);
    }

       function _0x31c153(uint256 _0x443b5c) internal view returns (uint256) {
        uint256 _0x02b6f8 = _0x86ac98._0x02b6f8();

        uint256 _0xe709d7 = block.timestamp - _0x02b6f8;

        uint256 _0x9a870f = _0x86ac98._0x9a870f();
        uint256 _0x29d7a5 = _0x86ac98._0x29d7a5();

        if (_0xe709d7 != 0 && _0x29d7a5 > 0 && _0x86ac98._0x2ceef0() > 0) {
            uint256 _0x3d1655 = _0x485476 * _0xe709d7;
            if (_0x3d1655 > _0x29d7a5) _0x3d1655 = _0x29d7a5;

            _0x9a870f += FullMath._0xd9ee89(_0x3d1655, FixedPoint128.Q128, _0x86ac98._0x2ceef0());
        }

        (,,,,, int24 _0xaa9a5e, int24 _0x6e38e1, uint128 _0x9aff2b,,,,) = _0x323db7._0x95f0a5(_0x443b5c);

        uint256 _0x78e302 = _0x2825a7[_0x443b5c];
        uint256 _0x24758b = _0x86ac98._0x6b7231(_0xaa9a5e, _0x6e38e1, _0x9a870f);

        uint256 _0xe4ee0e =
            FullMath._0xd9ee89(_0x24758b - _0x78e302, _0x9aff2b, FixedPoint128.Q128);
        return _0xe4ee0e;
    }

    function _0x1344e8(uint256 _0x443b5c) external _0xd10f3c _0xc92217 {

         (,,address _0x159d78, address _0x2b27e8, int24 _0x86f355, int24 _0xaa9a5e, int24 _0x6e38e1, uint128 _0x9aff2b,,,,) =
            _0x323db7._0x95f0a5(_0x443b5c);

        require(_0x9aff2b > 0, "Gauge: zero liquidity");

        address _0x54aed3 = _0x446af1(_0x159d78, _0x2b27e8, _0x86f355);

        require(_0x54aed3 == _0x354108, "Pool mismatch: Position not for this gauge pool");

        _0x323db7._0x3094ff(INonfungiblePositionManager.CollectParams({
                _0x443b5c: _0x443b5c,
                _0xd94e73: msg.sender,
                _0xca4b45: type(uint128)._0x22d1f6,
                _0x7c9fcf: type(uint128)._0x22d1f6
            }));

        _0x323db7._0x1c176e(msg.sender, address(this), _0x443b5c);

        _0x86ac98._0x6e667c(int128(_0x9aff2b), _0xaa9a5e, _0x6e38e1, true);

        uint256 _0x7ee89d = _0x86ac98._0x6b7231(_0xaa9a5e, _0x6e38e1, 0);
        _0x2825a7[_0x443b5c] = _0x7ee89d;
        _0xebeeaf[_0x443b5c] = block.timestamp;

        _0x19b6ab[msg.sender]._0xed8a00(_0x443b5c);

        emit Deposit(msg.sender, _0x443b5c);
    }

    function _0x3678e5(uint256 _0x443b5c, uint8 _0xc025a0) external _0xd10f3c _0xc92217 {
           require(_0x19b6ab[msg.sender]._0x5d9200(_0x443b5c), "NA");


        _0x323db7._0x3094ff(
            INonfungiblePositionManager.CollectParams({
                _0x443b5c: _0x443b5c,
                _0xd94e73: msg.sender,
                _0xca4b45: type(uint128)._0x22d1f6,
                _0x7c9fcf: type(uint128)._0x22d1f6
            })
        );

        (,,,,, int24 _0xaa9a5e, int24 _0x6e38e1, uint128 _0x78f9ab,,,,) = _0x323db7._0x95f0a5(_0x443b5c);
        _0xaa9c33(_0xaa9a5e, _0x6e38e1, _0x443b5c, msg.sender, _0xc025a0);


        if (_0x78f9ab != 0) {
            _0x86ac98._0x6e667c(-int128(_0x78f9ab), _0xaa9a5e, _0x6e38e1, true);
        }

        _0x19b6ab[msg.sender]._0x696b98(_0x443b5c);
        _0x323db7._0x1c176e(address(this), msg.sender, _0x443b5c);

        emit Withdraw(msg.sender, _0x443b5c);
    }

    function _0x6ebaf7(uint256 _0x443b5c, address _0x19f0c6,uint8 _0xc025a0 ) public _0xd10f3c _0xf1a89b {

        require(_0x19b6ab[_0x19f0c6]._0x5d9200(_0x443b5c), "NA");

        (,,,,, int24 _0xaa9a5e, int24 _0x6e38e1,,,,,) = _0x323db7._0x95f0a5(_0x443b5c);
        _0xaa9c33(_0xaa9a5e, _0x6e38e1, _0x443b5c, _0x19f0c6, _0xc025a0);
    }

    function _0xaa9c33(int24 _0xaa9a5e, int24 _0x6e38e1, uint256 _0x443b5c,address _0x19f0c6, uint8 _0xc025a0) internal {
        _0xe7491d(_0x443b5c, _0xaa9a5e, _0x6e38e1);
        uint256 _0xb24aae = _0xe38dda[_0x443b5c];
        if(_0xb24aae > 0){
            delete _0xe38dda[_0x443b5c];
            _0x5deb8a._0xa348f4(_0x12aa4e, _0xb24aae);
            IRHYBR(_0x12aa4e)._0x284e78(_0xb24aae);
            IRHYBR(_0x12aa4e)._0x9f6e0a(_0xb24aae, _0xc025a0, _0x19f0c6);
        }
        emit Harvest(msg.sender, _0xb24aae);
    }

    function _0x13e31c(address _0x01636d, uint256 _0xb24aae) external _0xd10f3c
        _0xc92217 _0xf1a89b returns (uint256 _0xd1e339) {
        require(_0x01636d == address(_0x5deb8a), "Invalid reward token");


        _0x86ac98._0xfd5cf8();


        uint256 _0x68ee92 = HybraTimeLibrary._0x402445(block.timestamp) - block.timestamp;
        uint256 _0x4facd7 = block.timestamp + _0x68ee92;


        uint256 _0x63fefa = _0xb24aae + _0x86ac98._0x02b5e9();


        if (block.timestamp >= _0x4d9235) {

            _0x485476 = _0xb24aae / _0x68ee92;
            _0x86ac98._0x02b208({
                _0x485476: _0x485476,
                _0x29d7a5: _0x63fefa,
                _0xd15aa9: _0x4facd7
            });
        } else {

            uint256 _0x847c25 = _0x68ee92 * _0x485476;
            _0x485476 = (_0xb24aae + _0x847c25) / _0x68ee92;
            _0x86ac98._0x02b208({
                _0x485476: _0x485476,
                _0x29d7a5: _0x63fefa + _0x847c25,
                _0xd15aa9: _0x4facd7
            });
        }


        _0xb1a810[HybraTimeLibrary._0x64ae38(block.timestamp)] = _0x485476;


        _0x5deb8a._0x1c176e(DISTRIBUTION, address(this), _0xb24aae);


        uint256 _0xbe6103 = _0x5deb8a._0x506a34(address(this));
        require(_0x485476 <= _0xbe6103 / _0x68ee92, "Insufficient balance for reward rate");


        _0x4d9235 = _0x4facd7;
        _0xd1e339 = _0x485476;

        emit RewardAdded(_0xb24aae);
    }

    function _0xa192b4() external view returns (uint256 _0x159d78, uint256 _0x2b27e8){

        (_0x159d78, _0x2b27e8) = _0x86ac98._0xaac0c7();

    }

    function _0x0b3520() external _0xd10f3c returns (uint256 _0x629e04, uint256 _0xa9afe7) {
        return _0x3e3672();
    }

    function _0x3e3672() internal returns (uint256 _0x629e04, uint256 _0xa9afe7) {
        if (!_0xdb57b0) {
            return (0, 0);
        }

        _0x86ac98._0xd8fe51();

        address _0x00561b = _0x86ac98._0x159d78();
        address _0x547b2e = _0x86ac98._0x2b27e8();

        _0x629e04 = IERC20(_0x00561b)._0x506a34(address(this));
        _0xa9afe7 = IERC20(_0x547b2e)._0x506a34(address(this));

        if (_0x629e04 > 0 || _0xa9afe7 > 0) {

            uint256 _0xe4531b = _0x629e04;
            uint256 _0xe6ddd4 = _0xa9afe7;

            if (_0xe4531b  > 0) {
                IERC20(_0x00561b)._0xa348f4(_0xdebf24, 0);
                IERC20(_0x00561b)._0xa348f4(_0xdebf24, _0xe4531b);
                IBribe(_0xdebf24)._0x13e31c(_0x00561b, _0xe4531b);
            }
            if (_0xe6ddd4  > 0) {
                IERC20(_0x547b2e)._0xa348f4(_0xdebf24, 0);
                IERC20(_0x547b2e)._0xa348f4(_0xdebf24, _0xe6ddd4);
                IBribe(_0xdebf24)._0x13e31c(_0x547b2e, _0xe6ddd4);
            }
            emit ClaimFees(msg.sender, _0x629e04, _0xa9afe7);
        }
    }


    function _0x4a9613() external view returns (uint256) {
        return _0x485476 * DURATION;
    }


    function _0x4ac419(address _0xf7ee81) external _0x4ffb3c {
        require(_0xf7ee81 >= address(0), "zero");
        _0xdebf24 = _0xf7ee81;
    }

    function _0x776cb2(address _0x01636d,address _0x847eba,uint256 value) internal {
        require(_0x01636d.code.length > 0);
        (bool _0x45eb14, bytes memory data) = _0x01636d.call(abi._0x61b35e(IERC20.transfer.selector, _0x847eba, value));
        require(_0x45eb14 && (data.length == 0 || abi._0x7820ef(data, (bool))));
    }


    function _0xbbde4b(
        address _0xffe889,
        address from,
        uint256 _0x443b5c,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0xbbde4b.selector;
    }

}