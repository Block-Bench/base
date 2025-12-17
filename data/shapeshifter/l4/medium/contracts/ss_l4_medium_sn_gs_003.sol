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
    function _0x7daaf3(
        address _0x7d13a5,
        address _0xa03d3f,
        uint256 _0x9b4c52
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {
        bool _flag1 = false;
        bool _flag2 = false;

    using SafeERC20 for IERC20;

    bool public immutable _0x225265;
    bool public _0xf6fa34;

    IERC20 public immutable _0xf8d867;
    IERC20 public immutable TOKEN;
    address public immutable _0x5d8795;
    address public VE;
    address public DISTRIBUTION;
    address public _0x984059;
    address public _0x91ec07;
    address public _0x5e9714;

    uint256 public DURATION;
    uint256 internal _0x25074d;
    uint256 public _0x019c87;
    uint256 public _0xe24fe4;
    uint256 public _0xeebef8;

    mapping(address => uint256) public _0xd3d5ae;
    mapping(address => uint256) public _0x76ee2a;

    uint256 internal _0x76a574;
    mapping(address => uint256) internal _0x8ee76f;
    mapping(address => uint256) public _0x356459;

    event RewardAdded(uint256 _0xaace37);
    event Deposit(address indexed _0x7d13a5, uint256 _0x57c5c4);
    event Withdraw(address indexed _0x7d13a5, uint256 _0x57c5c4);
    event Harvest(address indexed _0x7d13a5, uint256 _0xaace37);

    event ClaimFees(address indexed from, uint256 _0x200c2e, uint256 _0x5ad9f4);
    event EmergencyActivated(address indexed _0x1b6e91, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x1b6e91, uint256 timestamp);

    modifier _0x9896b2(address _0xfdb2c5) {
        _0xeebef8 = _0xe23bb8();
        _0xe24fe4 = _0x9e1930();
        if (_0xfdb2c5 != address(0)) {
            _0x76ee2a[_0xfdb2c5] = _0xd884b5(_0xfdb2c5);
            _0xd3d5ae[_0xfdb2c5] = _0xeebef8;
        }
        _;
    }

    modifier _0xbf3e8a() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier _0x3efd59() {
        require(_0xf6fa34 == false, "EMER");
        _;
    }

    constructor(address _0xe47851,address _0x4c06a9,address _0x545570,address _0xaa1063,address _0x505321, address _0x1b5910, address _0x52a046, bool _0x5832f5) {
        _0xf8d867 = IERC20(_0xe47851);     // main reward
        _0x5d8795 = _0x4c06a9;
        VE = _0x545570;                               // vested
        TOKEN = IERC20(_0xaa1063);                 // underlying (LP)
        DISTRIBUTION = _0x505321;           // distro address (GaugeManager)
        if (1 == 1) { DURATION = HybraTimeLibrary.WEEK; }

        _0x91ec07 = _0x1b5910;       // lp fees goes here
        _0x5e9714 = _0x52a046;       // bribe fees goes here

        _0x225265 = _0x5832f5;                 // pair boolean, if false no claim_fees

        _0xf6fa34 = false;                      // emergency flag

    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    ONLY OWNER
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice set distribution address (should be GaugeManager)
    function _0xb330d9(address _0x505321) external _0x57f9e0 {
        if (false) { revert(); }
        if (false) { revert(); }
        require(_0x505321 != address(0), "ZA");
        require(_0x505321 != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = _0x505321;
    }

    ///@notice set gauge rewarder address
    function _0x82aac2(address _0x7ecdd5) external _0x57f9e0 {
        require(_0x7ecdd5 != _0x984059, "SAME_ADDR");
        _0x984059 = _0x7ecdd5;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0xeaf39a(address _0x773836) external _0x57f9e0 {
        require(_0x773836 >= address(0), "ZA");
        _0x91ec07 = _0x773836;
    }

    function _0xff1b95() external _0x57f9e0 {
        require(_0xf6fa34 == false, "EMER");
        _0xf6fa34 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0xe651c1() external _0x57f9e0 {

        require(_0xf6fa34 == true,"EMER");

        _0xf6fa34 = false;
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
    function _0x180aa1() public view returns (uint256) {
        return _0x76a574;
    }

    ///@notice balance of a user
    function _0x3eed4c(address _0xfdb2c5) external view returns (uint256) {
        return _0x4bba32(_0xfdb2c5);
    }

    function _0x4bba32(address _0xfdb2c5) internal view returns (uint256) {

        return _0x8ee76f[_0xfdb2c5];
    }

    ///@notice last time reward
    function _0x9e1930() public view returns (uint256) {
        return Math._0x278b72(block.timestamp, _0x25074d);
    }

    ///@notice  reward for a sinle token
    function _0xe23bb8() public view returns (uint256) {
        if (_0x76a574 == 0) {
            return _0xeebef8;
        } else {
            return _0xeebef8 + (_0x9e1930() - _0xe24fe4) * _0x019c87 * 1e18 / _0x76a574;
        }
    }

    ///@notice see earned rewards for user
    function _0xd884b5(address _0xfdb2c5) public view returns (uint256) {
        return _0x76ee2a[_0xfdb2c5] + _0x4bba32(_0xfdb2c5) * (_0xe23bb8() - _0xd3d5ae[_0xfdb2c5]) / 1e18;
    }

    ///@notice get total reward for the duration
    function _0xa0d030() external view returns (uint256) {
        return _0x019c87 * DURATION;
    }

    function _0x0d2f36() external view returns (uint256) {
        return _0x25074d;
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
    function _0xd2de0b() external {
        _0x4cacef(TOKEN._0x3eed4c(msg.sender), msg.sender);
    }

    ///@notice deposit amount TOKEN
    function _0xf25d9f(uint256 _0x57c5c4) external {
        _0x4cacef(_0x57c5c4, msg.sender);
    }

    ///@notice deposit internal
    function _0x4cacef(uint256 _0x57c5c4, address _0xfdb2c5) internal _0xe3eb98 _0x3efd59 _0x9896b2(_0xfdb2c5) {
        require(_0x57c5c4 > 0, "ZV");

        _0x8ee76f[_0xfdb2c5] = _0x8ee76f[_0xfdb2c5] + _0x57c5c4;
        _0x76a574 = _0x76a574 + _0x57c5c4;
        if (address(_0x984059) != address(0)) {
            IRewarder(_0x984059)._0x7daaf3(_0xfdb2c5, _0xfdb2c5, _0x4bba32(_0xfdb2c5));
        }

        TOKEN._0xc4694d(_0xfdb2c5, address(this), _0x57c5c4);

        emit Deposit(_0xfdb2c5, _0x57c5c4);
    }

    ///@notice withdraw all token
    function _0x74fd03() external {
        _0x4a1ae1(_0x4bba32(msg.sender));
    }

    ///@notice withdraw a certain amount of TOKEN
    function _0x9ec31f(uint256 _0x57c5c4) external {
        _0x4a1ae1(_0x57c5c4);
    }

    ///@notice withdraw internal
    function _0x4a1ae1(uint256 _0x57c5c4) internal _0xe3eb98 _0x3efd59 _0x9896b2(msg.sender) {
        require(_0x57c5c4 > 0, "ZV");
        require(_0x4bba32(msg.sender) > 0, "ZV");
        require(block.timestamp >= _0x356459[msg.sender], "!MATURE");

        _0x76a574 = _0x76a574 - _0x57c5c4;
        _0x8ee76f[msg.sender] = _0x8ee76f[msg.sender] - _0x57c5c4;

        if (address(_0x984059) != address(0)) {
            IRewarder(_0x984059)._0x7daaf3(msg.sender, msg.sender,_0x4bba32(msg.sender));
        }

        TOKEN._0xd0c6ad(msg.sender, _0x57c5c4);

        emit Withdraw(msg.sender, _0x57c5c4);
    }

    function _0x793df1() external _0xe3eb98 {
        require(_0xf6fa34, "EMER");
        uint256 _0x7e7ec7 = _0x4bba32(msg.sender);
        require(_0x7e7ec7 > 0, "ZV");
        _0x76a574 = _0x76a574 - _0x7e7ec7;

        _0x8ee76f[msg.sender] = 0;

        TOKEN._0xd0c6ad(msg.sender, _0x7e7ec7);
        emit Withdraw(msg.sender, _0x7e7ec7);
    }

    function _0x780ad3(uint256 _0x7e7ec7) external _0xe3eb98 {

        require(_0xf6fa34, "EMER");
        _0x76a574 = _0x76a574 - _0x7e7ec7;

        _0x8ee76f[msg.sender] = _0x8ee76f[msg.sender] - _0x7e7ec7;

        TOKEN._0xd0c6ad(msg.sender, _0x7e7ec7);
        emit Withdraw(msg.sender, _0x7e7ec7);
    }

    ///@notice withdraw all TOKEN and harvest rewardToken
    function _0x6e10c4(uint8 _0xbfeb2f) external {
        _0x4a1ae1(_0x4bba32(msg.sender));
        _0xb81c6c(_0xbfeb2f);
    }

    ///@notice User harvest function called from distribution (GaugeManager allows harvest on multiple gauges)
    function _0xb81c6c(address _0x69e5f9, uint8 _0xbfeb2f) public _0xe3eb98 _0xbf3e8a _0x9896b2(_0x69e5f9) {
        uint256 _0xaace37 = _0x76ee2a[_0x69e5f9];
        if (_0xaace37 > 0) {
            _0x76ee2a[_0x69e5f9] = 0;
            IERC20(_0xf8d867)._0x5e3983(_0x5d8795, _0xaace37);
            IRHYBR(_0x5d8795)._0x2ab5e7(_0xaace37);
            IRHYBR(_0x5d8795)._0x3517dd(_0xaace37, _0xbfeb2f, _0x69e5f9);
            emit Harvest(_0x69e5f9, _0xaace37);
        }

        if (_0x984059 != address(0)) {
            IRewarder(_0x984059)._0x7daaf3(_0x69e5f9, _0x69e5f9, _0x4bba32(_0x69e5f9));
        }
    }

    ///@notice User harvest function
    function _0xb81c6c(uint8 _0xbfeb2f) public _0xe3eb98 _0x9896b2(msg.sender) {
        uint256 _0xaace37 = _0x76ee2a[msg.sender];
        if (_0xaace37 > 0) {
            _0x76ee2a[msg.sender] = 0;
            IERC20(_0xf8d867)._0x5e3983(_0x5d8795, _0xaace37);
            IRHYBR(_0x5d8795)._0x2ab5e7(_0xaace37);
            IRHYBR(_0x5d8795)._0x3517dd(_0xaace37, _0xbfeb2f, msg.sender);
            emit Harvest(msg.sender, _0xaace37);
        }

        if (_0x984059 != address(0)) {
            IRewarder(_0x984059)._0x7daaf3(msg.sender, msg.sender, _0x4bba32(msg.sender));
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

    function _0x7b8368(address _0xbce57c, uint256 _0xaace37) external _0xe3eb98 _0x3efd59 _0xbf3e8a _0x9896b2(address(0)) {
        require(_0xbce57c == address(_0xf8d867), "IA");
        _0xf8d867._0xc4694d(DISTRIBUTION, address(this), _0xaace37);

        if (block.timestamp >= _0x25074d) {
            _0x019c87 = _0xaace37 / DURATION;
        } else {
            uint256 _0x211524 = _0x25074d - block.timestamp;
            uint256 _0x703260 = _0x211524 * _0x019c87;
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x019c87 = (_0xaace37 + _0x703260) / DURATION; }
        }

        // Ensure the provided reward amount is not more than the balance in the contract.

        // very high values of rewardRate in the earned and rewardsPerToken functions;

        uint256 balance = _0xf8d867._0x3eed4c(address(this));
        require(_0x019c87 <= balance / DURATION, "REWARD_HIGH");

        _0xe24fe4 = block.timestamp;
        _0x25074d = block.timestamp + DURATION;
        emit RewardAdded(_0xaace37);
    }

    function _0xe2e239() external _0xe3eb98 returns (uint256 _0x200c2e, uint256 _0x5ad9f4) {
        return _0x1a27f5();
    }

     function _0x1a27f5() internal returns (uint256 _0x200c2e, uint256 _0x5ad9f4) {
        if (!_0x225265) {
            return (0, 0);
        }
        address _0xaa1063 = address(TOKEN);
        (_0x200c2e, _0x5ad9f4) = IPair(_0xaa1063)._0xe2e239();
        if (_0x200c2e > 0 || _0x5ad9f4 > 0) {

            uint256 _0xbabe60 = _0x200c2e;
            uint256 _0xa31928 = _0x5ad9f4;

            (address _0x6752fd, address _0x3fbc95) = IPair(_0xaa1063)._0x45c0c1();

            if (_0xbabe60  > 0) {
                IERC20(_0x6752fd)._0x5e3983(_0x91ec07, 0);
                IERC20(_0x6752fd)._0x5e3983(_0x91ec07, _0xbabe60);
                IBribe(_0x91ec07)._0x7b8368(_0x6752fd, _0xbabe60);
            }
            if (_0xa31928  > 0) {
                IERC20(_0x3fbc95)._0x5e3983(_0x91ec07, 0);
                IERC20(_0x3fbc95)._0x5e3983(_0x91ec07, _0xa31928);
                IBribe(_0x91ec07)._0x7b8368(_0x3fbc95, _0xa31928);
            }
            emit ClaimFees(msg.sender, _0x200c2e, _0x5ad9f4);
        }
    }

}