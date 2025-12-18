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

    uint256 public _0xf7650c = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public _0x5a89c7 = 1200;
    uint256 public _0xe0849a = 300;


    uint256 public _0x3b4006 = 100;
    uint256 public constant MIN_WITHDRAW_FEE = 10;
    uint256 public constant MAX_WITHDRAW_FEE = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public _0x40ce1d;
    uint256 public _0x4bbbc4;
    uint256 public _0x33e5f3;

    struct UserLock {
        uint256 _0xc0f86e;
        uint256 _0x7a545c;
    }

    mapping(address => UserLock[]) public _0x432439;
    mapping(address => uint256) public _0x707ac7;


    address public immutable HYBR;
    address public immutable _0x5a2eed;
    address public _0x654b43;
    address public _0x402011;
    address public _0xc95bbc;
    uint256 public _0x4b3d78;


    address public _0x73f78a;
    uint256 public _0x2b0b3b;


    uint256 public _0xdfc2c5;
    uint256 public _0xaba87c;


    ISwapper public _0xfd6d83;


    error NOT_AUTHORIZED();


    event Deposit(address indexed _0x5f0ccf, uint256 _0x979bef, uint256 _0x55a49c);
    event Withdraw(address indexed _0x5f0ccf, uint256 _0x684329, uint256 _0x979bef, uint256 _0x94abcc);
    event Compound(uint256 _0x991ecb, uint256 _0x187391);
    event PenaltyRewardReceived(uint256 _0xc0f86e);
    event TransferLockPeriodUpdated(uint256 _0x38874e, uint256 _0xf320e7);
    event SwapperUpdated(address indexed _0xc443ef, address indexed _0xdb86bd);
    event VoterSet(address _0x654b43);
    event EmergencyUnlock(address indexed _0x5f0ccf);
    event AutoVotingEnabled(bool _0x5c1450);
    event OperatorUpdated(address indexed _0xc6c247, address indexed _0x757e7f);
    event DefaultVotingStrategyUpdated(address[] _0x5928f9, uint256[] _0xf500af);
    event AutoVoteExecuted(uint256 _0xf48ae4, address[] _0x5928f9, uint256[] _0xf500af);

    constructor(
        address _0x0cb2aa,
        address _0xfb9c5a
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_0x0cb2aa != address(0), "Invalid HYBR");
        require(_0xfb9c5a != address(0), "Invalid VE");

        HYBR = _0x0cb2aa;
        _0x5a2eed = _0xfb9c5a;
        _0xdfc2c5 = block.timestamp;
        _0xaba87c = block.timestamp;
        _0x73f78a = msg.sender;
    }

    function _0x7a7b77(address _0xc4201b) external _0x3b2bdf {
        require(_0xc4201b != address(0), "Invalid rewards distributor");
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x402011 = _0xc4201b; }
    }

    function _0x534756(address _0x741f5b) external _0x3b2bdf {
        require(_0x741f5b != address(0), "Invalid gauge manager");
        _0xc95bbc = _0x741f5b;
    }


    modifier _0x44d5b1() {
        if (msg.sender != _0x73f78a) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function _0x6d4545(uint256 _0xc0f86e, address _0x66b75e) external _0xa239e6 {
        require(_0xc0f86e > 0, "Zero amount");
        _0x66b75e = _0x66b75e == address(0) ? msg.sender : _0x66b75e;


        IERC20(HYBR)._0xa5fa8b(msg.sender, address(this), _0xc0f86e);


        if (_0x4b3d78 == 0) {
            _0xa58650(_0xc0f86e);
        } else {

            IERC20(HYBR)._0x41f27a(_0x5a2eed, _0xc0f86e);
            IVotingEscrow(_0x5a2eed)._0xf6b592(_0x4b3d78, _0xc0f86e);


            _0x553ed2();
        }


        uint256 _0x684329 = _0xc4480f(_0xc0f86e);


        _0x25b704(_0x66b75e, _0x684329);


        _0x1ebbdf(_0x66b75e, _0x684329);

        emit Deposit(msg.sender, _0xc0f86e, _0x684329);
    }


    function _0xaf66f3(uint256 _0x684329) external _0xa239e6 returns (uint256 _0x27fbc4) {
        require(_0x684329 > 0, "Zero shares");
        require(_0x5b8a0b(msg.sender) >= _0x684329, "Insufficient balance");
        require(_0x4b3d78 != 0, "No veNFT initialized");
        require(IVotingEscrow(_0x5a2eed)._0x647869(_0x4b3d78) == false, "Cannot withdraw yet");

        uint256 _0x99c0d9 = HybraTimeLibrary._0x99c0d9(block.timestamp);
        uint256 _0x3f2576 = HybraTimeLibrary._0x3f2576(block.timestamp);

        require(block.timestamp >= _0x99c0d9 + _0x5a89c7 && block.timestamp < _0x3f2576 - _0xe0849a, "Cannot withdraw yet");


        uint256 _0x979bef = _0x1c801d(_0x684329);
        require(_0x979bef > 0, "No assets to withdraw");


        uint256 _0x0f4fbe = 0;
        if (_0x3b4006 > 0) {
            _0x0f4fbe = (_0x979bef * _0x3b4006) / BASIS;
        }


        uint256 _0x7e7d4d = _0x979bef - _0x0f4fbe;
        require(_0x7e7d4d > 0, "Amount too small after fee");


        uint256 _0x1a671f = _0xe10348();
        require(_0x979bef <= _0x1a671f, "Insufficient veNFT balance");

        uint256 _0xb0fe81 = _0x1a671f - _0x7e7d4d - _0x0f4fbe;
        require(_0xb0fe81 >= 0, "Cannot withdraw entire veNFT");


        _0x6991e0(msg.sender, _0x684329);


        uint256[] memory _0xcfae1c = new uint256[](3);
        _0xcfae1c[0] = _0xb0fe81;
        _0xcfae1c[1] = _0x7e7d4d;
        _0xcfae1c[2] = _0x0f4fbe;

        uint256[] memory _0x29c518 = IVotingEscrow(_0x5a2eed)._0x002d41(_0x4b3d78, _0xcfae1c);


        _0x4b3d78 = _0x29c518[0];
        _0x27fbc4 = _0x29c518[1];
        uint256 _0xfa671e = _0x29c518[2];

        IVotingEscrow(_0x5a2eed)._0x0b91e2(address(this), msg.sender, _0x27fbc4);
        IVotingEscrow(_0x5a2eed)._0x0b91e2(address(this), Team, _0xfa671e);
        emit Withdraw(msg.sender, _0x684329, _0x7e7d4d, _0x0f4fbe);
    }


    function _0xa58650(uint256 _0xf05543) internal {

        IERC20(HYBR)._0x41f27a(_0x5a2eed, type(uint256)._0x61a821);
        uint256 _0xf26e08 = HybraTimeLibrary.MAX_LOCK_DURATION;


        _0x4b3d78 = IVotingEscrow(_0x5a2eed)._0xc150e8(_0xf05543, _0xf26e08, address(this));

    }


    function _0xc4480f(uint256 _0xc0f86e) public view returns (uint256) {
        uint256 _0x158c45 = _0x2ecb68();
        uint256 _0xaed1f9 = _0xe10348();
        if (_0x158c45 == 0 || _0xaed1f9 == 0) {
            return _0xc0f86e;
        }
        return (_0xc0f86e * _0x158c45) / _0xaed1f9;
    }


    function _0x1c801d(uint256 _0x684329) public view returns (uint256) {
        uint256 _0x158c45 = _0x2ecb68();
        if (_0x158c45 == 0) {
            return _0x684329;
        }
        return (_0x684329 * _0xe10348()) / _0x158c45;
    }


    function _0xe10348() public view returns (uint256) {
        if (_0x4b3d78 == 0) {
            return 0;
        }

        IVotingEscrow.LockedBalance memory _0x644ea3 = IVotingEscrow(_0x5a2eed)._0x644ea3(_0x4b3d78);
        return uint256(int256(_0x644ea3._0xc0f86e));
    }


    function _0x1ebbdf(address _0x5f0ccf, uint256 _0xc0f86e) internal {
        uint256 _0x7a545c = block.timestamp + _0xf7650c;
        _0x432439[_0x5f0ccf].push(UserLock({
            _0xc0f86e: _0xc0f86e,
            _0x7a545c: _0x7a545c
        }));
        _0x707ac7[_0x5f0ccf] += _0xc0f86e;
    }


    function _0xb814e2(address _0x5f0ccf) external view returns (uint256 _0xefac7b) {
        uint256 _0xeffe5e = _0x5b8a0b(_0x5f0ccf);
        uint256 _0xdb583d = 0;

        UserLock[] storage _0xc83af9 = _0x432439[_0x5f0ccf];
        for (uint256 i = 0; i < _0xc83af9.length; i++) {
            if (_0xc83af9[i]._0x7a545c > block.timestamp) {
                _0xdb583d += _0xc83af9[i]._0xc0f86e;
            }
        }

        return _0xeffe5e > _0xdb583d ? _0xeffe5e - _0xdb583d : 0;
    }

    function _0x353b5c(address _0x5f0ccf) internal returns (uint256 _0xd7203d) {
        UserLock[] storage _0xc83af9 = _0x432439[_0x5f0ccf];
        uint256 _0x347a1d = _0xc83af9.length;
        if (_0x347a1d == 0) return 0;

        uint256 _0xc915e1 = 0;
        unchecked {
            for (uint256 i = 0; i < _0x347a1d; i++) {
                UserLock memory L = _0xc83af9[i];
                if (L._0x7a545c <= block.timestamp) {
                    _0xd7203d += L._0xc0f86e;
                } else {
                    if (_0xc915e1 != i) _0xc83af9[_0xc915e1] = L;
                    _0xc915e1++;
                }
            }
            if (_0xd7203d > 0) {
                _0x707ac7[_0x5f0ccf] -= _0xd7203d;
            }
            while (_0xc83af9.length > _0xc915e1) {
                _0xc83af9.pop();
            }
        }
    }


    function _0xe58043(
        address from,
        address _0xe9b60e,
        uint256 _0xc0f86e
    ) internal override {
        super._0xe58043(from, _0xe9b60e, _0xc0f86e);

        if (from != address(0) && _0xe9b60e != address(0)) {
            uint256 _0xeffe5e = _0x5b8a0b(from);


            uint256 _0xeb5df7 = _0xeffe5e > _0x707ac7[from] ? _0xeffe5e - _0x707ac7[from] : 0;


            if (_0xeb5df7 >= _0xc0f86e) {
                return;
            }


            _0x353b5c(from);
            uint256 _0x1194b1 = _0xeffe5e > _0x707ac7[from] ? _0xeffe5e - _0x707ac7[from] : 0;


            require(_0x1194b1 >= _0xc0f86e, "Tokens locked");
        }
    }


    function _0x5ece92() external _0x44d5b1 {
        require(_0x654b43 != address(0), "Voter not set");
        require(_0x402011 != address(0), "Distributor not set");


        uint256  _0x4c6734 = IRewardsDistributor(_0x402011)._0x03680a(_0x4b3d78);
        _0x40ce1d += _0x4c6734;

        address[] memory _0x192428 = IVoter(_0x654b43)._0x9864b3(_0x4b3d78);

        for (uint256 i = 0; i < _0x192428.length; i++) {
            if (_0x192428[i] != address(0)) {
                address _0x944870 = IGaugeManager(_0xc95bbc)._0x689a09(_0x192428[i]);

                if (_0x944870 != address(0)) {

                    address[] memory _0x7aabae = new address[](1);
                    address[][] memory _0x382bea = new address[][](1);


                    address _0x4f128e = IGaugeManager(_0xc95bbc)._0xcfa8e8(_0x944870);
                    if (_0x4f128e != address(0)) {
                        uint256 _0x1eb5fa = IBribe(_0x4f128e)._0x742083();
                        if (_0x1eb5fa > 0) {
                            address[] memory _0x1d9b04 = new address[](_0x1eb5fa);
                            for (uint256 j = 0; j < _0x1eb5fa; j++) {
                                _0x1d9b04[j] = IBribe(_0x4f128e)._0x1d9b04(j);
                            }
                            _0x7aabae[0] = _0x4f128e;
                            _0x382bea[0] = _0x1d9b04;

                            IGaugeManager(_0xc95bbc)._0x14073a(_0x7aabae, _0x382bea, _0x4b3d78);
                        }
                    }


                    address _0xb3561a = IGaugeManager(_0xc95bbc)._0x38c09d(_0x944870);
                    if (_0xb3561a != address(0)) {
                        uint256 _0x1eb5fa = IBribe(_0xb3561a)._0x742083();
                        if (_0x1eb5fa > 0) {
                            address[] memory _0x1d9b04 = new address[](_0x1eb5fa);
                            for (uint256 j = 0; j < _0x1eb5fa; j++) {
                                _0x1d9b04[j] = IBribe(_0xb3561a)._0x1d9b04(j);
                            }
                            _0x7aabae[0] = _0xb3561a;
                            _0x382bea[0] = _0x1d9b04;

                            IGaugeManager(_0xc95bbc)._0x14073a(_0x7aabae, _0x382bea, _0x4b3d78);
                        }
                    }
                }
            }
        }
    }


    function _0xc087b6(ISwapper.SwapParams calldata _0x94c645) external _0xa239e6 _0x44d5b1 {
        require(address(_0xfd6d83) != address(0), "Swapper not set");


        uint256 _0x8534dd = IERC20(_0x94c645._0x73f63b)._0x5b8a0b(address(this));
        require(_0x8534dd >= _0x94c645._0x7e4182, "Insufficient token balance");


        IERC20(_0x94c645._0x73f63b)._0xd7f14d(address(_0xfd6d83), _0x94c645._0x7e4182);


        uint256 _0xeb23b4 = _0xfd6d83._0x89827d(_0x94c645);


        IERC20(_0x94c645._0x73f63b)._0xd7f14d(address(_0xfd6d83), 0);


        _0x33e5f3 += _0xeb23b4;
    }


    function _0x5669e9() external _0x44d5b1 {


        uint256 _0x8641ed = IERC20(HYBR)._0x5b8a0b(address(this));

        if (_0x8641ed > 0) {

            IERC20(HYBR)._0xd7f14d(_0x5a2eed, _0x8641ed);
            IVotingEscrow(_0x5a2eed)._0xf6b592(_0x4b3d78, _0x8641ed);


            _0x553ed2();

            _0xaba87c = block.timestamp;

            emit Compound(_0x8641ed, _0xe10348());
        }
    }


    function _0xc66460(address[] calldata _0xcaed60, uint256[] calldata _0x9edd10) external {
        require(msg.sender == _0xb95c4b() || msg.sender == _0x73f78a, "Not authorized");
        require(_0x654b43 != address(0), "Voter not set");

        IVoter(_0x654b43)._0xc66460(_0x4b3d78, _0xcaed60, _0x9edd10);
        _0x2b0b3b = HybraTimeLibrary._0x99c0d9(block.timestamp);

    }


    function _0x6e9d4d() external {
        require(msg.sender == _0xb95c4b() || msg.sender == _0x73f78a, "Not authorized");
        require(_0x654b43 != address(0), "Voter not set");

        IVoter(_0x654b43)._0x6e9d4d(_0x4b3d78);
    }


    function _0xad4f7a(uint256 _0xc0f86e) external {


        if (_0xc0f86e > 0) {
            IERC20(HYBR)._0x41f27a(_0x5a2eed, _0xc0f86e);

            if(_0x4b3d78 == 0){
                _0xa58650(_0xc0f86e);
            } else{
                IVotingEscrow(_0x5a2eed)._0xf6b592(_0x4b3d78, _0xc0f86e);


                _0x553ed2();
            }
        }
        _0x4bbbc4 += _0xc0f86e;
        emit PenaltyRewardReceived(_0xc0f86e);
    }


    function _0x7ec69a(address _0xf5cdbb) external _0x3b2bdf {
        require(_0xf5cdbb != address(0), "Invalid voter");
        _0x654b43 = _0xf5cdbb;
        emit VoterSet(_0xf5cdbb);
    }


    function _0x6d16d7(uint256 _0x9846f9) external _0x3b2bdf {
        require(_0x9846f9 >= MIN_LOCK_PERIOD && _0x9846f9 <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 _0x38874e = _0xf7650c;
        if (1 == 1) { _0xf7650c = _0x9846f9; }
        emit TransferLockPeriodUpdated(_0x38874e, _0x9846f9);
    }


    function _0x97772b(uint256 _0x04658f) external _0x3b2bdf {
        require(_0x04658f >= MIN_WITHDRAW_FEE && _0x04658f <= MAX_WITHDRAW_FEE, "Invalid fee");
        _0x3b4006 = _0x04658f;
    }

    function _0x928be5(uint256 _0x883871) external _0x3b2bdf {
        if (1 == 1) { _0x5a89c7 = _0x883871; }
    }

    function _0x3435c2(uint256 _0x883871) external _0x3b2bdf {
        _0xe0849a = _0x883871;
    }


    function _0x504cc7(address _0x8162ec) external _0x3b2bdf {
        require(_0x8162ec != address(0), "Invalid swapper");
        address _0xc443ef = address(_0xfd6d83);
        _0xfd6d83 = ISwapper(_0x8162ec);
        emit SwapperUpdated(_0xc443ef, _0x8162ec);
    }


    function _0x081f78(address _0x0b8b85) external _0x3b2bdf {
        require(_0x0b8b85 != address(0), "Invalid team");
        Team = _0x0b8b85;
    }


    function _0xf56947(address _0x5f0ccf) external _0x44d5b1 {
        delete _0x432439[_0x5f0ccf];
        _0x707ac7[_0x5f0ccf] = 0;
        emit EmergencyUnlock(_0x5f0ccf);
    }


    function _0xe6d7bd(address _0x5f0ccf) external view returns (UserLock[] memory) {
        return _0x432439[_0x5f0ccf];
    }


    function _0x42a040(address _0xf30c31) external _0x3b2bdf {
        require(_0xf30c31 != address(0), "Invalid operator");
        address _0xc6c247 = _0x73f78a;
        _0x73f78a = _0xf30c31;
        emit OperatorUpdated(_0xc6c247, _0xf30c31);
    }


    function _0x40d4ad() external view returns (uint256) {
        if (_0x4b3d78 == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory _0x644ea3 = IVotingEscrow(_0x5a2eed)._0x644ea3(_0x4b3d78);
        return uint256(_0x644ea3._0x65739e);
    }


    function _0x553ed2() internal {
        if (_0x4b3d78 == 0) return;

        IVotingEscrow.LockedBalance memory _0x644ea3 = IVotingEscrow(_0x5a2eed)._0x644ea3(_0x4b3d78);
        if (_0x644ea3._0x653dd8 || _0x644ea3._0x65739e <= block.timestamp) return;

        uint256 _0x08fdee = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;


        if (_0x08fdee > _0x644ea3._0x65739e + 2 hours) {
            try IVotingEscrow(_0x5a2eed)._0x9574d6(_0x4b3d78, HybraTimeLibrary.MAX_LOCK_DURATION) {

            } catch {


            }
        }
    }

}