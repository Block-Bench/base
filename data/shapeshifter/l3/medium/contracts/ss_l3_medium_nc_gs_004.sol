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

    uint256 public _0x3476fb = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x04845f = 1200;
    uint256 public _0xcaacfc = 300;


    uint256 public _0xac613a = 100;
    uint256 public constant MIN_WITHDRAW_FEE = 10;
    uint256 public constant MAX_WITHDRAW_FEE = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public _0xb3ba58;
    uint256 public _0xc9b887;
    uint256 public _0xf64889;

    struct UserLock {
        uint256 _0x1d5d91;
        uint256 _0xffcfea;
    }

    mapping(address => UserLock[]) public _0xd68547;
    mapping(address => uint256) public _0x053d6c;


    address public immutable HYBR;
    address public immutable _0x9f15d5;
    address public _0x419979;
    address public _0x4826d1;
    address public _0xe9c70f;
    uint256 public _0xb32a9a;


    address public _0xc0a5f7;
    uint256 public _0x396cd8;


    uint256 public _0x560a73;
    uint256 public _0xfd0697;


    ISwapper public _0x3b92b3;


    error NOT_AUTHORIZED();


    event Deposit(address indexed _0xbea206, uint256 _0xb66e37, uint256 _0xf05f6d);
    event Withdraw(address indexed _0xbea206, uint256 _0x8577ea, uint256 _0xb66e37, uint256 _0xb412f3);
    event Compound(uint256 _0xab141b, uint256 _0xbb42a9);
    event PenaltyRewardReceived(uint256 _0x1d5d91);
    event TransferLockPeriodUpdated(uint256 _0x543151, uint256 _0x8b84f4);
    event SwapperUpdated(address indexed _0x7213e7, address indexed _0x012603);
    event VoterSet(address _0x419979);
    event EmergencyUnlock(address indexed _0xbea206);
    event AutoVotingEnabled(bool _0xb99d83);
    event OperatorUpdated(address indexed _0xa6e9c7, address indexed _0x9d1c2e);
    event DefaultVotingStrategyUpdated(address[] _0xadd74d, uint256[] _0xfaa044);
    event AutoVoteExecuted(uint256 _0x88b92d, address[] _0xadd74d, uint256[] _0xfaa044);

    constructor(
        address _0x23c7f4,
        address _0x997e6a
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0x23c7f4 != address(0), "Invalid HYBR");
        require(_0x997e6a != address(0), "Invalid VE");

        HYBR = _0x23c7f4;
        _0x9f15d5 = _0x997e6a;
        _0x560a73 = block.timestamp;
        _0xfd0697 = block.timestamp;
        _0xc0a5f7 = msg.sender;
    }

    function _0x10bdb6(address _0xad9f5e) external _0x95f723 {
        require(_0xad9f5e != address(0), "Invalid rewards distributor");
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x4826d1 = _0xad9f5e; }
    }

    function _0x4253f7(address _0xf29346) external _0x95f723 {
        require(_0xf29346 != address(0), "Invalid gauge manager");
        _0xe9c70f = _0xf29346;
    }


    modifier _0x0660fd() {
        if (msg.sender != _0xc0a5f7) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function _0x91becb(uint256 _0x1d5d91, address _0xe63b96) external _0x75502e {
        require(_0x1d5d91 > 0, "Zero amount");
        _0xe63b96 = _0xe63b96 == address(0) ? msg.sender : _0xe63b96;


        IERC20(HYBR)._0xd343f2(msg.sender, address(this), _0x1d5d91);


        if (_0xb32a9a == 0) {
            _0x610e20(_0x1d5d91);
        } else {

            IERC20(HYBR)._0xfd3432(_0x9f15d5, _0x1d5d91);
            IVotingEscrow(_0x9f15d5)._0x1e6c16(_0xb32a9a, _0x1d5d91);


            _0x0d66cc();
        }


        uint256 _0x8577ea = _0x5b3e9d(_0x1d5d91);


        _0xf86c77(_0xe63b96, _0x8577ea);


        _0x8e90a5(_0xe63b96, _0x8577ea);

        emit Deposit(msg.sender, _0x1d5d91, _0x8577ea);
    }


    function _0xc7ec59(uint256 _0x8577ea) external _0x75502e returns (uint256 _0xd84694) {
        require(_0x8577ea > 0, "Zero shares");
        require(_0x7ff3fe(msg.sender) >= _0x8577ea, "Insufficient balance");
        require(_0xb32a9a != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x9f15d5)._0xa163a5(_0xb32a9a) == false, "Cannot withdraw yet");

        uint256 _0x27a804 = HybraTimeLibrary._0x27a804(block.timestamp);
        uint256 _0x6f5e91 = HybraTimeLibrary._0x6f5e91(block.timestamp);

        require(block.timestamp >= _0x27a804 + _0x04845f && block.timestamp < _0x6f5e91 - _0xcaacfc, "Cannot withdraw yet");


        uint256 _0xb66e37 = _0xb67b3a(_0x8577ea);
        require(_0xb66e37 > 0, "No assets to withdraw");


        uint256 _0x405c55 = 0;
        if (_0xac613a > 0) {
            _0x405c55 = (_0xb66e37 * _0xac613a) / BASIS;
        }


        uint256 _0x1caaa7 = _0xb66e37 - _0x405c55;
        require(_0x1caaa7 > 0, "Amount too small after fee");


        uint256 _0xcedd6c = _0xd10b7f();
        require(_0xb66e37 <= _0xcedd6c, "Insufficient veNFT balance");

        uint256 _0x642ad2 = _0xcedd6c - _0x1caaa7 - _0x405c55;
        require(_0x642ad2 >= 0, "Cannot withdraw entire veNFT");


        _0xb2ff9a(msg.sender, _0x8577ea);


        uint256[] memory _0x165a71 = new uint256[](3);
        _0x165a71[0] = _0x642ad2;
        _0x165a71[1] = _0x1caaa7;
        _0x165a71[2] = _0x405c55;

        uint256[] memory _0x378213 = IVotingEscrow(_0x9f15d5)._0x106ef4(_0xb32a9a, _0x165a71);


        _0xb32a9a = _0x378213[0];
        _0xd84694 = _0x378213[1];
        uint256 _0x4a7453 = _0x378213[2];

        IVotingEscrow(_0x9f15d5)._0x0d94bb(address(this), msg.sender, _0xd84694);
        IVotingEscrow(_0x9f15d5)._0x0d94bb(address(this), Team, _0x4a7453);
        emit Withdraw(msg.sender, _0x8577ea, _0x1caaa7, _0x405c55);
    }


    function _0x610e20(uint256 _0xd51e11) internal {

        IERC20(HYBR)._0xfd3432(_0x9f15d5, type(uint256)._0xe89d95);
        uint256 _0x65820d = HybraTimeLibrary.MAX_LOCK_DURATION;


        _0xb32a9a = IVotingEscrow(_0x9f15d5)._0x7b46b5(_0xd51e11, _0x65820d, address(this));

    }


    function _0x5b3e9d(uint256 _0x1d5d91) public view returns (uint256) {
        uint256 _0x130991 = _0x3d3750();
        uint256 _0xfde7fd = _0xd10b7f();
        if (_0x130991 == 0 || _0xfde7fd == 0) {
            return _0x1d5d91;
        }
        return (_0x1d5d91 * _0x130991) / _0xfde7fd;
    }


    function _0xb67b3a(uint256 _0x8577ea) public view returns (uint256) {
        uint256 _0x130991 = _0x3d3750();
        if (_0x130991 == 0) {
            return _0x8577ea;
        }
        return (_0x8577ea * _0xd10b7f()) / _0x130991;
    }


    function _0xd10b7f() public view returns (uint256) {
        if (_0xb32a9a == 0) {
            return 0;
        }

        IVotingEscrow.LockedBalance memory _0x9c41bc = IVotingEscrow(_0x9f15d5)._0x9c41bc(_0xb32a9a);
        return uint256(int256(_0x9c41bc._0x1d5d91));
    }


    function _0x8e90a5(address _0xbea206, uint256 _0x1d5d91) internal {
        uint256 _0xffcfea = block.timestamp + _0x3476fb;
        _0xd68547[_0xbea206].push(UserLock({
            _0x1d5d91: _0x1d5d91,
            _0xffcfea: _0xffcfea
        }));
        _0x053d6c[_0xbea206] += _0x1d5d91;
    }


    function _0x051272(address _0xbea206) external view returns (uint256 _0x4fc7fc) {
        uint256 _0x34ec07 = _0x7ff3fe(_0xbea206);
        uint256 _0x1264b0 = 0;

        UserLock[] storage _0xa6b1da = _0xd68547[_0xbea206];
        for (uint256 i = 0; i < _0xa6b1da.length; i++) {
            if (_0xa6b1da[i]._0xffcfea > block.timestamp) {
                _0x1264b0 += _0xa6b1da[i]._0x1d5d91;
            }
        }

        return _0x34ec07 > _0x1264b0 ? _0x34ec07 - _0x1264b0 : 0;
    }

    function _0xc4b5f7(address _0xbea206) internal returns (uint256 _0x9e1025) {
        UserLock[] storage _0xa6b1da = _0xd68547[_0xbea206];
        uint256 _0x07a658 = _0xa6b1da.length;
        if (_0x07a658 == 0) return 0;

        uint256 _0x69abeb = 0;
        unchecked {
            for (uint256 i = 0; i < _0x07a658; i++) {
                UserLock memory L = _0xa6b1da[i];
                if (L._0xffcfea <= block.timestamp) {
                    _0x9e1025 += L._0x1d5d91;
                } else {
                    if (_0x69abeb != i) _0xa6b1da[_0x69abeb] = L;
                    _0x69abeb++;
                }
            }
            if (_0x9e1025 > 0) {
                _0x053d6c[_0xbea206] -= _0x9e1025;
            }
            while (_0xa6b1da.length > _0x69abeb) {
                _0xa6b1da.pop();
            }
        }
    }


    function _0xb33249(
        address from,
        address _0x03acbd,
        uint256 _0x1d5d91
    ) internal override {
        super._0xb33249(from, _0x03acbd, _0x1d5d91);

        if (from != address(0) && _0x03acbd != address(0)) {
            uint256 _0x34ec07 = _0x7ff3fe(from);


            uint256 _0xcc84b8 = _0x34ec07 > _0x053d6c[from] ? _0x34ec07 - _0x053d6c[from] : 0;


            if (_0xcc84b8 >= _0x1d5d91) {
                return;
            }


            _0xc4b5f7(from);
            uint256 _0x55255f = _0x34ec07 > _0x053d6c[from] ? _0x34ec07 - _0x053d6c[from] : 0;


            require(_0x55255f >= _0x1d5d91, "Tokens locked");
        }
    }


    function _0x7b7dc6() external _0x0660fd {
        require(_0x419979 != address(0), "Voter not set");
        require(_0x4826d1 != address(0), "Distributor not set");


        uint256  _0xe47c37 = IRewardsDistributor(_0x4826d1)._0x30db8f(_0xb32a9a);
        _0xb3ba58 += _0xe47c37;

        address[] memory _0x9f4267 = IVoter(_0x419979)._0x53ec37(_0xb32a9a);

        for (uint256 i = 0; i < _0x9f4267.length; i++) {
            if (_0x9f4267[i] != address(0)) {
                address _0x86b7db = IGaugeManager(_0xe9c70f)._0x662eb5(_0x9f4267[i]);

                if (_0x86b7db != address(0)) {

                    address[] memory _0xf1c170 = new address[](1);
                    address[][] memory _0x044903 = new address[][](1);


                    address _0x1dfefa = IGaugeManager(_0xe9c70f)._0xce5c5b(_0x86b7db);
                    if (_0x1dfefa != address(0)) {
                        uint256 _0x9e9e00 = IBribe(_0x1dfefa)._0xf676c5();
                        if (_0x9e9e00 > 0) {
                            address[] memory _0x8b5147 = new address[](_0x9e9e00);
                            for (uint256 j = 0; j < _0x9e9e00; j++) {
                                _0x8b5147[j] = IBribe(_0x1dfefa)._0x8b5147(j);
                            }
                            _0xf1c170[0] = _0x1dfefa;
                            _0x044903[0] = _0x8b5147;

                            IGaugeManager(_0xe9c70f)._0x06c1ba(_0xf1c170, _0x044903, _0xb32a9a);
                        }
                    }


                    address _0xa974f1 = IGaugeManager(_0xe9c70f)._0xdd3cf4(_0x86b7db);
                    if (_0xa974f1 != address(0)) {
                        uint256 _0x9e9e00 = IBribe(_0xa974f1)._0xf676c5();
                        if (_0x9e9e00 > 0) {
                            address[] memory _0x8b5147 = new address[](_0x9e9e00);
                            for (uint256 j = 0; j < _0x9e9e00; j++) {
                                _0x8b5147[j] = IBribe(_0xa974f1)._0x8b5147(j);
                            }
                            _0xf1c170[0] = _0xa974f1;
                            _0x044903[0] = _0x8b5147;

                            IGaugeManager(_0xe9c70f)._0x06c1ba(_0xf1c170, _0x044903, _0xb32a9a);
                        }
                    }
                }
            }
        }
    }


    function _0xad9132(ISwapper.SwapParams calldata _0x5c2cb1) external _0x75502e _0x0660fd {
        require(address(_0x3b92b3) != address(0), "Swapper not set");


        uint256 _0x633546 = IERC20(_0x5c2cb1._0x64f0d4)._0x7ff3fe(address(this));
        require(_0x633546 >= _0x5c2cb1._0x6771af, "Insufficient token balance");


        IERC20(_0x5c2cb1._0x64f0d4)._0x0e5203(address(_0x3b92b3), _0x5c2cb1._0x6771af);


        uint256 _0x8bd304 = _0x3b92b3._0xcf5a63(_0x5c2cb1);


        IERC20(_0x5c2cb1._0x64f0d4)._0x0e5203(address(_0x3b92b3), 0);


        _0xf64889 += _0x8bd304;
    }


    function _0x218cd2() external _0x0660fd {


        uint256 _0xbbf1ba = IERC20(HYBR)._0x7ff3fe(address(this));

        if (_0xbbf1ba > 0) {

            IERC20(HYBR)._0x0e5203(_0x9f15d5, _0xbbf1ba);
            IVotingEscrow(_0x9f15d5)._0x1e6c16(_0xb32a9a, _0xbbf1ba);


            _0x0d66cc();

            _0xfd0697 = block.timestamp;

            emit Compound(_0xbbf1ba, _0xd10b7f());
        }
    }


    function _0xdeefca(address[] calldata _0x322053, uint256[] calldata _0x5c08d8) external {
        require(msg.sender == _0x7be8da() || msg.sender == _0xc0a5f7, "Not authorized");
        require(_0x419979 != address(0), "Voter not set");

        IVoter(_0x419979)._0xdeefca(_0xb32a9a, _0x322053, _0x5c08d8);
        _0x396cd8 = HybraTimeLibrary._0x27a804(block.timestamp);

    }


    function _0x5f5d1a() external {
        require(msg.sender == _0x7be8da() || msg.sender == _0xc0a5f7, "Not authorized");
        require(_0x419979 != address(0), "Voter not set");

        IVoter(_0x419979)._0x5f5d1a(_0xb32a9a);
    }


    function _0x7533bc(uint256 _0x1d5d91) external {


        if (_0x1d5d91 > 0) {
            IERC20(HYBR)._0xfd3432(_0x9f15d5, _0x1d5d91);

            if(_0xb32a9a == 0){
                _0x610e20(_0x1d5d91);
            } else{
                IVotingEscrow(_0x9f15d5)._0x1e6c16(_0xb32a9a, _0x1d5d91);


                _0x0d66cc();
            }
        }
        _0xc9b887 += _0x1d5d91;
        emit PenaltyRewardReceived(_0x1d5d91);
    }


    function _0x6643ed(address _0xd408b4) external _0x95f723 {
        require(_0xd408b4 != address(0), "Invalid voter");
        _0x419979 = _0xd408b4;
        emit VoterSet(_0xd408b4);
    }


    function _0xf94804(uint256 _0x509be4) external _0x95f723 {
        require(_0x509be4 >= MIN_LOCK_PERIOD && _0x509be4 <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x543151 = _0x3476fb;
        if (block.timestamp > 0) { _0x3476fb = _0x509be4; }
        emit TransferLockPeriodUpdated(_0x543151, _0x509be4);
    }


    function _0x24bd00(uint256 _0x8b5cf8) external _0x95f723 {
        require(_0x8b5cf8 >= MIN_WITHDRAW_FEE && _0x8b5cf8 <= MAX_WITHDRAW_FEE, "Invalid fee");
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xac613a = _0x8b5cf8; }
    }

    function _0xfd54d3(uint256 _0xf5c288) external _0x95f723 {
        _0x04845f = _0xf5c288;
    }

    function _0x010f1b(uint256 _0xf5c288) external _0x95f723 {
        if (true) { _0xcaacfc = _0xf5c288; }
    }


    function _0x7cd114(address _0x326829) external _0x95f723 {
        require(_0x326829 != address(0), "Invalid swapper");
        address _0x7213e7 = address(_0x3b92b3);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x3b92b3 = ISwapper(_0x326829); }
        emit SwapperUpdated(_0x7213e7, _0x326829);
    }


    function _0x98c5e6(address _0xfeb64d) external _0x95f723 {
        require(_0xfeb64d != address(0), "Invalid team");
        Team = _0xfeb64d;
    }


    function _0x61295d(address _0xbea206) external _0x0660fd {
        delete _0xd68547[_0xbea206];
        _0x053d6c[_0xbea206] = 0;
        emit EmergencyUnlock(_0xbea206);
    }


    function _0x8a57d8(address _0xbea206) external view returns (UserLock[] memory) {
        return _0xd68547[_0xbea206];
    }


    function _0xfd857c(address _0x34d300) external _0x95f723 {
        require(_0x34d300 != address(0), "Invalid operator");
        address _0xa6e9c7 = _0xc0a5f7;
        if (block.timestamp > 0) { _0xc0a5f7 = _0x34d300; }
        emit OperatorUpdated(_0xa6e9c7, _0x34d300);
    }


    function _0xfcf5bd() external view returns (uint256) {
        if (_0xb32a9a == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x9c41bc = IVotingEscrow(_0x9f15d5)._0x9c41bc(_0xb32a9a);
        return uint256(_0x9c41bc._0x8b3553);
    }


    function _0x0d66cc() internal {
        if (_0xb32a9a == 0) return;

        IVotingEscrow.LockedBalance memory _0x9c41bc = IVotingEscrow(_0x9f15d5)._0x9c41bc(_0xb32a9a);
        if (_0x9c41bc._0xd3d2fe || _0x9c41bc._0x8b3553 <= block.timestamp) return;

        uint256 _0x60a105 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;


        if (_0x60a105 > _0x9c41bc._0x8b3553 + 2 hours) {
            try IVotingEscrow(_0x9f15d5)._0x5326a3(_0xb32a9a, HybraTimeLibrary.MAX_LOCK_DURATION) {

            } catch {


            }
        }
    }

}