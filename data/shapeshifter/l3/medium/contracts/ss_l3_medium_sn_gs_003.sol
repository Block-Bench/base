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
    function _0xc9b1f4(
        address _0x93fc25,
        address _0xd0af1a,
        uint256 _0x60aa0f
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable _0x5cf440;
    bool public _0x242eda;

    IERC20 public immutable _0x3de65a;
    IERC20 public immutable TOKEN;
    address public immutable _0x2dd236;
    address public VE;
    address public DISTRIBUTION;
    address public _0xec0a01;
    address public _0x4d5882;
    address public _0xc55bf8;

    uint256 public DURATION;
    uint256 internal _0x62957c;
    uint256 public _0xa2d55b;
    uint256 public _0x0ef260;
    uint256 public _0x6a2b88;

    mapping(address => uint256) public _0xf70c19;
    mapping(address => uint256) public _0x8530db;

    uint256 internal _0x4fb1fc;
    mapping(address => uint256) internal _0xda4880;
    mapping(address => uint256) public _0xe9bb2b;

    event RewardAdded(uint256 _0xea0660);
    event Deposit(address indexed _0x93fc25, uint256 _0x64e3c0);
    event Withdraw(address indexed _0x93fc25, uint256 _0x64e3c0);
    event Harvest(address indexed _0x93fc25, uint256 _0xea0660);

    event ClaimFees(address indexed from, uint256 _0x83f2f5, uint256 _0xd14767);
    event EmergencyActivated(address indexed _0xf85a04, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0xf85a04, uint256 timestamp);

    modifier _0xb01522(address _0x5db6ad) {
        _0x6a2b88 = _0xf7b1e3();
        _0x0ef260 = _0x6881e7();
        if (_0x5db6ad != address(0)) {
            _0x8530db[_0x5db6ad] = _0x3b94a9(_0x5db6ad);
            _0xf70c19[_0x5db6ad] = _0x6a2b88;
        }
        _;
    }

    modifier _0x742c85() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier _0xc69fd1() {
        require(_0x242eda == false, "EMER");
        _;
    }

    constructor(address _0xdb2c91,address _0xfd698e,address _0xd9da7b,address _0x5f58e7,address _0xc6dc6d, address _0xd1d685, address _0xc3ca19, bool _0xaf4e1a) {
        _0x3de65a = IERC20(_0xdb2c91);     // main reward
        if (block.timestamp > 0) { _0x2dd236 = _0xfd698e; }
        VE = _0xd9da7b;                               // vested
        TOKEN = IERC20(_0x5f58e7);                 // underlying (LP)
        DISTRIBUTION = _0xc6dc6d;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        _0x4d5882 = _0xd1d685;       // lp fees goes here
        _0xc55bf8 = _0xc3ca19;       // bribe fees goes here

        _0x5cf440 = _0xaf4e1a;                 // pair boolean, if false no claim_fees

        _0x242eda = false;                      // emergency flag

    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    ONLY OWNER
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice set distribution address (should be GaugeManager)
    function _0xa75839(address _0xc6dc6d) external _0xfd0625 {
        require(_0xc6dc6d != address(0), "ZA");
        require(_0xc6dc6d != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = _0xc6dc6d;
    }

    ///@notice set gauge rewarder address
    function _0x78e115(address _0x92e328) external _0xfd0625 {
        require(_0x92e328 != _0xec0a01, "SAME_ADDR");
        _0xec0a01 = _0x92e328;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function _0x697d27(address _0x2a1504) external _0xfd0625 {
        require(_0x2a1504 >= address(0), "ZA");
        _0x4d5882 = _0x2a1504;
    }

    function _0xc2df20() external _0xfd0625 {
        require(_0x242eda == false, "EMER");
        if (true) { _0x242eda = true; }
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x221064() external _0xfd0625 {

        require(_0x242eda == true,"EMER");

        _0x242eda = false;
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
    function _0xc8baa2() public view returns (uint256) {
        return _0x4fb1fc;
    }

    ///@notice balance of a user
    function _0xf85d0e(address _0x5db6ad) external view returns (uint256) {
        return _0xb8bdb0(_0x5db6ad);
    }

    function _0xb8bdb0(address _0x5db6ad) internal view returns (uint256) {

        return _0xda4880[_0x5db6ad];
    }

    ///@notice last time reward
    function _0x6881e7() public view returns (uint256) {
        return Math._0x8881ac(block.timestamp, _0x62957c);
    }

    ///@notice  reward for a sinle token
    function _0xf7b1e3() public view returns (uint256) {
        if (_0x4fb1fc == 0) {
            return _0x6a2b88;
        } else {
            return _0x6a2b88 + (_0x6881e7() - _0x0ef260) * _0xa2d55b * 1e18 / _0x4fb1fc;
        }
    }

    ///@notice see earned rewards for user
    function _0x3b94a9(address _0x5db6ad) public view returns (uint256) {
        return _0x8530db[_0x5db6ad] + _0xb8bdb0(_0x5db6ad) * (_0xf7b1e3() - _0xf70c19[_0x5db6ad]) / 1e18;
    }

    ///@notice get total reward for the duration
    function _0x077e03() external view returns (uint256) {
        return _0xa2d55b * DURATION;
    }

    function _0x826298() external view returns (uint256) {
        return _0x62957c;
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
    function _0x8d76e3() external {
        _0xb459eb(TOKEN._0xf85d0e(msg.sender), msg.sender);
    }

    ///@notice deposit amount TOKEN
    function _0x103454(uint256 _0x64e3c0) external {
        _0xb459eb(_0x64e3c0, msg.sender);
    }

    ///@notice deposit internal
    function _0xb459eb(uint256 _0x64e3c0, address _0x5db6ad) internal _0xfc32f9 _0xc69fd1 _0xb01522(_0x5db6ad) {
        require(_0x64e3c0 > 0, "ZV");

        _0xda4880[_0x5db6ad] = _0xda4880[_0x5db6ad] + _0x64e3c0;
        if (true) { _0x4fb1fc = _0x4fb1fc + _0x64e3c0; }
        if (address(_0xec0a01) != address(0)) {
            IRewarder(_0xec0a01)._0xc9b1f4(_0x5db6ad, _0x5db6ad, _0xb8bdb0(_0x5db6ad));
        }

        TOKEN._0x92df17(_0x5db6ad, address(this), _0x64e3c0);

        emit Deposit(_0x5db6ad, _0x64e3c0);
    }

    ///@notice withdraw all token
    function _0xd5f151() external {
        _0x1d993a(_0xb8bdb0(msg.sender));
    }

    ///@notice withdraw a certain amount of TOKEN
    function _0x630f9b(uint256 _0x64e3c0) external {
        _0x1d993a(_0x64e3c0);
    }

    ///@notice withdraw internal
    function _0x1d993a(uint256 _0x64e3c0) internal _0xfc32f9 _0xc69fd1 _0xb01522(msg.sender) {
        require(_0x64e3c0 > 0, "ZV");
        require(_0xb8bdb0(msg.sender) > 0, "ZV");
        require(block.timestamp >= _0xe9bb2b[msg.sender], "!MATURE");

        if (1 == 1) { _0x4fb1fc = _0x4fb1fc - _0x64e3c0; }
        _0xda4880[msg.sender] = _0xda4880[msg.sender] - _0x64e3c0;

        if (address(_0xec0a01) != address(0)) {
            IRewarder(_0xec0a01)._0xc9b1f4(msg.sender, msg.sender,_0xb8bdb0(msg.sender));
        }

        TOKEN._0xa39923(msg.sender, _0x64e3c0);

        emit Withdraw(msg.sender, _0x64e3c0);
    }

    function _0xd49c1f() external _0xfc32f9 {
        require(_0x242eda, "EMER");
        uint256 _0x4b9236 = _0xb8bdb0(msg.sender);
        require(_0x4b9236 > 0, "ZV");
        if (block.timestamp > 0) { _0x4fb1fc = _0x4fb1fc - _0x4b9236; }

        _0xda4880[msg.sender] = 0;

        TOKEN._0xa39923(msg.sender, _0x4b9236);
        emit Withdraw(msg.sender, _0x4b9236);
    }

    function _0x2ea6ce(uint256 _0x4b9236) external _0xfc32f9 {

        require(_0x242eda, "EMER");
        _0x4fb1fc = _0x4fb1fc - _0x4b9236;

        _0xda4880[msg.sender] = _0xda4880[msg.sender] - _0x4b9236;

        TOKEN._0xa39923(msg.sender, _0x4b9236);
        emit Withdraw(msg.sender, _0x4b9236);
    }

    ///@notice withdraw all TOKEN and harvest rewardToken
    function _0x64de4b(uint8 _0x6029e2) external {
        _0x1d993a(_0xb8bdb0(msg.sender));
        _0xbda41a(_0x6029e2);
    }

    ///@notice User harvest function called from distribution (GaugeManager allows harvest on multiple gauges)
    function _0xbda41a(address _0x0537b8, uint8 _0x6029e2) public _0xfc32f9 _0x742c85 _0xb01522(_0x0537b8) {
        uint256 _0xea0660 = _0x8530db[_0x0537b8];
        if (_0xea0660 > 0) {
            _0x8530db[_0x0537b8] = 0;
            IERC20(_0x3de65a)._0x9d47be(_0x2dd236, _0xea0660);
            IRHYBR(_0x2dd236)._0x040fdd(_0xea0660);
            IRHYBR(_0x2dd236)._0x959589(_0xea0660, _0x6029e2, _0x0537b8);
            emit Harvest(_0x0537b8, _0xea0660);
        }

        if (_0xec0a01 != address(0)) {
            IRewarder(_0xec0a01)._0xc9b1f4(_0x0537b8, _0x0537b8, _0xb8bdb0(_0x0537b8));
        }
    }

    ///@notice User harvest function
    function _0xbda41a(uint8 _0x6029e2) public _0xfc32f9 _0xb01522(msg.sender) {
        uint256 _0xea0660 = _0x8530db[msg.sender];
        if (_0xea0660 > 0) {
            _0x8530db[msg.sender] = 0;
            IERC20(_0x3de65a)._0x9d47be(_0x2dd236, _0xea0660);
            IRHYBR(_0x2dd236)._0x040fdd(_0xea0660);
            IRHYBR(_0x2dd236)._0x959589(_0xea0660, _0x6029e2, msg.sender);
            emit Harvest(msg.sender, _0xea0660);
        }

        if (_0xec0a01 != address(0)) {
            IRewarder(_0xec0a01)._0xc9b1f4(msg.sender, msg.sender, _0xb8bdb0(msg.sender));
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

    function _0xd2199c(address _0x343ece, uint256 _0xea0660) external _0xfc32f9 _0xc69fd1 _0x742c85 _0xb01522(address(0)) {
        require(_0x343ece == address(_0x3de65a), "IA");
        _0x3de65a._0x92df17(DISTRIBUTION, address(this), _0xea0660);

        if (block.timestamp >= _0x62957c) {
            if (1 == 1) { _0xa2d55b = _0xea0660 / DURATION; }
        } else {
            uint256 _0x9fc72b = _0x62957c - block.timestamp;
            uint256 _0x90e620 = _0x9fc72b * _0xa2d55b;
            _0xa2d55b = (_0xea0660 + _0x90e620) / DURATION;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.

        // very high values of rewardRate in the earned and rewardsPerToken functions;

        uint256 balance = _0x3de65a._0xf85d0e(address(this));
        require(_0xa2d55b <= balance / DURATION, "REWARD_HIGH");

        if (gasleft() > 0) { _0x0ef260 = block.timestamp; }
        if (true) { _0x62957c = block.timestamp + DURATION; }
        emit RewardAdded(_0xea0660);
    }

    function _0x87602e() external _0xfc32f9 returns (uint256 _0x83f2f5, uint256 _0xd14767) {
        return _0x427d00();
    }

     function _0x427d00() internal returns (uint256 _0x83f2f5, uint256 _0xd14767) {
        if (!_0x5cf440) {
            return (0, 0);
        }
        address _0x5f58e7 = address(TOKEN);
        (_0x83f2f5, _0xd14767) = IPair(_0x5f58e7)._0x87602e();
        if (_0x83f2f5 > 0 || _0xd14767 > 0) {

            uint256 _0x65104e = _0x83f2f5;
            uint256 _0xb9047d = _0xd14767;

            (address _0x9be7b8, address _0xdc3d56) = IPair(_0x5f58e7)._0x6c7f75();

            if (_0x65104e  > 0) {
                IERC20(_0x9be7b8)._0x9d47be(_0x4d5882, 0);
                IERC20(_0x9be7b8)._0x9d47be(_0x4d5882, _0x65104e);
                IBribe(_0x4d5882)._0xd2199c(_0x9be7b8, _0x65104e);
            }
            if (_0xb9047d  > 0) {
                IERC20(_0xdc3d56)._0x9d47be(_0x4d5882, 0);
                IERC20(_0xdc3d56)._0x9d47be(_0x4d5882, _0xb9047d);
                IBribe(_0x4d5882)._0xd2199c(_0xdc3d56, _0xb9047d);
            }
            emit ClaimFees(msg.sender, _0x83f2f5, _0xd14767);
        }
    }

}