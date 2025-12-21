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
    IERC20 public immutable _0x3695ec;
    address public immutable _0xf90e35;
    address public VE;
    address public DISTRIBUTION;
    address public _0x3b84c3;
    address public _0x8728fb;

    uint256 public DURATION;
    uint256 internal _0x21caad;
    uint256 public _0x99a5c4;
    ICLPool public _0x0b1dba;
    address public _0xeb2d91;
    INonfungiblePositionManager public _0x1fff77;

    bool public _0x8fa555;
    bool public immutable _0x5c4ead;
    address immutable _0x24bd7f;

    mapping(uint256 => uint256) public  _0x876f44; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _0x2b75e6;
    mapping(uint256 => uint256) public  _0xc00ab4;

    mapping(uint256 => uint256) public  _0x4a4046;

    mapping(uint256 => uint256) public  _0x66b852;

    event RewardAdded(uint256 _0x20078d);
    event Deposit(address indexed _0xc63224, uint256 _0x7f4730);
    event Withdraw(address indexed _0xc63224, uint256 _0x7f4730);
    event Harvest(address indexed _0xc63224, uint256 _0x20078d);
    event ClaimFees(address indexed from, uint256 _0x8cf07d, uint256 _0x4570d6);
    event EmergencyActivated(address indexed _0xe3320b, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0xe3320b, uint256 timestamp);

    constructor(address _0x496c0f, address _0xa44058, address _0x16e781, address _0x46ec1b, address _0x3f7d40, address _0xc23b31,
        address _0x3fdf3f, bool _0x76aef1, address _0x07a99a,  address _0x4af5d1) {
        _0x24bd7f = _0x4af5d1;
        _0x3695ec = IERC20(_0x496c0f);     // main reward
        _0xf90e35 = _0xa44058;
        VE = _0x16e781;                               // vested
        _0xeb2d91 = _0x46ec1b;
        _0x0b1dba = ICLPool(_0x46ec1b);
        DISTRIBUTION = _0x3f7d40;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0x3b84c3 = _0xc23b31;       // lp fees goes here
        _0x8728fb = _0x3fdf3f;       // bribe fees goes here
        _0x5c4ead = _0x76aef1;
        _0x1fff77 = INonfungiblePositionManager(_0x07a99a);
        _0x8fa555 = false;
    }

    modifier _0x125cda() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0x94bbeb() {
        require(_0x8fa555 == false, "emergency");
        _;
    }

    function _0x78ea27(uint256 _0xc4cb46, int24 _0x2c7653, int24 _0x6d0b67) internal {
        if (_0x66b852[_0xc4cb46] == block.timestamp) return;
        _0x0b1dba._0x54811e();
        _0x66b852[_0xc4cb46] = block.timestamp;
        _0x4a4046[_0xc4cb46] += _0x4fd6b9(_0xc4cb46);
        _0xc00ab4[_0xc4cb46] = _0x0b1dba._0x3b8557(_0x2c7653, _0x6d0b67, 0);
    }

    function _0x0a1ac3() external _0x8a32da {
        require(_0x8fa555 == false, "emergency");
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x8fa555 = true; }
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x62fd9d() external _0x8a32da {

        require(_0x8fa555 == true,"emergency");

        _0x8fa555 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0x2a9d82(uint256 _0xc4cb46) external view returns (uint256) {
        (,,,,,,,uint128 _0xcd8065,,,,) = _0x1fff77._0xe0201b(_0xc4cb46);
        return _0xcd8065;
    }

    function _0x953b05(address _0x1c2c35, address _0xdf591d, int24 _0xa7a9a1) internal view returns (address) {
        return ICLFactory(_0x1fff77._0x24bd7f())._0x02136e(_0x1c2c35, _0xdf591d, _0xa7a9a1);
    }

    function _0xb22389(uint256 _0xc4cb46) external view returns (uint256 _0x20078d) {
        require(_0x2b75e6[msg.sender]._0xfca870(_0xc4cb46), "NA");

        uint256 _0x20078d = _0x4fd6b9(_0xc4cb46);
        return (_0x20078d); // bonsReward is 0 for now
    }

       function _0x4fd6b9(uint256 _0xc4cb46) internal view returns (uint256) {
        uint256 _0x1a961f = _0x0b1dba._0x1a961f();

        uint256 _0x0e4db1 = block.timestamp - _0x1a961f;

        uint256 _0x0a8fa6 = _0x0b1dba._0x0a8fa6();
        uint256 _0xbbe7e0 = _0x0b1dba._0xbbe7e0();

        if (_0x0e4db1 != 0 && _0xbbe7e0 > 0 && _0x0b1dba._0x443d33() > 0) {
            uint256 _0x20078d = _0x99a5c4 * _0x0e4db1;
            if (_0x20078d > _0xbbe7e0) _0x20078d = _0xbbe7e0;

            _0x0a8fa6 += FullMath._0xc94a8c(_0x20078d, FixedPoint128.Q128, _0x0b1dba._0x443d33());
        }

        (,,,,, int24 _0x2c7653, int24 _0x6d0b67, uint128 _0xcd8065,,,,) = _0x1fff77._0xe0201b(_0xc4cb46);

        uint256 _0x5a1c32 = _0xc00ab4[_0xc4cb46];
        uint256 _0x285dce = _0x0b1dba._0x3b8557(_0x2c7653, _0x6d0b67, _0x0a8fa6);

        uint256 _0xa0e5dc =
            FullMath._0xc94a8c(_0x285dce - _0x5a1c32, _0xcd8065, FixedPoint128.Q128);
        return _0xa0e5dc;
    }

    function _0xdf30e1(uint256 _0xc4cb46) external _0x7acdab _0x94bbeb {

         (,,address _0x1c2c35, address _0xdf591d, int24 _0xa7a9a1, int24 _0x2c7653, int24 _0x6d0b67, uint128 _0xcd8065,,,,) =
            _0x1fff77._0xe0201b(_0xc4cb46);

        require(_0xcd8065 > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address _0x0553d6 = _0x953b05(_0x1c2c35, _0xdf591d, _0xa7a9a1);
        // Verify that the position's pool matches this gauge's pool
        require(_0x0553d6 == _0xeb2d91, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        _0x1fff77._0x8e0812(INonfungiblePositionManager.CollectParams({
                _0xc4cb46: _0xc4cb46,
                _0x9216b8: msg.sender,
                _0xce2df3: type(uint128)._0x766911,
                _0x76b6cd: type(uint128)._0x766911
            }));

        _0x1fff77._0xe1c845(msg.sender, address(this), _0xc4cb46);

        _0x0b1dba._0xe18385(int128(_0xcd8065), _0x2c7653, _0x6d0b67, true);

        uint256 _0xadb2ea = _0x0b1dba._0x3b8557(_0x2c7653, _0x6d0b67, 0);
        _0xc00ab4[_0xc4cb46] = _0xadb2ea;
        _0x66b852[_0xc4cb46] = block.timestamp;

        _0x2b75e6[msg.sender]._0xca4120(_0xc4cb46);

        emit Deposit(msg.sender, _0xc4cb46);
    }

    function _0xbd5c02(uint256 _0xc4cb46, uint8 _0xb0edc7) external _0x7acdab _0x94bbeb {
           require(_0x2b75e6[msg.sender]._0xfca870(_0xc4cb46), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        _0x1fff77._0x8e0812(
            INonfungiblePositionManager.CollectParams({
                _0xc4cb46: _0xc4cb46,
                _0x9216b8: msg.sender,
                _0xce2df3: type(uint128)._0x766911,
                _0x76b6cd: type(uint128)._0x766911
            })
        );

        (,,,,, int24 _0x2c7653, int24 _0x6d0b67, uint128 _0xf2d38b,,,,) = _0x1fff77._0xe0201b(_0xc4cb46);
        _0xd12db8(_0x2c7653, _0x6d0b67, _0xc4cb46, msg.sender, _0xb0edc7);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (_0xf2d38b != 0) {
            _0x0b1dba._0xe18385(-int128(_0xf2d38b), _0x2c7653, _0x6d0b67, true);
        }

        _0x2b75e6[msg.sender]._0x808cdd(_0xc4cb46);
        _0x1fff77._0xe1c845(address(this), msg.sender, _0xc4cb46);

        emit Withdraw(msg.sender, _0xc4cb46);
    }

    function _0x5978d7(uint256 _0xc4cb46, address _0x0895ad,uint8 _0xb0edc7 ) public _0x7acdab _0x125cda {

        require(_0x2b75e6[_0x0895ad]._0xfca870(_0xc4cb46), "NA");

        (,,,,, int24 _0x2c7653, int24 _0x6d0b67,,,,,) = _0x1fff77._0xe0201b(_0xc4cb46);
        _0xd12db8(_0x2c7653, _0x6d0b67, _0xc4cb46, _0x0895ad, _0xb0edc7);
    }

    function _0xd12db8(int24 _0x2c7653, int24 _0x6d0b67, uint256 _0xc4cb46,address _0x0895ad, uint8 _0xb0edc7) internal {
        _0x78ea27(_0xc4cb46, _0x2c7653, _0x6d0b67);
        uint256 _0x49c78b = _0x4a4046[_0xc4cb46];
        if(_0x49c78b > 0){
            delete _0x4a4046[_0xc4cb46];
            _0x3695ec._0xc23865(_0xf90e35, _0x49c78b);
            IRHYBR(_0xf90e35)._0x697f0d(_0x49c78b);
            IRHYBR(_0xf90e35)._0x63ea7e(_0x49c78b, _0xb0edc7, _0x0895ad);
        }
        emit Harvest(msg.sender, _0x49c78b);
    }

    function _0x672809(address _0xa510f9, uint256 _0x49c78b) external _0x7acdab
        _0x94bbeb _0x125cda returns (uint256 _0xa549ca) {
        require(_0xa510f9 == address(_0x3695ec), "Invalid reward token");

        // Update global reward growth before processing new rewards
        _0x0b1dba._0x54811e();

        // Calculate time remaining until next epoch begins
        uint256 _0xca741a = HybraTimeLibrary._0xa19aea(block.timestamp) - block.timestamp;
        uint256 _0xafdc19 = block.timestamp + _0xca741a;

        // Include any rolled over rewards from previous period
        uint256 _0xd8c118 = _0x49c78b + _0x0b1dba._0xe0ccc5();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _0x21caad) {
            // New period: distribute rewards over remaining epoch time
            _0x99a5c4 = _0x49c78b / _0xca741a;
            _0x0b1dba._0x2933bc({
                _0x99a5c4: _0x99a5c4,
                _0xbbe7e0: _0xd8c118,
                _0x13d13e: _0xafdc19
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 _0xa3ad2c = _0xca741a * _0x99a5c4;
            _0x99a5c4 = (_0x49c78b + _0xa3ad2c) / _0xca741a;
            _0x0b1dba._0x2933bc({
                _0x99a5c4: _0x99a5c4,
                _0xbbe7e0: _0xd8c118 + _0xa3ad2c,
                _0x13d13e: _0xafdc19
            });
        }

        // Store reward rate for current epoch tracking
        _0x876f44[HybraTimeLibrary._0xf9e925(block.timestamp)] = _0x99a5c4;

        // Transfer reward tokens from distributor to gauge
        _0x3695ec._0xe1c845(DISTRIBUTION, address(this), _0x49c78b);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 _0xd32afb = _0x3695ec._0x2a9d82(address(this));
        require(_0x99a5c4 <= _0xd32afb / _0xca741a, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _0x21caad = _0xafdc19;
        _0xa549ca = _0x99a5c4;

        emit RewardAdded(_0x49c78b);
    }

    function _0x7de2f9() external view returns (uint256 _0x1c2c35, uint256 _0xdf591d){

        (_0x1c2c35, _0xdf591d) = _0x0b1dba._0x4338a8();

    }

    function _0x415bf2() external _0x7acdab returns (uint256 _0x8cf07d, uint256 _0x4570d6) {
        return _0xacf43e();
    }

    function _0xacf43e() internal returns (uint256 _0x8cf07d, uint256 _0x4570d6) {
        if (!_0x5c4ead) {
            return (0, 0);
        }

        _0x0b1dba._0x96fe91();

        address _0x0c8b93 = _0x0b1dba._0x1c2c35();
        address _0x1ea582 = _0x0b1dba._0xdf591d();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        _0x8cf07d = IERC20(_0x0c8b93)._0x2a9d82(address(this));
        _0x4570d6 = IERC20(_0x1ea582)._0x2a9d82(address(this));

        if (_0x8cf07d > 0 || _0x4570d6 > 0) {

            uint256 _0x6063ab = _0x8cf07d;
            uint256 _0x71af79 = _0x4570d6;

            if (_0x6063ab  > 0) {
                IERC20(_0x0c8b93)._0xc23865(_0x3b84c3, 0);
                IERC20(_0x0c8b93)._0xc23865(_0x3b84c3, _0x6063ab);
                IBribe(_0x3b84c3)._0x672809(_0x0c8b93, _0x6063ab);
            }
            if (_0x71af79  > 0) {
                IERC20(_0x1ea582)._0xc23865(_0x3b84c3, 0);
                IERC20(_0x1ea582)._0xc23865(_0x3b84c3, _0x71af79);
                IBribe(_0x3b84c3)._0x672809(_0x1ea582, _0x71af79);
            }
            emit ClaimFees(msg.sender, _0x8cf07d, _0x4570d6);
        }
    }

    ///@notice get total reward for the duration
    function _0x965464() external view returns (uint256) {
        return _0x99a5c4 * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0x5e89cc(address _0xbb6359) external _0x8a32da {
        require(_0xbb6359 >= address(0), "zero");
        _0x3b84c3 = _0xbb6359;
    }

    function _0xf2e63b(address _0xa510f9,address _0xb13787,uint256 value) internal {
        require(_0xa510f9.code.length > 0);
        (bool _0x86f25d, bytes memory data) = _0xa510f9.call(abi._0x77f611(IERC20.transfer.selector, _0xb13787, value));
        require(_0x86f25d && (data.length == 0 || abi._0xb69e13(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function _0xeec473(
        address _0xa1049a,
        address from,
        uint256 _0xc4cb46,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0xeec473.selector;
    }

}

