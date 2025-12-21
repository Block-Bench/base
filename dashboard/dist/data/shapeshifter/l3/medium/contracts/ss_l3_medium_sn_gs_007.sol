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
    IERC20 public immutable _0x73bcb4;
    address public immutable _0x2741cd;
    address public VE;
    address public DISTRIBUTION;
    address public _0x209d10;
    address public _0x84f038;

    uint256 public DURATION;
    uint256 internal _0x830d6b;
    uint256 public _0x186f26;
    ICLPool public _0x6d3b7c;
    address public _0xa14fb9;
    INonfungiblePositionManager public _0x2d5616;

    bool public _0x43ffd7;
    bool public immutable _0x7d66e5;
    address immutable _0x41583d;

    mapping(uint256 => uint256) public  _0x8b7b8b; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _0x546408;
    mapping(uint256 => uint256) public  _0xbe5b03;

    mapping(uint256 => uint256) public  _0xea8593;

    mapping(uint256 => uint256) public  _0x7bf10c;

    event RewardAdded(uint256 _0x4d63db);
    event Deposit(address indexed _0x5af892, uint256 _0xbc3775);
    event Withdraw(address indexed _0x5af892, uint256 _0xbc3775);
    event Harvest(address indexed _0x5af892, uint256 _0x4d63db);
    event ClaimFees(address indexed from, uint256 _0x1ab47a, uint256 _0xe2a0fb);
    event EmergencyActivated(address indexed _0x25c63b, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x25c63b, uint256 timestamp);

    constructor(address _0x27bd2d, address _0x994d3e, address _0x91bfed, address _0x0fb620, address _0x2e1ba8, address _0x146287,
        address _0xa5755f, bool _0xcd21ad, address _0x58daf8,  address _0x44b6ed) {
        _0x41583d = _0x44b6ed;
        _0x73bcb4 = IERC20(_0x27bd2d);     // main reward
        _0x2741cd = _0x994d3e;
        VE = _0x91bfed;                               // vested
        _0xa14fb9 = _0x0fb620;
        _0x6d3b7c = ICLPool(_0x0fb620);
        DISTRIBUTION = _0x2e1ba8;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0x209d10 = _0x146287;       // lp fees goes here
        _0x84f038 = _0xa5755f;       // bribe fees goes here
        _0x7d66e5 = _0xcd21ad;
        _0x2d5616 = INonfungiblePositionManager(_0x58daf8);
        _0x43ffd7 = false;
    }

    modifier _0x4144f9() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0x9a1c8f() {
        require(_0x43ffd7 == false, "emergency");
        _;
    }

    function _0xa1e85a(uint256 _0xffe78b, int24 _0x89d911, int24 _0xca16d7) internal {
        if (_0x7bf10c[_0xffe78b] == block.timestamp) return;
        _0x6d3b7c._0x757f7f();
        _0x7bf10c[_0xffe78b] = block.timestamp;
        _0xea8593[_0xffe78b] += _0x44fa04(_0xffe78b);
        _0xbe5b03[_0xffe78b] = _0x6d3b7c._0xf91dbf(_0x89d911, _0xca16d7, 0);
    }

    function _0x7ba075() external _0x210a8a {
        require(_0x43ffd7 == false, "emergency");
        _0x43ffd7 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x87a394() external _0x210a8a {

        require(_0x43ffd7 == true,"emergency");

        _0x43ffd7 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0xc2fa5c(uint256 _0xffe78b) external view returns (uint256) {
        (,,,,,,,uint128 _0x96cad0,,,,) = _0x2d5616._0xede0b5(_0xffe78b);
        return _0x96cad0;
    }

    function _0x23e11b(address _0xfea62a, address _0x80142b, int24 _0x157842) internal view returns (address) {
        return ICLFactory(_0x2d5616._0x41583d())._0x775221(_0xfea62a, _0x80142b, _0x157842);
    }

    function _0x52bc4c(uint256 _0xffe78b) external view returns (uint256 _0x4d63db) {
        require(_0x546408[msg.sender]._0xe791b3(_0xffe78b), "NA");

        uint256 _0x4d63db = _0x44fa04(_0xffe78b);
        return (_0x4d63db); // bonsReward is 0 for now
    }

       function _0x44fa04(uint256 _0xffe78b) internal view returns (uint256) {
        uint256 _0x2a3c12 = _0x6d3b7c._0x2a3c12();

        uint256 _0xdc1d8c = block.timestamp - _0x2a3c12;

        uint256 _0x6d2581 = _0x6d3b7c._0x6d2581();
        uint256 _0x84617f = _0x6d3b7c._0x84617f();

        if (_0xdc1d8c != 0 && _0x84617f > 0 && _0x6d3b7c._0x87948b() > 0) {
            uint256 _0x4d63db = _0x186f26 * _0xdc1d8c;
            if (_0x4d63db > _0x84617f) _0x4d63db = _0x84617f;

            _0x6d2581 += FullMath._0x22d57d(_0x4d63db, FixedPoint128.Q128, _0x6d3b7c._0x87948b());
        }

        (,,,,, int24 _0x89d911, int24 _0xca16d7, uint128 _0x96cad0,,,,) = _0x2d5616._0xede0b5(_0xffe78b);

        uint256 _0x51dcc3 = _0xbe5b03[_0xffe78b];
        uint256 _0x6f4dcd = _0x6d3b7c._0xf91dbf(_0x89d911, _0xca16d7, _0x6d2581);

        uint256 _0x85c8d8 =
            FullMath._0x22d57d(_0x6f4dcd - _0x51dcc3, _0x96cad0, FixedPoint128.Q128);
        return _0x85c8d8;
    }

    function _0xb457d6(uint256 _0xffe78b) external _0xf53d14 _0x9a1c8f {

         (,,address _0xfea62a, address _0x80142b, int24 _0x157842, int24 _0x89d911, int24 _0xca16d7, uint128 _0x96cad0,,,,) =
            _0x2d5616._0xede0b5(_0xffe78b);

        require(_0x96cad0 > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address _0x009548 = _0x23e11b(_0xfea62a, _0x80142b, _0x157842);
        // Verify that the position's pool matches this gauge's pool
        require(_0x009548 == _0xa14fb9, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        _0x2d5616._0xbb50e0(INonfungiblePositionManager.CollectParams({
                _0xffe78b: _0xffe78b,
                _0x61c4a0: msg.sender,
                _0xd44f78: type(uint128)._0x5bb4e8,
                _0xc3b5c7: type(uint128)._0x5bb4e8
            }));

        _0x2d5616._0x990544(msg.sender, address(this), _0xffe78b);

        _0x6d3b7c._0x191afa(int128(_0x96cad0), _0x89d911, _0xca16d7, true);

        uint256 _0xcc5157 = _0x6d3b7c._0xf91dbf(_0x89d911, _0xca16d7, 0);
        _0xbe5b03[_0xffe78b] = _0xcc5157;
        _0x7bf10c[_0xffe78b] = block.timestamp;

        _0x546408[msg.sender]._0x35c9e6(_0xffe78b);

        emit Deposit(msg.sender, _0xffe78b);
    }

    function _0xa1c2fb(uint256 _0xffe78b, uint8 _0x0de72a) external _0xf53d14 _0x9a1c8f {
           require(_0x546408[msg.sender]._0xe791b3(_0xffe78b), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        _0x2d5616._0xbb50e0(
            INonfungiblePositionManager.CollectParams({
                _0xffe78b: _0xffe78b,
                _0x61c4a0: msg.sender,
                _0xd44f78: type(uint128)._0x5bb4e8,
                _0xc3b5c7: type(uint128)._0x5bb4e8
            })
        );

        (,,,,, int24 _0x89d911, int24 _0xca16d7, uint128 _0xd5bf5b,,,,) = _0x2d5616._0xede0b5(_0xffe78b);
        _0x4ef312(_0x89d911, _0xca16d7, _0xffe78b, msg.sender, _0x0de72a);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (_0xd5bf5b != 0) {
            _0x6d3b7c._0x191afa(-int128(_0xd5bf5b), _0x89d911, _0xca16d7, true);
        }

        _0x546408[msg.sender]._0x15f138(_0xffe78b);
        _0x2d5616._0x990544(address(this), msg.sender, _0xffe78b);

        emit Withdraw(msg.sender, _0xffe78b);
    }

    function _0x48ce63(uint256 _0xffe78b, address _0xd3e6b4,uint8 _0x0de72a ) public _0xf53d14 _0x4144f9 {

        require(_0x546408[_0xd3e6b4]._0xe791b3(_0xffe78b), "NA");

        (,,,,, int24 _0x89d911, int24 _0xca16d7,,,,,) = _0x2d5616._0xede0b5(_0xffe78b);
        _0x4ef312(_0x89d911, _0xca16d7, _0xffe78b, _0xd3e6b4, _0x0de72a);
    }

    function _0x4ef312(int24 _0x89d911, int24 _0xca16d7, uint256 _0xffe78b,address _0xd3e6b4, uint8 _0x0de72a) internal {
        _0xa1e85a(_0xffe78b, _0x89d911, _0xca16d7);
        uint256 _0xfc2254 = _0xea8593[_0xffe78b];
        if(_0xfc2254 > 0){
            delete _0xea8593[_0xffe78b];
            _0x73bcb4._0x3b5750(_0x2741cd, _0xfc2254);
            IRHYBR(_0x2741cd)._0x6feeb4(_0xfc2254);
            IRHYBR(_0x2741cd)._0x6c3a1f(_0xfc2254, _0x0de72a, _0xd3e6b4);
        }
        emit Harvest(msg.sender, _0xfc2254);
    }

    function _0x620d19(address _0x911188, uint256 _0xfc2254) external _0xf53d14
        _0x9a1c8f _0x4144f9 returns (uint256 _0x31416d) {
        require(_0x911188 == address(_0x73bcb4), "Invalid reward token");

        // Update global reward growth before processing new rewards
        _0x6d3b7c._0x757f7f();

        // Calculate time remaining until next epoch begins
        uint256 _0x0540cf = HybraTimeLibrary._0xbb4ed7(block.timestamp) - block.timestamp;
        uint256 _0xdc90ed = block.timestamp + _0x0540cf;

        // Include any rolled over rewards from previous period
        uint256 _0xafa548 = _0xfc2254 + _0x6d3b7c._0x5c0e96();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _0x830d6b) {
            // New period: distribute rewards over remaining epoch time
            _0x186f26 = _0xfc2254 / _0x0540cf;
            _0x6d3b7c._0xde4f55({
                _0x186f26: _0x186f26,
                _0x84617f: _0xafa548,
                _0xbc7092: _0xdc90ed
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 _0x861388 = _0x0540cf * _0x186f26;
            _0x186f26 = (_0xfc2254 + _0x861388) / _0x0540cf;
            _0x6d3b7c._0xde4f55({
                _0x186f26: _0x186f26,
                _0x84617f: _0xafa548 + _0x861388,
                _0xbc7092: _0xdc90ed
            });
        }

        // Store reward rate for current epoch tracking
        _0x8b7b8b[HybraTimeLibrary._0x8653e3(block.timestamp)] = _0x186f26;

        // Transfer reward tokens from distributor to gauge
        _0x73bcb4._0x990544(DISTRIBUTION, address(this), _0xfc2254);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 _0x345ebe = _0x73bcb4._0xc2fa5c(address(this));
        require(_0x186f26 <= _0x345ebe / _0x0540cf, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _0x830d6b = _0xdc90ed;
        _0x31416d = _0x186f26;

        emit RewardAdded(_0xfc2254);
    }

    function _0xb2b110() external view returns (uint256 _0xfea62a, uint256 _0x80142b){

        (_0xfea62a, _0x80142b) = _0x6d3b7c._0x353c33();

    }

    function _0x8c3ed8() external _0xf53d14 returns (uint256 _0x1ab47a, uint256 _0xe2a0fb) {
        return _0xd5b2c9();
    }

    function _0xd5b2c9() internal returns (uint256 _0x1ab47a, uint256 _0xe2a0fb) {
        if (!_0x7d66e5) {
            return (0, 0);
        }

        _0x6d3b7c._0x1127af();

        address _0xdde348 = _0x6d3b7c._0xfea62a();
        address _0x53cfc0 = _0x6d3b7c._0x80142b();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        _0x1ab47a = IERC20(_0xdde348)._0xc2fa5c(address(this));
        _0xe2a0fb = IERC20(_0x53cfc0)._0xc2fa5c(address(this));

        if (_0x1ab47a > 0 || _0xe2a0fb > 0) {

            uint256 _0x8f6570 = _0x1ab47a;
            uint256 _0xcaa382 = _0xe2a0fb;

            if (_0x8f6570  > 0) {
                IERC20(_0xdde348)._0x3b5750(_0x209d10, 0);
                IERC20(_0xdde348)._0x3b5750(_0x209d10, _0x8f6570);
                IBribe(_0x209d10)._0x620d19(_0xdde348, _0x8f6570);
            }
            if (_0xcaa382  > 0) {
                IERC20(_0x53cfc0)._0x3b5750(_0x209d10, 0);
                IERC20(_0x53cfc0)._0x3b5750(_0x209d10, _0xcaa382);
                IBribe(_0x209d10)._0x620d19(_0x53cfc0, _0xcaa382);
            }
            emit ClaimFees(msg.sender, _0x1ab47a, _0xe2a0fb);
        }
    }

    ///@notice get total reward for the duration
    function _0xaf270a() external view returns (uint256) {
        return _0x186f26 * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0xe43143(address _0x0564b1) external _0x210a8a {
        require(_0x0564b1 >= address(0), "zero");
        if (true) { _0x209d10 = _0x0564b1; }
    }

    function _0x33d824(address _0x911188,address _0x17bdf9,uint256 value) internal {
        require(_0x911188.code.length > 0);
        (bool _0xa787ed, bytes memory data) = _0x911188.call(abi._0x5daffe(IERC20.transfer.selector, _0x17bdf9, value));
        require(_0xa787ed && (data.length == 0 || abi._0x4ab647(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function _0x8ecb64(
        address _0xeb420c,
        address from,
        uint256 _0xffe78b,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0x8ecb64.selector;
    }

}

