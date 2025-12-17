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
    IERC20 public immutable _0xda85be;
    address public immutable _0xb8f9d6;
    address public VE;
    address public DISTRIBUTION;
    address public _0x8e564c;
    address public _0xe34fd9;

    uint256 public DURATION;
    uint256 internal _0xad737f;
    uint256 public _0x20961f;
    ICLPool public _0x4ca258;
    address public _0x00b38a;
    INonfungiblePositionManager public _0xd0ceb2;

    bool public _0xf02270;
    bool public immutable _0xd91d80;
    address immutable _0x92859d;

    mapping(uint256 => uint256) public  _0xeb0fea; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _0x13c9c7;
    mapping(uint256 => uint256) public  _0x213f93;

    mapping(uint256 => uint256) public  _0x84a66a;

    mapping(uint256 => uint256) public  _0x9e405f;

    event RewardAdded(uint256 _0xb3c8ac);
    event Deposit(address indexed _0xe3a508, uint256 _0xa8b354);
    event Withdraw(address indexed _0xe3a508, uint256 _0xa8b354);
    event Harvest(address indexed _0xe3a508, uint256 _0xb3c8ac);
    event ClaimFees(address indexed from, uint256 _0x336f73, uint256 _0x365927);
    event EmergencyActivated(address indexed _0x9c1aaa, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x9c1aaa, uint256 timestamp);

    constructor(address _0x3561f5, address _0x7d2bfa, address _0x11a188, address _0x38cb89, address _0xed0bc8, address _0x43a8c7,
        address _0x612db4, bool _0x95f927, address _0x384401,  address _0x1c4a43) {
        _0x92859d = _0x1c4a43;
        _0xda85be = IERC20(_0x3561f5);     // main reward
        _0xb8f9d6 = _0x7d2bfa;
        VE = _0x11a188;                               // vested
        _0x00b38a = _0x38cb89;
        _0x4ca258 = ICLPool(_0x38cb89);
        DISTRIBUTION = _0xed0bc8;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0x8e564c = _0x43a8c7;       // lp fees goes here
        _0xe34fd9 = _0x612db4;       // bribe fees goes here
        _0xd91d80 = _0x95f927;
        _0xd0ceb2 = INonfungiblePositionManager(_0x384401);
        _0xf02270 = false;
    }

    modifier _0xa65f5c() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0x8bd36a() {
        require(_0xf02270 == false, "emergency");
        _;
    }

    function _0xc4030a(uint256 _0x3fd364, int24 _0x70cf82, int24 _0x2a272c) internal {
        if (_0x9e405f[_0x3fd364] == block.timestamp) return;
        _0x4ca258._0xeffdd8();
        _0x9e405f[_0x3fd364] = block.timestamp;
        _0x84a66a[_0x3fd364] += _0xef90e8(_0x3fd364);
        _0x213f93[_0x3fd364] = _0x4ca258._0xdb4afa(_0x70cf82, _0x2a272c, 0);
    }

    function _0x544b53() external _0x66c2e2 {
        require(_0xf02270 == false, "emergency");
        _0xf02270 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x3d2cce() external _0x66c2e2 {

        require(_0xf02270 == true,"emergency");

        _0xf02270 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0xe44184(uint256 _0x3fd364) external view returns (uint256) {
        (,,,,,,,uint128 _0x8785a5,,,,) = _0xd0ceb2._0xcf8311(_0x3fd364);
        return _0x8785a5;
    }

    function _0x266ea6(address _0x74bbf7, address _0x72e7ee, int24 _0xd26eb3) internal view returns (address) {
        return ICLFactory(_0xd0ceb2._0x92859d())._0x26bb7b(_0x74bbf7, _0x72e7ee, _0xd26eb3);
    }

    function _0x30d0da(uint256 _0x3fd364) external view returns (uint256 _0xb3c8ac) {
        require(_0x13c9c7[msg.sender]._0x4c3ff5(_0x3fd364), "NA");

        uint256 _0xb3c8ac = _0xef90e8(_0x3fd364);
        return (_0xb3c8ac); // bonsReward is 0 for now
    }

       function _0xef90e8(uint256 _0x3fd364) internal view returns (uint256) {
        uint256 _0x9e0b4d = _0x4ca258._0x9e0b4d();

        uint256 _0x0192aa = block.timestamp - _0x9e0b4d;

        uint256 _0xc46810 = _0x4ca258._0xc46810();
        uint256 _0x47bc41 = _0x4ca258._0x47bc41();

        if (_0x0192aa != 0 && _0x47bc41 > 0 && _0x4ca258._0xc67680() > 0) {
            uint256 _0xb3c8ac = _0x20961f * _0x0192aa;
            if (_0xb3c8ac > _0x47bc41) _0xb3c8ac = _0x47bc41;

            _0xc46810 += FullMath._0xbba29d(_0xb3c8ac, FixedPoint128.Q128, _0x4ca258._0xc67680());
        }

        (,,,,, int24 _0x70cf82, int24 _0x2a272c, uint128 _0x8785a5,,,,) = _0xd0ceb2._0xcf8311(_0x3fd364);

        uint256 _0xf8c2cb = _0x213f93[_0x3fd364];
        uint256 _0x38cc25 = _0x4ca258._0xdb4afa(_0x70cf82, _0x2a272c, _0xc46810);

        uint256 _0xdd5568 =
            FullMath._0xbba29d(_0x38cc25 - _0xf8c2cb, _0x8785a5, FixedPoint128.Q128);
        return _0xdd5568;
    }

    function _0x628f9e(uint256 _0x3fd364) external _0x1cfc59 _0x8bd36a {

         (,,address _0x74bbf7, address _0x72e7ee, int24 _0xd26eb3, int24 _0x70cf82, int24 _0x2a272c, uint128 _0x8785a5,,,,) =
            _0xd0ceb2._0xcf8311(_0x3fd364);

        require(_0x8785a5 > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address _0xc6b38d = _0x266ea6(_0x74bbf7, _0x72e7ee, _0xd26eb3);
        // Verify that the position's pool matches this gauge's pool
        require(_0xc6b38d == _0x00b38a, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        _0xd0ceb2._0xde353c(INonfungiblePositionManager.CollectParams({
                _0x3fd364: _0x3fd364,
                _0x162371: msg.sender,
                _0x4a0459: type(uint128)._0xce98f5,
                _0x98e532: type(uint128)._0xce98f5
            }));

        _0xd0ceb2._0x8b2eb0(msg.sender, address(this), _0x3fd364);

        _0x4ca258._0xa76e45(int128(_0x8785a5), _0x70cf82, _0x2a272c, true);

        uint256 _0x7101ed = _0x4ca258._0xdb4afa(_0x70cf82, _0x2a272c, 0);
        _0x213f93[_0x3fd364] = _0x7101ed;
        _0x9e405f[_0x3fd364] = block.timestamp;

        _0x13c9c7[msg.sender]._0xc9bfaf(_0x3fd364);

        emit Deposit(msg.sender, _0x3fd364);
    }

    function _0x7eb23b(uint256 _0x3fd364, uint8 _0x42b65e) external _0x1cfc59 _0x8bd36a {
           require(_0x13c9c7[msg.sender]._0x4c3ff5(_0x3fd364), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        _0xd0ceb2._0xde353c(
            INonfungiblePositionManager.CollectParams({
                _0x3fd364: _0x3fd364,
                _0x162371: msg.sender,
                _0x4a0459: type(uint128)._0xce98f5,
                _0x98e532: type(uint128)._0xce98f5
            })
        );

        (,,,,, int24 _0x70cf82, int24 _0x2a272c, uint128 _0xfa0c1c,,,,) = _0xd0ceb2._0xcf8311(_0x3fd364);
        _0x5b3948(_0x70cf82, _0x2a272c, _0x3fd364, msg.sender, _0x42b65e);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (_0xfa0c1c != 0) {
            _0x4ca258._0xa76e45(-int128(_0xfa0c1c), _0x70cf82, _0x2a272c, true);
        }

        _0x13c9c7[msg.sender]._0x074910(_0x3fd364);
        _0xd0ceb2._0x8b2eb0(address(this), msg.sender, _0x3fd364);

        emit Withdraw(msg.sender, _0x3fd364);
    }

    function _0x617714(uint256 _0x3fd364, address _0x10b5ff,uint8 _0x42b65e ) public _0x1cfc59 _0xa65f5c {

        require(_0x13c9c7[_0x10b5ff]._0x4c3ff5(_0x3fd364), "NA");

        (,,,,, int24 _0x70cf82, int24 _0x2a272c,,,,,) = _0xd0ceb2._0xcf8311(_0x3fd364);
        _0x5b3948(_0x70cf82, _0x2a272c, _0x3fd364, _0x10b5ff, _0x42b65e);
    }

    function _0x5b3948(int24 _0x70cf82, int24 _0x2a272c, uint256 _0x3fd364,address _0x10b5ff, uint8 _0x42b65e) internal {
        _0xc4030a(_0x3fd364, _0x70cf82, _0x2a272c);
        uint256 _0xa67e8b = _0x84a66a[_0x3fd364];
        if(_0xa67e8b > 0){
            delete _0x84a66a[_0x3fd364];
            _0xda85be._0x6dc32c(_0xb8f9d6, _0xa67e8b);
            IRHYBR(_0xb8f9d6)._0x1ac785(_0xa67e8b);
            IRHYBR(_0xb8f9d6)._0x302e8f(_0xa67e8b, _0x42b65e, _0x10b5ff);
        }
        emit Harvest(msg.sender, _0xa67e8b);
    }

    function _0xde608c(address _0xb70c77, uint256 _0xa67e8b) external _0x1cfc59
        _0x8bd36a _0xa65f5c returns (uint256 _0xa274d1) {
        require(_0xb70c77 == address(_0xda85be), "Invalid reward token");

        // Update global reward growth before processing new rewards
        _0x4ca258._0xeffdd8();

        // Calculate time remaining until next epoch begins
        uint256 _0x56baaa = HybraTimeLibrary._0x4d4659(block.timestamp) - block.timestamp;
        uint256 _0xeeb4c5 = block.timestamp + _0x56baaa;

        // Include any rolled over rewards from previous period
        uint256 _0xd9d9b1 = _0xa67e8b + _0x4ca258._0x39eb4e();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _0xad737f) {
            // New period: distribute rewards over remaining epoch time
            _0x20961f = _0xa67e8b / _0x56baaa;
            _0x4ca258._0x7e494c({
                _0x20961f: _0x20961f,
                _0x47bc41: _0xd9d9b1,
                _0xd79977: _0xeeb4c5
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 _0x26bd16 = _0x56baaa * _0x20961f;
            _0x20961f = (_0xa67e8b + _0x26bd16) / _0x56baaa;
            _0x4ca258._0x7e494c({
                _0x20961f: _0x20961f,
                _0x47bc41: _0xd9d9b1 + _0x26bd16,
                _0xd79977: _0xeeb4c5
            });
        }

        // Store reward rate for current epoch tracking
        _0xeb0fea[HybraTimeLibrary._0x09adbc(block.timestamp)] = _0x20961f;

        // Transfer reward tokens from distributor to gauge
        _0xda85be._0x8b2eb0(DISTRIBUTION, address(this), _0xa67e8b);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 _0x739064 = _0xda85be._0xe44184(address(this));
        require(_0x20961f <= _0x739064 / _0x56baaa, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _0xad737f = _0xeeb4c5;
        _0xa274d1 = _0x20961f;

        emit RewardAdded(_0xa67e8b);
    }

    function _0x06c53b() external view returns (uint256 _0x74bbf7, uint256 _0x72e7ee){

        (_0x74bbf7, _0x72e7ee) = _0x4ca258._0x7ab2e5();

    }

    function _0x13bdca() external _0x1cfc59 returns (uint256 _0x336f73, uint256 _0x365927) {
        return _0xc6987c();
    }

    function _0xc6987c() internal returns (uint256 _0x336f73, uint256 _0x365927) {
        if (!_0xd91d80) {
            return (0, 0);
        }

        _0x4ca258._0xd74ca0();

        address _0x57c2d1 = _0x4ca258._0x74bbf7();
        address _0xd813b4 = _0x4ca258._0x72e7ee();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        _0x336f73 = IERC20(_0x57c2d1)._0xe44184(address(this));
        _0x365927 = IERC20(_0xd813b4)._0xe44184(address(this));

        if (_0x336f73 > 0 || _0x365927 > 0) {

            uint256 _0xfd2da3 = _0x336f73;
            uint256 _0xd57b76 = _0x365927;

            if (_0xfd2da3  > 0) {
                IERC20(_0x57c2d1)._0x6dc32c(_0x8e564c, 0);
                IERC20(_0x57c2d1)._0x6dc32c(_0x8e564c, _0xfd2da3);
                IBribe(_0x8e564c)._0xde608c(_0x57c2d1, _0xfd2da3);
            }
            if (_0xd57b76  > 0) {
                IERC20(_0xd813b4)._0x6dc32c(_0x8e564c, 0);
                IERC20(_0xd813b4)._0x6dc32c(_0x8e564c, _0xd57b76);
                IBribe(_0x8e564c)._0xde608c(_0xd813b4, _0xd57b76);
            }
            emit ClaimFees(msg.sender, _0x336f73, _0x365927);
        }
    }

    ///@notice get total reward for the duration
    function _0xedaf64() external view returns (uint256) {
        return _0x20961f * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0x5399ec(address _0x9ff964) external _0x66c2e2 {
        require(_0x9ff964 >= address(0), "zero");
        _0x8e564c = _0x9ff964;
    }

    function _0x5fdb7f(address _0xb70c77,address _0x6d52f1,uint256 value) internal {
        require(_0xb70c77.code.length > 0);
        (bool _0xfbd54e, bytes memory data) = _0xb70c77.call(abi._0x467cdd(IERC20.transfer.selector, _0x6d52f1, value));
        require(_0xfbd54e && (data.length == 0 || abi._0xec1d3d(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function _0x18d970(
        address _0x67eb0a,
        address from,
        uint256 _0x3fd364,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0x18d970.selector;
    }

}

