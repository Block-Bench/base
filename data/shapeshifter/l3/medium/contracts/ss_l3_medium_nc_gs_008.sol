pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IVotingEscrow.sol";
import "./interfaces/IVoter.sol";
import "./interfaces/IBribe.sol";
import "./interfaces/IRewardsDistributor.sol";
import "./interfaces/IGaugeManager.sol";
import "./interfaces/ISwapper.sol";
import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract GrowthHYBR is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public _0xcb54f0 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x25f319 = 1200;
    uint256 public _0x7b1111 = 300;


    uint256 public _0x4e5705 = 100;
    uint256 public constant MIN_WITHDRAW_FEE = 10;
    uint256 public constant MAX_WITHDRAW_FEE = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public _0x0a0d76;
    uint256 public _0x314d36;
    uint256 public _0x5627f8;

    struct UserLock {
        uint256 _0xe85248;
        uint256 _0x823e3a;
    }

    mapping(address => UserLock[]) public _0xdd39d9;
    mapping(address => uint256) public _0x5ac277;


    address public immutable HYBR;
    address public immutable _0x77e250;
    address public _0xbf5dc6;
    address public _0xfb4ce1;
    address public _0xe1255a;
    uint256 public _0xab8475;


    address public _0xa69e95;
    uint256 public _0x155a91;


    uint256 public _0xbf9195;
    uint256 public _0x85e1d8;


    ISwapper public _0x0571e8;


    error NOT_AUTHORIZED();


    event Deposit(address indexed _0x0a4371, uint256 _0x5f1aa1, uint256 _0x87e36d);
    event Withdraw(address indexed _0x0a4371, uint256 _0x1bf0b6, uint256 _0x5f1aa1, uint256 _0x232183);
    event Compound(uint256 _0x71a4b4, uint256 _0x8f5953);
    event PenaltyRewardReceived(uint256 _0xe85248);
    event TransferLockPeriodUpdated(uint256 _0x1b38be, uint256 _0xe4b98d);
    event SwapperUpdated(address indexed _0xd7dc0d, address indexed _0x6206e1);
    event VoterSet(address _0xbf5dc6);
    event EmergencyUnlock(address indexed _0x0a4371);
    event AutoVotingEnabled(bool _0x7672e8);
    event OperatorUpdated(address indexed _0xabaaff, address indexed _0x793e2e);
    event DefaultVotingStrategyUpdated(address[] _0x92c607, uint256[] _0x7d520e);
    event AutoVoteExecuted(uint256 _0xda0eb6, address[] _0x92c607, uint256[] _0x7d520e);

    constructor(
        address _0x4974b4,
        address _0x3f9ad3
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0x4974b4 != address(0), "Invalid HYBR");
        require(_0x3f9ad3 != address(0), "Invalid VE");

        HYBR = _0x4974b4;
        _0x77e250 = _0x3f9ad3;
        _0xbf9195 = block.timestamp;
        _0x85e1d8 = block.timestamp;
        _0xa69e95 = msg.sender;
    }

    function _0xdefa93(address _0xbb4603) external _0x0355ed {
        require(_0xbb4603 != address(0), "Invalid rewards distributor");
        if (1 == 1) { _0xfb4ce1 = _0xbb4603; }
    }

    function _0x60dab6(address _0x2c9b85) external _0x0355ed {
        require(_0x2c9b85 != address(0), "Invalid gauge manager");
        _0xe1255a = _0x2c9b85;
    }


    modifier _0x9ffd01() {
        if (msg.sender != _0xa69e95) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function _0xae5667(uint256 _0xe85248, address _0x5a0989) external _0x963996 {
        require(_0xe85248 > 0, "Zero amount");
        _0x5a0989 = _0x5a0989 == address(0) ? msg.sender : _0x5a0989;


        IERC20(HYBR)._0xd0c5ed(msg.sender, address(this), _0xe85248);


        if (_0xab8475 == 0) {
            _0xbf8ab0(_0xe85248);
        } else {

            IERC20(HYBR)._0xc92404(_0x77e250, _0xe85248);
            IVotingEscrow(_0x77e250)._0x310f34(_0xab8475, _0xe85248);


            _0xab2aea();
        }


        uint256 _0x1bf0b6 = _0xd6420d(_0xe85248);


        _0x0ce2d2(_0x5a0989, _0x1bf0b6);


        _0xf41bd8(_0x5a0989, _0x1bf0b6);

        emit Deposit(msg.sender, _0xe85248, _0x1bf0b6);
    }


    function _0x18d6ed(uint256 _0x1bf0b6) external _0x963996 returns (uint256 _0x7aba56) {
        require(_0x1bf0b6 > 0, "Zero shares");
        require(_0x7a2679(msg.sender) >= _0x1bf0b6, "Insufficient balance");
        require(_0xab8475 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x77e250)._0x7eb1c1(_0xab8475) == false, "Cannot withdraw yet");

        uint256 _0x59972b = HybraTimeLibrary._0x59972b(block.timestamp);
        uint256 _0xeb185c = HybraTimeLibrary._0xeb185c(block.timestamp);

        require(block.timestamp >= _0x59972b + _0x25f319 && block.timestamp < _0xeb185c - _0x7b1111, "Cannot withdraw yet");


        uint256 _0x5f1aa1 = _0xa5640a(_0x1bf0b6);
        require(_0x5f1aa1 > 0, "No assets to withdraw");


        uint256 _0x570124 = 0;
        if (_0x4e5705 > 0) {
            if (1 == 1) { _0x570124 = (_0x5f1aa1 * _0x4e5705) / BASIS; }
        }


        uint256 _0x1029e5 = _0x5f1aa1 - _0x570124;
        require(_0x1029e5 > 0, "Amount too small after fee");


        uint256 _0x6626e0 = _0x65c07e();
        require(_0x5f1aa1 <= _0x6626e0, "Insufficient veNFT balance");

        uint256 _0x4bba29 = _0x6626e0 - _0x1029e5 - _0x570124;
        require(_0x4bba29 >= 0, "Cannot withdraw entire veNFT");


        _0xdcee5e(msg.sender, _0x1bf0b6);


        uint256[] memory _0x55f1d8 = new uint256[](3);
        _0x55f1d8[0] = _0x4bba29;
        _0x55f1d8[1] = _0x1029e5;
        _0x55f1d8[2] = _0x570124;

        uint256[] memory _0xa75cef = IVotingEscrow(_0x77e250)._0x3032c8(_0xab8475, _0x55f1d8);


        _0xab8475 = _0xa75cef[0];
        _0x7aba56 = _0xa75cef[1];
        uint256 _0x62f8e7 = _0xa75cef[2];

        IVotingEscrow(_0x77e250)._0x8ec680(address(this), msg.sender, _0x7aba56);
        IVotingEscrow(_0x77e250)._0x8ec680(address(this), Team, _0x62f8e7);
        emit Withdraw(msg.sender, _0x1bf0b6, _0x1029e5, _0x570124);
    }


    function _0xbf8ab0(uint256 _0x779fbd) internal {

        IERC20(HYBR)._0xc92404(_0x77e250, type(uint256)._0x4747e5);
        uint256 _0x2d021e = HybraTimeLibrary.MAX_LOCK_DURATION;


        _0xab8475 = IVotingEscrow(_0x77e250)._0x4875e5(_0x779fbd, _0x2d021e, address(this));

    }


    function _0xd6420d(uint256 _0xe85248) public view returns (uint256) {
        uint256 _0x4894fd = _0x3f009d();
        uint256 _0xd76bcf = _0x65c07e();
        if (_0x4894fd == 0 || _0xd76bcf == 0) {
            return _0xe85248;
        }
        return (_0xe85248 * _0x4894fd) / _0xd76bcf;
    }


    function _0xa5640a(uint256 _0x1bf0b6) public view returns (uint256) {
        uint256 _0x4894fd = _0x3f009d();
        if (_0x4894fd == 0) {
            return _0x1bf0b6;
        }
        return (_0x1bf0b6 * _0x65c07e()) / _0x4894fd;
    }


    function _0x65c07e() public view returns (uint256) {
        if (_0xab8475 == 0) {
            return 0;
        }

        IVotingEscrow.LockedBalance memory _0x310ca3 = IVotingEscrow(_0x77e250)._0x310ca3(_0xab8475);
        return uint256(int256(_0x310ca3._0xe85248));
    }


    function _0xf41bd8(address _0x0a4371, uint256 _0xe85248) internal {
        uint256 _0x823e3a = block.timestamp + _0xcb54f0;
        _0xdd39d9[_0x0a4371].push(UserLock({
            _0xe85248: _0xe85248,
            _0x823e3a: _0x823e3a
        }));
        _0x5ac277[_0x0a4371] += _0xe85248;
    }


    function _0x01b75b(address _0x0a4371) external view returns (uint256 _0x2b1ea2) {
        uint256 _0x08f0fe = _0x7a2679(_0x0a4371);
        uint256 _0x113f29 = 0;

        UserLock[] storage _0x1e6a8c = _0xdd39d9[_0x0a4371];
        for (uint256 i = 0; i < _0x1e6a8c.length; i++) {
            if (_0x1e6a8c[i]._0x823e3a > block.timestamp) {
                _0x113f29 += _0x1e6a8c[i]._0xe85248;
            }
        }

        return _0x08f0fe > _0x113f29 ? _0x08f0fe - _0x113f29 : 0;
    }

    function _0x466264(address _0x0a4371) internal returns (uint256 _0x9d34b6) {
        UserLock[] storage _0x1e6a8c = _0xdd39d9[_0x0a4371];
        uint256 _0x9f4811 = _0x1e6a8c.length;
        if (_0x9f4811 == 0) return 0;

        uint256 _0x55d78c = 0;
        unchecked {
            for (uint256 i = 0; i < _0x9f4811; i++) {
                UserLock memory L = _0x1e6a8c[i];
                if (L._0x823e3a <= block.timestamp) {
                    _0x9d34b6 += L._0xe85248;
                } else {
                    if (_0x55d78c != i) _0x1e6a8c[_0x55d78c] = L;
                    _0x55d78c++;
                }
            }
            if (_0x9d34b6 > 0) {
                _0x5ac277[_0x0a4371] -= _0x9d34b6;
            }
            while (_0x1e6a8c.length > _0x55d78c) {
                _0x1e6a8c.pop();
            }
        }
    }


    function _0x6cbdee(
        address from,
        address _0x177f06,
        uint256 _0xe85248
    ) internal override {
        super._0x6cbdee(from, _0x177f06, _0xe85248);

        if (from != address(0) && _0x177f06 != address(0)) {
            uint256 _0x08f0fe = _0x7a2679(from);


            uint256 _0xb2c3e5 = _0x08f0fe > _0x5ac277[from] ? _0x08f0fe - _0x5ac277[from] : 0;


            if (_0xb2c3e5 >= _0xe85248) {
                return;
            }


            _0x466264(from);
            uint256 _0x9f21cd = _0x08f0fe > _0x5ac277[from] ? _0x08f0fe - _0x5ac277[from] : 0;


            require(_0x9f21cd >= _0xe85248, "Tokens locked");
        }
    }


    function _0x7bcacb() external _0x9ffd01 {
        require(_0xbf5dc6 != address(0), "Voter not set");
        require(_0xfb4ce1 != address(0), "Distributor not set");


        uint256  _0x02fa14 = IRewardsDistributor(_0xfb4ce1)._0x6267ea(_0xab8475);
        _0x0a0d76 += _0x02fa14;

        address[] memory _0xc23cdd = IVoter(_0xbf5dc6)._0x77c761(_0xab8475);

        for (uint256 i = 0; i < _0xc23cdd.length; i++) {
            if (_0xc23cdd[i] != address(0)) {
                address _0x3065fb = IGaugeManager(_0xe1255a)._0x7ceef2(_0xc23cdd[i]);

                if (_0x3065fb != address(0)) {

                    address[] memory _0xac9efb = new address[](1);
                    address[][] memory _0x149f69 = new address[][](1);


                    address _0x640d09 = IGaugeManager(_0xe1255a)._0x2a69d1(_0x3065fb);
                    if (_0x640d09 != address(0)) {
                        uint256 _0x35f22b = IBribe(_0x640d09)._0x0706c5();
                        if (_0x35f22b > 0) {
                            address[] memory _0xf53b4b = new address[](_0x35f22b);
                            for (uint256 j = 0; j < _0x35f22b; j++) {
                                _0xf53b4b[j] = IBribe(_0x640d09)._0xf53b4b(j);
                            }
                            _0xac9efb[0] = _0x640d09;
                            _0x149f69[0] = _0xf53b4b;

                            IGaugeManager(_0xe1255a)._0xec982b(_0xac9efb, _0x149f69, _0xab8475);
                        }
                    }


                    address _0x894765 = IGaugeManager(_0xe1255a)._0xdae397(_0x3065fb);
                    if (_0x894765 != address(0)) {
                        uint256 _0x35f22b = IBribe(_0x894765)._0x0706c5();
                        if (_0x35f22b > 0) {
                            address[] memory _0xf53b4b = new address[](_0x35f22b);
                            for (uint256 j = 0; j < _0x35f22b; j++) {
                                _0xf53b4b[j] = IBribe(_0x894765)._0xf53b4b(j);
                            }
                            _0xac9efb[0] = _0x894765;
                            _0x149f69[0] = _0xf53b4b;

                            IGaugeManager(_0xe1255a)._0xec982b(_0xac9efb, _0x149f69, _0xab8475);
                        }
                    }
                }
            }
        }
    }


    function _0x0afbe2(ISwapper.SwapParams calldata _0x8f317c) external _0x963996 _0x9ffd01 {
        require(address(_0x0571e8) != address(0), "Swapper not set");


        uint256 _0x168562 = IERC20(_0x8f317c._0xbe4187)._0x7a2679(address(this));
        require(_0x168562 >= _0x8f317c._0x1430fb, "Insufficient token balance");


        IERC20(_0x8f317c._0xbe4187)._0x1acc80(address(_0x0571e8), _0x8f317c._0x1430fb);


        uint256 _0xe3e7eb = _0x0571e8._0xcdb781(_0x8f317c);


        IERC20(_0x8f317c._0xbe4187)._0x1acc80(address(_0x0571e8), 0);


        _0x5627f8 += _0xe3e7eb;
    }


    function _0xfd93e2() external _0x9ffd01 {


        uint256 _0xbe97d5 = IERC20(HYBR)._0x7a2679(address(this));

        if (_0xbe97d5 > 0) {

            IERC20(HYBR)._0x1acc80(_0x77e250, _0xbe97d5);
            IVotingEscrow(_0x77e250)._0x310f34(_0xab8475, _0xbe97d5);


            _0xab2aea();

            _0x85e1d8 = block.timestamp;

            emit Compound(_0xbe97d5, _0x65c07e());
        }
    }


    function _0xd3fbf0(address[] calldata _0xdaf19d, uint256[] calldata _0xa90b19) external {
        require(msg.sender == _0xc4c6cb() || msg.sender == _0xa69e95, "Not authorized");
        require(_0xbf5dc6 != address(0), "Voter not set");

        IVoter(_0xbf5dc6)._0xd3fbf0(_0xab8475, _0xdaf19d, _0xa90b19);
        _0x155a91 = HybraTimeLibrary._0x59972b(block.timestamp);

    }


    function _0x9d7dd1() external {
        require(msg.sender == _0xc4c6cb() || msg.sender == _0xa69e95, "Not authorized");
        require(_0xbf5dc6 != address(0), "Voter not set");

        IVoter(_0xbf5dc6)._0x9d7dd1(_0xab8475);
    }


    function _0x27a247(uint256 _0xe85248) external {


        if (_0xe85248 > 0) {
            IERC20(HYBR)._0xc92404(_0x77e250, _0xe85248);

            if(_0xab8475 == 0){
                _0xbf8ab0(_0xe85248);
            } else{
                IVotingEscrow(_0x77e250)._0x310f34(_0xab8475, _0xe85248);


                _0xab2aea();
            }
        }
        _0x314d36 += _0xe85248;
        emit PenaltyRewardReceived(_0xe85248);
    }


    function _0x1e7b42(address _0x5bb1e1) external _0x0355ed {
        require(_0x5bb1e1 != address(0), "Invalid voter");
        _0xbf5dc6 = _0x5bb1e1;
        emit VoterSet(_0x5bb1e1);
    }


    function _0xd6fc84(uint256 _0xc7d496) external _0x0355ed {
        require(_0xc7d496 >= MIN_LOCK_PERIOD && _0xc7d496 <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x1b38be = _0xcb54f0;
        _0xcb54f0 = _0xc7d496;
        emit TransferLockPeriodUpdated(_0x1b38be, _0xc7d496);
    }


    function _0x14d874(uint256 _0x65e246) external _0x0355ed {
        require(_0x65e246 >= MIN_WITHDRAW_FEE && _0x65e246 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x4e5705 = _0x65e246;
    }

    function _0x59ead6(uint256 _0x214f47) external _0x0355ed {
        _0x25f319 = _0x214f47;
    }

    function _0x2a7508(uint256 _0x214f47) external _0x0355ed {
        _0x7b1111 = _0x214f47;
    }


    function _0x3230b5(address _0x0e9b24) external _0x0355ed {
        require(_0x0e9b24 != address(0), "Invalid swapper");
        address _0xd7dc0d = address(_0x0571e8);
        _0x0571e8 = ISwapper(_0x0e9b24);
        emit SwapperUpdated(_0xd7dc0d, _0x0e9b24);
    }


    function _0xc07155(address _0x1f8339) external _0x0355ed {
        require(_0x1f8339 != address(0), "Invalid team");
        Team = _0x1f8339;
    }


    function _0x40bd19(address _0x0a4371) external _0x9ffd01 {
        delete _0xdd39d9[_0x0a4371];
        _0x5ac277[_0x0a4371] = 0;
        emit EmergencyUnlock(_0x0a4371);
    }


    function _0x6661dd(address _0x0a4371) external view returns (UserLock[] memory) {
        return _0xdd39d9[_0x0a4371];
    }


    function _0x612f15(address _0x113301) external _0x0355ed {
        require(_0x113301 != address(0), "Invalid operator");
        address _0xabaaff = _0xa69e95;
        _0xa69e95 = _0x113301;
        emit OperatorUpdated(_0xabaaff, _0x113301);
    }


    function _0x8e524c() external view returns (uint256) {
        if (_0xab8475 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x310ca3 = IVotingEscrow(_0x77e250)._0x310ca3(_0xab8475);
        return uint256(_0x310ca3._0xff5947);
    }


    function _0xab2aea() internal {
        if (_0xab8475 == 0) return;

        IVotingEscrow.LockedBalance memory _0x310ca3 = IVotingEscrow(_0x77e250)._0x310ca3(_0xab8475);
        if (_0x310ca3._0x982c24 || _0x310ca3._0xff5947 <= block.timestamp) return;

        uint256 _0xe0e80f = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;


        if (_0xe0e80f > _0x310ca3._0xff5947 + 2 hours) {
            try IVotingEscrow(_0x77e250)._0xa8dd28(_0xab8475, HybraTimeLibrary.MAX_LOCK_DURATION) {

            } catch {


            }
        }
    }

}