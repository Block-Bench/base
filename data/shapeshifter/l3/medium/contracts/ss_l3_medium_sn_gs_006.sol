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
    IERC20 public immutable _0xc4c79a;
    address public immutable _0x46e7de;
    address public VE;
    address public DISTRIBUTION;
    address public _0x94dad1;
    address public _0xb7a841;

    uint256 public DURATION;
    uint256 internal _0x0efb95;
    uint256 public _0x6d0ac1;
    ICLPool public _0x98ccf2;
    address public _0xa12e09;
    INonfungiblePositionManager public _0x8c5a8c;

    bool public _0xf344f9;
    bool public immutable _0xc2bf4a;
    address immutable _0xadcaa1;

    mapping(uint256 => uint256) public  _0xc552e2; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _0xbe27dd;
    mapping(uint256 => uint256) public  _0xd8b552;

    mapping(uint256 => uint256) public  _0x58b4b2;

    mapping(uint256 => uint256) public  _0xcb9598;

    event RewardAdded(uint256 _0xe69a91);
    event Deposit(address indexed _0x22ebb5, uint256 _0x98c362);
    event Withdraw(address indexed _0x22ebb5, uint256 _0x98c362);
    event Harvest(address indexed _0x22ebb5, uint256 _0xe69a91);
    event ClaimFees(address indexed from, uint256 _0xae3464, uint256 _0x491fcb);
    event EmergencyActivated(address indexed _0xe1c620, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0xe1c620, uint256 timestamp);

    constructor(address _0xf82f5f, address _0xe1e8e9, address _0x15ef47, address _0xf32cb2, address _0xd1888d, address _0xc62c3f,
        address _0x89ada9, bool _0x844c26, address _0x4dfed5,  address _0x6a3e11) {
        _0xadcaa1 = _0x6a3e11;
        _0xc4c79a = IERC20(_0xf82f5f);     // main reward
        _0x46e7de = _0xe1e8e9;
        VE = _0x15ef47;                               // vested
        _0xa12e09 = _0xf32cb2;
        _0x98ccf2 = ICLPool(_0xf32cb2);
        DISTRIBUTION = _0xd1888d;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0x94dad1 = _0xc62c3f;       // lp fees goes here
        _0xb7a841 = _0x89ada9;       // bribe fees goes here
        _0xc2bf4a = _0x844c26;
        _0x8c5a8c = INonfungiblePositionManager(_0x4dfed5);
        _0xf344f9 = false;
    }

    modifier _0x5d7472() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0xaaea2f() {
        require(_0xf344f9 == false, "emergency");
        _;
    }

    function _0x0e369e(uint256 _0x70f394, int24 _0x3235b5, int24 _0xe03b69) internal {
        if (_0xcb9598[_0x70f394] == block.timestamp) return;
        _0x98ccf2._0xe2f713();
        _0xcb9598[_0x70f394] = block.timestamp;
        _0x58b4b2[_0x70f394] += _0x9ff2c7(_0x70f394);
        _0xd8b552[_0x70f394] = _0x98ccf2._0x6bd8ee(_0x3235b5, _0xe03b69, 0);
    }

    function _0x51e88c() external _0xf6c1ef {
        require(_0xf344f9 == false, "emergency");
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xf344f9 = true; }
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x3c8220() external _0xf6c1ef {

        require(_0xf344f9 == true,"emergency");

        _0xf344f9 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0x897ed7(uint256 _0x70f394) external view returns (uint256) {
        (,,,,,,,uint128 _0xbfe162,,,,) = _0x8c5a8c._0x8053e4(_0x70f394);
        return _0xbfe162;
    }

    function _0x15b5f2(address _0x556085, address _0xc8a7e5, int24 _0x1ae9cd) internal view returns (address) {
        return ICLFactory(_0x8c5a8c._0xadcaa1())._0x12d8a9(_0x556085, _0xc8a7e5, _0x1ae9cd);
    }

    function _0x28e9ed(uint256 _0x70f394) external view returns (uint256 _0xe69a91) {
        require(_0xbe27dd[msg.sender]._0x2a90bc(_0x70f394), "NA");

        uint256 _0xe69a91 = _0x9ff2c7(_0x70f394);
        return (_0xe69a91); // bonsReward is 0 for now
    }

       function _0x9ff2c7(uint256 _0x70f394) internal view returns (uint256) {
        uint256 _0x200357 = _0x98ccf2._0x200357();

        uint256 _0x326561 = block.timestamp - _0x200357;

        uint256 _0x568d09 = _0x98ccf2._0x568d09();
        uint256 _0xc69793 = _0x98ccf2._0xc69793();

        if (_0x326561 != 0 && _0xc69793 > 0 && _0x98ccf2._0x0ff066() > 0) {
            uint256 _0xe69a91 = _0x6d0ac1 * _0x326561;
            if (_0xe69a91 > _0xc69793) _0xe69a91 = _0xc69793;

            _0x568d09 += FullMath._0xa2391f(_0xe69a91, FixedPoint128.Q128, _0x98ccf2._0x0ff066());
        }

        (,,,,, int24 _0x3235b5, int24 _0xe03b69, uint128 _0xbfe162,,,,) = _0x8c5a8c._0x8053e4(_0x70f394);

        uint256 _0x510467 = _0xd8b552[_0x70f394];
        uint256 _0x63e3f8 = _0x98ccf2._0x6bd8ee(_0x3235b5, _0xe03b69, _0x568d09);

        uint256 _0xfbfefd =
            FullMath._0xa2391f(_0x63e3f8 - _0x510467, _0xbfe162, FixedPoint128.Q128);
        return _0xfbfefd;
    }

    function _0x1d78b5(uint256 _0x70f394) external _0x893b07 _0xaaea2f {

         (,,address _0x556085, address _0xc8a7e5, int24 _0x1ae9cd, int24 _0x3235b5, int24 _0xe03b69, uint128 _0xbfe162,,,,) =
            _0x8c5a8c._0x8053e4(_0x70f394);

        require(_0xbfe162 > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address _0xe1957b = _0x15b5f2(_0x556085, _0xc8a7e5, _0x1ae9cd);
        // Verify that the position's pool matches this gauge's pool
        require(_0xe1957b == _0xa12e09, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        _0x8c5a8c._0xf2592e(INonfungiblePositionManager.CollectParams({
                _0x70f394: _0x70f394,
                _0x835d69: msg.sender,
                _0xbcba7c: type(uint128)._0x8fb28e,
                _0x75696c: type(uint128)._0x8fb28e
            }));

        _0x8c5a8c._0xaece97(msg.sender, address(this), _0x70f394);

        _0x98ccf2._0xe6627a(int128(_0xbfe162), _0x3235b5, _0xe03b69, true);

        uint256 _0x5c9dc8 = _0x98ccf2._0x6bd8ee(_0x3235b5, _0xe03b69, 0);
        _0xd8b552[_0x70f394] = _0x5c9dc8;
        _0xcb9598[_0x70f394] = block.timestamp;

        _0xbe27dd[msg.sender]._0x6d7ba0(_0x70f394);

        emit Deposit(msg.sender, _0x70f394);
    }

    function _0x18a110(uint256 _0x70f394, uint8 _0x482578) external _0x893b07 _0xaaea2f {
           require(_0xbe27dd[msg.sender]._0x2a90bc(_0x70f394), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        _0x8c5a8c._0xf2592e(
            INonfungiblePositionManager.CollectParams({
                _0x70f394: _0x70f394,
                _0x835d69: msg.sender,
                _0xbcba7c: type(uint128)._0x8fb28e,
                _0x75696c: type(uint128)._0x8fb28e
            })
        );

        (,,,,, int24 _0x3235b5, int24 _0xe03b69, uint128 _0xffed38,,,,) = _0x8c5a8c._0x8053e4(_0x70f394);
        _0x47f031(_0x3235b5, _0xe03b69, _0x70f394, msg.sender, _0x482578);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (_0xffed38 != 0) {
            _0x98ccf2._0xe6627a(-int128(_0xffed38), _0x3235b5, _0xe03b69, true);
        }

        _0xbe27dd[msg.sender]._0x2a64da(_0x70f394);
        _0x8c5a8c._0xaece97(address(this), msg.sender, _0x70f394);

        emit Withdraw(msg.sender, _0x70f394);
    }

    function _0x161ae4(uint256 _0x70f394, address _0x9bee36,uint8 _0x482578 ) public _0x893b07 _0x5d7472 {

        require(_0xbe27dd[_0x9bee36]._0x2a90bc(_0x70f394), "NA");

        (,,,,, int24 _0x3235b5, int24 _0xe03b69,,,,,) = _0x8c5a8c._0x8053e4(_0x70f394);
        _0x47f031(_0x3235b5, _0xe03b69, _0x70f394, _0x9bee36, _0x482578);
    }

    function _0x47f031(int24 _0x3235b5, int24 _0xe03b69, uint256 _0x70f394,address _0x9bee36, uint8 _0x482578) internal {
        _0x0e369e(_0x70f394, _0x3235b5, _0xe03b69);
        uint256 _0xc28b09 = _0x58b4b2[_0x70f394];
        if(_0xc28b09 > 0){
            delete _0x58b4b2[_0x70f394];
            _0xc4c79a._0x45f787(_0x46e7de, _0xc28b09);
            IRHYBR(_0x46e7de)._0x68de3f(_0xc28b09);
            IRHYBR(_0x46e7de)._0xda5e69(_0xc28b09, _0x482578, _0x9bee36);
        }
        emit Harvest(msg.sender, _0xc28b09);
    }

    function _0x3521ed(address _0x413600, uint256 _0xc28b09) external _0x893b07
        _0xaaea2f _0x5d7472 returns (uint256 _0x5fb60c) {
        require(_0x413600 == address(_0xc4c79a), "Invalid reward token");

        // Update global reward growth before processing new rewards
        _0x98ccf2._0xe2f713();

        // Calculate time remaining until next epoch begins
        uint256 _0xc95066 = HybraTimeLibrary._0x72c553(block.timestamp) - block.timestamp;
        uint256 _0x1521ed = block.timestamp + _0xc95066;

        // Include any rolled over rewards from previous period
        uint256 _0xda122a = _0xc28b09 + _0x98ccf2._0x55a1f6();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _0x0efb95) {
            // New period: distribute rewards over remaining epoch time
            _0x6d0ac1 = _0xc28b09 / _0xc95066;
            _0x98ccf2._0xd90d51({
                _0x6d0ac1: _0x6d0ac1,
                _0xc69793: _0xda122a,
                _0xb583ac: _0x1521ed
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 _0x20cacd = _0xc95066 * _0x6d0ac1;
            _0x6d0ac1 = (_0xc28b09 + _0x20cacd) / _0xc95066;
            _0x98ccf2._0xd90d51({
                _0x6d0ac1: _0x6d0ac1,
                _0xc69793: _0xda122a + _0x20cacd,
                _0xb583ac: _0x1521ed
            });
        }

        // Store reward rate for current epoch tracking
        _0xc552e2[HybraTimeLibrary._0x49aa15(block.timestamp)] = _0x6d0ac1;

        // Transfer reward tokens from distributor to gauge
        _0xc4c79a._0xaece97(DISTRIBUTION, address(this), _0xc28b09);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 _0x23e4ea = _0xc4c79a._0x897ed7(address(this));
        require(_0x6d0ac1 <= _0x23e4ea / _0xc95066, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _0x0efb95 = _0x1521ed;
        _0x5fb60c = _0x6d0ac1;

        emit RewardAdded(_0xc28b09);
    }

    function _0xb13c94() external view returns (uint256 _0x556085, uint256 _0xc8a7e5){

        (_0x556085, _0xc8a7e5) = _0x98ccf2._0x21bc4d();

    }

    function _0xe624e5() external _0x893b07 returns (uint256 _0xae3464, uint256 _0x491fcb) {
        return _0xb263c3();
    }

    function _0xb263c3() internal returns (uint256 _0xae3464, uint256 _0x491fcb) {
        if (!_0xc2bf4a) {
            return (0, 0);
        }

        _0x98ccf2._0xed5748();

        address _0x75d126 = _0x98ccf2._0x556085();
        address _0xe73c33 = _0x98ccf2._0xc8a7e5();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        _0xae3464 = IERC20(_0x75d126)._0x897ed7(address(this));
        _0x491fcb = IERC20(_0xe73c33)._0x897ed7(address(this));

        if (_0xae3464 > 0 || _0x491fcb > 0) {

            uint256 _0x0bfd33 = _0xae3464;
            uint256 _0x1b51d6 = _0x491fcb;

            if (_0x0bfd33  > 0) {
                IERC20(_0x75d126)._0x45f787(_0x94dad1, 0);
                IERC20(_0x75d126)._0x45f787(_0x94dad1, _0x0bfd33);
                IBribe(_0x94dad1)._0x3521ed(_0x75d126, _0x0bfd33);
            }
            if (_0x1b51d6  > 0) {
                IERC20(_0xe73c33)._0x45f787(_0x94dad1, 0);
                IERC20(_0xe73c33)._0x45f787(_0x94dad1, _0x1b51d6);
                IBribe(_0x94dad1)._0x3521ed(_0xe73c33, _0x1b51d6);
            }
            emit ClaimFees(msg.sender, _0xae3464, _0x491fcb);
        }
    }

    ///@notice get total reward for the duration
    function _0x23d798() external view returns (uint256) {
        return _0x6d0ac1 * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0x067592(address _0xd4bf54) external _0xf6c1ef {
        require(_0xd4bf54 >= address(0), "zero");
        _0x94dad1 = _0xd4bf54;
    }

    function _0x678565(address _0x413600,address _0x2f5f2a,uint256 value) internal {
        require(_0x413600.code.length > 0);
        (bool _0xd32d7f, bytes memory data) = _0x413600.call(abi._0x58f8f2(IERC20.transfer.selector, _0x2f5f2a, value));
        require(_0xd32d7f && (data.length == 0 || abi._0x479150(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function _0xe370c2(
        address _0xef11fc,
        address from,
        uint256 _0x70f394,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0xe370c2.selector;
    }

}

