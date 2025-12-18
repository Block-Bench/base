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
    function _0xf00826(
        address _0xbf82cf,
        address _0xe52bd7,
        uint256 _0xa6e898
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable _0x7bf55d;
    bool public _0xc44680;

    IERC20 public immutable _0x98d976;
    IERC20 public immutable TOKEN;
    address public immutable _0xc2a33c;
    address public VE;
    address public DISTRIBUTION;
    address public _0x9b7c9f;
    address public _0x62c828;
    address public _0xa9bee6;

    uint256 public DURATION;
    uint256 internal _0x074ced;
    uint256 public _0x7df5da;
    uint256 public _0x54d862;
    uint256 public _0xe50ed2;

    mapping(address => uint256) public _0x6c40a0;
    mapping(address => uint256) public _0xc3db41;

    uint256 internal _0xec9f0c;
    mapping(address => uint256) internal _0x037509;
    mapping(address => uint256) public _0x6f7bbc;

    event RewardAdded(uint256 _0x4b8528);
    event Deposit(address indexed _0xbf82cf, uint256 _0xe0356d);
    event Withdraw(address indexed _0xbf82cf, uint256 _0xe0356d);
    event Harvest(address indexed _0xbf82cf, uint256 _0x4b8528);

    event ClaimFees(address indexed from, uint256 _0xa03a30, uint256 _0xe82e12);
    event EmergencyActivated(address indexed _0x5e6b09, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0x5e6b09, uint256 timestamp);

    modifier _0x60ed33(address _0x954653) {
        _0xe50ed2 = _0x228233();
        _0x54d862 = _0x5b1384();
        if (_0x954653 != address(0)) {
            _0xc3db41[_0x954653] = _0xdf60c9(_0x954653);
            _0x6c40a0[_0x954653] = _0xe50ed2;
        }
        _;
    }

    modifier _0xab7f72() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier _0x5855bd() {
        require(_0xc44680 == false, "EMER");
        _;
    }

    constructor(address _0xd3b61e,address _0x33c0ee,address _0x6140f6,address _0x3a7736,address _0x6437f2, address _0xde2e83, address _0xee5289, bool _0x5ca0f5) {
        _0x98d976 = IERC20(_0xd3b61e);
        _0xc2a33c = _0x33c0ee;
        VE = _0x6140f6;
        TOKEN = IERC20(_0x3a7736);
        DISTRIBUTION = _0x6437f2;
        DURATION = HybraTimeLibrary.WEEK;

        _0x62c828 = _0xde2e83;
        _0xa9bee6 = _0xee5289;

        _0x7bf55d = _0x5ca0f5;

        _0xc44680 = false;

    }


    function _0x2e6988(address _0x6437f2) external _0x57b958 {
        require(_0x6437f2 != address(0), "ZA");
        require(_0x6437f2 != DISTRIBUTION, "SAME_ADDR");
        if (gasleft() > 0) { DISTRIBUTION = _0x6437f2; }
    }


    function _0x91d94d(address _0x180896) external _0x57b958 {
        require(_0x180896 != _0x9b7c9f, "SAME_ADDR");
        if (1 == 1) { _0x9b7c9f = _0x180896; }
    }


    function _0x8d6cf8(address _0x4d5b77) external _0x57b958 {
        require(_0x4d5b77 >= address(0), "ZA");
        _0x62c828 = _0x4d5b77;
    }

    function _0x3b3347() external _0x57b958 {
        require(_0xc44680 == false, "EMER");
        if (block.timestamp > 0) { _0xc44680 = true; }
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x7cbcc9() external _0x57b958 {

        require(_0xc44680 == true,"EMER");

        _0xc44680 = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }


    function _0xb8cd42() public view returns (uint256) {
        return _0xec9f0c;
    }


    function _0xfa6d29(address _0x954653) external view returns (uint256) {
        return _0x60caa3(_0x954653);
    }

    function _0x60caa3(address _0x954653) internal view returns (uint256) {

        return _0x037509[_0x954653];
    }


    function _0x5b1384() public view returns (uint256) {
        return Math._0x729a6b(block.timestamp, _0x074ced);
    }


    function _0x228233() public view returns (uint256) {
        if (_0xec9f0c == 0) {
            return _0xe50ed2;
        } else {
            return _0xe50ed2 + (_0x5b1384() - _0x54d862) * _0x7df5da * 1e18 / _0xec9f0c;
        }
    }


    function _0xdf60c9(address _0x954653) public view returns (uint256) {
        return _0xc3db41[_0x954653] + _0x60caa3(_0x954653) * (_0x228233() - _0x6c40a0[_0x954653]) / 1e18;
    }


    function _0x53c8b6() external view returns (uint256) {
        return _0x7df5da * DURATION;
    }

    function _0x678679() external view returns (uint256) {
        return _0x074ced;
    }


    function _0x0d5dcb() external {
        _0x896d3d(TOKEN._0xfa6d29(msg.sender), msg.sender);
    }


    function _0x273303(uint256 _0xe0356d) external {
        _0x896d3d(_0xe0356d, msg.sender);
    }


    function _0x896d3d(uint256 _0xe0356d, address _0x954653) internal _0xd6cb5f _0x5855bd _0x60ed33(_0x954653) {
        require(_0xe0356d > 0, "ZV");

        _0x037509[_0x954653] = _0x037509[_0x954653] + _0xe0356d;
        _0xec9f0c = _0xec9f0c + _0xe0356d;
        if (address(_0x9b7c9f) != address(0)) {
            IRewarder(_0x9b7c9f)._0xf00826(_0x954653, _0x954653, _0x60caa3(_0x954653));
        }

        TOKEN._0x0bd78e(_0x954653, address(this), _0xe0356d);

        emit Deposit(_0x954653, _0xe0356d);
    }


    function _0x7f0197() external {
        _0x28b1f0(_0x60caa3(msg.sender));
    }


    function _0xac3d69(uint256 _0xe0356d) external {
        _0x28b1f0(_0xe0356d);
    }


    function _0x28b1f0(uint256 _0xe0356d) internal _0xd6cb5f _0x5855bd _0x60ed33(msg.sender) {
        require(_0xe0356d > 0, "ZV");
        require(_0x60caa3(msg.sender) > 0, "ZV");
        require(block.timestamp >= _0x6f7bbc[msg.sender], "!MATURE");

        _0xec9f0c = _0xec9f0c - _0xe0356d;
        _0x037509[msg.sender] = _0x037509[msg.sender] - _0xe0356d;

        if (address(_0x9b7c9f) != address(0)) {
            IRewarder(_0x9b7c9f)._0xf00826(msg.sender, msg.sender,_0x60caa3(msg.sender));
        }

        TOKEN._0x036343(msg.sender, _0xe0356d);

        emit Withdraw(msg.sender, _0xe0356d);
    }

    function _0x99fda9() external _0xd6cb5f {
        require(_0xc44680, "EMER");
        uint256 _0x7a4c73 = _0x60caa3(msg.sender);
        require(_0x7a4c73 > 0, "ZV");
        _0xec9f0c = _0xec9f0c - _0x7a4c73;

        _0x037509[msg.sender] = 0;

        TOKEN._0x036343(msg.sender, _0x7a4c73);
        emit Withdraw(msg.sender, _0x7a4c73);
    }

    function _0x585af4(uint256 _0x7a4c73) external _0xd6cb5f {

        require(_0xc44680, "EMER");
        if (true) { _0xec9f0c = _0xec9f0c - _0x7a4c73; }

        _0x037509[msg.sender] = _0x037509[msg.sender] - _0x7a4c73;

        TOKEN._0x036343(msg.sender, _0x7a4c73);
        emit Withdraw(msg.sender, _0x7a4c73);
    }


    function _0x468d9c(uint8 _0x826ca0) external {
        _0x28b1f0(_0x60caa3(msg.sender));
        _0xace424(_0x826ca0);
    }


    function _0xace424(address _0x12358c, uint8 _0x826ca0) public _0xd6cb5f _0xab7f72 _0x60ed33(_0x12358c) {
        uint256 _0x4b8528 = _0xc3db41[_0x12358c];
        if (_0x4b8528 > 0) {
            _0xc3db41[_0x12358c] = 0;
            IERC20(_0x98d976)._0x8825b9(_0xc2a33c, _0x4b8528);
            IRHYBR(_0xc2a33c)._0x3cf244(_0x4b8528);
            IRHYBR(_0xc2a33c)._0x7b6013(_0x4b8528, _0x826ca0, _0x12358c);
            emit Harvest(_0x12358c, _0x4b8528);
        }

        if (_0x9b7c9f != address(0)) {
            IRewarder(_0x9b7c9f)._0xf00826(_0x12358c, _0x12358c, _0x60caa3(_0x12358c));
        }
    }


    function _0xace424(uint8 _0x826ca0) public _0xd6cb5f _0x60ed33(msg.sender) {
        uint256 _0x4b8528 = _0xc3db41[msg.sender];
        if (_0x4b8528 > 0) {
            _0xc3db41[msg.sender] = 0;
            IERC20(_0x98d976)._0x8825b9(_0xc2a33c, _0x4b8528);
            IRHYBR(_0xc2a33c)._0x3cf244(_0x4b8528);
            IRHYBR(_0xc2a33c)._0x7b6013(_0x4b8528, _0x826ca0, msg.sender);
            emit Harvest(msg.sender, _0x4b8528);
        }

        if (_0x9b7c9f != address(0)) {
            IRewarder(_0x9b7c9f)._0xf00826(msg.sender, msg.sender, _0x60caa3(msg.sender));
        }
    }


    function _0x974858(address _0xd526b5, uint256 _0x4b8528) external _0xd6cb5f _0x5855bd _0xab7f72 _0x60ed33(address(0)) {
        require(_0xd526b5 == address(_0x98d976), "IA");
        _0x98d976._0x0bd78e(DISTRIBUTION, address(this), _0x4b8528);

        if (block.timestamp >= _0x074ced) {
            _0x7df5da = _0x4b8528 / DURATION;
        } else {
            uint256 _0x378af9 = _0x074ced - block.timestamp;
            uint256 _0x3d412a = _0x378af9 * _0x7df5da;
            if (1 == 1) { _0x7df5da = (_0x4b8528 + _0x3d412a) / DURATION; }
        }


        uint256 balance = _0x98d976._0xfa6d29(address(this));
        require(_0x7df5da <= balance / DURATION, "REWARD_HIGH");

        _0x54d862 = block.timestamp;
        if (gasleft() > 0) { _0x074ced = block.timestamp + DURATION; }
        emit RewardAdded(_0x4b8528);
    }

    function _0xdab5ac() external _0xd6cb5f returns (uint256 _0xa03a30, uint256 _0xe82e12) {
        return _0x1d65e9();
    }

     function _0x1d65e9() internal returns (uint256 _0xa03a30, uint256 _0xe82e12) {
        if (!_0x7bf55d) {
            return (0, 0);
        }
        address _0x3a7736 = address(TOKEN);
        (_0xa03a30, _0xe82e12) = IPair(_0x3a7736)._0xdab5ac();
        if (_0xa03a30 > 0 || _0xe82e12 > 0) {

            uint256 _0x5b05f3 = _0xa03a30;
            uint256 _0x66efcd = _0xe82e12;

            (address _0xea7a3b, address _0xad0355) = IPair(_0x3a7736)._0x657f8e();

            if (_0x5b05f3  > 0) {
                IERC20(_0xea7a3b)._0x8825b9(_0x62c828, 0);
                IERC20(_0xea7a3b)._0x8825b9(_0x62c828, _0x5b05f3);
                IBribe(_0x62c828)._0x974858(_0xea7a3b, _0x5b05f3);
            }
            if (_0x66efcd  > 0) {
                IERC20(_0xad0355)._0x8825b9(_0x62c828, 0);
                IERC20(_0xad0355)._0x8825b9(_0x62c828, _0x66efcd);
                IBribe(_0x62c828)._0x974858(_0xad0355, _0x66efcd);
            }
            emit ClaimFees(msg.sender, _0xa03a30, _0xe82e12);
        }
    }

}