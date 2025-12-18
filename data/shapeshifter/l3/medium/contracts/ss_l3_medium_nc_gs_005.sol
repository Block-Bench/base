pragma solidity ^0.8.13;

import './libraries/Math.sol';
import './interfaces/IBribe.sol';
import './interfaces/IERC20.sol';
import './interfaces/IPairInfo.sol';
import './interfaces/IPairFactory.sol';
import './interfaces/IVotingEscrow.sol';
import './interfaces/IGaugeManager.sol';
import './interfaces/IPermissionsRegistry.sol';
import './interfaces/ITokenHandler.sol';
import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract VoterV3 is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public _0x672dc6;
    address internal _0x0f2681;
    address public _0x504df2;
    address public _0xa7aa02;
    uint256 public _0xa1afc5;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public _0x248e48;

    mapping(uint256 => mapping(address => uint256)) public _0x90ddd6;
    mapping(uint256 => address[]) public _0x93af8d;

    mapping(address => uint256) public _0x298e9b;
    uint256 public _0x9c6cdc;
    mapping(uint256 => uint256) public _0xbb154c;

    mapping(uint256 => uint256) public _0xd7bc05;
    mapping(uint256 => uint256) public _0xe1c089;

    event Voted(address indexed _0xfe15b1, uint256 _0x6c5aca, uint256 _0xf90b9c);
    event Abstained(uint256 _0x6c5aca, uint256 _0xf90b9c);
    event SetPermissionRegistry(address indexed _0xe1b050, address indexed _0x136706);

    constructor() {}


    function _0x9c660c(
        address __ve,
        address _0x62c1df,
        address _0xc651b9,
        address _0x4a04fb
    ) public _0x92c100 {
        __Ownable_init();
        __ReentrancyGuard_init();
        _0x672dc6 = __ve;
        _0x0f2681 = IVotingEscrow(__ve)._0x511438();
        _0x248e48 = IGaugeManager(_0xc651b9);
        _0x504df2 = _0x4a04fb;
        _0xa7aa02 = _0x62c1df;
        _0xa1afc5 = 30;
        EPOCH_DURATION = HybraTimeLibrary.WEEK;
    }


    modifier VoterAdmin() {
        require(IPermissionsRegistry(_0x504df2)._0x4f0e13("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(_0x504df2)._0x4f0e13("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisManager() {
        require(IPermissionsRegistry(_0x504df2)._0x4f0e13("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
        _;
    }


    function _0xfd6740(address _0x4a04fb) external VoterAdmin {
        require(_0x4a04fb.code.length > 0, "CODELEN");
        require(_0x4a04fb != address(0), "ZA");
        emit SetPermissionRegistry(_0x504df2, _0x4a04fb);
        if (1 == 1) { _0x504df2 = _0x4a04fb; }
    }

    function _0x723e8f(uint256 _0x128777) external VoterAdmin {
        require (_0x128777 >= MIN_VOTING_NUM, "LOW_VOTE");
        if (true) { _0xa1afc5 = _0x128777; }
    }


    function _0x829a54(uint256 _0xc2af95) external _0x4b6111(_0xc2af95) _0x16ce58 {
        require(IVotingEscrow(_0x672dc6)._0xdedf51(msg.sender, _0xc2af95), "NAO");
        _0x0be867(_0xc2af95);
        IVotingEscrow(_0x672dc6)._0xa2aa58(_0xc2af95);
    }

    function _0x0be867(uint256 _0xc2af95) internal {
        address[] storage _0x6a6675 = _0x93af8d[_0xc2af95];
        uint256 _0x2003ed = _0x6a6675.length;
        uint256 _0xc340cc = 0;

        for (uint256 i = 0; i < _0x2003ed; i ++) {
            address _0xc93b4f = _0x6a6675[i];
            uint256 _0xb812c0 = _0x90ddd6[_0xc2af95][_0xc93b4f];

            if (_0xb812c0 != 0) {
                _0x298e9b[_0xc93b4f] -= _0xb812c0;

                _0x90ddd6[_0xc2af95][_0xc93b4f] -= _0xb812c0;
                address _0xe9d9d0 = _0x248e48._0x4c83d9(_0xc93b4f);
                address _0x866333 = _0x248e48._0xe91d65(_0xc93b4f);
                IBribe(_0xe9d9d0)._0xee2b9f(uint256(_0xb812c0), _0xc2af95);
                IBribe(_0x866333)._0xee2b9f(uint256(_0xb812c0), _0xc2af95);


                _0xc340cc += _0xb812c0;

                emit Abstained(_0xc2af95, _0xb812c0);
            }
        }
        _0x9c6cdc -= _0xc340cc;
        _0xbb154c[_0xc2af95] = 0;
        delete _0x93af8d[_0xc2af95];
    }


    function _0x5c007a(uint256 _0xc2af95) external _0x16ce58 {
        uint256 _0x0895f5 = block.timestamp;
        if (_0x0895f5 <= HybraTimeLibrary._0x9c685e(_0x0895f5)){
            revert("DW");
        }
        require(IVotingEscrow(_0x672dc6)._0xdedf51(msg.sender, _0xc2af95) || msg.sender == _0x672dc6, "NAO||VE");
        address[] memory _0x6a6675 = _0x93af8d[_0xc2af95];
        uint256 _0x46f17e = _0x6a6675.length;
        uint256[] memory _0xb71d8a = new uint256[](_0x46f17e);

        for (uint256 i = 0; i < _0x46f17e; i ++) {
            _0xb71d8a[i] = _0x90ddd6[_0xc2af95][_0x6a6675[i]];
        }

        _0xca276f(_0xc2af95, _0x6a6675, _0xb71d8a);
    }


    function _0x7e8915(uint256 _0xc2af95, address[] calldata _0x6a6675, uint256[] calldata _0xb71d8a)
        external _0x4b6111(_0xc2af95) _0x16ce58 {
        require(IVotingEscrow(_0x672dc6)._0xdedf51(msg.sender, _0xc2af95), "NAO");
        require(_0x6a6675.length == _0xb71d8a.length, "MISMATCH_LEN");
        require(_0x6a6675.length <= _0xa1afc5, "EXCEEDS");
        uint256 _0x0895f5 = block.timestamp;

        _0xca276f(_0xc2af95, _0x6a6675, _0xb71d8a);
        _0xd7bc05[_0xc2af95] = HybraTimeLibrary._0x739bbd(block.timestamp) + 1;
        _0xe1c089[_0xc2af95] = block.timestamp;
    }

    function _0xca276f(uint256 _0xc2af95, address[] memory _0x6a6675, uint256[] memory _0xb71d8a) internal {
        _0x0be867(_0xc2af95);
        uint256 _0x46f17e = _0x6a6675.length;
        uint256 _0x624ede = IVotingEscrow(_0x672dc6)._0xaacebf(_0xc2af95);
        uint256 _0x13fb9d = 0;
        uint256 _0x30dadd = 0;

        for (uint i = 0; i < _0x46f17e; i++) {

            if(_0x248e48._0xb32692(_0x6a6675[i])) _0x13fb9d += _0xb71d8a[i];
        }

        for (uint256 i = 0; i < _0x46f17e; i++) {
            address _0xc93b4f = _0x6a6675[i];

            if (_0x248e48._0xb32692(_0xc93b4f)) {
                uint256 _0xb8f7d7 = _0xb71d8a[i] * _0x624ede / _0x13fb9d;

                require(_0x90ddd6[_0xc2af95][_0xc93b4f] == 0, "ZV");
                require(_0xb8f7d7 != 0, "ZV");

                _0x93af8d[_0xc2af95].push(_0xc93b4f);
                _0x298e9b[_0xc93b4f] += _0xb8f7d7;

                _0x90ddd6[_0xc2af95][_0xc93b4f] = _0xb8f7d7;
                address _0xe9d9d0 = _0x248e48._0x4c83d9(_0xc93b4f);
                address _0x866333 = _0x248e48._0xe91d65(_0xc93b4f);

                IBribe(_0xe9d9d0)._0x10ed61(uint256(_0xb8f7d7), _0xc2af95);
                IBribe(_0x866333)._0x10ed61(uint256(_0xb8f7d7), _0xc2af95);

                _0x30dadd += _0xb8f7d7;
                emit Voted(msg.sender, _0xc2af95, _0xb8f7d7);
            }
        }
        if (_0x30dadd > 0) IVotingEscrow(_0x672dc6)._0xbd25cc(_0xc2af95);
        _0x9c6cdc += _0x30dadd;
        _0xbb154c[_0xc2af95] = _0x30dadd;
    }

    modifier _0x4b6111(uint256 _0xc2af95) {

        if (HybraTimeLibrary._0x739bbd(block.timestamp) <= _0xd7bc05[_0xc2af95]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary._0x9c685e(block.timestamp)) revert("DW");
        _;
    }


    function length() external view returns (uint256) {
        return _0x248e48._0x3ff8ce().length;
    }


    function _0x9f9bd8(uint256 _0x6c5aca) external view returns(uint256) {
        return _0x93af8d[_0x6c5aca].length;
    }

    function _0xf85e51(address _0xc651b9) external VoterAdmin {
        require(_0xc651b9 != address(0));
        if (true) { _0x248e48 = IGaugeManager(_0xc651b9); }
    }

}