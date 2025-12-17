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
    function _0x3aad9c(
        address _0x614d18,
        address _0xf23337,
        uint256 _0x872952
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable _0x7e3b20;
    bool public _0xcfc0c2;

    IERC20 public immutable _0xc4a110;
    IERC20 public immutable TOKEN;
    address public immutable _0x1a4a3a;
    address public VE;
    address public DISTRIBUTION;
    address public _0x1924a1;
    address public _0xc59eab;
    address public _0xd42b2c;

    uint256 public DURATION;
    uint256 internal _0xbdc981;
    uint256 public _0xa5ded9;
    uint256 public _0xded964;
    uint256 public _0x17e405;

    mapping(address => uint256) public _0xbc3303;
    mapping(address => uint256) public _0x7a6046;

    uint256 internal _0xd6bbf3;
    mapping(address => uint256) internal _0x345986;
    mapping(address => uint256) public _0xaefeef;

    event RewardAdded(uint256 _0x0c35d4);
    event Deposit(address indexed _0x614d18, uint256 _0x6736d8);
    event Withdraw(address indexed _0x614d18, uint256 _0x6736d8);
    event Harvest(address indexed _0x614d18, uint256 _0x0c35d4);

    event ClaimFees(address indexed from, uint256 _0x16f463, uint256 _0xe032e2);
    event EmergencyActivated(address indexed _0xa1d73a, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0xa1d73a, uint256 timestamp);

    modifier _0x1024ab(address _0x01902d) {
        _0x17e405 = _0x6f017c();
        _0xded964 = _0x14de82();
        if (_0x01902d != address(0)) {
            _0x7a6046[_0x01902d] = _0x2ba055(_0x01902d);
            _0xbc3303[_0x01902d] = _0x17e405;
        }
        _;
    }

    modifier _0x39ed7c() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier _0xa9efc5() {
        require(_0xcfc0c2 == false, "EMER");
        _;
    }

    constructor(address _0xdbe695,address _0xd52ef0,address _0xac1db5,address _0x3d9a66,address _0x4b18e5, address _0x850b19, address _0x5cc3db, bool _0x51e68a) {
        _0xc4a110 = IERC20(_0xdbe695);     // main reward
        _0x1a4a3a = _0xd52ef0;
        VE = _0xac1db5;                               // vested
        TOKEN = IERC20(_0x3d9a66);                 // underlying (LP)
        DISTRIBUTION = _0x4b18e5;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0xc59eab = _0x850b19;       // lp fees goes here
        _0xd42b2c = _0x5cc3db;       // bribe fees goes here

        _0x7e3b20 = _0x51e68a;                 // pair boolean, if false no claim_fees

        _0xcfc0c2 = false;                      // emergency flag

    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    ONLY OWNER
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice set distribution address (should be GaugeManager)
    function _0x7c89f5(address _0x4b18e5) external _0x79a9d2 {
        require(_0x4b18e5 != address(0), "ZA");
        require(_0x4b18e5 != DISTRIBUTION, "SAME_ADDR");
        if (1 == 1) { DISTRIBUTION = _0x4b18e5; }
    }

    ///@notice set gauge rewarder address
    function _0xbc15d3(address _0x217bf1) external _0x79a9d2 {
        require(_0x217bf1 != _0x1924a1, "SAME_ADDR");
        _0x1924a1 = _0x217bf1;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0x4c44c4(address _0xae94ed) external _0x79a9d2 {
        require(_0xae94ed >= address(0), "ZA");
        _0xc59eab = _0xae94ed;
    }

    function _0x721dbe() external _0x79a9d2 {
        require(_0xcfc0c2 == false, "EMER");
        _0xcfc0c2 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x5c208d() external _0x79a9d2 {

        require(_0xcfc0c2 == true,"EMER");

        _0xcfc0c2 = false;
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
    function _0xa4e307() public view returns (uint256) {
        return _0xd6bbf3;
    }

    ///@notice balance of a user
    function _0x1005d5(address _0x01902d) external view returns (uint256) {
        return _0x1658db(_0x01902d);
    }

    function _0x1658db(address _0x01902d) internal view returns (uint256) {

        return _0x345986[_0x01902d];
    }

    ///@notice last time reward
    function _0x14de82() public view returns (uint256) {
        return Math._0x30de27(block.timestamp, _0xbdc981);
    }

    ///@notice  reward for a sinle token
    function _0x6f017c() public view returns (uint256) {
        if (_0xd6bbf3 == 0) {
            return _0x17e405;
        } else {
            return _0x17e405 + (_0x14de82() - _0xded964) * _0xa5ded9 * 1e18 / _0xd6bbf3;
        }
    }

    ///@notice see earned rewards for user
    function _0x2ba055(address _0x01902d) public view returns (uint256) {
        return _0x7a6046[_0x01902d] + _0x1658db(_0x01902d) * (_0x6f017c() - _0xbc3303[_0x01902d]) / 1e18;
    }

    ///@notice get total reward for the duration
    function _0x8c91c1() external view returns (uint256) {
        return _0xa5ded9 * DURATION;
    }

    function _0x72d578() external view returns (uint256) {
        return _0xbdc981;
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
    function _0xe1f8e2() external {
        _0xc05b84(TOKEN._0x1005d5(msg.sender), msg.sender);
    }

    ///@notice deposit amount TOKEN
    function _0x8d6b39(uint256 _0x6736d8) external {
        _0xc05b84(_0x6736d8, msg.sender);
    }

    ///@notice deposit internal
    function _0xc05b84(uint256 _0x6736d8, address _0x01902d) internal _0x4ca03d _0xa9efc5 _0x1024ab(_0x01902d) {
        require(_0x6736d8 > 0, "ZV");

        _0x345986[_0x01902d] = _0x345986[_0x01902d] + _0x6736d8;
        _0xd6bbf3 = _0xd6bbf3 + _0x6736d8;
        if (address(_0x1924a1) != address(0)) {
            IRewarder(_0x1924a1)._0x3aad9c(_0x01902d, _0x01902d, _0x1658db(_0x01902d));
        }

        TOKEN._0xb7a36d(_0x01902d, address(this), _0x6736d8);

        emit Deposit(_0x01902d, _0x6736d8);
    }

    ///@notice withdraw all token
    function _0x2bd416() external {
        _0xd45c11(_0x1658db(msg.sender));
    }

    ///@notice withdraw a certain amount of TOKEN
    function _0x650def(uint256 _0x6736d8) external {
        _0xd45c11(_0x6736d8);
    }

    ///@notice withdraw internal
    function _0xd45c11(uint256 _0x6736d8) internal _0x4ca03d _0xa9efc5 _0x1024ab(msg.sender) {
        require(_0x6736d8 > 0, "ZV");
        require(_0x1658db(msg.sender) > 0, "ZV");
        require(block.timestamp >= _0xaefeef[msg.sender], "!MATURE");

        _0xd6bbf3 = _0xd6bbf3 - _0x6736d8;
        _0x345986[msg.sender] = _0x345986[msg.sender] - _0x6736d8;

        if (address(_0x1924a1) != address(0)) {
            IRewarder(_0x1924a1)._0x3aad9c(msg.sender, msg.sender,_0x1658db(msg.sender));
        }

        TOKEN._0x9ccd26(msg.sender, _0x6736d8);

        emit Withdraw(msg.sender, _0x6736d8);
    }

    function _0x73e346() external _0x4ca03d {
        require(_0xcfc0c2, "EMER");
        uint256 _0x27e7ec = _0x1658db(msg.sender);
        require(_0x27e7ec > 0, "ZV");
        if (block.timestamp > 0) { _0xd6bbf3 = _0xd6bbf3 - _0x27e7ec; }

        _0x345986[msg.sender] = 0;

        TOKEN._0x9ccd26(msg.sender, _0x27e7ec);
        emit Withdraw(msg.sender, _0x27e7ec);
    }

    function _0x1b4455(uint256 _0x27e7ec) external _0x4ca03d {

        require(_0xcfc0c2, "EMER");
        _0xd6bbf3 = _0xd6bbf3 - _0x27e7ec;

        _0x345986[msg.sender] = _0x345986[msg.sender] - _0x27e7ec;

        TOKEN._0x9ccd26(msg.sender, _0x27e7ec);
        emit Withdraw(msg.sender, _0x27e7ec);
    }

    ///@notice withdraw all TOKEN and harvest rewardToken
    function _0x889b85(uint8 _0x251c3a) external {
        _0xd45c11(_0x1658db(msg.sender));
        _0xb478bd(_0x251c3a);
    }

    ///@notice User harvest function called from distribution (GaugeManager allows harvest on multiple gauges)
    function _0xb478bd(address _0xf4a407, uint8 _0x251c3a) public _0x4ca03d _0x39ed7c _0x1024ab(_0xf4a407) {
        uint256 _0x0c35d4 = _0x7a6046[_0xf4a407];
        if (_0x0c35d4 > 0) {
            _0x7a6046[_0xf4a407] = 0;
            IERC20(_0xc4a110)._0xd6b5c1(_0x1a4a3a, _0x0c35d4);
            IRHYBR(_0x1a4a3a)._0x915d0d(_0x0c35d4);
            IRHYBR(_0x1a4a3a)._0xbebd30(_0x0c35d4, _0x251c3a, _0xf4a407);
            emit Harvest(_0xf4a407, _0x0c35d4);
        }

        if (_0x1924a1 != address(0)) {
            IRewarder(_0x1924a1)._0x3aad9c(_0xf4a407, _0xf4a407, _0x1658db(_0xf4a407));
        }
    }

    ///@notice User harvest function
    function _0xb478bd(uint8 _0x251c3a) public _0x4ca03d _0x1024ab(msg.sender) {
        uint256 _0x0c35d4 = _0x7a6046[msg.sender];
        if (_0x0c35d4 > 0) {
            _0x7a6046[msg.sender] = 0;
            IERC20(_0xc4a110)._0xd6b5c1(_0x1a4a3a, _0x0c35d4);
            IRHYBR(_0x1a4a3a)._0x915d0d(_0x0c35d4);
            IRHYBR(_0x1a4a3a)._0xbebd30(_0x0c35d4, _0x251c3a, msg.sender);
            emit Harvest(msg.sender, _0x0c35d4);
        }

        if (_0x1924a1 != address(0)) {
            IRewarder(_0x1924a1)._0x3aad9c(msg.sender, msg.sender, _0x1658db(msg.sender));
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

    function _0x306102(address _0x0f3c3f, uint256 _0x0c35d4) external _0x4ca03d _0xa9efc5 _0x39ed7c _0x1024ab(address(0)) {
        require(_0x0f3c3f == address(_0xc4a110), "IA");
        _0xc4a110._0xb7a36d(DISTRIBUTION, address(this), _0x0c35d4);

        if (block.timestamp >= _0xbdc981) {
            _0xa5ded9 = _0x0c35d4 / DURATION;
        } else {
            uint256 _0x20b903 = _0xbdc981 - block.timestamp;
            uint256 _0xb5d1b5 = _0x20b903 * _0xa5ded9;
            if (gasleft() > 0) { _0xa5ded9 = (_0x0c35d4 + _0xb5d1b5) / DURATION; }
        }

        // Ensure the provided reward amount is not more than the balance in the contract.

        // very high values of rewardRate in the earned and rewardsPerToken functions;

        uint256 balance = _0xc4a110._0x1005d5(address(this));
        require(_0xa5ded9 <= balance / DURATION, "REWARD_HIGH");

        if (1 == 1) { _0xded964 = block.timestamp; }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xbdc981 = block.timestamp + DURATION; }
        emit RewardAdded(_0x0c35d4);
    }

    function _0x44e070() external _0x4ca03d returns (uint256 _0x16f463, uint256 _0xe032e2) {
        return _0xba7eac();
    }

     function _0xba7eac() internal returns (uint256 _0x16f463, uint256 _0xe032e2) {
        if (!_0x7e3b20) {
            return (0, 0);
        }
        address _0x3d9a66 = address(TOKEN);
        (_0x16f463, _0xe032e2) = IPair(_0x3d9a66)._0x44e070();
        if (_0x16f463 > 0 || _0xe032e2 > 0) {

            uint256 _0x86c98d = _0x16f463;
            uint256 _0x83c677 = _0xe032e2;

            (address _0xd62033, address _0x553428) = IPair(_0x3d9a66)._0xd8bddc();

            if (_0x86c98d  > 0) {
                IERC20(_0xd62033)._0xd6b5c1(_0xc59eab, 0);
                IERC20(_0xd62033)._0xd6b5c1(_0xc59eab, _0x86c98d);
                IBribe(_0xc59eab)._0x306102(_0xd62033, _0x86c98d);
            }
            if (_0x83c677  > 0) {
                IERC20(_0x553428)._0xd6b5c1(_0xc59eab, 0);
                IERC20(_0x553428)._0xd6b5c1(_0xc59eab, _0x83c677);
                IBribe(_0xc59eab)._0x306102(_0x553428, _0x83c677);
            }
            emit ClaimFees(msg.sender, _0x16f463, _0xe032e2);
        }
    }

}