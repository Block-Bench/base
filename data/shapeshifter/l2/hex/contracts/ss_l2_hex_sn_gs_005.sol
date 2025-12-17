// SPDX-License-Identifier: MIT
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

    address public _0x902c91;                                         // the ve token that governs these contracts
    address internal _0x7b4c76;                                      // $the token
    address public _0xf547e6;                          // registry to check accesses
    address public _0xf8ca15;
    uint256 public _0x59ee51;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public _0xe197b3;

    mapping(uint256 => mapping(address => uint256)) public _0x06d0f2;  // nft      => pool     => votes
    mapping(uint256 => address[]) public _0x444da1;                 // nft      => pools

    mapping(address => uint256) public _0x02122e;
    uint256 public _0x5a17d7;
    mapping(uint256 => uint256) public _0xcfff42;

    mapping(uint256 => uint256) public _0x25e8f6;                     // nft      => timestamp of last vote (this is shifted to thursday of that epoc)
    mapping(uint256 => uint256) public _0xef5a70;            // nft      => timestamp of last vote

    event Voted(address indexed _0xec7190, uint256 _0x09baac, uint256 _0x223ea6);
    event Abstained(uint256 _0x09baac, uint256 _0x223ea6);
    event SetPermissionRegistry(address indexed _0x89f7d0, address indexed _0x43c4ae);

    constructor() {}

    // function initialize(address __ve, address _pairFactory, address  _gaugeFactory, address _bribes, address _tokenHandler) initializer public {
    function _0x69bd97(
        address __ve,
        address _0xb9cfa1,
        address _0x3f6951,
        address _0x79cf62
    ) public _0xe1e871 {
        __Ownable_init();
        __ReentrancyGuard_init();
        _0x902c91 = __ve;
        _0x7b4c76 = IVotingEscrow(__ve)._0xf7d8f7();
        _0xe197b3 = IGaugeManager(_0x3f6951);
        _0xf547e6 = _0x79cf62;
        _0xf8ca15 = _0xb9cfa1;
        _0x59ee51 = 30;
        EPOCH_DURATION = HybraTimeLibrary.WEEK;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    MODIFIERS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    modifier VoterAdmin() {
        require(IPermissionsRegistry(_0xf547e6)._0x56a865("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(_0xf547e6)._0x56a865("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisManager() {
        require(IPermissionsRegistry(_0xf547e6)._0x56a865("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
        _;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VoterAdmin
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Set a new PermissionRegistry
    function _0x24d2f7(address _0x79cf62) external VoterAdmin {
        require(_0x79cf62.code.length > 0, "CODELEN");
        require(_0x79cf62 != address(0), "ZA");
        emit SetPermissionRegistry(_0xf547e6, _0x79cf62);
        _0xf547e6 = _0x79cf62;
    }

    function _0x0f6a2b(uint256 _0x708f47) external VoterAdmin {
        require (_0x708f47 >= MIN_VOTING_NUM, "LOW_VOTE");
        _0x59ee51 = _0x708f47;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Reset the votes of a given TokenID
    function _0x63155d(uint256 _0x54da63) external _0x493e69(_0x54da63) _0xe5f5a2 {
        require(IVotingEscrow(_0x902c91)._0x09db80(msg.sender, _0x54da63), "NAO");
        _0xa01770(_0x54da63);
        IVotingEscrow(_0x902c91)._0xd58fe4(_0x54da63);
    }

    function _0xa01770(uint256 _0x54da63) internal {
        address[] storage _0xe10e94 = _0x444da1[_0x54da63];
        uint256 _0xe7f919 = _0xe10e94.length;
        uint256 _0xa770c5 = 0;

        for (uint256 i = 0; i < _0xe7f919; i ++) {
            address _0xbbb9cf = _0xe10e94[i];
            uint256 _0x339809 = _0x06d0f2[_0x54da63][_0xbbb9cf];

            if (_0x339809 != 0) {
                _0x02122e[_0xbbb9cf] -= _0x339809;

                _0x06d0f2[_0x54da63][_0xbbb9cf] -= _0x339809;
                address _0x1da55a = _0xe197b3._0x42da21(_0xbbb9cf);
                address _0x433412 = _0xe197b3._0xaae9a9(_0xbbb9cf);
                IBribe(_0x1da55a)._0x3aca48(uint256(_0x339809), _0x54da63);
                IBribe(_0x433412)._0x3aca48(uint256(_0x339809), _0x54da63);

                // decrease totalWeight irrespective of gauge is killed/alive for this current pool
                _0xa770c5 += _0x339809;

                emit Abstained(_0x54da63, _0x339809);
            }
        }
        _0x5a17d7 -= _0xa770c5;
        _0xcfff42[_0x54da63] = 0;
        delete _0x444da1[_0x54da63];
    }

    /// @notice Recast the saved votes of a given TokenID
    function _0x95c8d5(uint256 _0x54da63) external _0xe5f5a2 {
        uint256 _0x1d81a7 = block.timestamp;
        if (_0x1d81a7 <= HybraTimeLibrary._0xffafd7(_0x1d81a7)){
            revert("DW");
        }
        require(IVotingEscrow(_0x902c91)._0x09db80(msg.sender, _0x54da63) || msg.sender == _0x902c91, "NAO||VE");
        address[] memory _0xe10e94 = _0x444da1[_0x54da63];
        uint256 _0xe34db9 = _0xe10e94.length;
        uint256[] memory _0xad2c79 = new uint256[](_0xe34db9);

        for (uint256 i = 0; i < _0xe34db9; i ++) {
            _0xad2c79[i] = _0x06d0f2[_0x54da63][_0xe10e94[i]];
        }

        _0x4d0a13(_0x54da63, _0xe10e94, _0xad2c79);
    }

    /// @notice Vote for pools
    /// @param  _tokenId    veNFT tokenID used to vote
    /// @param  _poolVote   array of LPs addresses to vote  (eg.: [sAMM usdc-usdt   , sAMM busd-usdt, vAMM wbnb-the ,...])
    /// @param  _weights    array of weights for each LPs   (eg.: [10               , 90            , 45             ,...])
    function _0x0f6b87(uint256 _0x54da63, address[] calldata _0xe10e94, uint256[] calldata _0xad2c79)
        external _0x493e69(_0x54da63) _0xe5f5a2 {
        require(IVotingEscrow(_0x902c91)._0x09db80(msg.sender, _0x54da63), "NAO");
        require(_0xe10e94.length == _0xad2c79.length, "MISMATCH_LEN");
        require(_0xe10e94.length <= _0x59ee51, "EXCEEDS");
        uint256 _0x1d81a7 = block.timestamp;

        _0x4d0a13(_0x54da63, _0xe10e94, _0xad2c79);
        _0x25e8f6[_0x54da63] = HybraTimeLibrary._0xac7e37(block.timestamp) + 1;
        _0xef5a70[_0x54da63] = block.timestamp;
    }

    function _0x4d0a13(uint256 _0x54da63, address[] memory _0xe10e94, uint256[] memory _0xad2c79) internal {
        _0xa01770(_0x54da63);
        uint256 _0xe34db9 = _0xe10e94.length;
        uint256 _0xc16f07 = IVotingEscrow(_0x902c91)._0x3495fa(_0x54da63);
        uint256 _0x6e8dbc = 0;
        uint256 _0x898df9 = 0;

        for (uint i = 0; i < _0xe34db9; i++) {

            if(_0xe197b3._0x05640b(_0xe10e94[i])) _0x6e8dbc += _0xad2c79[i];
        }

        for (uint256 i = 0; i < _0xe34db9; i++) {
            address _0xbbb9cf = _0xe10e94[i];

            if (_0xe197b3._0x05640b(_0xbbb9cf)) {
                uint256 _0x1028f5 = _0xad2c79[i] * _0xc16f07 / _0x6e8dbc;

                require(_0x06d0f2[_0x54da63][_0xbbb9cf] == 0, "ZV");
                require(_0x1028f5 != 0, "ZV");

                _0x444da1[_0x54da63].push(_0xbbb9cf);
                _0x02122e[_0xbbb9cf] += _0x1028f5;

                _0x06d0f2[_0x54da63][_0xbbb9cf] = _0x1028f5;
                address _0x1da55a = _0xe197b3._0x42da21(_0xbbb9cf);
                address _0x433412 = _0xe197b3._0xaae9a9(_0xbbb9cf);

                IBribe(_0x1da55a)._0x7f050a(uint256(_0x1028f5), _0x54da63);
                IBribe(_0x433412)._0x7f050a(uint256(_0x1028f5), _0x54da63);

                _0x898df9 += _0x1028f5;
                emit Voted(msg.sender, _0x54da63, _0x1028f5);
            }
        }
        if (_0x898df9 > 0) IVotingEscrow(_0x902c91)._0x8a2204(_0x54da63);
        _0x5a17d7 += _0x898df9;
        _0xcfff42[_0x54da63] = _0x898df9;
    }

    modifier _0x493e69(uint256 _0x54da63) {
        // ensure new epoch since last vote
        if (HybraTimeLibrary._0xac7e37(block.timestamp) <= _0x25e8f6[_0x54da63]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary._0xffafd7(block.timestamp)) revert("DW");
        _;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VIEW FUNCTIONS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice view the total length of the pools
    function length() external view returns (uint256) {
        return _0xe197b3._0x5486d4().length;
    }

    /// @notice view the total length of the voted pools given a tokenId
    function _0x7dbfc4(uint256 _0x09baac) external view returns(uint256) {
        return _0x444da1[_0x09baac].length;
    }

    function _0xca0de8(address _0x3f6951) external VoterAdmin {
        require(_0x3f6951 != address(0));
        _0xe197b3 = IGaugeManager(_0x3f6951);
    }

}