// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './interfaces/IPair.sol';
import './interfaces/IBribe.sol';
import "./libraries/Math.sol";

import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import './interfaces/IRHYBR.sol';
interface IRewarder {
    function _0x705e90(
        address _0x677a35,
        address _0xff61c4,
        uint256 _0x5610c4
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable _0x9c48d5;
    bool public _0x6ca576;

    IERC20 public immutable _0xe554e7;
    IERC20 public immutable TOKEN;
    address public immutable _0xf6237b;
    address public VE;
    address public DISTRIBUTION;
    address public _0xf33612;
    address public _0x0b49ce;
    address public _0x2524ce;

    uint256 public DURATION;
    uint256 internal _0x3c01dc;
    uint256 public _0x8a4b89;
    uint256 public _0x65fe70;
    uint256 public _0xca2567;

    mapping(address => uint256) public _0xeedf3e;
    mapping(address => uint256) public _0x7257dd;

    uint256 internal _0xfbc3db;
    mapping(address => uint256) internal _0x1f624e;
    mapping(address => uint256) public _0xf90e6c;

    event RewardAdded(uint256 _0x8aec4b);
    event Deposit(address indexed _0x677a35, uint256 _0x957ead);
    event Withdraw(address indexed _0x677a35, uint256 _0x957ead);
    event Harvest(address indexed _0x677a35, uint256 _0x8aec4b);

    event ClaimFees(address indexed from, uint256 _0xc220c0, uint256 _0x2519a7);
    event EmergencyActivated(address indexed _0x29b729, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x29b729, uint256 timestamp);

    modifier _0x018025(address _0x647df5) {
        _0xca2567 = _0xff6159();
        _0x65fe70 = _0x79d2a4();
        if (_0x647df5 != address(0)) {
            _0x7257dd[_0x647df5] = _0xb0ccfb(_0x647df5);
            _0xeedf3e[_0x647df5] = _0xca2567;
        }
        _;
    }

    modifier _0x8bfb96() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier _0x038ae6() {
        require(_0x6ca576 == false, "EMER");
        _;
    }

    constructor(address _0x9cace0,address _0xd23796,address _0x421096,address _0xf32c5f,address _0xfac2fb, address _0x20ce35, address _0x538fd0, bool _0xf87d06) {
        _0xe554e7 = IERC20(_0x9cace0);     // main reward
        _0xf6237b = _0xd23796;
        VE = _0x421096;                               // vested
        TOKEN = IERC20(_0xf32c5f);                 // underlying (LP)
        DISTRIBUTION = _0xfac2fb;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0x0b49ce = _0x20ce35;       // lp fees goes here
        _0x2524ce = _0x538fd0;       // bribe fees goes here

        _0x9c48d5 = _0xf87d06;                 // pair boolean, if false no claim_fees

        _0x6ca576 = false;                      // emergency flag

    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    ONLY OWNER
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice set distribution address (should be GaugeManager)
    function _0x8050f2(address _0xfac2fb) external _0xc6687b {
        require(_0xfac2fb != address(0), "ZA");
        require(_0xfac2fb != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = _0xfac2fb;
    }

    ///@notice set gauge rewarder address
    function _0x12ee66(address _0xd6ade4) external _0xc6687b {
        require(_0xd6ade4 != _0xf33612, "SAME_ADDR");
        _0xf33612 = _0xd6ade4;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0xe40d17(address _0xa0393c) external _0xc6687b {
        require(_0xa0393c >= address(0), "ZA");
        _0x0b49ce = _0xa0393c;
    }

    function _0x3660b8() external _0xc6687b {
        require(_0x6ca576 == false, "EMER");
        _0x6ca576 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x0b5f4c() external _0xc6687b {

        require(_0x6ca576 == true,"EMER");

        _0x6ca576 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VIEW FUNCTIONS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice total supply held
    function _0x5ff905() public view returns (uint256) {
        return _0xfbc3db;
    }

    ///@notice balance of a user
    function _0xc54a0b(address _0x647df5) external view returns (uint256) {
        return _0xbe1d42(_0x647df5);
    }

    function _0xbe1d42(address _0x647df5) internal view returns (uint256) {

        return _0x1f624e[_0x647df5];
    }

    ///@notice last time reward
    function _0x79d2a4() public view returns (uint256) {
        return Math._0xf443cb(block.timestamp, _0x3c01dc);
    }

    ///@notice  reward for a sinle token
    function _0xff6159() public view returns (uint256) {
        if (_0xfbc3db == 0) {
            return _0xca2567;
        } else {
            return _0xca2567 + (_0x79d2a4() - _0x65fe70) * _0x8a4b89 * 1e18 / _0xfbc3db;
        }
    }

    ///@notice see earned rewards for user
    function _0xb0ccfb(address _0x647df5) public view returns (uint256) {
        return _0x7257dd[_0x647df5] + _0xbe1d42(_0x647df5) * (_0xff6159() - _0xeedf3e[_0x647df5]) / 1e18;
    }

    ///@notice get total reward for the duration
    function _0x5d5c0d() external view returns (uint256) {
        return _0x8a4b89 * DURATION;
    }

    function _0xa64f57() external view returns (uint256) {
        return _0x3c01dc;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    // send whole liquidity as additional param

    ///@notice deposit all TOKEN of msg.sender
    function _0x1a17be() external {
        _0x05c4cd(TOKEN._0xc54a0b(msg.sender), msg.sender);
    }

    ///@notice deposit amount TOKEN
    function _0x294d1c(uint256 _0x957ead) external {
        _0x05c4cd(_0x957ead, msg.sender);
    }

    ///@notice deposit internal
    function _0x05c4cd(uint256 _0x957ead, address _0x647df5) internal _0x3b813f _0x038ae6 _0x018025(_0x647df5) {
        require(_0x957ead > 0, "ZV");

        _0x1f624e[_0x647df5] = _0x1f624e[_0x647df5] + _0x957ead;
        _0xfbc3db = _0xfbc3db + _0x957ead;
        if (address(_0xf33612) != address(0)) {
            IRewarder(_0xf33612)._0x705e90(_0x647df5, _0x647df5, _0xbe1d42(_0x647df5));
        }

        TOKEN._0xd30d72(_0x647df5, address(this), _0x957ead);

        emit Deposit(_0x647df5, _0x957ead);
    }

    ///@notice withdraw all token
    function _0x88f737() external {
        _0x59eee2(_0xbe1d42(msg.sender));
    }

    ///@notice withdraw a certain amount of TOKEN
    function _0xba5475(uint256 _0x957ead) external {
        _0x59eee2(_0x957ead);
    }

    ///@notice withdraw internal
    function _0x59eee2(uint256 _0x957ead) internal _0x3b813f _0x038ae6 _0x018025(msg.sender) {
        require(_0x957ead > 0, "ZV");
        require(_0xbe1d42(msg.sender) > 0, "ZV");
        require(block.timestamp >= _0xf90e6c[msg.sender], "!MATURE");

        _0xfbc3db = _0xfbc3db - _0x957ead;
        _0x1f624e[msg.sender] = _0x1f624e[msg.sender] - _0x957ead;

        if (address(_0xf33612) != address(0)) {
            IRewarder(_0xf33612)._0x705e90(msg.sender, msg.sender,_0xbe1d42(msg.sender));
        }

        TOKEN._0x14172a(msg.sender, _0x957ead);

        emit Withdraw(msg.sender, _0x957ead);
    }

    function _0x638caa() external _0x3b813f {
        require(_0x6ca576, "EMER");
        uint256 _0x715042 = _0xbe1d42(msg.sender);
        require(_0x715042 > 0, "ZV");
        _0xfbc3db = _0xfbc3db - _0x715042;

        _0x1f624e[msg.sender] = 0;

        TOKEN._0x14172a(msg.sender, _0x715042);
        emit Withdraw(msg.sender, _0x715042);
    }

    function _0xd2ddbc(uint256 _0x715042) external _0x3b813f {

        require(_0x6ca576, "EMER");
        _0xfbc3db = _0xfbc3db - _0x715042;

        _0x1f624e[msg.sender] = _0x1f624e[msg.sender] - _0x715042;

        TOKEN._0x14172a(msg.sender, _0x715042);
        emit Withdraw(msg.sender, _0x715042);
    }

    ///@notice withdraw all TOKEN and harvest rewardToken
    function _0x824525(uint8 _0xec2241) external {
        _0x59eee2(_0xbe1d42(msg.sender));
        _0x799db6(_0xec2241);
    }

    ///@notice User harvest function called from distribution (GaugeManager allows harvest on multiple gauges)
    function _0x799db6(address _0x95bdb6, uint8 _0xec2241) public _0x3b813f _0x8bfb96 _0x018025(_0x95bdb6) {
        uint256 _0x8aec4b = _0x7257dd[_0x95bdb6];
        if (_0x8aec4b > 0) {
            _0x7257dd[_0x95bdb6] = 0;
            IERC20(_0xe554e7)._0x9fc3e3(_0xf6237b, _0x8aec4b);
            IRHYBR(_0xf6237b)._0x2ec0e0(_0x8aec4b);
            IRHYBR(_0xf6237b)._0xaf1135(_0x8aec4b, _0xec2241, _0x95bdb6);
            emit Harvest(_0x95bdb6, _0x8aec4b);
        }

        if (_0xf33612 != address(0)) {
            IRewarder(_0xf33612)._0x705e90(_0x95bdb6, _0x95bdb6, _0xbe1d42(_0x95bdb6));
        }
    }

    ///@notice User harvest function
    function _0x799db6(uint8 _0xec2241) public _0x3b813f _0x018025(msg.sender) {
        uint256 _0x8aec4b = _0x7257dd[msg.sender];
        if (_0x8aec4b > 0) {
            _0x7257dd[msg.sender] = 0;
            IERC20(_0xe554e7)._0x9fc3e3(_0xf6237b, _0x8aec4b);
            IRHYBR(_0xf6237b)._0x2ec0e0(_0x8aec4b);
            IRHYBR(_0xf6237b)._0xaf1135(_0x8aec4b, _0xec2241, msg.sender);
            emit Harvest(msg.sender, _0x8aec4b);
        }

        if (_0xf33612 != address(0)) {
            IRewarder(_0xf33612)._0x705e90(msg.sender, msg.sender, _0xbe1d42(msg.sender));
        }
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    DISTRIBUTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @dev Receive rewards from distribution

    function _0xd8333d(address _0xdaccff, uint256 _0x8aec4b) external _0x3b813f _0x038ae6 _0x8bfb96 _0x018025(address(0)) {
        require(_0xdaccff == address(_0xe554e7), "IA");
        _0xe554e7._0xd30d72(DISTRIBUTION, address(this), _0x8aec4b);

        if (block.timestamp >= _0x3c01dc) {
            _0x8a4b89 = _0x8aec4b / DURATION;
        } else {
            uint256 _0xf825c7 = _0x3c01dc - block.timestamp;
            uint256 _0x35267a = _0xf825c7 * _0x8a4b89;
            _0x8a4b89 = (_0x8aec4b + _0x35267a) / DURATION;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.

        // very high values of rewardRate in the earned and rewardsPerToken functions;

        uint256 balance = _0xe554e7._0xc54a0b(address(this));
        require(_0x8a4b89 <= balance / DURATION, "REWARD_HIGH");

        _0x65fe70 = block.timestamp;
        _0x3c01dc = block.timestamp + DURATION;
        emit RewardAdded(_0x8aec4b);
    }

    function _0xd0ff1b() external _0x3b813f returns (uint256 _0xc220c0, uint256 _0x2519a7) {
        return _0x2cd166();
    }

     function _0x2cd166() internal returns (uint256 _0xc220c0, uint256 _0x2519a7) {
        if (!_0x9c48d5) {
            return (0, 0);
        }
        address _0xf32c5f = address(TOKEN);
        (_0xc220c0, _0x2519a7) = IPair(_0xf32c5f)._0xd0ff1b();
        if (_0xc220c0 > 0 || _0x2519a7 > 0) {

            uint256 _0x822b25 = _0xc220c0;
            uint256 _0xcf646e = _0x2519a7;

            (address _0x1381f6, address _0x105283) = IPair(_0xf32c5f)._0xbf4cc2();

            if (_0x822b25  > 0) {
                IERC20(_0x1381f6)._0x9fc3e3(_0x0b49ce, 0);
                IERC20(_0x1381f6)._0x9fc3e3(_0x0b49ce, _0x822b25);
                IBribe(_0x0b49ce)._0xd8333d(_0x1381f6, _0x822b25);
            }
            if (_0xcf646e  > 0) {
                IERC20(_0x105283)._0x9fc3e3(_0x0b49ce, 0);
                IERC20(_0x105283)._0x9fc3e3(_0x0b49ce, _0xcf646e);
                IBribe(_0x0b49ce)._0xd8333d(_0x105283, _0xcf646e);
            }
            emit ClaimFees(msg.sender, _0xc220c0, _0x2519a7);
        }
    }

}