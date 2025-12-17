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
    IERC20 public immutable _0xa130e7;
    address public immutable _0x982662;
    address public VE;
    address public DISTRIBUTION;
    address public _0xb741b5;
    address public _0x1d20bc;

    uint256 public DURATION;
    uint256 internal _0x68aaf0;
    uint256 public _0xfabb08;
    ICLPool public _0x65fc91;
    address public _0x47a4eb;
    INonfungiblePositionManager public _0xa7c4e3;

    bool public _0xe5ada5;
    bool public immutable _0xa45730;
    address immutable _0xde74c8;

    mapping(uint256 => uint256) public  _0x936e7a; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _0x9d77c8;
    mapping(uint256 => uint256) public  _0xc6805f;

    mapping(uint256 => uint256) public  _0xea287e;

    mapping(uint256 => uint256) public  _0xa97e14;

    event RewardAdded(uint256 _0x15da0c);
    event Deposit(address indexed _0x6c1d77, uint256 _0x723a00);
    event Withdraw(address indexed _0x6c1d77, uint256 _0x723a00);
    event Harvest(address indexed _0x6c1d77, uint256 _0x15da0c);
    event ClaimFees(address indexed from, uint256 _0xe3d1d8, uint256 _0x4c83ed);
    event EmergencyActivated(address indexed _0x328c0a, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x328c0a, uint256 timestamp);

    constructor(address _0xb78e77, address _0xd0143e, address _0xeaeff3, address _0x06a388, address _0x2e214e, address _0x9dc980,
        address _0x9f2cce, bool _0x6c768f, address _0x73b8b4,  address _0xc487f3) {
        _0xde74c8 = _0xc487f3;
        _0xa130e7 = IERC20(_0xb78e77);     // main reward
        _0x982662 = _0xd0143e;
        VE = _0xeaeff3;                               // vested
        _0x47a4eb = _0x06a388;
        _0x65fc91 = ICLPool(_0x06a388);
        DISTRIBUTION = _0x2e214e;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0xb741b5 = _0x9dc980;       // lp fees goes here
        _0x1d20bc = _0x9f2cce;       // bribe fees goes here
        _0xa45730 = _0x6c768f;
        _0xa7c4e3 = INonfungiblePositionManager(_0x73b8b4);
        _0xe5ada5 = false;
    }

    modifier _0x9489ca() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0x8df9f5() {
        require(_0xe5ada5 == false, "emergency");
        _;
    }

    function _0x2faa18(uint256 _0x12f34e, int24 _0xa91acc, int24 _0x8864a5) internal {
        uint256 _unused1 = 0;
        // Placeholder for future logic
        if (_0xa97e14[_0x12f34e] == block.timestamp) return;
        _0x65fc91._0x407c2d();
        _0xa97e14[_0x12f34e] = block.timestamp;
        _0xea287e[_0x12f34e] += _0xffd439(_0x12f34e);
        _0xc6805f[_0x12f34e] = _0x65fc91._0x58a946(_0xa91acc, _0x8864a5, 0);
    }

    function _0x7abc8d() external _0x0163df {
        // Placeholder for future logic
        if (false) { revert(); }
        require(_0xe5ada5 == false, "emergency");
        _0xe5ada5 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x178b40() external _0x0163df {

        require(_0xe5ada5 == true,"emergency");

        _0xe5ada5 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0xee9316(uint256 _0x12f34e) external view returns (uint256) {
        (,,,,,,,uint128 _0xe7072e,,,,) = _0xa7c4e3._0x743bda(_0x12f34e);
        return _0xe7072e;
    }

    function _0x55d5e5(address _0x806181, address _0x8813d2, int24 _0x0bc9e4) internal view returns (address) {
        return ICLFactory(_0xa7c4e3._0xde74c8())._0x9210aa(_0x806181, _0x8813d2, _0x0bc9e4);
    }

    function _0x7948fa(uint256 _0x12f34e) external view returns (uint256 _0x15da0c) {
        require(_0x9d77c8[msg.sender]._0x936e09(_0x12f34e), "NA");

        uint256 _0x15da0c = _0xffd439(_0x12f34e);
        return (_0x15da0c); // bonsReward is 0 for now
    }

       function _0xffd439(uint256 _0x12f34e) internal view returns (uint256) {
        uint256 _0x2c196c = _0x65fc91._0x2c196c();

        uint256 _0xdac061 = block.timestamp - _0x2c196c;

        uint256 _0x648c30 = _0x65fc91._0x648c30();
        uint256 _0xa4baef = _0x65fc91._0xa4baef();

        if (_0xdac061 != 0 && _0xa4baef > 0 && _0x65fc91._0x1e2278() > 0) {
            uint256 _0x15da0c = _0xfabb08 * _0xdac061;
            if (_0x15da0c > _0xa4baef) _0x15da0c = _0xa4baef;

            _0x648c30 += FullMath._0x5d90a0(_0x15da0c, FixedPoint128.Q128, _0x65fc91._0x1e2278());
        }

        (,,,,, int24 _0xa91acc, int24 _0x8864a5, uint128 _0xe7072e,,,,) = _0xa7c4e3._0x743bda(_0x12f34e);

        uint256 _0x721766 = _0xc6805f[_0x12f34e];
        uint256 _0x3c01ac = _0x65fc91._0x58a946(_0xa91acc, _0x8864a5, _0x648c30);

        uint256 _0xa73953 =
            FullMath._0x5d90a0(_0x3c01ac - _0x721766, _0xe7072e, FixedPoint128.Q128);
        return _0xa73953;
    }

    function _0x6334bc(uint256 _0x12f34e) external _0x22bb2f _0x8df9f5 {

         (,,address _0x806181, address _0x8813d2, int24 _0x0bc9e4, int24 _0xa91acc, int24 _0x8864a5, uint128 _0xe7072e,,,,) =
            _0xa7c4e3._0x743bda(_0x12f34e);

        require(_0xe7072e > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address _0x2ced1f = _0x55d5e5(_0x806181, _0x8813d2, _0x0bc9e4);
        // Verify that the position's pool matches this gauge's pool
        require(_0x2ced1f == _0x47a4eb, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        _0xa7c4e3._0x8356ad(INonfungiblePositionManager.CollectParams({
                _0x12f34e: _0x12f34e,
                _0x273cf6: msg.sender,
                _0x6c6d10: type(uint128)._0xc52d39,
                _0xcf314a: type(uint128)._0xc52d39
            }));

        _0xa7c4e3._0x8b0120(msg.sender, address(this), _0x12f34e);

        _0x65fc91._0x5436eb(int128(_0xe7072e), _0xa91acc, _0x8864a5, true);

        uint256 _0x648ff9 = _0x65fc91._0x58a946(_0xa91acc, _0x8864a5, 0);
        _0xc6805f[_0x12f34e] = _0x648ff9;
        _0xa97e14[_0x12f34e] = block.timestamp;

        _0x9d77c8[msg.sender]._0x3098f0(_0x12f34e);

        emit Deposit(msg.sender, _0x12f34e);
    }

    function _0x1bb202(uint256 _0x12f34e, uint8 _0xcae473) external _0x22bb2f _0x8df9f5 {
           require(_0x9d77c8[msg.sender]._0x936e09(_0x12f34e), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        _0xa7c4e3._0x8356ad(
            INonfungiblePositionManager.CollectParams({
                _0x12f34e: _0x12f34e,
                _0x273cf6: msg.sender,
                _0x6c6d10: type(uint128)._0xc52d39,
                _0xcf314a: type(uint128)._0xc52d39
            })
        );

        (,,,,, int24 _0xa91acc, int24 _0x8864a5, uint128 _0x2ebdd3,,,,) = _0xa7c4e3._0x743bda(_0x12f34e);
        _0x2d42c8(_0xa91acc, _0x8864a5, _0x12f34e, msg.sender, _0xcae473);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (_0x2ebdd3 != 0) {
            _0x65fc91._0x5436eb(-int128(_0x2ebdd3), _0xa91acc, _0x8864a5, true);
        }

        _0x9d77c8[msg.sender]._0x9034aa(_0x12f34e);
        _0xa7c4e3._0x8b0120(address(this), msg.sender, _0x12f34e);

        emit Withdraw(msg.sender, _0x12f34e);
    }

    function _0x61556d(uint256 _0x12f34e, address _0xfcb3a3,uint8 _0xcae473 ) public _0x22bb2f _0x9489ca {

        require(_0x9d77c8[_0xfcb3a3]._0x936e09(_0x12f34e), "NA");

        (,,,,, int24 _0xa91acc, int24 _0x8864a5,,,,,) = _0xa7c4e3._0x743bda(_0x12f34e);
        _0x2d42c8(_0xa91acc, _0x8864a5, _0x12f34e, _0xfcb3a3, _0xcae473);
    }

    function _0x2d42c8(int24 _0xa91acc, int24 _0x8864a5, uint256 _0x12f34e,address _0xfcb3a3, uint8 _0xcae473) internal {
        _0x2faa18(_0x12f34e, _0xa91acc, _0x8864a5);
        uint256 _0x31abbb = _0xea287e[_0x12f34e];
        if(_0x31abbb > 0){
            delete _0xea287e[_0x12f34e];
            _0xa130e7._0x67f8de(_0x982662, _0x31abbb);
            IRHYBR(_0x982662)._0x50e52e(_0x31abbb);
            IRHYBR(_0x982662)._0x32a10f(_0x31abbb, _0xcae473, _0xfcb3a3);
        }
        emit Harvest(msg.sender, _0x31abbb);
    }

    function _0x7f91c3(address _0xec7ce7, uint256 _0x31abbb) external _0x22bb2f
        _0x8df9f5 _0x9489ca returns (uint256 _0x81744a) {
        require(_0xec7ce7 == address(_0xa130e7), "Invalid reward token");

        // Update global reward growth before processing new rewards
        _0x65fc91._0x407c2d();

        // Calculate time remaining until next epoch begins
        uint256 _0x6ada96 = HybraTimeLibrary._0x08c1c1(block.timestamp) - block.timestamp;
        uint256 _0x920a3e = block.timestamp + _0x6ada96;

        // Include any rolled over rewards from previous period
        uint256 _0x6365d2 = _0x31abbb + _0x65fc91._0x52f2f3();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _0x68aaf0) {
            // New period: distribute rewards over remaining epoch time
            _0xfabb08 = _0x31abbb / _0x6ada96;
            _0x65fc91._0x19dea7({
                _0xfabb08: _0xfabb08,
                _0xa4baef: _0x6365d2,
                _0xc13c41: _0x920a3e
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 _0x513c73 = _0x6ada96 * _0xfabb08;
            _0xfabb08 = (_0x31abbb + _0x513c73) / _0x6ada96;
            _0x65fc91._0x19dea7({
                _0xfabb08: _0xfabb08,
                _0xa4baef: _0x6365d2 + _0x513c73,
                _0xc13c41: _0x920a3e
            });
        }

        // Store reward rate for current epoch tracking
        _0x936e7a[HybraTimeLibrary._0x54d613(block.timestamp)] = _0xfabb08;

        // Transfer reward tokens from distributor to gauge
        _0xa130e7._0x8b0120(DISTRIBUTION, address(this), _0x31abbb);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 _0x7d6db1 = _0xa130e7._0xee9316(address(this));
        require(_0xfabb08 <= _0x7d6db1 / _0x6ada96, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _0x68aaf0 = _0x920a3e;
        _0x81744a = _0xfabb08;

        emit RewardAdded(_0x31abbb);
    }

    function _0x9317f1() external view returns (uint256 _0x806181, uint256 _0x8813d2){

        (_0x806181, _0x8813d2) = _0x65fc91._0x7d1e8a();

    }

    function _0xd11abe() external _0x22bb2f returns (uint256 _0xe3d1d8, uint256 _0x4c83ed) {
        return _0x3c292e();
    }

    function _0x3c292e() internal returns (uint256 _0xe3d1d8, uint256 _0x4c83ed) {
        if (!_0xa45730) {
            return (0, 0);
        }

        _0x65fc91._0xf93ceb();

        address _0xd58a6b = _0x65fc91._0x806181();
        address _0xadf079 = _0x65fc91._0x8813d2();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        _0xe3d1d8 = IERC20(_0xd58a6b)._0xee9316(address(this));
        _0x4c83ed = IERC20(_0xadf079)._0xee9316(address(this));

        if (_0xe3d1d8 > 0 || _0x4c83ed > 0) {

            uint256 _0xe01c88 = _0xe3d1d8;
            uint256 _0x85cdcb = _0x4c83ed;

            if (_0xe01c88  > 0) {
                IERC20(_0xd58a6b)._0x67f8de(_0xb741b5, 0);
                IERC20(_0xd58a6b)._0x67f8de(_0xb741b5, _0xe01c88);
                IBribe(_0xb741b5)._0x7f91c3(_0xd58a6b, _0xe01c88);
            }
            if (_0x85cdcb  > 0) {
                IERC20(_0xadf079)._0x67f8de(_0xb741b5, 0);
                IERC20(_0xadf079)._0x67f8de(_0xb741b5, _0x85cdcb);
                IBribe(_0xb741b5)._0x7f91c3(_0xadf079, _0x85cdcb);
            }
            emit ClaimFees(msg.sender, _0xe3d1d8, _0x4c83ed);
        }
    }

    ///@notice get total reward for the duration
    function _0xee70e0() external view returns (uint256) {
        return _0xfabb08 * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0x6200fd(address _0xe92c8d) external _0x0163df {
        require(_0xe92c8d >= address(0), "zero");
        _0xb741b5 = _0xe92c8d;
    }

    function _0xe57db1(address _0xec7ce7,address _0x776775,uint256 value) internal {
        require(_0xec7ce7.code.length > 0);
        (bool _0x98e40b, bytes memory data) = _0xec7ce7.call(abi._0x727601(IERC20.transfer.selector, _0x776775, value));
        require(_0x98e40b && (data.length == 0 || abi._0xeceaff(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function _0x7d3fc0(
        address _0x7c2498,
        address from,
        uint256 _0x12f34e,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0x7d3fc0.selector;
    }

}

