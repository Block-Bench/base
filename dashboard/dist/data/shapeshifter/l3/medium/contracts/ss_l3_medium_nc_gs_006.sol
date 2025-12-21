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
    IERC20 public immutable _0x244150;
    address public immutable _0x00fe1f;
    address public VE;
    address public DISTRIBUTION;
    address public _0x1ccf76;
    address public _0x565115;

    uint256 public DURATION;
    uint256 internal _0x2b7972;
    uint256 public _0xf3cc85;
    ICLPool public _0xfb15a1;
    address public _0x027114;
    INonfungiblePositionManager public _0x15dd58;

    bool public _0x1671d0;
    bool public immutable _0xda9318;
    address immutable _0xdbf42a;

    mapping(uint256 => uint256) public  _0x0330e3;
    mapping(address => EnumerableSet.UintSet) internal _0x3a1211;
    mapping(uint256 => uint256) public  _0xcc0985;

    mapping(uint256 => uint256) public  _0x269a7d;

    mapping(uint256 => uint256) public  _0x6d8d2b;

    event RewardAdded(uint256 _0x8ed574);
    event Deposit(address indexed _0xcd8389, uint256 _0xc26ab8);
    event Withdraw(address indexed _0xcd8389, uint256 _0xc26ab8);
    event Harvest(address indexed _0xcd8389, uint256 _0x8ed574);
    event ClaimFees(address indexed from, uint256 _0xd36f55, uint256 _0xdc53c7);
    event EmergencyActivated(address indexed _0x035773, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x035773, uint256 timestamp);

    constructor(address _0x8e1be9, address _0xe4f129, address _0xdc6622, address _0x4d3286, address _0x6872ac, address _0x5cdfcb,
        address _0x64e21e, bool _0x8e500d, address _0x87f187,  address _0x1cd298) {
        _0xdbf42a = _0x1cd298;
        _0x244150 = IERC20(_0x8e1be9);
        _0x00fe1f = _0xe4f129;
        VE = _0xdc6622;
        _0x027114 = _0x4d3286;
        _0xfb15a1 = ICLPool(_0x4d3286);
        DISTRIBUTION = _0x6872ac;
        DURATION = HybraTimeLibrary.WEEK;

        _0x1ccf76 = _0x5cdfcb;
        _0x565115 = _0x64e21e;
        _0xda9318 = _0x8e500d;
        _0x15dd58 = INonfungiblePositionManager(_0x87f187);
        _0x1671d0 = false;
    }

    modifier _0x42388f() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0x745af9() {
        require(_0x1671d0 == false, "emergency");
        _;
    }

    function _0xd46d20(uint256 _0x73147f, int24 _0x9aef0b, int24 _0xe58492) internal {
        if (_0x6d8d2b[_0x73147f] == block.timestamp) return;
        _0xfb15a1._0xe6465f();
        _0x6d8d2b[_0x73147f] = block.timestamp;
        _0x269a7d[_0x73147f] += _0x13da62(_0x73147f);
        _0xcc0985[_0x73147f] = _0xfb15a1._0xc7272e(_0x9aef0b, _0xe58492, 0);
    }

    function _0xc26e1d() external _0x198972 {
        require(_0x1671d0 == false, "emergency");
        if (block.timestamp > 0) { _0x1671d0 = true; }
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0xc8e8b7() external _0x198972 {

        require(_0x1671d0 == true,"emergency");

        _0x1671d0 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0x54796b(uint256 _0x73147f) external view returns (uint256) {
        (,,,,,,,uint128 _0x9dfe66,,,,) = _0x15dd58._0xc2e078(_0x73147f);
        return _0x9dfe66;
    }

    function _0x634454(address _0xc448c0, address _0xb573c2, int24 _0xaca909) internal view returns (address) {
        return ICLFactory(_0x15dd58._0xdbf42a())._0xcc22c7(_0xc448c0, _0xb573c2, _0xaca909);
    }

    function _0x2c559e(uint256 _0x73147f) external view returns (uint256 _0x8ed574) {
        require(_0x3a1211[msg.sender]._0x3ba486(_0x73147f), "NA");

        uint256 _0x8ed574 = _0x13da62(_0x73147f);
        return (_0x8ed574);
    }

       function _0x13da62(uint256 _0x73147f) internal view returns (uint256) {
        uint256 _0x2894ab = _0xfb15a1._0x2894ab();

        uint256 _0x07b1c5 = block.timestamp - _0x2894ab;

        uint256 _0xd1bcc9 = _0xfb15a1._0xd1bcc9();
        uint256 _0x2a68c1 = _0xfb15a1._0x2a68c1();

        if (_0x07b1c5 != 0 && _0x2a68c1 > 0 && _0xfb15a1._0x946176() > 0) {
            uint256 _0x8ed574 = _0xf3cc85 * _0x07b1c5;
            if (_0x8ed574 > _0x2a68c1) _0x8ed574 = _0x2a68c1;

            _0xd1bcc9 += FullMath._0x522d54(_0x8ed574, FixedPoint128.Q128, _0xfb15a1._0x946176());
        }

        (,,,,, int24 _0x9aef0b, int24 _0xe58492, uint128 _0x9dfe66,,,,) = _0x15dd58._0xc2e078(_0x73147f);

        uint256 _0x59d8df = _0xcc0985[_0x73147f];
        uint256 _0xeefdfa = _0xfb15a1._0xc7272e(_0x9aef0b, _0xe58492, _0xd1bcc9);

        uint256 _0x714faf =
            FullMath._0x522d54(_0xeefdfa - _0x59d8df, _0x9dfe66, FixedPoint128.Q128);
        return _0x714faf;
    }

    function _0xd03d98(uint256 _0x73147f) external _0x7b257c _0x745af9 {

         (,,address _0xc448c0, address _0xb573c2, int24 _0xaca909, int24 _0x9aef0b, int24 _0xe58492, uint128 _0x9dfe66,,,,) =
            _0x15dd58._0xc2e078(_0x73147f);

        require(_0x9dfe66 > 0, "Gauge: zero liquidity");

        address _0x496621 = _0x634454(_0xc448c0, _0xb573c2, _0xaca909);

        require(_0x496621 == _0x027114, "Pool mismatch: Position not for this gauge pool");

        _0x15dd58._0x79b44a(INonfungiblePositionManager.CollectParams({
                _0x73147f: _0x73147f,
                _0xa5b89e: msg.sender,
                _0xb5b1a1: type(uint128)._0x1611bf,
                _0x6c29ba: type(uint128)._0x1611bf
            }));

        _0x15dd58._0x734472(msg.sender, address(this), _0x73147f);

        _0xfb15a1._0x5fb416(int128(_0x9dfe66), _0x9aef0b, _0xe58492, true);

        uint256 _0x3d9fd6 = _0xfb15a1._0xc7272e(_0x9aef0b, _0xe58492, 0);
        _0xcc0985[_0x73147f] = _0x3d9fd6;
        _0x6d8d2b[_0x73147f] = block.timestamp;

        _0x3a1211[msg.sender]._0xfc8e0e(_0x73147f);

        emit Deposit(msg.sender, _0x73147f);
    }

    function _0xa12f9e(uint256 _0x73147f, uint8 _0xa6aa53) external _0x7b257c _0x745af9 {
           require(_0x3a1211[msg.sender]._0x3ba486(_0x73147f), "NA");


        _0x15dd58._0x79b44a(
            INonfungiblePositionManager.CollectParams({
                _0x73147f: _0x73147f,
                _0xa5b89e: msg.sender,
                _0xb5b1a1: type(uint128)._0x1611bf,
                _0x6c29ba: type(uint128)._0x1611bf
            })
        );

        (,,,,, int24 _0x9aef0b, int24 _0xe58492, uint128 _0x717eee,,,,) = _0x15dd58._0xc2e078(_0x73147f);
        _0xecbaa7(_0x9aef0b, _0xe58492, _0x73147f, msg.sender, _0xa6aa53);


        if (_0x717eee != 0) {
            _0xfb15a1._0x5fb416(-int128(_0x717eee), _0x9aef0b, _0xe58492, true);
        }

        _0x3a1211[msg.sender]._0x983753(_0x73147f);
        _0x15dd58._0x734472(address(this), msg.sender, _0x73147f);

        emit Withdraw(msg.sender, _0x73147f);
    }

    function _0xd3064c(uint256 _0x73147f, address _0x97b5ae,uint8 _0xa6aa53 ) public _0x7b257c _0x42388f {

        require(_0x3a1211[_0x97b5ae]._0x3ba486(_0x73147f), "NA");

        (,,,,, int24 _0x9aef0b, int24 _0xe58492,,,,,) = _0x15dd58._0xc2e078(_0x73147f);
        _0xecbaa7(_0x9aef0b, _0xe58492, _0x73147f, _0x97b5ae, _0xa6aa53);
    }

    function _0xecbaa7(int24 _0x9aef0b, int24 _0xe58492, uint256 _0x73147f,address _0x97b5ae, uint8 _0xa6aa53) internal {
        _0xd46d20(_0x73147f, _0x9aef0b, _0xe58492);
        uint256 _0x3398e5 = _0x269a7d[_0x73147f];
        if(_0x3398e5 > 0){
            delete _0x269a7d[_0x73147f];
            _0x244150._0xdf7802(_0x00fe1f, _0x3398e5);
            IRHYBR(_0x00fe1f)._0x8f5117(_0x3398e5);
            IRHYBR(_0x00fe1f)._0xb985be(_0x3398e5, _0xa6aa53, _0x97b5ae);
        }
        emit Harvest(msg.sender, _0x3398e5);
    }

    function _0xb76167(address _0x0cad45, uint256 _0x3398e5) external _0x7b257c
        _0x745af9 _0x42388f returns (uint256 _0x829229) {
        require(_0x0cad45 == address(_0x244150), "Invalid reward token");


        _0xfb15a1._0xe6465f();


        uint256 _0x33f3b9 = HybraTimeLibrary._0x9f22fd(block.timestamp) - block.timestamp;
        uint256 _0x2ad975 = block.timestamp + _0x33f3b9;


        uint256 _0xbe2feb = _0x3398e5 + _0xfb15a1._0x1b27c2();


        if (block.timestamp >= _0x2b7972) {

            _0xf3cc85 = _0x3398e5 / _0x33f3b9;
            _0xfb15a1._0xd8d150({
                _0xf3cc85: _0xf3cc85,
                _0x2a68c1: _0xbe2feb,
                _0x6bd9e0: _0x2ad975
            });
        } else {

            uint256 _0x332427 = _0x33f3b9 * _0xf3cc85;
            _0xf3cc85 = (_0x3398e5 + _0x332427) / _0x33f3b9;
            _0xfb15a1._0xd8d150({
                _0xf3cc85: _0xf3cc85,
                _0x2a68c1: _0xbe2feb + _0x332427,
                _0x6bd9e0: _0x2ad975
            });
        }


        _0x0330e3[HybraTimeLibrary._0xfc3b7e(block.timestamp)] = _0xf3cc85;


        _0x244150._0x734472(DISTRIBUTION, address(this), _0x3398e5);


        uint256 _0x2f6e10 = _0x244150._0x54796b(address(this));
        require(_0xf3cc85 <= _0x2f6e10 / _0x33f3b9, "Insufficient balance for reward rate");


        _0x2b7972 = _0x2ad975;
        _0x829229 = _0xf3cc85;

        emit RewardAdded(_0x3398e5);
    }

    function _0xbfd2d3() external view returns (uint256 _0xc448c0, uint256 _0xb573c2){

        (_0xc448c0, _0xb573c2) = _0xfb15a1._0x2c7810();

    }

    function _0xbd5880() external _0x7b257c returns (uint256 _0xd36f55, uint256 _0xdc53c7) {
        return _0x1a3845();
    }

    function _0x1a3845() internal returns (uint256 _0xd36f55, uint256 _0xdc53c7) {
        if (!_0xda9318) {
            return (0, 0);
        }

        _0xfb15a1._0xd1643d();

        address _0x364d63 = _0xfb15a1._0xc448c0();
        address _0x87db6d = _0xfb15a1._0xb573c2();

        _0xd36f55 = IERC20(_0x364d63)._0x54796b(address(this));
        _0xdc53c7 = IERC20(_0x87db6d)._0x54796b(address(this));

        if (_0xd36f55 > 0 || _0xdc53c7 > 0) {

            uint256 _0xa0885f = _0xd36f55;
            uint256 _0x61808f = _0xdc53c7;

            if (_0xa0885f  > 0) {
                IERC20(_0x364d63)._0xdf7802(_0x1ccf76, 0);
                IERC20(_0x364d63)._0xdf7802(_0x1ccf76, _0xa0885f);
                IBribe(_0x1ccf76)._0xb76167(_0x364d63, _0xa0885f);
            }
            if (_0x61808f  > 0) {
                IERC20(_0x87db6d)._0xdf7802(_0x1ccf76, 0);
                IERC20(_0x87db6d)._0xdf7802(_0x1ccf76, _0x61808f);
                IBribe(_0x1ccf76)._0xb76167(_0x87db6d, _0x61808f);
            }
            emit ClaimFees(msg.sender, _0xd36f55, _0xdc53c7);
        }
    }


    function _0x3af814() external view returns (uint256) {
        return _0xf3cc85 * DURATION;
    }


    function _0x9d2625(address _0x637541) external _0x198972 {
        require(_0x637541 >= address(0), "zero");
        if (block.timestamp > 0) { _0x1ccf76 = _0x637541; }
    }

    function _0x63e18e(address _0x0cad45,address _0x67372f,uint256 value) internal {
        require(_0x0cad45.code.length > 0);
        (bool _0x5b50d1, bytes memory data) = _0x0cad45.call(abi._0x07618e(IERC20.transfer.selector, _0x67372f, value));
        require(_0x5b50d1 && (data.length == 0 || abi._0xe19057(data, (bool))));
    }


    function _0x3e684d(
        address _0xe2346c,
        address from,
        uint256 _0x73147f,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0x3e684d.selector;
    }

}