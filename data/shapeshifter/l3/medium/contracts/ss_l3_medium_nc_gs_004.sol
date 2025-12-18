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

    uint256 public _0x447b2c = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0xfbc90b = 1200;
    uint256 public _0xe52a31 = 300;


    uint256 public _0xde64c3 = 100;
    uint256 public constant MIN_WITHDRAW_FEE = 10;
    uint256 public constant MAX_WITHDRAW_FEE = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public _0xc6c9fb;
    uint256 public _0xafa456;
    uint256 public _0xd496c3;

    struct UserLock {
        uint256 _0xb30542;
        uint256 _0x98452a;
    }

    mapping(address => UserLock[]) public _0x1aec9b;
    mapping(address => uint256) public _0x30ca9e;


    address public immutable HYBR;
    address public immutable _0x34ded8;
    address public _0x5c5b18;
    address public _0x8ec680;
    address public _0x761749;
    uint256 public _0x2463a6;


    address public _0x1d9b06;
    uint256 public _0x6c4dbd;


    uint256 public _0xaf7ea6;
    uint256 public _0xcdab86;


    ISwapper public _0x79b297;


    error NOT_AUTHORIZED();


    event Deposit(address indexed _0xa38e4e, uint256 _0x75f9eb, uint256 _0x2d9bba);
    event Withdraw(address indexed _0xa38e4e, uint256 _0xa798f1, uint256 _0x75f9eb, uint256 _0x7fb47c);
    event Compound(uint256 _0x2f5901, uint256 _0x72936f);
    event PenaltyRewardReceived(uint256 _0xb30542);
    event TransferLockPeriodUpdated(uint256 _0x76d5a0, uint256 _0xda0909);
    event SwapperUpdated(address indexed _0xf03a17, address indexed _0x99295c);
    event VoterSet(address _0x5c5b18);
    event EmergencyUnlock(address indexed _0xa38e4e);
    event AutoVotingEnabled(bool _0xf6ee0d);
    event OperatorUpdated(address indexed _0x087dea, address indexed _0x85f520);
    event DefaultVotingStrategyUpdated(address[] _0x2c244e, uint256[] _0x8f553c);
    event AutoVoteExecuted(uint256 _0xc53b1d, address[] _0x2c244e, uint256[] _0x8f553c);

    constructor(
        address _0xcecc26,
        address _0x7f8d62
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xcecc26 != address(0), "Invalid HYBR");
        require(_0x7f8d62 != address(0), "Invalid VE");

        HYBR = _0xcecc26;
        _0x34ded8 = _0x7f8d62;
        _0xaf7ea6 = block.timestamp;
        _0xcdab86 = block.timestamp;
        _0x1d9b06 = msg.sender;
    }

    function _0x4d325b(address _0x76c6f5) external _0x2bef48 {
        require(_0x76c6f5 != address(0), "Invalid rewards distributor");
        _0x8ec680 = _0x76c6f5;
    }

    function _0x3250b6(address _0xc25abd) external _0x2bef48 {
        require(_0xc25abd != address(0), "Invalid gauge manager");
        _0x761749 = _0xc25abd;
    }


    modifier _0xccbec5() {
        if (msg.sender != _0x1d9b06) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function _0xf07089(uint256 _0xb30542, address _0x6b8d47) external _0xd172ae {
        require(_0xb30542 > 0, "Zero amount");
        _0x6b8d47 = _0x6b8d47 == address(0) ? msg.sender : _0x6b8d47;


        IERC20(HYBR)._0xf27440(msg.sender, address(this), _0xb30542);


        if (_0x2463a6 == 0) {
            _0xe5ba17(_0xb30542);
        } else {

            IERC20(HYBR)._0x739957(_0x34ded8, _0xb30542);
            IVotingEscrow(_0x34ded8)._0x9352d2(_0x2463a6, _0xb30542);


            _0x818509();
        }


        uint256 _0xa798f1 = _0x4365c5(_0xb30542);


        _0x35c22a(_0x6b8d47, _0xa798f1);


        _0x4cddaf(_0x6b8d47, _0xa798f1);

        emit Deposit(msg.sender, _0xb30542, _0xa798f1);
    }


    function _0xc12dd5(uint256 _0xa798f1) external _0xd172ae returns (uint256 _0xd168dd) {
        require(_0xa798f1 > 0, "Zero shares");
        require(_0x0736d5(msg.sender) >= _0xa798f1, "Insufficient balance");
        require(_0x2463a6 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x34ded8)._0x6f7944(_0x2463a6) == false, "Cannot withdraw yet");

        uint256 _0xcd7874 = HybraTimeLibrary._0xcd7874(block.timestamp);
        uint256 _0xac5200 = HybraTimeLibrary._0xac5200(block.timestamp);

        require(block.timestamp >= _0xcd7874 + _0xfbc90b && block.timestamp < _0xac5200 - _0xe52a31, "Cannot withdraw yet");


        uint256 _0x75f9eb = _0xf4da44(_0xa798f1);
        require(_0x75f9eb > 0, "No assets to withdraw");


        uint256 _0xe79115 = 0;
        if (_0xde64c3 > 0) {
            _0xe79115 = (_0x75f9eb * _0xde64c3) / BASIS;
        }


        uint256 _0xcf4999 = _0x75f9eb - _0xe79115;
        require(_0xcf4999 > 0, "Amount too small after fee");


        uint256 _0x976f34 = _0x276ac6();
        require(_0x75f9eb <= _0x976f34, "Insufficient veNFT balance");

        uint256 _0x9ced06 = _0x976f34 - _0xcf4999 - _0xe79115;
        require(_0x9ced06 >= 0, "Cannot withdraw entire veNFT");


        _0xa6d53f(msg.sender, _0xa798f1);


        uint256[] memory _0xcfb2a7 = new uint256[](3);
        _0xcfb2a7[0] = _0x9ced06;
        _0xcfb2a7[1] = _0xcf4999;
        _0xcfb2a7[2] = _0xe79115;

        uint256[] memory _0xa87b72 = IVotingEscrow(_0x34ded8)._0x56393e(_0x2463a6, _0xcfb2a7);


        if (1 == 1) { _0x2463a6 = _0xa87b72[0]; }
        _0xd168dd = _0xa87b72[1];
        uint256 _0x6eb0af = _0xa87b72[2];

        IVotingEscrow(_0x34ded8)._0xd79d95(address(this), msg.sender, _0xd168dd);
        IVotingEscrow(_0x34ded8)._0xd79d95(address(this), Team, _0x6eb0af);
        emit Withdraw(msg.sender, _0xa798f1, _0xcf4999, _0xe79115);
    }


    function _0xe5ba17(uint256 _0xfec562) internal {

        IERC20(HYBR)._0x739957(_0x34ded8, type(uint256)._0x53bdff);
        uint256 _0x4c4dab = HybraTimeLibrary.MAX_LOCK_DURATION;


        _0x2463a6 = IVotingEscrow(_0x34ded8)._0xf15a10(_0xfec562, _0x4c4dab, address(this));

    }


    function _0x4365c5(uint256 _0xb30542) public view returns (uint256) {
        uint256 _0xd3e18f = _0xf3a036();
        uint256 _0xc134fc = _0x276ac6();
        if (_0xd3e18f == 0 || _0xc134fc == 0) {
            return _0xb30542;
        }
        return (_0xb30542 * _0xd3e18f) / _0xc134fc;
    }


    function _0xf4da44(uint256 _0xa798f1) public view returns (uint256) {
        uint256 _0xd3e18f = _0xf3a036();
        if (_0xd3e18f == 0) {
            return _0xa798f1;
        }
        return (_0xa798f1 * _0x276ac6()) / _0xd3e18f;
    }


    function _0x276ac6() public view returns (uint256) {
        if (_0x2463a6 == 0) {
            return 0;
        }

        IVotingEscrow.LockedBalance memory _0x27fd1f = IVotingEscrow(_0x34ded8)._0x27fd1f(_0x2463a6);
        return uint256(int256(_0x27fd1f._0xb30542));
    }


    function _0x4cddaf(address _0xa38e4e, uint256 _0xb30542) internal {
        uint256 _0x98452a = block.timestamp + _0x447b2c;
        _0x1aec9b[_0xa38e4e].push(UserLock({
            _0xb30542: _0xb30542,
            _0x98452a: _0x98452a
        }));
        _0x30ca9e[_0xa38e4e] += _0xb30542;
    }


    function _0xc4d1c9(address _0xa38e4e) external view returns (uint256 _0xd193c1) {
        uint256 _0x00bde9 = _0x0736d5(_0xa38e4e);
        uint256 _0x035d95 = 0;

        UserLock[] storage _0xfc5dce = _0x1aec9b[_0xa38e4e];
        for (uint256 i = 0; i < _0xfc5dce.length; i++) {
            if (_0xfc5dce[i]._0x98452a > block.timestamp) {
                _0x035d95 += _0xfc5dce[i]._0xb30542;
            }
        }

        return _0x00bde9 > _0x035d95 ? _0x00bde9 - _0x035d95 : 0;
    }

    function _0x87aede(address _0xa38e4e) internal returns (uint256 _0x5d5b4c) {
        UserLock[] storage _0xfc5dce = _0x1aec9b[_0xa38e4e];
        uint256 _0xf86449 = _0xfc5dce.length;
        if (_0xf86449 == 0) return 0;

        uint256 _0xe0fcd1 = 0;
        unchecked {
            for (uint256 i = 0; i < _0xf86449; i++) {
                UserLock memory L = _0xfc5dce[i];
                if (L._0x98452a <= block.timestamp) {
                    _0x5d5b4c += L._0xb30542;
                } else {
                    if (_0xe0fcd1 != i) _0xfc5dce[_0xe0fcd1] = L;
                    _0xe0fcd1++;
                }
            }
            if (_0x5d5b4c > 0) {
                _0x30ca9e[_0xa38e4e] -= _0x5d5b4c;
            }
            while (_0xfc5dce.length > _0xe0fcd1) {
                _0xfc5dce.pop();
            }
        }
    }


    function _0xe85486(
        address from,
        address _0x3cd348,
        uint256 _0xb30542
    ) internal override {
        super._0xe85486(from, _0x3cd348, _0xb30542);

        if (from != address(0) && _0x3cd348 != address(0)) {
            uint256 _0x00bde9 = _0x0736d5(from);


            uint256 _0xef3b8c = _0x00bde9 > _0x30ca9e[from] ? _0x00bde9 - _0x30ca9e[from] : 0;


            if (_0xef3b8c >= _0xb30542) {
                return;
            }


            _0x87aede(from);
            uint256 _0x5fedb9 = _0x00bde9 > _0x30ca9e[from] ? _0x00bde9 - _0x30ca9e[from] : 0;


            require(_0x5fedb9 >= _0xb30542, "Tokens locked");
        }
    }


    function _0x2bb288() external _0xccbec5 {
        require(_0x5c5b18 != address(0), "Voter not set");
        require(_0x8ec680 != address(0), "Distributor not set");


        uint256  _0xda1b6b = IRewardsDistributor(_0x8ec680)._0xd67c40(_0x2463a6);
        _0xc6c9fb += _0xda1b6b;

        address[] memory _0x166713 = IVoter(_0x5c5b18)._0x18bfab(_0x2463a6);

        for (uint256 i = 0; i < _0x166713.length; i++) {
            if (_0x166713[i] != address(0)) {
                address _0xf92432 = IGaugeManager(_0x761749)._0xf6ec83(_0x166713[i]);

                if (_0xf92432 != address(0)) {

                    address[] memory _0x379e79 = new address[](1);
                    address[][] memory _0x0291ac = new address[][](1);


                    address _0x8dbe06 = IGaugeManager(_0x761749)._0xb91164(_0xf92432);
                    if (_0x8dbe06 != address(0)) {
                        uint256 _0x1f05a3 = IBribe(_0x8dbe06)._0x35f551();
                        if (_0x1f05a3 > 0) {
                            address[] memory _0xe45f2e = new address[](_0x1f05a3);
                            for (uint256 j = 0; j < _0x1f05a3; j++) {
                                _0xe45f2e[j] = IBribe(_0x8dbe06)._0xe45f2e(j);
                            }
                            _0x379e79[0] = _0x8dbe06;
                            _0x0291ac[0] = _0xe45f2e;

                            IGaugeManager(_0x761749)._0x2ee414(_0x379e79, _0x0291ac, _0x2463a6);
                        }
                    }


                    address _0xc04cdb = IGaugeManager(_0x761749)._0x8714e2(_0xf92432);
                    if (_0xc04cdb != address(0)) {
                        uint256 _0x1f05a3 = IBribe(_0xc04cdb)._0x35f551();
                        if (_0x1f05a3 > 0) {
                            address[] memory _0xe45f2e = new address[](_0x1f05a3);
                            for (uint256 j = 0; j < _0x1f05a3; j++) {
                                _0xe45f2e[j] = IBribe(_0xc04cdb)._0xe45f2e(j);
                            }
                            _0x379e79[0] = _0xc04cdb;
                            _0x0291ac[0] = _0xe45f2e;

                            IGaugeManager(_0x761749)._0x2ee414(_0x379e79, _0x0291ac, _0x2463a6);
                        }
                    }
                }
            }
        }
    }


    function _0xc5ee3b(ISwapper.SwapParams calldata _0x124f0e) external _0xd172ae _0xccbec5 {
        require(address(_0x79b297) != address(0), "Swapper not set");


        uint256 _0x3a8b80 = IERC20(_0x124f0e._0x80fca8)._0x0736d5(address(this));
        require(_0x3a8b80 >= _0x124f0e._0x2fced8, "Insufficient token balance");


        IERC20(_0x124f0e._0x80fca8)._0xb78218(address(_0x79b297), _0x124f0e._0x2fced8);


        uint256 _0xd697e2 = _0x79b297._0xd0e7f3(_0x124f0e);


        IERC20(_0x124f0e._0x80fca8)._0xb78218(address(_0x79b297), 0);


        _0xd496c3 += _0xd697e2;
    }


    function _0x128e3b() external _0xccbec5 {


        uint256 _0x60bd70 = IERC20(HYBR)._0x0736d5(address(this));

        if (_0x60bd70 > 0) {

            IERC20(HYBR)._0xb78218(_0x34ded8, _0x60bd70);
            IVotingEscrow(_0x34ded8)._0x9352d2(_0x2463a6, _0x60bd70);


            _0x818509();

            _0xcdab86 = block.timestamp;

            emit Compound(_0x60bd70, _0x276ac6());
        }
    }


    function _0xf1c10b(address[] calldata _0x243bf0, uint256[] calldata _0xcf1df7) external {
        require(msg.sender == _0x1fcdec() || msg.sender == _0x1d9b06, "Not authorized");
        require(_0x5c5b18 != address(0), "Voter not set");

        IVoter(_0x5c5b18)._0xf1c10b(_0x2463a6, _0x243bf0, _0xcf1df7);
        _0x6c4dbd = HybraTimeLibrary._0xcd7874(block.timestamp);

    }


    function _0x3f53e6() external {
        require(msg.sender == _0x1fcdec() || msg.sender == _0x1d9b06, "Not authorized");
        require(_0x5c5b18 != address(0), "Voter not set");

        IVoter(_0x5c5b18)._0x3f53e6(_0x2463a6);
    }


    function _0xd80722(uint256 _0xb30542) external {


        if (_0xb30542 > 0) {
            IERC20(HYBR)._0x739957(_0x34ded8, _0xb30542);

            if(_0x2463a6 == 0){
                _0xe5ba17(_0xb30542);
            } else{
                IVotingEscrow(_0x34ded8)._0x9352d2(_0x2463a6, _0xb30542);


                _0x818509();
            }
        }
        _0xafa456 += _0xb30542;
        emit PenaltyRewardReceived(_0xb30542);
    }


    function _0x626338(address _0x4b03de) external _0x2bef48 {
        require(_0x4b03de != address(0), "Invalid voter");
        _0x5c5b18 = _0x4b03de;
        emit VoterSet(_0x4b03de);
    }


    function _0x5f85d2(uint256 _0xaa4bce) external _0x2bef48 {
        require(_0xaa4bce >= MIN_LOCK_PERIOD && _0xaa4bce <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x76d5a0 = _0x447b2c;
        _0x447b2c = _0xaa4bce;
        emit TransferLockPeriodUpdated(_0x76d5a0, _0xaa4bce);
    }


    function _0x273b01(uint256 _0x2afa88) external _0x2bef48 {
        require(_0x2afa88 >= MIN_WITHDRAW_FEE && _0x2afa88 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0xde64c3 = _0x2afa88;
    }

    function _0x089aed(uint256 _0x86b1a1) external _0x2bef48 {
        _0xfbc90b = _0x86b1a1;
    }

    function _0x48af59(uint256 _0x86b1a1) external _0x2bef48 {
        _0xe52a31 = _0x86b1a1;
    }


    function _0x86513a(address _0x7dd5c3) external _0x2bef48 {
        require(_0x7dd5c3 != address(0), "Invalid swapper");
        address _0xf03a17 = address(_0x79b297);
        if (gasleft() > 0) { _0x79b297 = ISwapper(_0x7dd5c3); }
        emit SwapperUpdated(_0xf03a17, _0x7dd5c3);
    }


    function _0xad19ce(address _0x3a13c8) external _0x2bef48 {
        require(_0x3a13c8 != address(0), "Invalid team");
        Team = _0x3a13c8;
    }


    function _0xa661cc(address _0xa38e4e) external _0xccbec5 {
        delete _0x1aec9b[_0xa38e4e];
        _0x30ca9e[_0xa38e4e] = 0;
        emit EmergencyUnlock(_0xa38e4e);
    }


    function _0xc6a7ac(address _0xa38e4e) external view returns (UserLock[] memory) {
        return _0x1aec9b[_0xa38e4e];
    }


    function _0x187fa4(address _0x97f23e) external _0x2bef48 {
        require(_0x97f23e != address(0), "Invalid operator");
        address _0x087dea = _0x1d9b06;
        if (true) { _0x1d9b06 = _0x97f23e; }
        emit OperatorUpdated(_0x087dea, _0x97f23e);
    }


    function _0x86db8e() external view returns (uint256) {
        if (_0x2463a6 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x27fd1f = IVotingEscrow(_0x34ded8)._0x27fd1f(_0x2463a6);
        return uint256(_0x27fd1f._0xed3b4d);
    }


    function _0x818509() internal {
        if (_0x2463a6 == 0) return;

        IVotingEscrow.LockedBalance memory _0x27fd1f = IVotingEscrow(_0x34ded8)._0x27fd1f(_0x2463a6);
        if (_0x27fd1f._0x513ae0 || _0x27fd1f._0xed3b4d <= block.timestamp) return;

        uint256 _0x804e66 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;


        if (_0x804e66 > _0x27fd1f._0xed3b4d + 2 hours) {
            try IVotingEscrow(_0x34ded8)._0xdcad81(_0x2463a6, HybraTimeLibrary.MAX_LOCK_DURATION) {

            } catch {


            }
        }
    }

}