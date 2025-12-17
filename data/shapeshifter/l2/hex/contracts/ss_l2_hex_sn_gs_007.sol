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
    IERC20 public immutable _0x0c6f2f;
    address public immutable _0xec62a3;
    address public VE;
    address public DISTRIBUTION;
    address public _0x4d46cf;
    address public _0x85e39c;

    uint256 public DURATION;
    uint256 internal _0xb0aee8;
    uint256 public _0xf7d23a;
    ICLPool public _0x52c5ec;
    address public _0x387970;
    INonfungiblePositionManager public _0x32575e;

    bool public _0x26616e;
    bool public immutable _0x1e4b45;
    address immutable _0x3a6b03;

    mapping(uint256 => uint256) public  _0xba7465; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _0x250c8a;
    mapping(uint256 => uint256) public  _0xd36935;

    mapping(uint256 => uint256) public  _0x77d6b0;

    mapping(uint256 => uint256) public  _0x7b7e67;

    event RewardAdded(uint256 _0xe30b28);
    event Deposit(address indexed _0x4ed4b0, uint256 _0xe73e03);
    event Withdraw(address indexed _0x4ed4b0, uint256 _0xe73e03);
    event Harvest(address indexed _0x4ed4b0, uint256 _0xe30b28);
    event ClaimFees(address indexed from, uint256 _0xf841e3, uint256 _0x6666d7);
    event EmergencyActivated(address indexed _0x46b2ac, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x46b2ac, uint256 timestamp);

    constructor(address _0x8d0405, address _0xac27a1, address _0x5ba5a8, address _0x208cbe, address _0x02207b, address _0x7f07ab,
        address _0xdc464a, bool _0x390066, address _0x0fca62,  address _0xab4815) {
        _0x3a6b03 = _0xab4815;
        _0x0c6f2f = IERC20(_0x8d0405);     // main reward
        _0xec62a3 = _0xac27a1;
        VE = _0x5ba5a8;                               // vested
        _0x387970 = _0x208cbe;
        _0x52c5ec = ICLPool(_0x208cbe);
        DISTRIBUTION = _0x02207b;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0x4d46cf = _0x7f07ab;       // lp fees goes here
        _0x85e39c = _0xdc464a;       // bribe fees goes here
        _0x1e4b45 = _0x390066;
        _0x32575e = INonfungiblePositionManager(_0x0fca62);
        _0x26616e = false;
    }

    modifier _0x203c98() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0xe7156e() {
        require(_0x26616e == false, "emergency");
        _;
    }

    function _0x04af4f(uint256 _0x4aa1d3, int24 _0x4ca32c, int24 _0xee8b22) internal {
        if (_0x7b7e67[_0x4aa1d3] == block.timestamp) return;
        _0x52c5ec._0xa931bc();
        _0x7b7e67[_0x4aa1d3] = block.timestamp;
        _0x77d6b0[_0x4aa1d3] += _0x4d9677(_0x4aa1d3);
        _0xd36935[_0x4aa1d3] = _0x52c5ec._0xd0186c(_0x4ca32c, _0xee8b22, 0);
    }

    function _0xe2f8d4() external _0x70acec {
        require(_0x26616e == false, "emergency");
        _0x26616e = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x96996e() external _0x70acec {

        require(_0x26616e == true,"emergency");

        _0x26616e = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0x835101(uint256 _0x4aa1d3) external view returns (uint256) {
        (,,,,,,,uint128 _0x46e160,,,,) = _0x32575e._0x234396(_0x4aa1d3);
        return _0x46e160;
    }

    function _0xbee468(address _0x52c311, address _0x7369b8, int24 _0x96ab3c) internal view returns (address) {
        return ICLFactory(_0x32575e._0x3a6b03())._0x1964c8(_0x52c311, _0x7369b8, _0x96ab3c);
    }

    function _0xcb603e(uint256 _0x4aa1d3) external view returns (uint256 _0xe30b28) {
        require(_0x250c8a[msg.sender]._0x9c01cc(_0x4aa1d3), "NA");

        uint256 _0xe30b28 = _0x4d9677(_0x4aa1d3);
        return (_0xe30b28); // bonsReward is 0 for now
    }

       function _0x4d9677(uint256 _0x4aa1d3) internal view returns (uint256) {
        uint256 _0x9158d1 = _0x52c5ec._0x9158d1();

        uint256 _0x3ebf9f = block.timestamp - _0x9158d1;

        uint256 _0xddd465 = _0x52c5ec._0xddd465();
        uint256 _0xfa9c48 = _0x52c5ec._0xfa9c48();

        if (_0x3ebf9f != 0 && _0xfa9c48 > 0 && _0x52c5ec._0x619646() > 0) {
            uint256 _0xe30b28 = _0xf7d23a * _0x3ebf9f;
            if (_0xe30b28 > _0xfa9c48) _0xe30b28 = _0xfa9c48;

            _0xddd465 += FullMath._0x0d2442(_0xe30b28, FixedPoint128.Q128, _0x52c5ec._0x619646());
        }

        (,,,,, int24 _0x4ca32c, int24 _0xee8b22, uint128 _0x46e160,,,,) = _0x32575e._0x234396(_0x4aa1d3);

        uint256 _0x302b05 = _0xd36935[_0x4aa1d3];
        uint256 _0xdda7b4 = _0x52c5ec._0xd0186c(_0x4ca32c, _0xee8b22, _0xddd465);

        uint256 _0x034fd7 =
            FullMath._0x0d2442(_0xdda7b4 - _0x302b05, _0x46e160, FixedPoint128.Q128);
        return _0x034fd7;
    }

    function _0x43dab1(uint256 _0x4aa1d3) external _0x98d996 _0xe7156e {

         (,,address _0x52c311, address _0x7369b8, int24 _0x96ab3c, int24 _0x4ca32c, int24 _0xee8b22, uint128 _0x46e160,,,,) =
            _0x32575e._0x234396(_0x4aa1d3);

        require(_0x46e160 > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address _0xcf1d7c = _0xbee468(_0x52c311, _0x7369b8, _0x96ab3c);
        // Verify that the position's pool matches this gauge's pool
        require(_0xcf1d7c == _0x387970, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        _0x32575e._0x011315(INonfungiblePositionManager.CollectParams({
                _0x4aa1d3: _0x4aa1d3,
                _0x4eabb3: msg.sender,
                _0x3cd116: type(uint128)._0x409af3,
                _0xdeb34b: type(uint128)._0x409af3
            }));

        _0x32575e._0x8e86e9(msg.sender, address(this), _0x4aa1d3);

        _0x52c5ec._0x81c6bd(int128(_0x46e160), _0x4ca32c, _0xee8b22, true);

        uint256 _0xb19540 = _0x52c5ec._0xd0186c(_0x4ca32c, _0xee8b22, 0);
        _0xd36935[_0x4aa1d3] = _0xb19540;
        _0x7b7e67[_0x4aa1d3] = block.timestamp;

        _0x250c8a[msg.sender]._0x81c8c7(_0x4aa1d3);

        emit Deposit(msg.sender, _0x4aa1d3);
    }

    function _0xe89447(uint256 _0x4aa1d3, uint8 _0xdcf75e) external _0x98d996 _0xe7156e {
           require(_0x250c8a[msg.sender]._0x9c01cc(_0x4aa1d3), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        _0x32575e._0x011315(
            INonfungiblePositionManager.CollectParams({
                _0x4aa1d3: _0x4aa1d3,
                _0x4eabb3: msg.sender,
                _0x3cd116: type(uint128)._0x409af3,
                _0xdeb34b: type(uint128)._0x409af3
            })
        );

        (,,,,, int24 _0x4ca32c, int24 _0xee8b22, uint128 _0x047206,,,,) = _0x32575e._0x234396(_0x4aa1d3);
        _0xb99986(_0x4ca32c, _0xee8b22, _0x4aa1d3, msg.sender, _0xdcf75e);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (_0x047206 != 0) {
            _0x52c5ec._0x81c6bd(-int128(_0x047206), _0x4ca32c, _0xee8b22, true);
        }

        _0x250c8a[msg.sender]._0xe01a73(_0x4aa1d3);
        _0x32575e._0x8e86e9(address(this), msg.sender, _0x4aa1d3);

        emit Withdraw(msg.sender, _0x4aa1d3);
    }

    function _0x416464(uint256 _0x4aa1d3, address _0xcb0266,uint8 _0xdcf75e ) public _0x98d996 _0x203c98 {

        require(_0x250c8a[_0xcb0266]._0x9c01cc(_0x4aa1d3), "NA");

        (,,,,, int24 _0x4ca32c, int24 _0xee8b22,,,,,) = _0x32575e._0x234396(_0x4aa1d3);
        _0xb99986(_0x4ca32c, _0xee8b22, _0x4aa1d3, _0xcb0266, _0xdcf75e);
    }

    function _0xb99986(int24 _0x4ca32c, int24 _0xee8b22, uint256 _0x4aa1d3,address _0xcb0266, uint8 _0xdcf75e) internal {
        _0x04af4f(_0x4aa1d3, _0x4ca32c, _0xee8b22);
        uint256 _0x359420 = _0x77d6b0[_0x4aa1d3];
        if(_0x359420 > 0){
            delete _0x77d6b0[_0x4aa1d3];
            _0x0c6f2f._0xe0eec3(_0xec62a3, _0x359420);
            IRHYBR(_0xec62a3)._0xe23d28(_0x359420);
            IRHYBR(_0xec62a3)._0xe42d76(_0x359420, _0xdcf75e, _0xcb0266);
        }
        emit Harvest(msg.sender, _0x359420);
    }

    function _0x404f78(address _0x23cdce, uint256 _0x359420) external _0x98d996
        _0xe7156e _0x203c98 returns (uint256 _0xfcd942) {
        require(_0x23cdce == address(_0x0c6f2f), "Invalid reward token");

        // Update global reward growth before processing new rewards
        _0x52c5ec._0xa931bc();

        // Calculate time remaining until next epoch begins
        uint256 _0x9651e6 = HybraTimeLibrary._0xdae2d3(block.timestamp) - block.timestamp;
        uint256 _0xf392b8 = block.timestamp + _0x9651e6;

        // Include any rolled over rewards from previous period
        uint256 _0xbd60aa = _0x359420 + _0x52c5ec._0x6603cb();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _0xb0aee8) {
            // New period: distribute rewards over remaining epoch time
            _0xf7d23a = _0x359420 / _0x9651e6;
            _0x52c5ec._0xdd528f({
                _0xf7d23a: _0xf7d23a,
                _0xfa9c48: _0xbd60aa,
                _0x2a3f0e: _0xf392b8
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 _0xebe52b = _0x9651e6 * _0xf7d23a;
            _0xf7d23a = (_0x359420 + _0xebe52b) / _0x9651e6;
            _0x52c5ec._0xdd528f({
                _0xf7d23a: _0xf7d23a,
                _0xfa9c48: _0xbd60aa + _0xebe52b,
                _0x2a3f0e: _0xf392b8
            });
        }

        // Store reward rate for current epoch tracking
        _0xba7465[HybraTimeLibrary._0xf0bec0(block.timestamp)] = _0xf7d23a;

        // Transfer reward tokens from distributor to gauge
        _0x0c6f2f._0x8e86e9(DISTRIBUTION, address(this), _0x359420);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 _0xb06ace = _0x0c6f2f._0x835101(address(this));
        require(_0xf7d23a <= _0xb06ace / _0x9651e6, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _0xb0aee8 = _0xf392b8;
        _0xfcd942 = _0xf7d23a;

        emit RewardAdded(_0x359420);
    }

    function _0x653eef() external view returns (uint256 _0x52c311, uint256 _0x7369b8){

        (_0x52c311, _0x7369b8) = _0x52c5ec._0x4b9c06();

    }

    function _0x28d570() external _0x98d996 returns (uint256 _0xf841e3, uint256 _0x6666d7) {
        return _0xf67d71();
    }

    function _0xf67d71() internal returns (uint256 _0xf841e3, uint256 _0x6666d7) {
        if (!_0x1e4b45) {
            return (0, 0);
        }

        _0x52c5ec._0xce0309();

        address _0xd35c7d = _0x52c5ec._0x52c311();
        address _0x755ca7 = _0x52c5ec._0x7369b8();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        _0xf841e3 = IERC20(_0xd35c7d)._0x835101(address(this));
        _0x6666d7 = IERC20(_0x755ca7)._0x835101(address(this));

        if (_0xf841e3 > 0 || _0x6666d7 > 0) {

            uint256 _0x00e6ca = _0xf841e3;
            uint256 _0xc62c5a = _0x6666d7;

            if (_0x00e6ca  > 0) {
                IERC20(_0xd35c7d)._0xe0eec3(_0x4d46cf, 0);
                IERC20(_0xd35c7d)._0xe0eec3(_0x4d46cf, _0x00e6ca);
                IBribe(_0x4d46cf)._0x404f78(_0xd35c7d, _0x00e6ca);
            }
            if (_0xc62c5a  > 0) {
                IERC20(_0x755ca7)._0xe0eec3(_0x4d46cf, 0);
                IERC20(_0x755ca7)._0xe0eec3(_0x4d46cf, _0xc62c5a);
                IBribe(_0x4d46cf)._0x404f78(_0x755ca7, _0xc62c5a);
            }
            emit ClaimFees(msg.sender, _0xf841e3, _0x6666d7);
        }
    }

    ///@notice get total reward for the duration
    function _0x32df17() external view returns (uint256) {
        return _0xf7d23a * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0x931bc5(address _0xae7501) external _0x70acec {
        require(_0xae7501 >= address(0), "zero");
        _0x4d46cf = _0xae7501;
    }

    function _0x000a77(address _0x23cdce,address _0x506bf5,uint256 value) internal {
        require(_0x23cdce.code.length > 0);
        (bool _0x354499, bytes memory data) = _0x23cdce.call(abi._0xbca373(IERC20.transfer.selector, _0x506bf5, value));
        require(_0x354499 && (data.length == 0 || abi._0x50cfb0(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function _0x4c4bc5(
        address _0x431c2f,
        address from,
        uint256 _0x4aa1d3,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0x4c4bc5.selector;
    }

}

