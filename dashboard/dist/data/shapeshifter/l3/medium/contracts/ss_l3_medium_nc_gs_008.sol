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

    uint256 public _0x8e40db = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x0c65e1 = 1200;
    uint256 public _0x4e6f19 = 300;


    uint256 public _0x5ef95c = 100;
    uint256 public constant MIN_WITHDRAW_FEE = 10;
    uint256 public constant MAX_WITHDRAW_FEE = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public _0xd14f31;
    uint256 public _0xd7f84f;
    uint256 public _0x387d8a;

    struct UserLock {
        uint256 _0xffce9f;
        uint256 _0x73c242;
    }

    mapping(address => UserLock[]) public _0x6280d6;
    mapping(address => uint256) public _0xd439b9;


    address public immutable HYBR;
    address public immutable _0xe3d5f5;
    address public _0x7bf77a;
    address public _0xe16290;
    address public _0x663223;
    uint256 public _0x1dc102;


    address public _0xdb7bef;
    uint256 public _0x1dd50d;


    uint256 public _0x7db46b;
    uint256 public _0x6a7c25;


    ISwapper public _0x03b5f6;


    error NOT_AUTHORIZED();


    event Deposit(address indexed _0x716d1a, uint256 _0x8e7b36, uint256 _0x02b862);
    event Withdraw(address indexed _0x716d1a, uint256 _0xb66f3a, uint256 _0x8e7b36, uint256 _0xc35382);
    event Compound(uint256 _0xa07c5e, uint256 _0x55a2db);
    event PenaltyRewardReceived(uint256 _0xffce9f);
    event TransferLockPeriodUpdated(uint256 _0xab06ad, uint256 _0x3787b7);
    event SwapperUpdated(address indexed _0x523582, address indexed _0xb383b4);
    event VoterSet(address _0x7bf77a);
    event EmergencyUnlock(address indexed _0x716d1a);
    event AutoVotingEnabled(bool _0xa1303e);
    event OperatorUpdated(address indexed _0x15ada6, address indexed _0xaf1748);
    event DefaultVotingStrategyUpdated(address[] _0x095904, uint256[] _0xa91111);
    event AutoVoteExecuted(uint256 _0x3799c1, address[] _0x095904, uint256[] _0xa91111);

    constructor(
        address _0xa0d278,
        address _0x3e13ed
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0xa0d278 != address(0), "Invalid HYBR");
        require(_0x3e13ed != address(0), "Invalid VE");

        HYBR = _0xa0d278;
        _0xe3d5f5 = _0x3e13ed;
        _0x7db46b = block.timestamp;
        _0x6a7c25 = block.timestamp;
        _0xdb7bef = msg.sender;
    }

    function _0x553028(address _0x567cb2) external _0x07d37a {
        require(_0x567cb2 != address(0), "Invalid rewards distributor");
        _0xe16290 = _0x567cb2;
    }

    function _0x1f2bd1(address _0x50e3de) external _0x07d37a {
        require(_0x50e3de != address(0), "Invalid gauge manager");
        _0x663223 = _0x50e3de;
    }


    modifier _0x355ff2() {
        if (msg.sender != _0xdb7bef) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function _0x0f1d0d(uint256 _0xffce9f, address _0xfa1550) external _0x36da5d {
        require(_0xffce9f > 0, "Zero amount");
        _0xfa1550 = _0xfa1550 == address(0) ? msg.sender : _0xfa1550;


        IERC20(HYBR)._0x4d52e5(msg.sender, address(this), _0xffce9f);


        if (_0x1dc102 == 0) {
            _0xb9dbd6(_0xffce9f);
        } else {

            IERC20(HYBR)._0x466241(_0xe3d5f5, _0xffce9f);
            IVotingEscrow(_0xe3d5f5)._0xbd437e(_0x1dc102, _0xffce9f);


            _0xb11c81();
        }


        uint256 _0xb66f3a = _0x6479fe(_0xffce9f);


        _0x42cfad(_0xfa1550, _0xb66f3a);


        _0x26cb28(_0xfa1550, _0xb66f3a);

        emit Deposit(msg.sender, _0xffce9f, _0xb66f3a);
    }


    function _0x1b3dbf(uint256 _0xb66f3a) external _0x36da5d returns (uint256 _0x9c160e) {
        require(_0xb66f3a > 0, "Zero shares");
        require(_0xc84859(msg.sender) >= _0xb66f3a, "Insufficient balance");
        require(_0x1dc102 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0xe3d5f5)._0xe147ef(_0x1dc102) == false, "Cannot withdraw yet");

        uint256 _0x9bc671 = HybraTimeLibrary._0x9bc671(block.timestamp);
        uint256 _0x62ebea = HybraTimeLibrary._0x62ebea(block.timestamp);

        require(block.timestamp >= _0x9bc671 + _0x0c65e1 && block.timestamp < _0x62ebea - _0x4e6f19, "Cannot withdraw yet");


        uint256 _0x8e7b36 = _0xaf61e2(_0xb66f3a);
        require(_0x8e7b36 > 0, "No assets to withdraw");


        uint256 _0x95bb60 = 0;
        if (_0x5ef95c > 0) {
            _0x95bb60 = (_0x8e7b36 * _0x5ef95c) / BASIS;
        }


        uint256 _0xed72f6 = _0x8e7b36 - _0x95bb60;
        require(_0xed72f6 > 0, "Amount too small after fee");


        uint256 _0xc9abd5 = _0x80dd85();
        require(_0x8e7b36 <= _0xc9abd5, "Insufficient veNFT balance");

        uint256 _0x90b462 = _0xc9abd5 - _0xed72f6 - _0x95bb60;
        require(_0x90b462 >= 0, "Cannot withdraw entire veNFT");


        _0x42fe29(msg.sender, _0xb66f3a);


        uint256[] memory _0x461b70 = new uint256[](3);
        _0x461b70[0] = _0x90b462;
        _0x461b70[1] = _0xed72f6;
        _0x461b70[2] = _0x95bb60;

        uint256[] memory _0x960298 = IVotingEscrow(_0xe3d5f5)._0x733841(_0x1dc102, _0x461b70);


        if (1 == 1) { _0x1dc102 = _0x960298[0]; }
        _0x9c160e = _0x960298[1];
        uint256 _0x4c6e55 = _0x960298[2];

        IVotingEscrow(_0xe3d5f5)._0xf41f13(address(this), msg.sender, _0x9c160e);
        IVotingEscrow(_0xe3d5f5)._0xf41f13(address(this), Team, _0x4c6e55);
        emit Withdraw(msg.sender, _0xb66f3a, _0xed72f6, _0x95bb60);
    }


    function _0xb9dbd6(uint256 _0x426457) internal {

        IERC20(HYBR)._0x466241(_0xe3d5f5, type(uint256)._0x3450dd);
        uint256 _0xe773e0 = HybraTimeLibrary.MAX_LOCK_DURATION;


        _0x1dc102 = IVotingEscrow(_0xe3d5f5)._0xa4e32c(_0x426457, _0xe773e0, address(this));

    }


    function _0x6479fe(uint256 _0xffce9f) public view returns (uint256) {
        uint256 _0x6e5b65 = _0xb64bc3();
        uint256 _0x4e5fac = _0x80dd85();
        if (_0x6e5b65 == 0 || _0x4e5fac == 0) {
            return _0xffce9f;
        }
        return (_0xffce9f * _0x6e5b65) / _0x4e5fac;
    }


    function _0xaf61e2(uint256 _0xb66f3a) public view returns (uint256) {
        uint256 _0x6e5b65 = _0xb64bc3();
        if (_0x6e5b65 == 0) {
            return _0xb66f3a;
        }
        return (_0xb66f3a * _0x80dd85()) / _0x6e5b65;
    }


    function _0x80dd85() public view returns (uint256) {
        if (_0x1dc102 == 0) {
            return 0;
        }

        IVotingEscrow.LockedBalance memory _0xabbaa1 = IVotingEscrow(_0xe3d5f5)._0xabbaa1(_0x1dc102);
        return uint256(int256(_0xabbaa1._0xffce9f));
    }


    function _0x26cb28(address _0x716d1a, uint256 _0xffce9f) internal {
        uint256 _0x73c242 = block.timestamp + _0x8e40db;
        _0x6280d6[_0x716d1a].push(UserLock({
            _0xffce9f: _0xffce9f,
            _0x73c242: _0x73c242
        }));
        _0xd439b9[_0x716d1a] += _0xffce9f;
    }


    function _0x371f16(address _0x716d1a) external view returns (uint256 _0x9fb733) {
        uint256 _0x35c762 = _0xc84859(_0x716d1a);
        uint256 _0x9178d8 = 0;

        UserLock[] storage _0x95e7d7 = _0x6280d6[_0x716d1a];
        for (uint256 i = 0; i < _0x95e7d7.length; i++) {
            if (_0x95e7d7[i]._0x73c242 > block.timestamp) {
                _0x9178d8 += _0x95e7d7[i]._0xffce9f;
            }
        }

        return _0x35c762 > _0x9178d8 ? _0x35c762 - _0x9178d8 : 0;
    }

    function _0xc3c344(address _0x716d1a) internal returns (uint256 _0x779b0c) {
        UserLock[] storage _0x95e7d7 = _0x6280d6[_0x716d1a];
        uint256 _0x05472c = _0x95e7d7.length;
        if (_0x05472c == 0) return 0;

        uint256 _0x0dd2aa = 0;
        unchecked {
            for (uint256 i = 0; i < _0x05472c; i++) {
                UserLock memory L = _0x95e7d7[i];
                if (L._0x73c242 <= block.timestamp) {
                    _0x779b0c += L._0xffce9f;
                } else {
                    if (_0x0dd2aa != i) _0x95e7d7[_0x0dd2aa] = L;
                    _0x0dd2aa++;
                }
            }
            if (_0x779b0c > 0) {
                _0xd439b9[_0x716d1a] -= _0x779b0c;
            }
            while (_0x95e7d7.length > _0x0dd2aa) {
                _0x95e7d7.pop();
            }
        }
    }


    function _0x8a5c45(
        address from,
        address _0xb0fa9f,
        uint256 _0xffce9f
    ) internal override {
        super._0x8a5c45(from, _0xb0fa9f, _0xffce9f);

        if (from != address(0) && _0xb0fa9f != address(0)) {
            uint256 _0x35c762 = _0xc84859(from);


            uint256 _0x56deff = _0x35c762 > _0xd439b9[from] ? _0x35c762 - _0xd439b9[from] : 0;


            if (_0x56deff >= _0xffce9f) {
                return;
            }


            _0xc3c344(from);
            uint256 _0xff6c5f = _0x35c762 > _0xd439b9[from] ? _0x35c762 - _0xd439b9[from] : 0;


            require(_0xff6c5f >= _0xffce9f, "Tokens locked");
        }
    }


    function _0xc485dd() external _0x355ff2 {
        require(_0x7bf77a != address(0), "Voter not set");
        require(_0xe16290 != address(0), "Distributor not set");


        uint256  _0x7ae4f7 = IRewardsDistributor(_0xe16290)._0x4eafbd(_0x1dc102);
        _0xd14f31 += _0x7ae4f7;

        address[] memory _0x79af57 = IVoter(_0x7bf77a)._0x40ee56(_0x1dc102);

        for (uint256 i = 0; i < _0x79af57.length; i++) {
            if (_0x79af57[i] != address(0)) {
                address _0xf41b9a = IGaugeManager(_0x663223)._0x804d00(_0x79af57[i]);

                if (_0xf41b9a != address(0)) {

                    address[] memory _0xf331e4 = new address[](1);
                    address[][] memory _0x6b66b4 = new address[][](1);


                    address _0xe38f62 = IGaugeManager(_0x663223)._0xb2c285(_0xf41b9a);
                    if (_0xe38f62 != address(0)) {
                        uint256 _0xd0792f = IBribe(_0xe38f62)._0x455322();
                        if (_0xd0792f > 0) {
                            address[] memory _0x61e08c = new address[](_0xd0792f);
                            for (uint256 j = 0; j < _0xd0792f; j++) {
                                _0x61e08c[j] = IBribe(_0xe38f62)._0x61e08c(j);
                            }
                            _0xf331e4[0] = _0xe38f62;
                            _0x6b66b4[0] = _0x61e08c;

                            IGaugeManager(_0x663223)._0x845a9b(_0xf331e4, _0x6b66b4, _0x1dc102);
                        }
                    }


                    address _0xce6f96 = IGaugeManager(_0x663223)._0xada628(_0xf41b9a);
                    if (_0xce6f96 != address(0)) {
                        uint256 _0xd0792f = IBribe(_0xce6f96)._0x455322();
                        if (_0xd0792f > 0) {
                            address[] memory _0x61e08c = new address[](_0xd0792f);
                            for (uint256 j = 0; j < _0xd0792f; j++) {
                                _0x61e08c[j] = IBribe(_0xce6f96)._0x61e08c(j);
                            }
                            _0xf331e4[0] = _0xce6f96;
                            _0x6b66b4[0] = _0x61e08c;

                            IGaugeManager(_0x663223)._0x845a9b(_0xf331e4, _0x6b66b4, _0x1dc102);
                        }
                    }
                }
            }
        }
    }


    function _0x7a49ad(ISwapper.SwapParams calldata _0x1c2c0d) external _0x36da5d _0x355ff2 {
        require(address(_0x03b5f6) != address(0), "Swapper not set");


        uint256 _0xa5f63c = IERC20(_0x1c2c0d._0x95834c)._0xc84859(address(this));
        require(_0xa5f63c >= _0x1c2c0d._0xe0de05, "Insufficient token balance");


        IERC20(_0x1c2c0d._0x95834c)._0x641e80(address(_0x03b5f6), _0x1c2c0d._0xe0de05);


        uint256 _0x314e84 = _0x03b5f6._0xbb53bb(_0x1c2c0d);


        IERC20(_0x1c2c0d._0x95834c)._0x641e80(address(_0x03b5f6), 0);


        _0x387d8a += _0x314e84;
    }


    function _0xaa358f() external _0x355ff2 {


        uint256 _0x915ae9 = IERC20(HYBR)._0xc84859(address(this));

        if (_0x915ae9 > 0) {

            IERC20(HYBR)._0x641e80(_0xe3d5f5, _0x915ae9);
            IVotingEscrow(_0xe3d5f5)._0xbd437e(_0x1dc102, _0x915ae9);


            _0xb11c81();

            _0x6a7c25 = block.timestamp;

            emit Compound(_0x915ae9, _0x80dd85());
        }
    }


    function _0x84ef92(address[] calldata _0x96089f, uint256[] calldata _0x7ad5a9) external {
        require(msg.sender == _0x8e9bff() || msg.sender == _0xdb7bef, "Not authorized");
        require(_0x7bf77a != address(0), "Voter not set");

        IVoter(_0x7bf77a)._0x84ef92(_0x1dc102, _0x96089f, _0x7ad5a9);
        _0x1dd50d = HybraTimeLibrary._0x9bc671(block.timestamp);

    }


    function _0x57b503() external {
        require(msg.sender == _0x8e9bff() || msg.sender == _0xdb7bef, "Not authorized");
        require(_0x7bf77a != address(0), "Voter not set");

        IVoter(_0x7bf77a)._0x57b503(_0x1dc102);
    }


    function _0x4c8428(uint256 _0xffce9f) external {


        if (_0xffce9f > 0) {
            IERC20(HYBR)._0x466241(_0xe3d5f5, _0xffce9f);

            if(_0x1dc102 == 0){
                _0xb9dbd6(_0xffce9f);
            } else{
                IVotingEscrow(_0xe3d5f5)._0xbd437e(_0x1dc102, _0xffce9f);


                _0xb11c81();
            }
        }
        _0xd7f84f += _0xffce9f;
        emit PenaltyRewardReceived(_0xffce9f);
    }


    function _0xff9081(address _0xe300cf) external _0x07d37a {
        require(_0xe300cf != address(0), "Invalid voter");
        _0x7bf77a = _0xe300cf;
        emit VoterSet(_0xe300cf);
    }


    function _0x6f8f38(uint256 _0x0fb11f) external _0x07d37a {
        require(_0x0fb11f >= MIN_LOCK_PERIOD && _0x0fb11f <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0xab06ad = _0x8e40db;
        _0x8e40db = _0x0fb11f;
        emit TransferLockPeriodUpdated(_0xab06ad, _0x0fb11f);
    }


    function _0xbea1bf(uint256 _0xde6367) external _0x07d37a {
        require(_0xde6367 >= MIN_WITHDRAW_FEE && _0xde6367 <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x5ef95c = _0xde6367;
    }

    function _0xec9b13(uint256 _0xd74591) external _0x07d37a {
        _0x0c65e1 = _0xd74591;
    }

    function _0x881b91(uint256 _0xd74591) external _0x07d37a {
        _0x4e6f19 = _0xd74591;
    }


    function _0xea4801(address _0xd6d188) external _0x07d37a {
        require(_0xd6d188 != address(0), "Invalid swapper");
        address _0x523582 = address(_0x03b5f6);
        _0x03b5f6 = ISwapper(_0xd6d188);
        emit SwapperUpdated(_0x523582, _0xd6d188);
    }


    function _0x47be4b(address _0x88b314) external _0x07d37a {
        require(_0x88b314 != address(0), "Invalid team");
        Team = _0x88b314;
    }


    function _0x7f377d(address _0x716d1a) external _0x355ff2 {
        delete _0x6280d6[_0x716d1a];
        _0xd439b9[_0x716d1a] = 0;
        emit EmergencyUnlock(_0x716d1a);
    }


    function _0x0a0243(address _0x716d1a) external view returns (UserLock[] memory) {
        return _0x6280d6[_0x716d1a];
    }


    function _0x44a6a6(address _0xbc23d1) external _0x07d37a {
        require(_0xbc23d1 != address(0), "Invalid operator");
        address _0x15ada6 = _0xdb7bef;
        if (block.timestamp > 0) { _0xdb7bef = _0xbc23d1; }
        emit OperatorUpdated(_0x15ada6, _0xbc23d1);
    }


    function _0x4fb3a9() external view returns (uint256) {
        if (_0x1dc102 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0xabbaa1 = IVotingEscrow(_0xe3d5f5)._0xabbaa1(_0x1dc102);
        return uint256(_0xabbaa1._0xe0b938);
    }


    function _0xb11c81() internal {
        if (_0x1dc102 == 0) return;

        IVotingEscrow.LockedBalance memory _0xabbaa1 = IVotingEscrow(_0xe3d5f5)._0xabbaa1(_0x1dc102);
        if (_0xabbaa1._0x52e7f1 || _0xabbaa1._0xe0b938 <= block.timestamp) return;

        uint256 _0x97e2f5 = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;


        if (_0x97e2f5 > _0xabbaa1._0xe0b938 + 2 hours) {
            try IVotingEscrow(_0xe3d5f5)._0xd78299(_0x1dc102, HybraTimeLibrary.MAX_LOCK_DURATION) {

            } catch {


            }
        }
    }

}