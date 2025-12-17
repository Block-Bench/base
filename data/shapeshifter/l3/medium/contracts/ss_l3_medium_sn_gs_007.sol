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
    IERC20 public immutable _0xd7798c;
    address public immutable _0x2cea87;
    address public VE;
    address public DISTRIBUTION;
    address public _0xed2a19;
    address public _0x153362;

    uint256 public DURATION;
    uint256 internal _0xee22da;
    uint256 public _0x7e4188;
    ICLPool public _0x9cebf0;
    address public _0x8e1047;
    INonfungiblePositionManager public _0xadad59;

    bool public _0x347319;
    bool public immutable _0xc5523c;
    address immutable _0x717ece;

    mapping(uint256 => uint256) public  _0xa13679; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _0x5b2005;
    mapping(uint256 => uint256) public  _0x06bbb7;

    mapping(uint256 => uint256) public  _0xf894bc;

    mapping(uint256 => uint256) public  _0x7916e1;

    event RewardAdded(uint256 _0xdf19a6);
    event Deposit(address indexed _0x3d6692, uint256 _0x92d532);
    event Withdraw(address indexed _0x3d6692, uint256 _0x92d532);
    event Harvest(address indexed _0x3d6692, uint256 _0xdf19a6);
    event ClaimFees(address indexed from, uint256 _0xbc9460, uint256 _0xe707de);
    event EmergencyActivated(address indexed _0x5728c2, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x5728c2, uint256 timestamp);

    constructor(address _0x3dcae3, address _0xb71010, address _0x7974e8, address _0x7c731e, address _0x987d01, address _0xcb35a1,
        address _0x224f10, bool _0x998ed9, address _0x4dbe39,  address _0x99697b) {
        _0x717ece = _0x99697b;
        _0xd7798c = IERC20(_0x3dcae3);     // main reward
        _0x2cea87 = _0xb71010;
        VE = _0x7974e8;                               // vested
        _0x8e1047 = _0x7c731e;
        _0x9cebf0 = ICLPool(_0x7c731e);
        DISTRIBUTION = _0x987d01;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0xed2a19 = _0xcb35a1;       // lp fees goes here
        _0x153362 = _0x224f10;       // bribe fees goes here
        _0xc5523c = _0x998ed9;
        _0xadad59 = INonfungiblePositionManager(_0x4dbe39);
        _0x347319 = false;
    }

    modifier _0xfac871() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0xde51c2() {
        require(_0x347319 == false, "emergency");
        _;
    }

    function _0x0a6bd0(uint256 _0xf50e29, int24 _0x987762, int24 _0xb4f989) internal {
        if (_0x7916e1[_0xf50e29] == block.timestamp) return;
        _0x9cebf0._0x51a36a();
        _0x7916e1[_0xf50e29] = block.timestamp;
        _0xf894bc[_0xf50e29] += _0xef1410(_0xf50e29);
        _0x06bbb7[_0xf50e29] = _0x9cebf0._0x5cfb18(_0x987762, _0xb4f989, 0);
    }

    function _0x302e5a() external _0xe79b80 {
        require(_0x347319 == false, "emergency");
        _0x347319 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x022f9f() external _0xe79b80 {

        require(_0x347319 == true,"emergency");

        _0x347319 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0x92b3ea(uint256 _0xf50e29) external view returns (uint256) {
        (,,,,,,,uint128 _0x984caf,,,,) = _0xadad59._0x3a6593(_0xf50e29);
        return _0x984caf;
    }

    function _0x921d05(address _0x994d79, address _0x1f0e9b, int24 _0x0cb8e1) internal view returns (address) {
        return ICLFactory(_0xadad59._0x717ece())._0xad6336(_0x994d79, _0x1f0e9b, _0x0cb8e1);
    }

    function _0xf91ff3(uint256 _0xf50e29) external view returns (uint256 _0xdf19a6) {
        require(_0x5b2005[msg.sender]._0xb0daff(_0xf50e29), "NA");

        uint256 _0xdf19a6 = _0xef1410(_0xf50e29);
        return (_0xdf19a6); // bonsReward is 0 for now
    }

       function _0xef1410(uint256 _0xf50e29) internal view returns (uint256) {
        uint256 _0x14bed8 = _0x9cebf0._0x14bed8();

        uint256 _0xb9e515 = block.timestamp - _0x14bed8;

        uint256 _0x4dc08c = _0x9cebf0._0x4dc08c();
        uint256 _0x11d09a = _0x9cebf0._0x11d09a();

        if (_0xb9e515 != 0 && _0x11d09a > 0 && _0x9cebf0._0xeb6408() > 0) {
            uint256 _0xdf19a6 = _0x7e4188 * _0xb9e515;
            if (_0xdf19a6 > _0x11d09a) _0xdf19a6 = _0x11d09a;

            _0x4dc08c += FullMath._0x9d0c45(_0xdf19a6, FixedPoint128.Q128, _0x9cebf0._0xeb6408());
        }

        (,,,,, int24 _0x987762, int24 _0xb4f989, uint128 _0x984caf,,,,) = _0xadad59._0x3a6593(_0xf50e29);

        uint256 _0xa1c7da = _0x06bbb7[_0xf50e29];
        uint256 _0x87e16d = _0x9cebf0._0x5cfb18(_0x987762, _0xb4f989, _0x4dc08c);

        uint256 _0x16a203 =
            FullMath._0x9d0c45(_0x87e16d - _0xa1c7da, _0x984caf, FixedPoint128.Q128);
        return _0x16a203;
    }

    function _0x29f915(uint256 _0xf50e29) external _0x503c96 _0xde51c2 {

         (,,address _0x994d79, address _0x1f0e9b, int24 _0x0cb8e1, int24 _0x987762, int24 _0xb4f989, uint128 _0x984caf,,,,) =
            _0xadad59._0x3a6593(_0xf50e29);

        require(_0x984caf > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address _0xe29e18 = _0x921d05(_0x994d79, _0x1f0e9b, _0x0cb8e1);
        // Verify that the position's pool matches this gauge's pool
        require(_0xe29e18 == _0x8e1047, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        _0xadad59._0x17bc31(INonfungiblePositionManager.CollectParams({
                _0xf50e29: _0xf50e29,
                _0xdf9a6e: msg.sender,
                _0x1017fa: type(uint128)._0xd71873,
                _0x33c82e: type(uint128)._0xd71873
            }));

        _0xadad59._0xa1eda3(msg.sender, address(this), _0xf50e29);

        _0x9cebf0._0xa71882(int128(_0x984caf), _0x987762, _0xb4f989, true);

        uint256 _0xa81007 = _0x9cebf0._0x5cfb18(_0x987762, _0xb4f989, 0);
        _0x06bbb7[_0xf50e29] = _0xa81007;
        _0x7916e1[_0xf50e29] = block.timestamp;

        _0x5b2005[msg.sender]._0x09bd36(_0xf50e29);

        emit Deposit(msg.sender, _0xf50e29);
    }

    function _0x4a0efc(uint256 _0xf50e29, uint8 _0x238cd1) external _0x503c96 _0xde51c2 {
           require(_0x5b2005[msg.sender]._0xb0daff(_0xf50e29), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        _0xadad59._0x17bc31(
            INonfungiblePositionManager.CollectParams({
                _0xf50e29: _0xf50e29,
                _0xdf9a6e: msg.sender,
                _0x1017fa: type(uint128)._0xd71873,
                _0x33c82e: type(uint128)._0xd71873
            })
        );

        (,,,,, int24 _0x987762, int24 _0xb4f989, uint128 _0x94d007,,,,) = _0xadad59._0x3a6593(_0xf50e29);
        _0x4a5e56(_0x987762, _0xb4f989, _0xf50e29, msg.sender, _0x238cd1);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (_0x94d007 != 0) {
            _0x9cebf0._0xa71882(-int128(_0x94d007), _0x987762, _0xb4f989, true);
        }

        _0x5b2005[msg.sender]._0xbfd0b1(_0xf50e29);
        _0xadad59._0xa1eda3(address(this), msg.sender, _0xf50e29);

        emit Withdraw(msg.sender, _0xf50e29);
    }

    function _0x76dfbc(uint256 _0xf50e29, address _0xb06b03,uint8 _0x238cd1 ) public _0x503c96 _0xfac871 {

        require(_0x5b2005[_0xb06b03]._0xb0daff(_0xf50e29), "NA");

        (,,,,, int24 _0x987762, int24 _0xb4f989,,,,,) = _0xadad59._0x3a6593(_0xf50e29);
        _0x4a5e56(_0x987762, _0xb4f989, _0xf50e29, _0xb06b03, _0x238cd1);
    }

    function _0x4a5e56(int24 _0x987762, int24 _0xb4f989, uint256 _0xf50e29,address _0xb06b03, uint8 _0x238cd1) internal {
        _0x0a6bd0(_0xf50e29, _0x987762, _0xb4f989);
        uint256 _0x95ae15 = _0xf894bc[_0xf50e29];
        if(_0x95ae15 > 0){
            delete _0xf894bc[_0xf50e29];
            _0xd7798c._0x9ddbfb(_0x2cea87, _0x95ae15);
            IRHYBR(_0x2cea87)._0x5ab3ac(_0x95ae15);
            IRHYBR(_0x2cea87)._0x822a9f(_0x95ae15, _0x238cd1, _0xb06b03);
        }
        emit Harvest(msg.sender, _0x95ae15);
    }

    function _0xc2d99e(address _0x41ec1f, uint256 _0x95ae15) external _0x503c96
        _0xde51c2 _0xfac871 returns (uint256 _0x5ddb0e) {
        require(_0x41ec1f == address(_0xd7798c), "Invalid reward token");

        // Update global reward growth before processing new rewards
        _0x9cebf0._0x51a36a();

        // Calculate time remaining until next epoch begins
        uint256 _0x12a806 = HybraTimeLibrary._0x9477d0(block.timestamp) - block.timestamp;
        uint256 _0x8438d7 = block.timestamp + _0x12a806;

        // Include any rolled over rewards from previous period
        uint256 _0xadf28d = _0x95ae15 + _0x9cebf0._0x4de5d0();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _0xee22da) {
            // New period: distribute rewards over remaining epoch time
            _0x7e4188 = _0x95ae15 / _0x12a806;
            _0x9cebf0._0xce97b8({
                _0x7e4188: _0x7e4188,
                _0x11d09a: _0xadf28d,
                _0x508f08: _0x8438d7
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 _0x374f58 = _0x12a806 * _0x7e4188;
            _0x7e4188 = (_0x95ae15 + _0x374f58) / _0x12a806;
            _0x9cebf0._0xce97b8({
                _0x7e4188: _0x7e4188,
                _0x11d09a: _0xadf28d + _0x374f58,
                _0x508f08: _0x8438d7
            });
        }

        // Store reward rate for current epoch tracking
        _0xa13679[HybraTimeLibrary._0xa8cc74(block.timestamp)] = _0x7e4188;

        // Transfer reward tokens from distributor to gauge
        _0xd7798c._0xa1eda3(DISTRIBUTION, address(this), _0x95ae15);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 _0x72cdcf = _0xd7798c._0x92b3ea(address(this));
        require(_0x7e4188 <= _0x72cdcf / _0x12a806, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _0xee22da = _0x8438d7;
        _0x5ddb0e = _0x7e4188;

        emit RewardAdded(_0x95ae15);
    }

    function _0xc6e0f4() external view returns (uint256 _0x994d79, uint256 _0x1f0e9b){

        (_0x994d79, _0x1f0e9b) = _0x9cebf0._0x0491f6();

    }

    function _0x6fc1ec() external _0x503c96 returns (uint256 _0xbc9460, uint256 _0xe707de) {
        return _0x6c8128();
    }

    function _0x6c8128() internal returns (uint256 _0xbc9460, uint256 _0xe707de) {
        if (!_0xc5523c) {
            return (0, 0);
        }

        _0x9cebf0._0x73f7b1();

        address _0x8b8e30 = _0x9cebf0._0x994d79();
        address _0x9cd0ad = _0x9cebf0._0x1f0e9b();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        _0xbc9460 = IERC20(_0x8b8e30)._0x92b3ea(address(this));
        _0xe707de = IERC20(_0x9cd0ad)._0x92b3ea(address(this));

        if (_0xbc9460 > 0 || _0xe707de > 0) {

            uint256 _0x9ad63f = _0xbc9460;
            uint256 _0xff2123 = _0xe707de;

            if (_0x9ad63f  > 0) {
                IERC20(_0x8b8e30)._0x9ddbfb(_0xed2a19, 0);
                IERC20(_0x8b8e30)._0x9ddbfb(_0xed2a19, _0x9ad63f);
                IBribe(_0xed2a19)._0xc2d99e(_0x8b8e30, _0x9ad63f);
            }
            if (_0xff2123  > 0) {
                IERC20(_0x9cd0ad)._0x9ddbfb(_0xed2a19, 0);
                IERC20(_0x9cd0ad)._0x9ddbfb(_0xed2a19, _0xff2123);
                IBribe(_0xed2a19)._0xc2d99e(_0x9cd0ad, _0xff2123);
            }
            emit ClaimFees(msg.sender, _0xbc9460, _0xe707de);
        }
    }

    ///@notice get total reward for the duration
    function _0xb2045f() external view returns (uint256) {
        return _0x7e4188 * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0xb2bf15(address _0xdd477c) external _0xe79b80 {
        require(_0xdd477c >= address(0), "zero");
        _0xed2a19 = _0xdd477c;
    }

    function _0x11bd71(address _0x41ec1f,address _0x1dc5de,uint256 value) internal {
        require(_0x41ec1f.code.length > 0);
        (bool _0x39161d, bytes memory data) = _0x41ec1f.call(abi._0x7a9555(IERC20.transfer.selector, _0x1dc5de, value));
        require(_0x39161d && (data.length == 0 || abi._0x8cd874(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function _0x5ab2a1(
        address _0xeff6df,
        address from,
        uint256 _0xf50e29,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0x5ab2a1.selector;
    }

}

