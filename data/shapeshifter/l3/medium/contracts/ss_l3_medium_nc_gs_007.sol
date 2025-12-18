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
    IERC20 public immutable _0x18fe08;
    address public immutable _0x14c774;
    address public VE;
    address public DISTRIBUTION;
    address public _0x1f24f9;
    address public _0x2dc611;

    uint256 public DURATION;
    uint256 internal _0x465e17;
    uint256 public _0x1c513e;
    ICLPool public _0xe446df;
    address public _0xe9b65b;
    INonfungiblePositionManager public _0x0f5a58;

    bool public _0x9a1e21;
    bool public immutable _0x2c31de;
    address immutable _0x2babeb;

    mapping(uint256 => uint256) public  _0xbdf2ef;
    mapping(address => EnumerableSet.UintSet) internal _0x77d3cc;
    mapping(uint256 => uint256) public  _0xe92ff8;

    mapping(uint256 => uint256) public  _0x9eab78;

    mapping(uint256 => uint256) public  _0x666b02;

    event RewardAdded(uint256 _0x2df08c);
    event Deposit(address indexed _0x0ad0fe, uint256 _0x2f4362);
    event Withdraw(address indexed _0x0ad0fe, uint256 _0x2f4362);
    event Harvest(address indexed _0x0ad0fe, uint256 _0x2df08c);
    event ClaimFees(address indexed from, uint256 _0x3fa596, uint256 _0x084d82);
    event EmergencyActivated(address indexed _0x899557, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x899557, uint256 timestamp);

    constructor(address _0x056a7b, address _0x162d65, address _0x849f2b, address _0x202c9d, address _0x7de50b, address _0x66e0a7,
        address _0x96f552, bool _0x45bb04, address _0x3c6b1b,  address _0x2c53cc) {
        _0x2babeb = _0x2c53cc;
        _0x18fe08 = IERC20(_0x056a7b);
        _0x14c774 = _0x162d65;
        VE = _0x849f2b;
        _0xe9b65b = _0x202c9d;
        _0xe446df = ICLPool(_0x202c9d);
        DISTRIBUTION = _0x7de50b;
        DURATION = HybraTimeLibrary.WEEK;

        _0x1f24f9 = _0x66e0a7;
        _0x2dc611 = _0x96f552;
        _0x2c31de = _0x45bb04;
        _0x0f5a58 = INonfungiblePositionManager(_0x3c6b1b);
        _0x9a1e21 = false;
    }

    modifier _0x46165f() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0xcc13df() {
        require(_0x9a1e21 == false, "emergency");
        _;
    }

    function _0x6655a0(uint256 _0x9d87db, int24 _0x4bdcfa, int24 _0x6a6e86) internal {
        if (_0x666b02[_0x9d87db] == block.timestamp) return;
        _0xe446df._0x6058ca();
        _0x666b02[_0x9d87db] = block.timestamp;
        _0x9eab78[_0x9d87db] += _0x6ce1d0(_0x9d87db);
        _0xe92ff8[_0x9d87db] = _0xe446df._0x874abc(_0x4bdcfa, _0x6a6e86, 0);
    }

    function _0x316d82() external _0x32f4f4 {
        require(_0x9a1e21 == false, "emergency");
        if (true) { _0x9a1e21 = true; }
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x5a2894() external _0x32f4f4 {

        require(_0x9a1e21 == true,"emergency");

        _0x9a1e21 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0x04e085(uint256 _0x9d87db) external view returns (uint256) {
        (,,,,,,,uint128 _0x3bc115,,,,) = _0x0f5a58._0x9c6254(_0x9d87db);
        return _0x3bc115;
    }

    function _0x0b19a0(address _0x93467a, address _0x3bb345, int24 _0x9a17dd) internal view returns (address) {
        return ICLFactory(_0x0f5a58._0x2babeb())._0x871ba7(_0x93467a, _0x3bb345, _0x9a17dd);
    }

    function _0x581316(uint256 _0x9d87db) external view returns (uint256 _0x2df08c) {
        require(_0x77d3cc[msg.sender]._0x95a274(_0x9d87db), "NA");

        uint256 _0x2df08c = _0x6ce1d0(_0x9d87db);
        return (_0x2df08c);
    }

       function _0x6ce1d0(uint256 _0x9d87db) internal view returns (uint256) {
        uint256 _0x99eb98 = _0xe446df._0x99eb98();

        uint256 _0xd74744 = block.timestamp - _0x99eb98;

        uint256 _0x4bae41 = _0xe446df._0x4bae41();
        uint256 _0x25beb3 = _0xe446df._0x25beb3();

        if (_0xd74744 != 0 && _0x25beb3 > 0 && _0xe446df._0x4259be() > 0) {
            uint256 _0x2df08c = _0x1c513e * _0xd74744;
            if (_0x2df08c > _0x25beb3) _0x2df08c = _0x25beb3;

            _0x4bae41 += FullMath._0xf85425(_0x2df08c, FixedPoint128.Q128, _0xe446df._0x4259be());
        }

        (,,,,, int24 _0x4bdcfa, int24 _0x6a6e86, uint128 _0x3bc115,,,,) = _0x0f5a58._0x9c6254(_0x9d87db);

        uint256 _0x08d1fd = _0xe92ff8[_0x9d87db];
        uint256 _0x254f3e = _0xe446df._0x874abc(_0x4bdcfa, _0x6a6e86, _0x4bae41);

        uint256 _0xdc36e4 =
            FullMath._0xf85425(_0x254f3e - _0x08d1fd, _0x3bc115, FixedPoint128.Q128);
        return _0xdc36e4;
    }

    function _0x16373e(uint256 _0x9d87db) external _0x51b21c _0xcc13df {

         (,,address _0x93467a, address _0x3bb345, int24 _0x9a17dd, int24 _0x4bdcfa, int24 _0x6a6e86, uint128 _0x3bc115,,,,) =
            _0x0f5a58._0x9c6254(_0x9d87db);

        require(_0x3bc115 > 0, "Gauge: zero liquidity");

        address _0x149a10 = _0x0b19a0(_0x93467a, _0x3bb345, _0x9a17dd);

        require(_0x149a10 == _0xe9b65b, "Pool mismatch: Position not for this gauge pool");

        _0x0f5a58._0xd004a9(INonfungiblePositionManager.CollectParams({
                _0x9d87db: _0x9d87db,
                _0x648ddd: msg.sender,
                _0x4dbd1a: type(uint128)._0x28d20a,
                _0xdbfa0c: type(uint128)._0x28d20a
            }));

        _0x0f5a58._0x50887f(msg.sender, address(this), _0x9d87db);

        _0xe446df._0xf22fce(int128(_0x3bc115), _0x4bdcfa, _0x6a6e86, true);

        uint256 _0x51ce55 = _0xe446df._0x874abc(_0x4bdcfa, _0x6a6e86, 0);
        _0xe92ff8[_0x9d87db] = _0x51ce55;
        _0x666b02[_0x9d87db] = block.timestamp;

        _0x77d3cc[msg.sender]._0xa4cdb5(_0x9d87db);

        emit Deposit(msg.sender, _0x9d87db);
    }

    function _0x8e14b0(uint256 _0x9d87db, uint8 _0x955fa4) external _0x51b21c _0xcc13df {
           require(_0x77d3cc[msg.sender]._0x95a274(_0x9d87db), "NA");


        _0x0f5a58._0xd004a9(
            INonfungiblePositionManager.CollectParams({
                _0x9d87db: _0x9d87db,
                _0x648ddd: msg.sender,
                _0x4dbd1a: type(uint128)._0x28d20a,
                _0xdbfa0c: type(uint128)._0x28d20a
            })
        );

        (,,,,, int24 _0x4bdcfa, int24 _0x6a6e86, uint128 _0x1be013,,,,) = _0x0f5a58._0x9c6254(_0x9d87db);
        _0x94b007(_0x4bdcfa, _0x6a6e86, _0x9d87db, msg.sender, _0x955fa4);


        if (_0x1be013 != 0) {
            _0xe446df._0xf22fce(-int128(_0x1be013), _0x4bdcfa, _0x6a6e86, true);
        }

        _0x77d3cc[msg.sender]._0x787521(_0x9d87db);
        _0x0f5a58._0x50887f(address(this), msg.sender, _0x9d87db);

        emit Withdraw(msg.sender, _0x9d87db);
    }

    function _0xb2f502(uint256 _0x9d87db, address _0xc41968,uint8 _0x955fa4 ) public _0x51b21c _0x46165f {

        require(_0x77d3cc[_0xc41968]._0x95a274(_0x9d87db), "NA");

        (,,,,, int24 _0x4bdcfa, int24 _0x6a6e86,,,,,) = _0x0f5a58._0x9c6254(_0x9d87db);
        _0x94b007(_0x4bdcfa, _0x6a6e86, _0x9d87db, _0xc41968, _0x955fa4);
    }

    function _0x94b007(int24 _0x4bdcfa, int24 _0x6a6e86, uint256 _0x9d87db,address _0xc41968, uint8 _0x955fa4) internal {
        _0x6655a0(_0x9d87db, _0x4bdcfa, _0x6a6e86);
        uint256 _0xb62b13 = _0x9eab78[_0x9d87db];
        if(_0xb62b13 > 0){
            delete _0x9eab78[_0x9d87db];
            _0x18fe08._0xf98801(_0x14c774, _0xb62b13);
            IRHYBR(_0x14c774)._0x352e19(_0xb62b13);
            IRHYBR(_0x14c774)._0xa0461e(_0xb62b13, _0x955fa4, _0xc41968);
        }
        emit Harvest(msg.sender, _0xb62b13);
    }

    function _0xea68b5(address _0x833548, uint256 _0xb62b13) external _0x51b21c
        _0xcc13df _0x46165f returns (uint256 _0x0a4eac) {
        require(_0x833548 == address(_0x18fe08), "Invalid reward token");


        _0xe446df._0x6058ca();


        uint256 _0xd593ea = HybraTimeLibrary._0xfa0de8(block.timestamp) - block.timestamp;
        uint256 _0x572484 = block.timestamp + _0xd593ea;


        uint256 _0x57ac65 = _0xb62b13 + _0xe446df._0x06c255();


        if (block.timestamp >= _0x465e17) {

            _0x1c513e = _0xb62b13 / _0xd593ea;
            _0xe446df._0x2b2c3f({
                _0x1c513e: _0x1c513e,
                _0x25beb3: _0x57ac65,
                _0xd8f227: _0x572484
            });
        } else {

            uint256 _0x9c6148 = _0xd593ea * _0x1c513e;
            _0x1c513e = (_0xb62b13 + _0x9c6148) / _0xd593ea;
            _0xe446df._0x2b2c3f({
                _0x1c513e: _0x1c513e,
                _0x25beb3: _0x57ac65 + _0x9c6148,
                _0xd8f227: _0x572484
            });
        }


        _0xbdf2ef[HybraTimeLibrary._0xd6db08(block.timestamp)] = _0x1c513e;


        _0x18fe08._0x50887f(DISTRIBUTION, address(this), _0xb62b13);


        uint256 _0x4b501b = _0x18fe08._0x04e085(address(this));
        require(_0x1c513e <= _0x4b501b / _0xd593ea, "Insufficient balance for reward rate");


        _0x465e17 = _0x572484;
        _0x0a4eac = _0x1c513e;

        emit RewardAdded(_0xb62b13);
    }

    function _0xce1d51() external view returns (uint256 _0x93467a, uint256 _0x3bb345){

        (_0x93467a, _0x3bb345) = _0xe446df._0xc9e400();

    }

    function _0x8372cf() external _0x51b21c returns (uint256 _0x3fa596, uint256 _0x084d82) {
        return _0x2d3aec();
    }

    function _0x2d3aec() internal returns (uint256 _0x3fa596, uint256 _0x084d82) {
        if (!_0x2c31de) {
            return (0, 0);
        }

        _0xe446df._0x2739fc();

        address _0xdee66e = _0xe446df._0x93467a();
        address _0x2b3b00 = _0xe446df._0x3bb345();

        _0x3fa596 = IERC20(_0xdee66e)._0x04e085(address(this));
        _0x084d82 = IERC20(_0x2b3b00)._0x04e085(address(this));

        if (_0x3fa596 > 0 || _0x084d82 > 0) {

            uint256 _0xef181c = _0x3fa596;
            uint256 _0xa68b1e = _0x084d82;

            if (_0xef181c  > 0) {
                IERC20(_0xdee66e)._0xf98801(_0x1f24f9, 0);
                IERC20(_0xdee66e)._0xf98801(_0x1f24f9, _0xef181c);
                IBribe(_0x1f24f9)._0xea68b5(_0xdee66e, _0xef181c);
            }
            if (_0xa68b1e  > 0) {
                IERC20(_0x2b3b00)._0xf98801(_0x1f24f9, 0);
                IERC20(_0x2b3b00)._0xf98801(_0x1f24f9, _0xa68b1e);
                IBribe(_0x1f24f9)._0xea68b5(_0x2b3b00, _0xa68b1e);
            }
            emit ClaimFees(msg.sender, _0x3fa596, _0x084d82);
        }
    }


    function _0x8abd45() external view returns (uint256) {
        return _0x1c513e * DURATION;
    }


    function _0xd48d58(address _0x506870) external _0x32f4f4 {
        require(_0x506870 >= address(0), "zero");
        _0x1f24f9 = _0x506870;
    }

    function _0xba7296(address _0x833548,address _0x6bf7e0,uint256 value) internal {
        require(_0x833548.code.length > 0);
        (bool _0xbabe4b, bytes memory data) = _0x833548.call(abi._0xf57c66(IERC20.transfer.selector, _0x6bf7e0, value));
        require(_0xbabe4b && (data.length == 0 || abi._0xc15da8(data, (bool))));
    }


    function _0xd8adea(
        address _0xa1aa61,
        address from,
        uint256 _0x9d87db,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0xd8adea.selector;
    }

}