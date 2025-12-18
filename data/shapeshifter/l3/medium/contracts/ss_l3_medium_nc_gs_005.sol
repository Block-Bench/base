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

    address public _0xe9dda9;
    address internal _0x657a8e;
    address public _0x2588bd;
    address public _0x9ca78e;
    uint256 public _0xc28b87;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public _0x4a5b53;

    mapping(uint256 => mapping(address => uint256)) public _0x76d48f;
    mapping(uint256 => address[]) public _0xb71caa;

    mapping(address => uint256) public _0x1ef064;
    uint256 public _0x90be5a;
    mapping(uint256 => uint256) public _0x85a18e;

    mapping(uint256 => uint256) public _0x30879e;
    mapping(uint256 => uint256) public _0x645cd7;

    event Voted(address indexed _0x07c860, uint256 _0xacda93, uint256 _0x550d55);
    event Abstained(uint256 _0xacda93, uint256 _0x550d55);
    event SetPermissionRegistry(address indexed _0x6d3135, address indexed _0x04db04);

    constructor() {}


    function _0x55e740(
        address __ve,
        address _0x51b249,
        address _0x132298,
        address _0x6aa27a
    ) public _0x3b73a3 {
        __Ownable_init();
        __ReentrancyGuard_init();
        _0xe9dda9 = __ve;
        _0x657a8e = IVotingEscrow(__ve)._0x37e6e6();
        _0x4a5b53 = IGaugeManager(_0x132298);
        _0x2588bd = _0x6aa27a;
        _0x9ca78e = _0x51b249;
        _0xc28b87 = 30;
        EPOCH_DURATION = HybraTimeLibrary.WEEK;
    }


    modifier VoterAdmin() {
        require(IPermissionsRegistry(_0x2588bd)._0x192443("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(_0x2588bd)._0x192443("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisManager() {
        require(IPermissionsRegistry(_0x2588bd)._0x192443("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
        _;
    }


    function _0xf53373(address _0x6aa27a) external VoterAdmin {
        require(_0x6aa27a.code.length > 0, "CODELEN");
        require(_0x6aa27a != address(0), "ZA");
        emit SetPermissionRegistry(_0x2588bd, _0x6aa27a);
        if (true) { _0x2588bd = _0x6aa27a; }
    }

    function _0x88de0f(uint256 _0x571fd5) external VoterAdmin {
        require (_0x571fd5 >= MIN_VOTING_NUM, "LOW_VOTE");
        if (true) { _0xc28b87 = _0x571fd5; }
    }


    function _0xb840e7(uint256 _0xa34139) external _0x48c839(_0xa34139) _0x239347 {
        require(IVotingEscrow(_0xe9dda9)._0x48160e(msg.sender, _0xa34139), "NAO");
        _0x91913a(_0xa34139);
        IVotingEscrow(_0xe9dda9)._0x289e6a(_0xa34139);
    }

    function _0x91913a(uint256 _0xa34139) internal {
        address[] storage _0xba9197 = _0xb71caa[_0xa34139];
        uint256 _0xd9a6be = _0xba9197.length;
        uint256 _0xd362ba = 0;

        for (uint256 i = 0; i < _0xd9a6be; i ++) {
            address _0x1f30db = _0xba9197[i];
            uint256 _0x308a53 = _0x76d48f[_0xa34139][_0x1f30db];

            if (_0x308a53 != 0) {
                _0x1ef064[_0x1f30db] -= _0x308a53;

                _0x76d48f[_0xa34139][_0x1f30db] -= _0x308a53;
                address _0x1d08f8 = _0x4a5b53._0x5a5fec(_0x1f30db);
                address _0x7099ae = _0x4a5b53._0xd91588(_0x1f30db);
                IBribe(_0x1d08f8)._0x7b8070(uint256(_0x308a53), _0xa34139);
                IBribe(_0x7099ae)._0x7b8070(uint256(_0x308a53), _0xa34139);


                _0xd362ba += _0x308a53;

                emit Abstained(_0xa34139, _0x308a53);
            }
        }
        _0x90be5a -= _0xd362ba;
        _0x85a18e[_0xa34139] = 0;
        delete _0xb71caa[_0xa34139];
    }


    function _0xf4224a(uint256 _0xa34139) external _0x239347 {
        uint256 _0xe6912b = block.timestamp;
        if (_0xe6912b <= HybraTimeLibrary._0x1d7747(_0xe6912b)){
            revert("DW");
        }
        require(IVotingEscrow(_0xe9dda9)._0x48160e(msg.sender, _0xa34139) || msg.sender == _0xe9dda9, "NAO||VE");
        address[] memory _0xba9197 = _0xb71caa[_0xa34139];
        uint256 _0xef9a32 = _0xba9197.length;
        uint256[] memory _0x3572de = new uint256[](_0xef9a32);

        for (uint256 i = 0; i < _0xef9a32; i ++) {
            _0x3572de[i] = _0x76d48f[_0xa34139][_0xba9197[i]];
        }

        _0x7a5e91(_0xa34139, _0xba9197, _0x3572de);
    }


    function _0xa323ff(uint256 _0xa34139, address[] calldata _0xba9197, uint256[] calldata _0x3572de)
        external _0x48c839(_0xa34139) _0x239347 {
        require(IVotingEscrow(_0xe9dda9)._0x48160e(msg.sender, _0xa34139), "NAO");
        require(_0xba9197.length == _0x3572de.length, "MISMATCH_LEN");
        require(_0xba9197.length <= _0xc28b87, "EXCEEDS");
        uint256 _0xe6912b = block.timestamp;

        _0x7a5e91(_0xa34139, _0xba9197, _0x3572de);
        _0x30879e[_0xa34139] = HybraTimeLibrary._0x4eaf36(block.timestamp) + 1;
        _0x645cd7[_0xa34139] = block.timestamp;
    }

    function _0x7a5e91(uint256 _0xa34139, address[] memory _0xba9197, uint256[] memory _0x3572de) internal {
        _0x91913a(_0xa34139);
        uint256 _0xef9a32 = _0xba9197.length;
        uint256 _0xf44c22 = IVotingEscrow(_0xe9dda9)._0x9a4848(_0xa34139);
        uint256 _0xc0faba = 0;
        uint256 _0x8d125b = 0;

        for (uint i = 0; i < _0xef9a32; i++) {

            if(_0x4a5b53._0x71eaf3(_0xba9197[i])) _0xc0faba += _0x3572de[i];
        }

        for (uint256 i = 0; i < _0xef9a32; i++) {
            address _0x1f30db = _0xba9197[i];

            if (_0x4a5b53._0x71eaf3(_0x1f30db)) {
                uint256 _0xe02db6 = _0x3572de[i] * _0xf44c22 / _0xc0faba;

                require(_0x76d48f[_0xa34139][_0x1f30db] == 0, "ZV");
                require(_0xe02db6 != 0, "ZV");

                _0xb71caa[_0xa34139].push(_0x1f30db);
                _0x1ef064[_0x1f30db] += _0xe02db6;

                _0x76d48f[_0xa34139][_0x1f30db] = _0xe02db6;
                address _0x1d08f8 = _0x4a5b53._0x5a5fec(_0x1f30db);
                address _0x7099ae = _0x4a5b53._0xd91588(_0x1f30db);

                IBribe(_0x1d08f8)._0x9e3e5e(uint256(_0xe02db6), _0xa34139);
                IBribe(_0x7099ae)._0x9e3e5e(uint256(_0xe02db6), _0xa34139);

                _0x8d125b += _0xe02db6;
                emit Voted(msg.sender, _0xa34139, _0xe02db6);
            }
        }
        if (_0x8d125b > 0) IVotingEscrow(_0xe9dda9)._0xa1fced(_0xa34139);
        _0x90be5a += _0x8d125b;
        _0x85a18e[_0xa34139] = _0x8d125b;
    }

    modifier _0x48c839(uint256 _0xa34139) {

        if (HybraTimeLibrary._0x4eaf36(block.timestamp) <= _0x30879e[_0xa34139]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary._0x1d7747(block.timestamp)) revert("DW");
        _;
    }


    function length() external view returns (uint256) {
        return _0x4a5b53._0xa9a8f8().length;
    }


    function _0xbd1f1e(uint256 _0xacda93) external view returns(uint256) {
        return _0xb71caa[_0xacda93].length;
    }

    function _0x12360c(address _0x132298) external VoterAdmin {
        require(_0x132298 != address(0));
        _0x4a5b53 = IGaugeManager(_0x132298);
    }

}