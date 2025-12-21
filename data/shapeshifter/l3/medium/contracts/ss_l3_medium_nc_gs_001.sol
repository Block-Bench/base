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

    uint256 public _0xaaaea8 = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0xadf5cc = 1200;
    uint256 public _0xa4f705 = 300;


    uint256 public _0x7ef047 = 100;
    uint256 public constant MIN_WITHDRAW_FEE = 10;
    uint256 public constant MAX_WITHDRAW_FEE = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public _0x31ca07;
    uint256 public _0x97948d;
    uint256 public _0x4dc9da;

    struct UserLock {
        uint256 _0xe8aa9e;
        uint256 _0xda0981;
    }

    mapping(address => UserLock[]) public _0x7813e2;
    mapping(address => uint256) public _0x9f0083;


    address public immutable HYBR;
    address public immutable _0x4eabba;
    address public _0x773c47;
    address public _0xc4818e;
    address public _0x3454d9;
    uint256 public _0x5adfbc;


    address public _0x70d0e8;
    uint256 public _0xa068eb;


    uint256 public _0xcb871a;
    uint256 public _0x70803c;


    ISwapper public _0x5d4364;


    error NOT_AUTHORIZED();


    event Deposit(address indexed _0x7e6844, uint256 _0xce68a8, uint256 _0x4f3d10);
    event Withdraw(address indexed _0x7e6844, uint256 _0x92cc93, uint256 _0xce68a8, uint256 _0x758ace);
    event Compound(uint256 _0xde2412, uint256 _0xc01c47);
    event PenaltyRewardReceived(uint256 _0xe8aa9e);
    event TransferLockPeriodUpdated(uint256 _0x052e0d, uint256 _0xf612d6);
    event SwapperUpdated(address indexed _0x512adc, address indexed _0x7403fa);
    event VoterSet(address _0x773c47);
    event EmergencyUnlock(address indexed _0x7e6844);
    event AutoVotingEnabled(bool _0xae60cf);
    event OperatorUpdated(address indexed _0x5507b0, address indexed _0x6d2907);
    event DefaultVotingStrategyUpdated(address[] _0xb57515, uint256[] _0x00b9d1);
    event AutoVoteExecuted(uint256 _0xabb927, address[] _0xb57515, uint256[] _0x00b9d1);

    constructor(
        address _0xd170b4,
        address _0x619ae4
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xd170b4 != address(0), "Invalid HYBR");
        require(_0x619ae4 != address(0), "Invalid VE");

        HYBR = _0xd170b4;
        _0x4eabba = _0x619ae4;
        _0xcb871a = block.timestamp;
        _0x70803c = block.timestamp;
        _0x70d0e8 = msg.sender;
    }

    function _0x9243cf(address _0x41e826) external _0x0a8ba7 {
        require(_0x41e826 != address(0), "Invalid rewards distributor");
        if (block.timestamp > 0) { _0xc4818e = _0x41e826; }
    }

    function _0x69d64e(address _0x7f4850) external _0x0a8ba7 {
        require(_0x7f4850 != address(0), "Invalid gauge manager");
        _0x3454d9 = _0x7f4850;
    }


    modifier _0xacafcf() {
        if (msg.sender != _0x70d0e8) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function _0xf9916b(uint256 _0xe8aa9e, address _0xe0adab) external _0xfc1165 {
        require(_0xe8aa9e > 0, "Zero amount");
        _0xe0adab = _0xe0adab == address(0) ? msg.sender : _0xe0adab;


        IERC20(HYBR)._0xa99d49(msg.sender, address(this), _0xe8aa9e);


        if (_0x5adfbc == 0) {
            _0xbfeb5c(_0xe8aa9e);
        } else {

            IERC20(HYBR)._0xdaf430(_0x4eabba, _0xe8aa9e);
            IVotingEscrow(_0x4eabba)._0x8dccb9(_0x5adfbc, _0xe8aa9e);


            _0xdb880b();
        }


        uint256 _0x92cc93 = _0x4baf74(_0xe8aa9e);


        _0xd184bd(_0xe0adab, _0x92cc93);


        _0xc598cd(_0xe0adab, _0x92cc93);

        emit Deposit(msg.sender, _0xe8aa9e, _0x92cc93);
    }


    function _0x79e0bd(uint256 _0x92cc93) external _0xfc1165 returns (uint256 _0x3cd399) {
        require(_0x92cc93 > 0, "Zero shares");
        require(_0x495696(msg.sender) >= _0x92cc93, "Insufficient balance");
        require(_0x5adfbc != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x4eabba)._0xd99998(_0x5adfbc) == false, "Cannot withdraw yet");

        uint256 _0x1ae2e2 = HybraTimeLibrary._0x1ae2e2(block.timestamp);
        uint256 _0xdc87e9 = HybraTimeLibrary._0xdc87e9(block.timestamp);

        require(block.timestamp >= _0x1ae2e2 + _0xadf5cc && block.timestamp < _0xdc87e9 - _0xa4f705, "Cannot withdraw yet");


        uint256 _0xce68a8 = _0x5c474a(_0x92cc93);
        require(_0xce68a8 > 0, "No assets to withdraw");


        uint256 _0xe7bf27 = 0;
        if (_0x7ef047 > 0) {
            _0xe7bf27 = (_0xce68a8 * _0x7ef047) / BASIS;
        }


        uint256 _0x72ed4b = _0xce68a8 - _0xe7bf27;
        require(_0x72ed4b > 0, "Amount too small after fee");


        uint256 _0xdb0b71 = _0x7a37bf();
        require(_0xce68a8 <= _0xdb0b71, "Insufficient veNFT balance");

        uint256 _0x2de63b = _0xdb0b71 - _0x72ed4b - _0xe7bf27;
        require(_0x2de63b >= 0, "Cannot withdraw entire veNFT");


        _0xd47d4d(msg.sender, _0x92cc93);


        uint256[] memory _0x3ce710 = new uint256[](3);
        _0x3ce710[0] = _0x2de63b;
        _0x3ce710[1] = _0x72ed4b;
        _0x3ce710[2] = _0xe7bf27;

        uint256[] memory _0xf67af3 = IVotingEscrow(_0x4eabba)._0xa9a5c3(_0x5adfbc, _0x3ce710);


        _0x5adfbc = _0xf67af3[0];
        _0x3cd399 = _0xf67af3[1];
        uint256 _0x63cce3 = _0xf67af3[2];

        IVotingEscrow(_0x4eabba)._0xe42bb7(address(this), msg.sender, _0x3cd399);
        IVotingEscrow(_0x4eabba)._0xe42bb7(address(this), Team, _0x63cce3);
        emit Withdraw(msg.sender, _0x92cc93, _0x72ed4b, _0xe7bf27);
    }


    function _0xbfeb5c(uint256 _0xfc0bd3) internal {

        IERC20(HYBR)._0xdaf430(_0x4eabba, type(uint256)._0x4ed948);
        uint256 _0xe3d673 = HybraTimeLibrary.MAX_LOCK_DURATION;


        _0x5adfbc = IVotingEscrow(_0x4eabba)._0xd1dea7(_0xfc0bd3, _0xe3d673, address(this));

    }


    function _0x4baf74(uint256 _0xe8aa9e) public view returns (uint256) {
        uint256 _0xb90633 = _0x602942();
        uint256 _0xa6f679 = _0x7a37bf();
        if (_0xb90633 == 0 || _0xa6f679 == 0) {
            return _0xe8aa9e;
        }
        return (_0xe8aa9e * _0xb90633) / _0xa6f679;
    }


    function _0x5c474a(uint256 _0x92cc93) public view returns (uint256) {
        uint256 _0xb90633 = _0x602942();
        if (_0xb90633 == 0) {
            return _0x92cc93;
        }
        return (_0x92cc93 * _0x7a37bf()) / _0xb90633;
    }


    function _0x7a37bf() public view returns (uint256) {
        if (_0x5adfbc == 0) {
            return 0;
        }

        IVotingEscrow.LockedBalance memory _0x15546e = IVotingEscrow(_0x4eabba)._0x15546e(_0x5adfbc);
        return uint256(int256(_0x15546e._0xe8aa9e));
    }


    function _0xc598cd(address _0x7e6844, uint256 _0xe8aa9e) internal {
        uint256 _0xda0981 = block.timestamp + _0xaaaea8;
        _0x7813e2[_0x7e6844].push(UserLock({
            _0xe8aa9e: _0xe8aa9e,
            _0xda0981: _0xda0981
        }));
        _0x9f0083[_0x7e6844] += _0xe8aa9e;
    }


    function _0xfbfe46(address _0x7e6844) external view returns (uint256 _0x7871fd) {
        uint256 _0x37105f = _0x495696(_0x7e6844);
        uint256 _0x5754c6 = 0;

        UserLock[] storage _0x8771e6 = _0x7813e2[_0x7e6844];
        for (uint256 i = 0; i < _0x8771e6.length; i++) {
            if (_0x8771e6[i]._0xda0981 > block.timestamp) {
                _0x5754c6 += _0x8771e6[i]._0xe8aa9e;
            }
        }

        return _0x37105f > _0x5754c6 ? _0x37105f - _0x5754c6 : 0;
    }

    function _0x2c4054(address _0x7e6844) internal returns (uint256 _0x9ebb1d) {
        UserLock[] storage _0x8771e6 = _0x7813e2[_0x7e6844];
        uint256 _0x411517 = _0x8771e6.length;
        if (_0x411517 == 0) return 0;

        uint256 _0xa71862 = 0;
        unchecked {
            for (uint256 i = 0; i < _0x411517; i++) {
                UserLock memory L = _0x8771e6[i];
                if (L._0xda0981 <= block.timestamp) {
                    _0x9ebb1d += L._0xe8aa9e;
                } else {
                    if (_0xa71862 != i) _0x8771e6[_0xa71862] = L;
                    _0xa71862++;
                }
            }
            if (_0x9ebb1d > 0) {
                _0x9f0083[_0x7e6844] -= _0x9ebb1d;
            }
            while (_0x8771e6.length > _0xa71862) {
                _0x8771e6.pop();
            }
        }
    }


    function _0xc67aba(
        address from,
        address _0x88ffa5,
        uint256 _0xe8aa9e
    ) internal override {
        super._0xc67aba(from, _0x88ffa5, _0xe8aa9e);

        if (from != address(0) && _0x88ffa5 != address(0)) {
            uint256 _0x37105f = _0x495696(from);


            uint256 _0xc764e2 = _0x37105f > _0x9f0083[from] ? _0x37105f - _0x9f0083[from] : 0;


            if (_0xc764e2 >= _0xe8aa9e) {
                return;
            }


            _0x2c4054(from);
            uint256 _0x101334 = _0x37105f > _0x9f0083[from] ? _0x37105f - _0x9f0083[from] : 0;


            require(_0x101334 >= _0xe8aa9e, "Tokens locked");
        }
    }


    function _0x943e41() external _0xacafcf {
        require(_0x773c47 != address(0), "Voter not set");
        require(_0xc4818e != address(0), "Distributor not set");


        uint256  _0x779840 = IRewardsDistributor(_0xc4818e)._0x8225fe(_0x5adfbc);
        _0x31ca07 += _0x779840;

        address[] memory _0xdea61b = IVoter(_0x773c47)._0x3ffa66(_0x5adfbc);

        for (uint256 i = 0; i < _0xdea61b.length; i++) {
            if (_0xdea61b[i] != address(0)) {
                address _0x274ef3 = IGaugeManager(_0x3454d9)._0x06e143(_0xdea61b[i]);

                if (_0x274ef3 != address(0)) {

                    address[] memory _0xd32eb8 = new address[](1);
                    address[][] memory _0x8eaa82 = new address[][](1);


                    address _0xa48385 = IGaugeManager(_0x3454d9)._0xafc5ab(_0x274ef3);
                    if (_0xa48385 != address(0)) {
                        uint256 _0xb32c05 = IBribe(_0xa48385)._0x422ff1();
                        if (_0xb32c05 > 0) {
                            address[] memory _0x488ff5 = new address[](_0xb32c05);
                            for (uint256 j = 0; j < _0xb32c05; j++) {
                                _0x488ff5[j] = IBribe(_0xa48385)._0x488ff5(j);
                            }
                            _0xd32eb8[0] = _0xa48385;
                            _0x8eaa82[0] = _0x488ff5;

                            IGaugeManager(_0x3454d9)._0x63f9c0(_0xd32eb8, _0x8eaa82, _0x5adfbc);
                        }
                    }


                    address _0x83041c = IGaugeManager(_0x3454d9)._0x1bd531(_0x274ef3);
                    if (_0x83041c != address(0)) {
                        uint256 _0xb32c05 = IBribe(_0x83041c)._0x422ff1();
                        if (_0xb32c05 > 0) {
                            address[] memory _0x488ff5 = new address[](_0xb32c05);
                            for (uint256 j = 0; j < _0xb32c05; j++) {
                                _0x488ff5[j] = IBribe(_0x83041c)._0x488ff5(j);
                            }
                            _0xd32eb8[0] = _0x83041c;
                            _0x8eaa82[0] = _0x488ff5;

                            IGaugeManager(_0x3454d9)._0x63f9c0(_0xd32eb8, _0x8eaa82, _0x5adfbc);
                        }
                    }
                }
            }
        }
    }


    function _0xe5d90a(ISwapper.SwapParams calldata _0x2fe9cc) external _0xfc1165 _0xacafcf {
        require(address(_0x5d4364) != address(0), "Swapper not set");


        uint256 _0xa11c03 = IERC20(_0x2fe9cc._0x8864f5)._0x495696(address(this));
        require(_0xa11c03 >= _0x2fe9cc._0x5b3ee5, "Insufficient token balance");


        IERC20(_0x2fe9cc._0x8864f5)._0x7cc475(address(_0x5d4364), _0x2fe9cc._0x5b3ee5);


        uint256 _0xc4ffd9 = _0x5d4364._0x6d7c65(_0x2fe9cc);


        IERC20(_0x2fe9cc._0x8864f5)._0x7cc475(address(_0x5d4364), 0);


        _0x4dc9da += _0xc4ffd9;
    }


    function _0x06fe30() external _0xacafcf {


        uint256 _0x88838a = IERC20(HYBR)._0x495696(address(this));

        if (_0x88838a > 0) {

            IERC20(HYBR)._0x7cc475(_0x4eabba, _0x88838a);
            IVotingEscrow(_0x4eabba)._0x8dccb9(_0x5adfbc, _0x88838a);


            _0xdb880b();

            _0x70803c = block.timestamp;

            emit Compound(_0x88838a, _0x7a37bf());
        }
    }


    function _0x1fd1ca(address[] calldata _0x6e2ad1, uint256[] calldata _0x93bb83) external {
        require(msg.sender == _0x87db9f() || msg.sender == _0x70d0e8, "Not authorized");
        require(_0x773c47 != address(0), "Voter not set");

        IVoter(_0x773c47)._0x1fd1ca(_0x5adfbc, _0x6e2ad1, _0x93bb83);
        _0xa068eb = HybraTimeLibrary._0x1ae2e2(block.timestamp);

    }


    function _0xa7d8ae() external {
        require(msg.sender == _0x87db9f() || msg.sender == _0x70d0e8, "Not authorized");
        require(_0x773c47 != address(0), "Voter not set");

        IVoter(_0x773c47)._0xa7d8ae(_0x5adfbc);
    }


    function _0x1e2388(uint256 _0xe8aa9e) external {


        if (_0xe8aa9e > 0) {
            IERC20(HYBR)._0xdaf430(_0x4eabba, _0xe8aa9e);

            if(_0x5adfbc == 0){
                _0xbfeb5c(_0xe8aa9e);
            } else{
                IVotingEscrow(_0x4eabba)._0x8dccb9(_0x5adfbc, _0xe8aa9e);


                _0xdb880b();
            }
        }
        _0x97948d += _0xe8aa9e;
        emit PenaltyRewardReceived(_0xe8aa9e);
    }


    function _0xd1859a(address _0x1c4702) external _0x0a8ba7 {
        require(_0x1c4702 != address(0), "Invalid voter");
        _0x773c47 = _0x1c4702;
        emit VoterSet(_0x1c4702);
    }


    function _0xafb42a(uint256 _0xafa20d) external _0x0a8ba7 {
        require(_0xafa20d >= MIN_LOCK_PERIOD && _0xafa20d <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x052e0d = _0xaaaea8;
        _0xaaaea8 = _0xafa20d;
        emit TransferLockPeriodUpdated(_0x052e0d, _0xafa20d);
    }


    function _0xa20c7c(uint256 _0x91826a) external _0x0a8ba7 {
        require(_0x91826a >= MIN_WITHDRAW_FEE && _0x91826a <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x7ef047 = _0x91826a;
    }

    function _0xfbf823(uint256 _0x3d95dd) external _0x0a8ba7 {
        _0xadf5cc = _0x3d95dd;
    }

    function _0x7e189e(uint256 _0x3d95dd) external _0x0a8ba7 {
        if (block.timestamp > 0) { _0xa4f705 = _0x3d95dd; }
    }


    function _0x541755(address _0x644f51) external _0x0a8ba7 {
        require(_0x644f51 != address(0), "Invalid swapper");
        address _0x512adc = address(_0x5d4364);
        _0x5d4364 = ISwapper(_0x644f51);
        emit SwapperUpdated(_0x512adc, _0x644f51);
    }


    function _0x10f63d(address _0x070338) external _0x0a8ba7 {
        require(_0x070338 != address(0), "Invalid team");
        Team = _0x070338;
    }


    function _0x9e36fb(address _0x7e6844) external _0xacafcf {
        delete _0x7813e2[_0x7e6844];
        _0x9f0083[_0x7e6844] = 0;
        emit EmergencyUnlock(_0x7e6844);
    }


    function _0x647bc8(address _0x7e6844) external view returns (UserLock[] memory) {
        return _0x7813e2[_0x7e6844];
    }


    function _0x22cf71(address _0xc05552) external _0x0a8ba7 {
        require(_0xc05552 != address(0), "Invalid operator");
        address _0x5507b0 = _0x70d0e8;
        _0x70d0e8 = _0xc05552;
        emit OperatorUpdated(_0x5507b0, _0xc05552);
    }


    function _0x593ab2() external view returns (uint256) {
        if (_0x5adfbc == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x15546e = IVotingEscrow(_0x4eabba)._0x15546e(_0x5adfbc);
        return uint256(_0x15546e._0xb7221b);
    }


    function _0xdb880b() internal {
        if (_0x5adfbc == 0) return;

        IVotingEscrow.LockedBalance memory _0x15546e = IVotingEscrow(_0x4eabba)._0x15546e(_0x5adfbc);
        if (_0x15546e._0xac02ee || _0x15546e._0xb7221b <= block.timestamp) return;

        uint256 _0xfdbaed = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;


        if (_0xfdbaed > _0x15546e._0xb7221b + 2 hours) {
            try IVotingEscrow(_0x4eabba)._0x1f181f(_0x5adfbc, HybraTimeLibrary.MAX_LOCK_DURATION) {

            } catch {


            }
        }
    }

}