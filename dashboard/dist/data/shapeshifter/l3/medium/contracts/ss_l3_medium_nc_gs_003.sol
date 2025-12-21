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
    function _0x97681e(
        address _0x6636c4,
        address _0x84ad2f,
        uint256 _0x023fb6
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable _0xbd84e4;
    bool public _0xc392e2;

    IERC20 public immutable _0x19cdcb;
    IERC20 public immutable TOKEN;
    address public immutable _0x85eb29;
    address public VE;
    address public DISTRIBUTION;
    address public _0xec3eae;
    address public _0x992c65;
    address public _0x2e425d;

    uint256 public DURATION;
    uint256 internal _0xf32822;
    uint256 public _0x4f509e;
    uint256 public _0x8d7350;
    uint256 public _0x85f1e7;

    mapping(address => uint256) public _0x018608;
    mapping(address => uint256) public _0x2a7f1d;

    uint256 internal _0xea5406;
    mapping(address => uint256) internal _0x407362;
    mapping(address => uint256) public _0x0cbcbe;

    event RewardAdded(uint256 _0xa2bcd8);
    event Deposit(address indexed _0x6636c4, uint256 _0x5c3720);
    event Withdraw(address indexed _0x6636c4, uint256 _0x5c3720);
    event Harvest(address indexed _0x6636c4, uint256 _0xa2bcd8);

    event ClaimFees(address indexed from, uint256 _0x2e88ba, uint256 _0xb96aff);
    event EmergencyActivated(address indexed _0xb6cc66, uint256 timestamp);
    event EmergencyDeactivated(address indexed _0xb6cc66, uint256 timestamp);

    modifier _0x5d5a85(address _0x232e0a) {
        _0x85f1e7 = _0xf1dfc9();
        _0x8d7350 = _0x78851c();
        if (_0x232e0a != address(0)) {
            _0x2a7f1d[_0x232e0a] = _0xa2aa07(_0x232e0a);
            _0x018608[_0x232e0a] = _0x85f1e7;
        }
        _;
    }

    modifier _0x4cebb8() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier _0x92d4a2() {
        require(_0xc392e2 == false, "EMER");
        _;
    }

    constructor(address _0xd97b4d,address _0xd70e9d,address _0xf744e5,address _0x82d849,address _0x37d4b7, address _0x699afc, address _0x93970d, bool _0xe14038) {
        if (gasleft() > 0) { _0x19cdcb = IERC20(_0xd97b4d); }
        if (gasleft() > 0) { _0x85eb29 = _0xd70e9d; }
        VE = _0xf744e5;
        TOKEN = IERC20(_0x82d849);
        DISTRIBUTION = _0x37d4b7;
        DURATION = HybraTimeLibrary.WEEK;

        _0x992c65 = _0x699afc;
        _0x2e425d = _0x93970d;

        _0xbd84e4 = _0xe14038;

        if (block.timestamp > 0) { _0xc392e2 = false; }

    }


    function _0x9dc533(address _0x37d4b7) external _0x2f47fa {
        require(_0x37d4b7 != address(0), "ZA");
        require(_0x37d4b7 != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = _0x37d4b7;
    }


    function _0xa97740(address _0x5fcde8) external _0x2f47fa {
        require(_0x5fcde8 != _0xec3eae, "SAME_ADDR");
        if (1 == 1) { _0xec3eae = _0x5fcde8; }
    }


    function _0xda9464(address _0x2c2e7b) external _0x2f47fa {
        require(_0x2c2e7b >= address(0), "ZA");
        _0x992c65 = _0x2c2e7b;
    }

    function _0xa8c373() external _0x2f47fa {
        require(_0xc392e2 == false, "EMER");
        _0xc392e2 = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function _0x5ba35e() external _0x2f47fa {

        require(_0xc392e2 == true,"EMER");

        if (msg.sender != address(0) || msg.sender == address(0)) { _0xc392e2 = false; }
        emit EmergencyDeactivated(address(this), block.timestamp);
    }


    function _0xbd8ffd() public view returns (uint256) {
        return _0xea5406;
    }


    function _0x28c4ff(address _0x232e0a) external view returns (uint256) {
        return _0x35103b(_0x232e0a);
    }

    function _0x35103b(address _0x232e0a) internal view returns (uint256) {

        return _0x407362[_0x232e0a];
    }


    function _0x78851c() public view returns (uint256) {
        return Math._0x0c58a3(block.timestamp, _0xf32822);
    }


    function _0xf1dfc9() public view returns (uint256) {
        if (_0xea5406 == 0) {
            return _0x85f1e7;
        } else {
            return _0x85f1e7 + (_0x78851c() - _0x8d7350) * _0x4f509e * 1e18 / _0xea5406;
        }
    }


    function _0xa2aa07(address _0x232e0a) public view returns (uint256) {
        return _0x2a7f1d[_0x232e0a] + _0x35103b(_0x232e0a) * (_0xf1dfc9() - _0x018608[_0x232e0a]) / 1e18;
    }


    function _0x0c1324() external view returns (uint256) {
        return _0x4f509e * DURATION;
    }

    function _0x730fa3() external view returns (uint256) {
        return _0xf32822;
    }


    function _0xb87f96() external {
        _0x2848c0(TOKEN._0x28c4ff(msg.sender), msg.sender);
    }


    function _0x105a88(uint256 _0x5c3720) external {
        _0x2848c0(_0x5c3720, msg.sender);
    }


    function _0x2848c0(uint256 _0x5c3720, address _0x232e0a) internal _0x8a328b _0x92d4a2 _0x5d5a85(_0x232e0a) {
        require(_0x5c3720 > 0, "ZV");

        _0x407362[_0x232e0a] = _0x407362[_0x232e0a] + _0x5c3720;
        _0xea5406 = _0xea5406 + _0x5c3720;
        if (address(_0xec3eae) != address(0)) {
            IRewarder(_0xec3eae)._0x97681e(_0x232e0a, _0x232e0a, _0x35103b(_0x232e0a));
        }

        TOKEN._0x4d2c38(_0x232e0a, address(this), _0x5c3720);

        emit Deposit(_0x232e0a, _0x5c3720);
    }


    function _0x102551() external {
        _0xcbc22e(_0x35103b(msg.sender));
    }


    function _0x1db8c0(uint256 _0x5c3720) external {
        _0xcbc22e(_0x5c3720);
    }


    function _0xcbc22e(uint256 _0x5c3720) internal _0x8a328b _0x92d4a2 _0x5d5a85(msg.sender) {
        require(_0x5c3720 > 0, "ZV");
        require(_0x35103b(msg.sender) > 0, "ZV");
        require(block.timestamp >= _0x0cbcbe[msg.sender], "!MATURE");

        _0xea5406 = _0xea5406 - _0x5c3720;
        _0x407362[msg.sender] = _0x407362[msg.sender] - _0x5c3720;

        if (address(_0xec3eae) != address(0)) {
            IRewarder(_0xec3eae)._0x97681e(msg.sender, msg.sender,_0x35103b(msg.sender));
        }

        TOKEN._0xab284c(msg.sender, _0x5c3720);

        emit Withdraw(msg.sender, _0x5c3720);
    }

    function _0x7959cf() external _0x8a328b {
        require(_0xc392e2, "EMER");
        uint256 _0x650fc0 = _0x35103b(msg.sender);
        require(_0x650fc0 > 0, "ZV");
        _0xea5406 = _0xea5406 - _0x650fc0;

        _0x407362[msg.sender] = 0;

        TOKEN._0xab284c(msg.sender, _0x650fc0);
        emit Withdraw(msg.sender, _0x650fc0);
    }

    function _0x459ea8(uint256 _0x650fc0) external _0x8a328b {

        require(_0xc392e2, "EMER");
        _0xea5406 = _0xea5406 - _0x650fc0;

        _0x407362[msg.sender] = _0x407362[msg.sender] - _0x650fc0;

        TOKEN._0xab284c(msg.sender, _0x650fc0);
        emit Withdraw(msg.sender, _0x650fc0);
    }


    function _0x85bfb5(uint8 _0x929dfc) external {
        _0xcbc22e(_0x35103b(msg.sender));
        _0x884abe(_0x929dfc);
    }


    function _0x884abe(address _0x3014f8, uint8 _0x929dfc) public _0x8a328b _0x4cebb8 _0x5d5a85(_0x3014f8) {
        uint256 _0xa2bcd8 = _0x2a7f1d[_0x3014f8];
        if (_0xa2bcd8 > 0) {
            _0x2a7f1d[_0x3014f8] = 0;
            IERC20(_0x19cdcb)._0xea89e0(_0x85eb29, _0xa2bcd8);
            IRHYBR(_0x85eb29)._0x8b7527(_0xa2bcd8);
            IRHYBR(_0x85eb29)._0xf55d4f(_0xa2bcd8, _0x929dfc, _0x3014f8);
            emit Harvest(_0x3014f8, _0xa2bcd8);
        }

        if (_0xec3eae != address(0)) {
            IRewarder(_0xec3eae)._0x97681e(_0x3014f8, _0x3014f8, _0x35103b(_0x3014f8));
        }
    }


    function _0x884abe(uint8 _0x929dfc) public _0x8a328b _0x5d5a85(msg.sender) {
        uint256 _0xa2bcd8 = _0x2a7f1d[msg.sender];
        if (_0xa2bcd8 > 0) {
            _0x2a7f1d[msg.sender] = 0;
            IERC20(_0x19cdcb)._0xea89e0(_0x85eb29, _0xa2bcd8);
            IRHYBR(_0x85eb29)._0x8b7527(_0xa2bcd8);
            IRHYBR(_0x85eb29)._0xf55d4f(_0xa2bcd8, _0x929dfc, msg.sender);
            emit Harvest(msg.sender, _0xa2bcd8);
        }

        if (_0xec3eae != address(0)) {
            IRewarder(_0xec3eae)._0x97681e(msg.sender, msg.sender, _0x35103b(msg.sender));
        }
    }


    function _0x256758(address _0x2ed002, uint256 _0xa2bcd8) external _0x8a328b _0x92d4a2 _0x4cebb8 _0x5d5a85(address(0)) {
        require(_0x2ed002 == address(_0x19cdcb), "IA");
        _0x19cdcb._0x4d2c38(DISTRIBUTION, address(this), _0xa2bcd8);

        if (block.timestamp >= _0xf32822) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x4f509e = _0xa2bcd8 / DURATION; }
        } else {
            uint256 _0xf7ec84 = _0xf32822 - block.timestamp;
            uint256 _0xa38bd7 = _0xf7ec84 * _0x4f509e;
            _0x4f509e = (_0xa2bcd8 + _0xa38bd7) / DURATION;
        }


        uint256 balance = _0x19cdcb._0x28c4ff(address(this));
        require(_0x4f509e <= balance / DURATION, "REWARD_HIGH");

        _0x8d7350 = block.timestamp;
        _0xf32822 = block.timestamp + DURATION;
        emit RewardAdded(_0xa2bcd8);
    }

    function _0x5566ec() external _0x8a328b returns (uint256 _0x2e88ba, uint256 _0xb96aff) {
        return _0x2b5929();
    }

     function _0x2b5929() internal returns (uint256 _0x2e88ba, uint256 _0xb96aff) {
        if (!_0xbd84e4) {
            return (0, 0);
        }
        address _0x82d849 = address(TOKEN);
        (_0x2e88ba, _0xb96aff) = IPair(_0x82d849)._0x5566ec();
        if (_0x2e88ba > 0 || _0xb96aff > 0) {

            uint256 _0xb619e5 = _0x2e88ba;
            uint256 _0x093c1f = _0xb96aff;

            (address _0xfaa7de, address _0x35fcbb) = IPair(_0x82d849)._0x530f0a();

            if (_0xb619e5  > 0) {
                IERC20(_0xfaa7de)._0xea89e0(_0x992c65, 0);
                IERC20(_0xfaa7de)._0xea89e0(_0x992c65, _0xb619e5);
                IBribe(_0x992c65)._0x256758(_0xfaa7de, _0xb619e5);
            }
            if (_0x093c1f  > 0) {
                IERC20(_0x35fcbb)._0xea89e0(_0x992c65, 0);
                IERC20(_0x35fcbb)._0xea89e0(_0x992c65, _0x093c1f);
                IBribe(_0x992c65)._0x256758(_0x35fcbb, _0x093c1f);
            }
            emit ClaimFees(msg.sender, _0x2e88ba, _0xb96aff);
        }
    }

}