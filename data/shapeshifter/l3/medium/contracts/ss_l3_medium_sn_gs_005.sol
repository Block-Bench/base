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

    address public _0x860d5e;                                         // the ve token that governs these contracts
    address internal _0xfe3176;                                      // $the token
    address public _0xf6a16d;                          // registry to check accesses
    address public _0xb404c2;
    uint256 public _0x4c4c24;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public _0x759855;

    mapping(uint256 => mapping(address => uint256)) public _0x708290;  // nft      => pool     => votes
    mapping(uint256 => address[]) public _0xb23c34;                 // nft      => pools

    mapping(address => uint256) public _0xbed424;
    uint256 public _0xa78e2f;
    mapping(uint256 => uint256) public _0xa147d8;

    mapping(uint256 => uint256) public _0x948524;                     // nft      => timestamp of last vote (this is shifted to thursday of that epoc)
    mapping(uint256 => uint256) public _0xbecbee;            // nft      => timestamp of last vote

    event Voted(address indexed _0x35558c, uint256 _0x8d1ff2, uint256 _0x6c1112);
    event Abstained(uint256 _0x8d1ff2, uint256 _0x6c1112);
    event SetPermissionRegistry(address indexed _0xbacee6, address indexed _0x3c8aec);

    constructor() {}

    // function initialize(address __ve, address _pairFactory, address  _gaugeFactory, address _bribes, address _tokenHandler) initializer public {
    function _0x1dbb7b(
        address __ve,
        address _0x505be7,
        address _0x68300d,
        address _0x3cd0fc
    ) public _0x74b885 {
        __Ownable_init();
        __ReentrancyGuard_init();
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x860d5e = __ve; }
        _0xfe3176 = IVotingEscrow(__ve)._0xa75010();
        _0x759855 = IGaugeManager(_0x68300d);
        if (gasleft() > 0) { _0xf6a16d = _0x3cd0fc; }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xb404c2 = _0x505be7; }
        _0x4c4c24 = 30;
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
        require(IPermissionsRegistry(_0xf6a16d)._0x90dc17("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(_0xf6a16d)._0x90dc17("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisManager() {
        require(IPermissionsRegistry(_0xf6a16d)._0x90dc17("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
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
    function _0x065597(address _0x3cd0fc) external VoterAdmin {
        require(_0x3cd0fc.code.length > 0, "CODELEN");
        require(_0x3cd0fc != address(0), "ZA");
        emit SetPermissionRegistry(_0xf6a16d, _0x3cd0fc);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xf6a16d = _0x3cd0fc; }
    }

    function _0xc4c1c7(uint256 _0x4628c7) external VoterAdmin {
        require (_0x4628c7 >= MIN_VOTING_NUM, "LOW_VOTE");
        if (gasleft() > 0) { _0x4c4c24 = _0x4628c7; }
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Reset the votes of a given TokenID
    function _0xc8b62d(uint256 _0xb31ea4) external _0xb908d3(_0xb31ea4) _0xf8ddd5 {
        require(IVotingEscrow(_0x860d5e)._0x7c6b8b(msg.sender, _0xb31ea4), "NAO");
        _0x5a9771(_0xb31ea4);
        IVotingEscrow(_0x860d5e)._0x2204dd(_0xb31ea4);
    }

    function _0x5a9771(uint256 _0xb31ea4) internal {
        address[] storage _0x625b05 = _0xb23c34[_0xb31ea4];
        uint256 _0x1c5b04 = _0x625b05.length;
        uint256 _0x7d6f5b = 0;

        for (uint256 i = 0; i < _0x1c5b04; i ++) {
            address _0x990e16 = _0x625b05[i];
            uint256 _0x5227a6 = _0x708290[_0xb31ea4][_0x990e16];

            if (_0x5227a6 != 0) {
                _0xbed424[_0x990e16] -= _0x5227a6;

                _0x708290[_0xb31ea4][_0x990e16] -= _0x5227a6;
                address _0xbc34b2 = _0x759855._0xde5efc(_0x990e16);
                address _0x4c54a9 = _0x759855._0x4c2948(_0x990e16);
                IBribe(_0xbc34b2)._0x0aec3e(uint256(_0x5227a6), _0xb31ea4);
                IBribe(_0x4c54a9)._0x0aec3e(uint256(_0x5227a6), _0xb31ea4);

                // decrease totalWeight irrespective of gauge is killed/alive for this current pool
                _0x7d6f5b += _0x5227a6;

                emit Abstained(_0xb31ea4, _0x5227a6);
            }
        }
        _0xa78e2f -= _0x7d6f5b;
        _0xa147d8[_0xb31ea4] = 0;
        delete _0xb23c34[_0xb31ea4];
    }

    /// @notice Recast the saved votes of a given TokenID
    function _0x179d89(uint256 _0xb31ea4) external _0xf8ddd5 {
        uint256 _0x9dec9f = block.timestamp;
        if (_0x9dec9f <= HybraTimeLibrary._0xb001ac(_0x9dec9f)){
            revert("DW");
        }
        require(IVotingEscrow(_0x860d5e)._0x7c6b8b(msg.sender, _0xb31ea4) || msg.sender == _0x860d5e, "NAO||VE");
        address[] memory _0x625b05 = _0xb23c34[_0xb31ea4];
        uint256 _0x0fbbdc = _0x625b05.length;
        uint256[] memory _0x4070f3 = new uint256[](_0x0fbbdc);

        for (uint256 i = 0; i < _0x0fbbdc; i ++) {
            _0x4070f3[i] = _0x708290[_0xb31ea4][_0x625b05[i]];
        }

        _0x3d3fb7(_0xb31ea4, _0x625b05, _0x4070f3);
    }

    /// @notice Vote for pools
    /// @param  _tokenId    veNFT tokenID used to vote
    /// @param  _poolVote   array of LPs addresses to vote  (eg.: [sAMM usdc-usdt   , sAMM busd-usdt, vAMM wbnb-the ,...])
    /// @param  _weights    array of weights for each LPs   (eg.: [10               , 90            , 45             ,...])
    function _0xad7e4d(uint256 _0xb31ea4, address[] calldata _0x625b05, uint256[] calldata _0x4070f3)
        external _0xb908d3(_0xb31ea4) _0xf8ddd5 {
        require(IVotingEscrow(_0x860d5e)._0x7c6b8b(msg.sender, _0xb31ea4), "NAO");
        require(_0x625b05.length == _0x4070f3.length, "MISMATCH_LEN");
        require(_0x625b05.length <= _0x4c4c24, "EXCEEDS");
        uint256 _0x9dec9f = block.timestamp;

        _0x3d3fb7(_0xb31ea4, _0x625b05, _0x4070f3);
        _0x948524[_0xb31ea4] = HybraTimeLibrary._0x32dd54(block.timestamp) + 1;
        _0xbecbee[_0xb31ea4] = block.timestamp;
    }

    function _0x3d3fb7(uint256 _0xb31ea4, address[] memory _0x625b05, uint256[] memory _0x4070f3) internal {
        _0x5a9771(_0xb31ea4);
        uint256 _0x0fbbdc = _0x625b05.length;
        uint256 _0xb0ea27 = IVotingEscrow(_0x860d5e)._0x44078c(_0xb31ea4);
        uint256 _0xeb7230 = 0;
        uint256 _0x1a6c14 = 0;

        for (uint i = 0; i < _0x0fbbdc; i++) {

            if(_0x759855._0x3ac178(_0x625b05[i])) _0xeb7230 += _0x4070f3[i];
        }

        for (uint256 i = 0; i < _0x0fbbdc; i++) {
            address _0x990e16 = _0x625b05[i];

            if (_0x759855._0x3ac178(_0x990e16)) {
                uint256 _0xc64a8a = _0x4070f3[i] * _0xb0ea27 / _0xeb7230;

                require(_0x708290[_0xb31ea4][_0x990e16] == 0, "ZV");
                require(_0xc64a8a != 0, "ZV");

                _0xb23c34[_0xb31ea4].push(_0x990e16);
                _0xbed424[_0x990e16] += _0xc64a8a;

                _0x708290[_0xb31ea4][_0x990e16] = _0xc64a8a;
                address _0xbc34b2 = _0x759855._0xde5efc(_0x990e16);
                address _0x4c54a9 = _0x759855._0x4c2948(_0x990e16);

                IBribe(_0xbc34b2)._0xd454b1(uint256(_0xc64a8a), _0xb31ea4);
                IBribe(_0x4c54a9)._0xd454b1(uint256(_0xc64a8a), _0xb31ea4);

                _0x1a6c14 += _0xc64a8a;
                emit Voted(msg.sender, _0xb31ea4, _0xc64a8a);
            }
        }
        if (_0x1a6c14 > 0) IVotingEscrow(_0x860d5e)._0xa1c58b(_0xb31ea4);
        _0xa78e2f += _0x1a6c14;
        _0xa147d8[_0xb31ea4] = _0x1a6c14;
    }

    modifier _0xb908d3(uint256 _0xb31ea4) {
        // ensure new epoch since last vote
        if (HybraTimeLibrary._0x32dd54(block.timestamp) <= _0x948524[_0xb31ea4]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary._0xb001ac(block.timestamp)) revert("DW");
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
        return _0x759855._0x13f2bd().length;
    }

    /// @notice view the total length of the voted pools given a tokenId
    function _0xeb0ac8(uint256 _0x8d1ff2) external view returns(uint256) {
        return _0xb23c34[_0x8d1ff2].length;
    }

    function _0xd225fd(address _0x68300d) external VoterAdmin {
        require(_0x68300d != address(0));
        _0x759855 = IGaugeManager(_0x68300d);
    }

}