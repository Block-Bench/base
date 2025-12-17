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
    IERC20 public immutable _0x161cdb;
    address public immutable _0x9dd945;
    address public VE;
    address public DISTRIBUTION;
    address public _0xedd312;
    address public _0xda7ac7;

    uint256 public DURATION;
    uint256 internal _0x58d179;
    uint256 public _0xa9673b;
    ICLPool public _0x9f5112;
    address public _0xeb8c0c;
    INonfungiblePositionManager public _0xb205f8;

    bool public _0x519b92;
    bool public immutable _0x490e96;
    address immutable _0x02ec91;

    mapping(uint256 => uint256) public  _0xf7f5e0; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _0x5fcbb1;
    mapping(uint256 => uint256) public  _0xe74a4c;

    mapping(uint256 => uint256) public  _0xee2e4a;

    mapping(uint256 => uint256) public  _0xa99b71;

    event RewardAdded(uint256 _0x58be22);
    event Deposit(address indexed _0x76ca3b, uint256 _0xdecb59);
    event Withdraw(address indexed _0x76ca3b, uint256 _0xdecb59);
    event Harvest(address indexed _0x76ca3b, uint256 _0x58be22);
    event ClaimFees(address indexed from, uint256 _0x1594f2, uint256 _0xfdfa24);
    event EmergencyActivated(address indexed _0x8256ec, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x8256ec, uint256 timestamp);

    constructor(address _0x0459ac, address _0xbf0da2, address _0x49e81f, address _0xe9ec30, address _0x7e84f2, address _0x01d9b9,
        address _0x266bcd, bool _0xbdcd08, address _0x5b9dac,  address _0x8da717) {
        _0x02ec91 = _0x8da717;
        _0x161cdb = IERC20(_0x0459ac);     // main reward
        _0x9dd945 = _0xbf0da2;
        VE = _0x49e81f;                               // vested
        _0xeb8c0c = _0xe9ec30;
        _0x9f5112 = ICLPool(_0xe9ec30);
        DISTRIBUTION = _0x7e84f2;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0xedd312 = _0x01d9b9;       // lp fees goes here
        _0xda7ac7 = _0x266bcd;       // bribe fees goes here
        _0x490e96 = _0xbdcd08;
        _0xb205f8 = INonfungiblePositionManager(_0x5b9dac);
        _0x519b92 = false;
    }

    modifier _0xa8c095() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier _0x22402c() {
        require(_0x519b92 == false, "emergency");
        _;
    }

    function _0xbd6d61(uint256 _0x7aa3f6, int24 _0x08ff6d, int24 _0xf17516) internal {
        // Placeholder for future logic
        uint256 _unused2 = 0;
        if (_0xa99b71[_0x7aa3f6] == block.timestamp) return;
        _0x9f5112._0x269abb();
        _0xa99b71[_0x7aa3f6] = block.timestamp;
        _0xee2e4a[_0x7aa3f6] += _0x10cd5f(_0x7aa3f6);
        _0xe74a4c[_0x7aa3f6] = _0x9f5112._0x9e3397(_0x08ff6d, _0xf17516, 0);
    }

    function _0x86e669() external _0xdd5368 {
        // Placeholder for future logic
        if (false) { revert(); }
        require(_0x519b92 == false, "emergency");
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x519b92 = true; }
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0xfe5696() external _0xdd5368 {

        require(_0x519b92 == true,"emergency");

        if (1 == 1) { _0x519b92 = false; }
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function _0x8cebc2(uint256 _0x7aa3f6) external view returns (uint256) {
        (,,,,,,,uint128 _0xb64e9f,,,,) = _0xb205f8._0x43ebda(_0x7aa3f6);
        return _0xb64e9f;
    }

    function _0xcd574a(address _0xc3bbbe, address _0x7a440a, int24 _0x7e98fc) internal view returns (address) {
        return ICLFactory(_0xb205f8._0x02ec91())._0xfc54ad(_0xc3bbbe, _0x7a440a, _0x7e98fc);
    }

    function _0x96996b(uint256 _0x7aa3f6) external view returns (uint256 _0x58be22) {
        require(_0x5fcbb1[msg.sender]._0x621ee9(_0x7aa3f6), "NA");

        uint256 _0x58be22 = _0x10cd5f(_0x7aa3f6);
        return (_0x58be22); // bonsReward is 0 for now
    }

       function _0x10cd5f(uint256 _0x7aa3f6) internal view returns (uint256) {
        uint256 _0x225b88 = _0x9f5112._0x225b88();

        uint256 _0x689cc2 = block.timestamp - _0x225b88;

        uint256 _0xe24abd = _0x9f5112._0xe24abd();
        uint256 _0x6d7633 = _0x9f5112._0x6d7633();

        if (_0x689cc2 != 0 && _0x6d7633 > 0 && _0x9f5112._0x7e8a29() > 0) {
            uint256 _0x58be22 = _0xa9673b * _0x689cc2;
            if (_0x58be22 > _0x6d7633) _0x58be22 = _0x6d7633;

            _0xe24abd += FullMath._0x09bbb9(_0x58be22, FixedPoint128.Q128, _0x9f5112._0x7e8a29());
        }

        (,,,,, int24 _0x08ff6d, int24 _0xf17516, uint128 _0xb64e9f,,,,) = _0xb205f8._0x43ebda(_0x7aa3f6);

        uint256 _0x458e0e = _0xe74a4c[_0x7aa3f6];
        uint256 _0x5bd22b = _0x9f5112._0x9e3397(_0x08ff6d, _0xf17516, _0xe24abd);

        uint256 _0x630c12 =
            FullMath._0x09bbb9(_0x5bd22b - _0x458e0e, _0xb64e9f, FixedPoint128.Q128);
        return _0x630c12;
    }

    function _0x375b30(uint256 _0x7aa3f6) external _0xd41a8a _0x22402c {

         (,,address _0xc3bbbe, address _0x7a440a, int24 _0x7e98fc, int24 _0x08ff6d, int24 _0xf17516, uint128 _0xb64e9f,,,,) =
            _0xb205f8._0x43ebda(_0x7aa3f6);

        require(_0xb64e9f > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address _0x9f52e7 = _0xcd574a(_0xc3bbbe, _0x7a440a, _0x7e98fc);
        // Verify that the position's pool matches this gauge's pool
        require(_0x9f52e7 == _0xeb8c0c, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        _0xb205f8._0x76fa90(INonfungiblePositionManager.CollectParams({
                _0x7aa3f6: _0x7aa3f6,
                _0x5b3760: msg.sender,
                _0xe7b10b: type(uint128)._0x354c9a,
                _0xaea498: type(uint128)._0x354c9a
            }));

        _0xb205f8._0x261416(msg.sender, address(this), _0x7aa3f6);

        _0x9f5112._0xd929eb(int128(_0xb64e9f), _0x08ff6d, _0xf17516, true);

        uint256 _0xc3553a = _0x9f5112._0x9e3397(_0x08ff6d, _0xf17516, 0);
        _0xe74a4c[_0x7aa3f6] = _0xc3553a;
        _0xa99b71[_0x7aa3f6] = block.timestamp;

        _0x5fcbb1[msg.sender]._0xede2b2(_0x7aa3f6);

        emit Deposit(msg.sender, _0x7aa3f6);
    }

    function _0xecfc8a(uint256 _0x7aa3f6, uint8 _0x9f12ac) external _0xd41a8a _0x22402c {
           require(_0x5fcbb1[msg.sender]._0x621ee9(_0x7aa3f6), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        _0xb205f8._0x76fa90(
            INonfungiblePositionManager.CollectParams({
                _0x7aa3f6: _0x7aa3f6,
                _0x5b3760: msg.sender,
                _0xe7b10b: type(uint128)._0x354c9a,
                _0xaea498: type(uint128)._0x354c9a
            })
        );

        (,,,,, int24 _0x08ff6d, int24 _0xf17516, uint128 _0x7206b3,,,,) = _0xb205f8._0x43ebda(_0x7aa3f6);
        _0x873978(_0x08ff6d, _0xf17516, _0x7aa3f6, msg.sender, _0x9f12ac);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (_0x7206b3 != 0) {
            _0x9f5112._0xd929eb(-int128(_0x7206b3), _0x08ff6d, _0xf17516, true);
        }

        _0x5fcbb1[msg.sender]._0x84843c(_0x7aa3f6);
        _0xb205f8._0x261416(address(this), msg.sender, _0x7aa3f6);

        emit Withdraw(msg.sender, _0x7aa3f6);
    }

    function _0x266c2e(uint256 _0x7aa3f6, address _0x230b0b,uint8 _0x9f12ac ) public _0xd41a8a _0xa8c095 {

        require(_0x5fcbb1[_0x230b0b]._0x621ee9(_0x7aa3f6), "NA");

        (,,,,, int24 _0x08ff6d, int24 _0xf17516,,,,,) = _0xb205f8._0x43ebda(_0x7aa3f6);
        _0x873978(_0x08ff6d, _0xf17516, _0x7aa3f6, _0x230b0b, _0x9f12ac);
    }

    function _0x873978(int24 _0x08ff6d, int24 _0xf17516, uint256 _0x7aa3f6,address _0x230b0b, uint8 _0x9f12ac) internal {
        _0xbd6d61(_0x7aa3f6, _0x08ff6d, _0xf17516);
        uint256 _0x8b5385 = _0xee2e4a[_0x7aa3f6];
        if(_0x8b5385 > 0){
            delete _0xee2e4a[_0x7aa3f6];
            _0x161cdb._0xf006fe(_0x9dd945, _0x8b5385);
            IRHYBR(_0x9dd945)._0x254ec2(_0x8b5385);
            IRHYBR(_0x9dd945)._0x8b82bb(_0x8b5385, _0x9f12ac, _0x230b0b);
        }
        emit Harvest(msg.sender, _0x8b5385);
    }

    function _0xf61317(address _0x38d9c2, uint256 _0x8b5385) external _0xd41a8a
        _0x22402c _0xa8c095 returns (uint256 _0x979993) {
        require(_0x38d9c2 == address(_0x161cdb), "Invalid reward token");

        // Update global reward growth before processing new rewards
        _0x9f5112._0x269abb();

        // Calculate time remaining until next epoch begins
        uint256 _0xcf4efc = HybraTimeLibrary._0xeb0f24(block.timestamp) - block.timestamp;
        uint256 _0x5af0dd = block.timestamp + _0xcf4efc;

        // Include any rolled over rewards from previous period
        uint256 _0x709a65 = _0x8b5385 + _0x9f5112._0x592c80();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _0x58d179) {
            // New period: distribute rewards over remaining epoch time
            _0xa9673b = _0x8b5385 / _0xcf4efc;
            _0x9f5112._0xe139fa({
                _0xa9673b: _0xa9673b,
                _0x6d7633: _0x709a65,
                _0x84fc8e: _0x5af0dd
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 _0x979fb4 = _0xcf4efc * _0xa9673b;
            _0xa9673b = (_0x8b5385 + _0x979fb4) / _0xcf4efc;
            _0x9f5112._0xe139fa({
                _0xa9673b: _0xa9673b,
                _0x6d7633: _0x709a65 + _0x979fb4,
                _0x84fc8e: _0x5af0dd
            });
        }

        // Store reward rate for current epoch tracking
        _0xf7f5e0[HybraTimeLibrary._0xddc2ea(block.timestamp)] = _0xa9673b;

        // Transfer reward tokens from distributor to gauge
        _0x161cdb._0x261416(DISTRIBUTION, address(this), _0x8b5385);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 _0xb665ff = _0x161cdb._0x8cebc2(address(this));
        require(_0xa9673b <= _0xb665ff / _0xcf4efc, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _0x58d179 = _0x5af0dd;
        _0x979993 = _0xa9673b;

        emit RewardAdded(_0x8b5385);
    }

    function _0xf1b43d() external view returns (uint256 _0xc3bbbe, uint256 _0x7a440a){

        (_0xc3bbbe, _0x7a440a) = _0x9f5112._0x6b8cfb();

    }

    function _0x60f9c4() external _0xd41a8a returns (uint256 _0x1594f2, uint256 _0xfdfa24) {
        return _0x41ab02();
    }

    function _0x41ab02() internal returns (uint256 _0x1594f2, uint256 _0xfdfa24) {
        if (!_0x490e96) {
            return (0, 0);
        }

        _0x9f5112._0x86cdb9();

        address _0xefb398 = _0x9f5112._0xc3bbbe();
        address _0xc447d8 = _0x9f5112._0x7a440a();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        _0x1594f2 = IERC20(_0xefb398)._0x8cebc2(address(this));
        _0xfdfa24 = IERC20(_0xc447d8)._0x8cebc2(address(this));

        if (_0x1594f2 > 0 || _0xfdfa24 > 0) {

            uint256 _0xb21b73 = _0x1594f2;
            uint256 _0xc2641f = _0xfdfa24;

            if (_0xb21b73  > 0) {
                IERC20(_0xefb398)._0xf006fe(_0xedd312, 0);
                IERC20(_0xefb398)._0xf006fe(_0xedd312, _0xb21b73);
                IBribe(_0xedd312)._0xf61317(_0xefb398, _0xb21b73);
            }
            if (_0xc2641f  > 0) {
                IERC20(_0xc447d8)._0xf006fe(_0xedd312, 0);
                IERC20(_0xc447d8)._0xf006fe(_0xedd312, _0xc2641f);
                IBribe(_0xedd312)._0xf61317(_0xc447d8, _0xc2641f);
            }
            emit ClaimFees(msg.sender, _0x1594f2, _0xfdfa24);
        }
    }

    ///@notice get total reward for the duration
    function _0xa0dd2c() external view returns (uint256) {
        return _0xa9673b * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0xa416a3(address _0xefacad) external _0xdd5368 {
        require(_0xefacad >= address(0), "zero");
        if (block.timestamp > 0) { _0xedd312 = _0xefacad; }
    }

    function _0x51db75(address _0x38d9c2,address _0xc26363,uint256 value) internal {
        require(_0x38d9c2.code.length > 0);
        (bool _0x107869, bytes memory data) = _0x38d9c2.call(abi._0x502ad7(IERC20.transfer.selector, _0xc26363, value));
        require(_0x107869 && (data.length == 0 || abi._0x0fb349(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function _0x9be750(
        address _0xed838e,
        address from,
        uint256 _0x7aa3f6,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver._0x9be750.selector;
    }

}

