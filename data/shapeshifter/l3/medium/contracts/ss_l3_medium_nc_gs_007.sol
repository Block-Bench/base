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
    IERC20 public immutable _0x73ff6d;
    address public immutable _0xfdcc24;
    address public VE;
    address public DISTRIBUTION;
    address public _0x95e6cc;
    address public _0xdb6ea5;

    uint256 public DURATION;
    uint256 internal _0x928aec;
    uint256 public _0xb78242;
    ICLPool public _0x0871bf;
    address public _0xe7235c;
    INonfungiblePositionManager public _0x3f40d3;

    bool public _0x153dd9;
    bool public immutable _0xdef549;
    address immutable _0x12a7e8;

    mapping(uint256 => uint256) public  _0x2436a6;
    mapping(address => EnumerableSet.UintSet) internal _0xc26a1b;
    mapping(uint256 => uint256) public  _0x4ddd53;

    mapping(uint256 => uint256) public  _0xc3a213;

    mapping(uint256 => uint256) public  _0xde5dd6;

    event RewardAdded(uint256 _0xe25faa);
    event Deposit(address indexed _0x6aa0a5, uint256 _0xc6d15a);
    event Withdraw(address indexed _0x6aa0a5, uint256 _0xc6d15a);
    event Harvest(address indexed _0x6aa0a5, uint256 _0xe25faa);
    event ClaimFees(address indexed from, uint256 _0xbbaeb7, uint256 _0xe19510);
    event EmergencyActivated(address indexed _0x87e349, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x87e349, uint256 timestamp);

    constructor(address _0x42dcf2, address _0x1cb588, address _0xf01642, address _0xc49fc4, address _0x580f9b, address _0x1f0818,
        address _0x6a8598, bool _0xf26adc, address _0x75fc83,  address _0x2a70bb) {
        _0x12a7e8 = _0x2a70bb;
        _0x73ff6d = IERC20(_0x42dcf2);
        _0xfdcc24 = _0x1cb588;
        VE = _0xf01642;
        _0xe7235c = _0xc49fc4;
        _0x0871bf = ICLPool(_0xc49fc4);
        DISTRIBUTION = _0x580f9b;
        DURATION = HybraTimeLibrary.WEEK;

        _0x95e6cc = _0x1f0818;
        _0xdb6ea5 = _0x6a8598;
        _0xdef549 = _0xf26adc;
        _0x3f40d3 = INonfungiblePositionManager(_0x75fc83);
        _0x153dd9 = false;
    }

    modifier _0x6fec85() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0xdba6d8() {
        require(_0x153dd9 == false, "emergency");
        _;
    }

    function _0xd21056(uint256 _0xbb1bba, int24 _0x758e02, int24 _0xde6387) internal {
        if (_0xde5dd6[_0xbb1bba] == block.timestamp) return;
        _0x0871bf._0x45be72();
        _0xde5dd6[_0xbb1bba] = block.timestamp;
        _0xc3a213[_0xbb1bba] += _0xe1e196(_0xbb1bba);
        _0x4ddd53[_0xbb1bba] = _0x0871bf._0xcfa31c(_0x758e02, _0xde6387, 0);
    }

    function _0x195724() external _0x6a0070 {
        require(_0x153dd9 == false, "emergency");
        _0x153dd9 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x94c8fb() external _0x6a0070 {

        require(_0x153dd9 == true,"emergency");

        _0x153dd9 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0xde5c17(uint256 _0xbb1bba) external view returns (uint256) {
        (,,,,,,,uint128 _0xe2e5f1,,,,) = _0x3f40d3._0xe5f64b(_0xbb1bba);
        return _0xe2e5f1;
    }

    function _0xcadec1(address _0x9e88b3, address _0x7fc581, int24 _0x86aab2) internal view returns (address) {
        return ICLFactory(_0x3f40d3._0x12a7e8())._0x49db96(_0x9e88b3, _0x7fc581, _0x86aab2);
    }

    function _0x51ccf2(uint256 _0xbb1bba) external view returns (uint256 _0xe25faa) {
        require(_0xc26a1b[msg.sender]._0xecaadf(_0xbb1bba), "NA");

        uint256 _0xe25faa = _0xe1e196(_0xbb1bba);
        return (_0xe25faa);
    }

       function _0xe1e196(uint256 _0xbb1bba) internal view returns (uint256) {
        uint256 _0xc016e5 = _0x0871bf._0xc016e5();

        uint256 _0x9d23b1 = block.timestamp - _0xc016e5;

        uint256 _0x05c282 = _0x0871bf._0x05c282();
        uint256 _0x638181 = _0x0871bf._0x638181();

        if (_0x9d23b1 != 0 && _0x638181 > 0 && _0x0871bf._0xebedef() > 0) {
            uint256 _0xe25faa = _0xb78242 * _0x9d23b1;
            if (_0xe25faa > _0x638181) _0xe25faa = _0x638181;

            _0x05c282 += FullMath._0x731a84(_0xe25faa, FixedPoint128.Q128, _0x0871bf._0xebedef());
        }

        (,,,,, int24 _0x758e02, int24 _0xde6387, uint128 _0xe2e5f1,,,,) = _0x3f40d3._0xe5f64b(_0xbb1bba);

        uint256 _0x484021 = _0x4ddd53[_0xbb1bba];
        uint256 _0xc6462f = _0x0871bf._0xcfa31c(_0x758e02, _0xde6387, _0x05c282);

        uint256 _0xe21830 =
            FullMath._0x731a84(_0xc6462f - _0x484021, _0xe2e5f1, FixedPoint128.Q128);
        return _0xe21830;
    }

    function _0x6d3a47(uint256 _0xbb1bba) external _0x50c90d _0xdba6d8 {

         (,,address _0x9e88b3, address _0x7fc581, int24 _0x86aab2, int24 _0x758e02, int24 _0xde6387, uint128 _0xe2e5f1,,,,) =
            _0x3f40d3._0xe5f64b(_0xbb1bba);

        require(_0xe2e5f1 > 0, "Gauge: zero liquidity");

        address _0xc5877d = _0xcadec1(_0x9e88b3, _0x7fc581, _0x86aab2);

        require(_0xc5877d == _0xe7235c, "Pool mismatch: Position not for this gauge pool");

        _0x3f40d3._0xd37161(INonfungiblePositionManager.CollectParams({
                _0xbb1bba: _0xbb1bba,
                _0x5a96ef: msg.sender,
                _0x79e2d2: type(uint128)._0x82b7c1,
                _0x878a8b: type(uint128)._0x82b7c1
            }));

        _0x3f40d3._0x4c4d35(msg.sender, address(this), _0xbb1bba);

        _0x0871bf._0x01c767(int128(_0xe2e5f1), _0x758e02, _0xde6387, true);

        uint256 _0x1f28dc = _0x0871bf._0xcfa31c(_0x758e02, _0xde6387, 0);
        _0x4ddd53[_0xbb1bba] = _0x1f28dc;
        _0xde5dd6[_0xbb1bba] = block.timestamp;

        _0xc26a1b[msg.sender]._0x4ccbed(_0xbb1bba);

        emit Deposit(msg.sender, _0xbb1bba);
    }

    function _0x851f6c(uint256 _0xbb1bba, uint8 _0x273da4) external _0x50c90d _0xdba6d8 {
           require(_0xc26a1b[msg.sender]._0xecaadf(_0xbb1bba), "NA");


        _0x3f40d3._0xd37161(
            INonfungiblePositionManager.CollectParams({
                _0xbb1bba: _0xbb1bba,
                _0x5a96ef: msg.sender,
                _0x79e2d2: type(uint128)._0x82b7c1,
                _0x878a8b: type(uint128)._0x82b7c1
            })
        );

        (,,,,, int24 _0x758e02, int24 _0xde6387, uint128 _0x16d27c,,,,) = _0x3f40d3._0xe5f64b(_0xbb1bba);
        _0x5446fe(_0x758e02, _0xde6387, _0xbb1bba, msg.sender, _0x273da4);


        if (_0x16d27c != 0) {
            _0x0871bf._0x01c767(-int128(_0x16d27c), _0x758e02, _0xde6387, true);
        }

        _0xc26a1b[msg.sender]._0xb7b21d(_0xbb1bba);
        _0x3f40d3._0x4c4d35(address(this), msg.sender, _0xbb1bba);

        emit Withdraw(msg.sender, _0xbb1bba);
    }

    function _0x9ee91c(uint256 _0xbb1bba, address _0x0f2f02,uint8 _0x273da4 ) public _0x50c90d _0x6fec85 {

        require(_0xc26a1b[_0x0f2f02]._0xecaadf(_0xbb1bba), "NA");

        (,,,,, int24 _0x758e02, int24 _0xde6387,,,,,) = _0x3f40d3._0xe5f64b(_0xbb1bba);
        _0x5446fe(_0x758e02, _0xde6387, _0xbb1bba, _0x0f2f02, _0x273da4);
    }

    function _0x5446fe(int24 _0x758e02, int24 _0xde6387, uint256 _0xbb1bba,address _0x0f2f02, uint8 _0x273da4) internal {
        _0xd21056(_0xbb1bba, _0x758e02, _0xde6387);
        uint256 _0x8fb404 = _0xc3a213[_0xbb1bba];
        if(_0x8fb404 > 0){
            delete _0xc3a213[_0xbb1bba];
            _0x73ff6d._0x98b79c(_0xfdcc24, _0x8fb404);
            IRHYBR(_0xfdcc24)._0xc6ffb9(_0x8fb404);
            IRHYBR(_0xfdcc24)._0x6ce6ad(_0x8fb404, _0x273da4, _0x0f2f02);
        }
        emit Harvest(msg.sender, _0x8fb404);
    }

    function _0xe79ddb(address _0xf819a3, uint256 _0x8fb404) external _0x50c90d
        _0xdba6d8 _0x6fec85 returns (uint256 _0x650fdc) {
        require(_0xf819a3 == address(_0x73ff6d), "Invalid reward token");


        _0x0871bf._0x45be72();


        uint256 _0xe1ebb4 = HybraTimeLibrary._0xe9dbd4(block.timestamp) - block.timestamp;
        uint256 _0xf077ac = block.timestamp + _0xe1ebb4;


        uint256 _0x487d4a = _0x8fb404 + _0x0871bf._0x34f838();


        if (block.timestamp >= _0x928aec) {

            _0xb78242 = _0x8fb404 / _0xe1ebb4;
            _0x0871bf._0x5121e0({
                _0xb78242: _0xb78242,
                _0x638181: _0x487d4a,
                _0xfbb3ae: _0xf077ac
            });
        } else {

            uint256 _0xfb1495 = _0xe1ebb4 * _0xb78242;
            _0xb78242 = (_0x8fb404 + _0xfb1495) / _0xe1ebb4;
            _0x0871bf._0x5121e0({
                _0xb78242: _0xb78242,
                _0x638181: _0x487d4a + _0xfb1495,
                _0xfbb3ae: _0xf077ac
            });
        }


        _0x2436a6[HybraTimeLibrary._0x4b612c(block.timestamp)] = _0xb78242;


        _0x73ff6d._0x4c4d35(DISTRIBUTION, address(this), _0x8fb404);


        uint256 _0x2784bf = _0x73ff6d._0xde5c17(address(this));
        require(_0xb78242 <= _0x2784bf / _0xe1ebb4, "Insufficient balance for reward rate");


        _0x928aec = _0xf077ac;
        _0x650fdc = _0xb78242;

        emit RewardAdded(_0x8fb404);
    }

    function _0x5e1d01() external view returns (uint256 _0x9e88b3, uint256 _0x7fc581){

        (_0x9e88b3, _0x7fc581) = _0x0871bf._0x135e1f();

    }

    function _0xba8c33() external _0x50c90d returns (uint256 _0xbbaeb7, uint256 _0xe19510) {
        return _0xa93810();
    }

    function _0xa93810() internal returns (uint256 _0xbbaeb7, uint256 _0xe19510) {
        if (!_0xdef549) {
            return (0, 0);
        }

        _0x0871bf._0x29a1a8();

        address _0xb4a39c = _0x0871bf._0x9e88b3();
        address _0xca5c7b = _0x0871bf._0x7fc581();

        _0xbbaeb7 = IERC20(_0xb4a39c)._0xde5c17(address(this));
        _0xe19510 = IERC20(_0xca5c7b)._0xde5c17(address(this));

        if (_0xbbaeb7 > 0 || _0xe19510 > 0) {

            uint256 _0x133cae = _0xbbaeb7;
            uint256 _0x39a3bf = _0xe19510;

            if (_0x133cae  > 0) {
                IERC20(_0xb4a39c)._0x98b79c(_0x95e6cc, 0);
                IERC20(_0xb4a39c)._0x98b79c(_0x95e6cc, _0x133cae);
                IBribe(_0x95e6cc)._0xe79ddb(_0xb4a39c, _0x133cae);
            }
            if (_0x39a3bf  > 0) {
                IERC20(_0xca5c7b)._0x98b79c(_0x95e6cc, 0);
                IERC20(_0xca5c7b)._0x98b79c(_0x95e6cc, _0x39a3bf);
                IBribe(_0x95e6cc)._0xe79ddb(_0xca5c7b, _0x39a3bf);
            }
            emit ClaimFees(msg.sender, _0xbbaeb7, _0xe19510);
        }
    }


    function _0x82a20e() external view returns (uint256) {
        return _0xb78242 * DURATION;
    }


    function _0xc7cd8d(address _0x7cebc3) external _0x6a0070 {
        require(_0x7cebc3 >= address(0), "zero");
        if (block.timestamp > 0) { _0x95e6cc = _0x7cebc3; }
    }

    function _0xfab9fe(address _0xf819a3,address _0x1894c2,uint256 value) internal {
        require(_0xf819a3.code.length > 0);
        (bool _0xcfca34, bytes memory data) = _0xf819a3.call(abi._0x80ac61(IERC20.transfer.selector, _0x1894c2, value));
        require(_0xcfca34 && (data.length == 0 || abi._0x7d464b(data, (bool))));
    }


    function _0x08870d(
        address _0xd2a4c5,
        address from,
        uint256 _0xbb1bba,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0x08870d.selector;
    }

}