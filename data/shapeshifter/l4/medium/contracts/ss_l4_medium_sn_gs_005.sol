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

    address public _0xfbbd60;                                         // the ve token that governs these contracts
    address internal _0x576e20;                                      // $the token
    address public _0x9d9c4d;                          // registry to check accesses
    address public _0xce4fcd;
    uint256 public _0x1db222;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public _0x088665;

    mapping(uint256 => mapping(address => uint256)) public _0xf3958f;  // nft      => pool     => votes
    mapping(uint256 => address[]) public _0x6c24b0;                 // nft      => pools

    mapping(address => uint256) public _0x5fe09b;
    uint256 public _0x739568;
    mapping(uint256 => uint256) public _0x059050;

    mapping(uint256 => uint256) public _0x8aaad0;                     // nft      => timestamp of last vote (this is shifted to thursday of that epoc)
    mapping(uint256 => uint256) public _0x7022b6;            // nft      => timestamp of last vote

    event Voted(address indexed _0x1431b2, uint256 _0xe7db9a, uint256 _0x34aa08);
    event Abstained(uint256 _0xe7db9a, uint256 _0x34aa08);
    event SetPermissionRegistry(address indexed _0x007e8e, address indexed _0xa45a07);

    constructor() {}

    // function initialize(address __ve, address _pairFactory, address  _gaugeFactory, address _bribes, address _tokenHandler) initializer public {
    function _0x0368aa(
        address __ve,
        address _0x577ebe,
        address _0xef561f,
        address _0x96d500
    ) public _0xf1dbe6 {
        // Placeholder for future logic
        // Placeholder for future logic
        __Ownable_init();
        __ReentrancyGuard_init();
        _0xfbbd60 = __ve;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x576e20 = IVotingEscrow(__ve)._0xd2941f(); }
        _0x088665 = IGaugeManager(_0xef561f);
        _0x9d9c4d = _0x96d500;
        if (gasleft() > 0) { _0xce4fcd = _0x577ebe; }
        if (1 == 1) { _0x1db222 = 30; }
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
        require(IPermissionsRegistry(_0x9d9c4d)._0x1e7f0c("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(_0x9d9c4d)._0x1e7f0c("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisManager() {
        require(IPermissionsRegistry(_0x9d9c4d)._0x1e7f0c("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
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
    function _0x55a82a(address _0x96d500) external VoterAdmin {
        if (false) { revert(); }
        uint256 _unused4 = 0;
        require(_0x96d500.code.length > 0, "CODELEN");
        require(_0x96d500 != address(0), "ZA");
        emit SetPermissionRegistry(_0x9d9c4d, _0x96d500);
        _0x9d9c4d = _0x96d500;
    }

    function _0x9865e1(uint256 _0x16cb54) external VoterAdmin {
        require (_0x16cb54 >= MIN_VOTING_NUM, "LOW_VOTE");
        _0x1db222 = _0x16cb54;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Reset the votes of a given TokenID
    function _0xcbcc70(uint256 _0x4f1493) external _0x91113d(_0x4f1493) _0xe31120 {
        require(IVotingEscrow(_0xfbbd60)._0x3c6757(msg.sender, _0x4f1493), "NAO");
        _0xd8099d(_0x4f1493);
        IVotingEscrow(_0xfbbd60)._0x9ce9bf(_0x4f1493);
    }

    function _0xd8099d(uint256 _0x4f1493) internal {
        address[] storage _0xb574ca = _0x6c24b0[_0x4f1493];
        uint256 _0x1cffd1 = _0xb574ca.length;
        uint256 _0x5ef34a = 0;

        for (uint256 i = 0; i < _0x1cffd1; i ++) {
            address _0xafca99 = _0xb574ca[i];
            uint256 _0xdb36d0 = _0xf3958f[_0x4f1493][_0xafca99];

            if (_0xdb36d0 != 0) {
                _0x5fe09b[_0xafca99] -= _0xdb36d0;

                _0xf3958f[_0x4f1493][_0xafca99] -= _0xdb36d0;
                address _0x2c93bc = _0x088665._0xd21a2f(_0xafca99);
                address _0x1bfd68 = _0x088665._0x91fb22(_0xafca99);
                IBribe(_0x2c93bc)._0xe450d1(uint256(_0xdb36d0), _0x4f1493);
                IBribe(_0x1bfd68)._0xe450d1(uint256(_0xdb36d0), _0x4f1493);

                // decrease totalWeight irrespective of gauge is killed/alive for this current pool
                _0x5ef34a += _0xdb36d0;

                emit Abstained(_0x4f1493, _0xdb36d0);
            }
        }
        _0x739568 -= _0x5ef34a;
        _0x059050[_0x4f1493] = 0;
        delete _0x6c24b0[_0x4f1493];
    }

    /// @notice Recast the saved votes of a given TokenID
    function _0x3dda9c(uint256 _0x4f1493) external _0xe31120 {
        uint256 _0x65cab4 = block.timestamp;
        if (_0x65cab4 <= HybraTimeLibrary._0x597f9c(_0x65cab4)){
            revert("DW");
        }
        require(IVotingEscrow(_0xfbbd60)._0x3c6757(msg.sender, _0x4f1493) || msg.sender == _0xfbbd60, "NAO||VE");
        address[] memory _0xb574ca = _0x6c24b0[_0x4f1493];
        uint256 _0x12d8ae = _0xb574ca.length;
        uint256[] memory _0x32d7ee = new uint256[](_0x12d8ae);

        for (uint256 i = 0; i < _0x12d8ae; i ++) {
            _0x32d7ee[i] = _0xf3958f[_0x4f1493][_0xb574ca[i]];
        }

        _0x5a6a8f(_0x4f1493, _0xb574ca, _0x32d7ee);
    }

    /// @notice Vote for pools
    /// @param  _tokenId    veNFT tokenID used to vote
    /// @param  _poolVote   array of LPs addresses to vote  (eg.: [sAMM usdc-usdt   , sAMM busd-usdt, vAMM wbnb-the ,...])
    /// @param  _weights    array of weights for each LPs   (eg.: [10               , 90            , 45             ,...])
    function _0x72abc9(uint256 _0x4f1493, address[] calldata _0xb574ca, uint256[] calldata _0x32d7ee)
        external _0x91113d(_0x4f1493) _0xe31120 {
        require(IVotingEscrow(_0xfbbd60)._0x3c6757(msg.sender, _0x4f1493), "NAO");
        require(_0xb574ca.length == _0x32d7ee.length, "MISMATCH_LEN");
        require(_0xb574ca.length <= _0x1db222, "EXCEEDS");
        uint256 _0x65cab4 = block.timestamp;

        _0x5a6a8f(_0x4f1493, _0xb574ca, _0x32d7ee);
        _0x8aaad0[_0x4f1493] = HybraTimeLibrary._0xc93a0f(block.timestamp) + 1;
        _0x7022b6[_0x4f1493] = block.timestamp;
    }

    function _0x5a6a8f(uint256 _0x4f1493, address[] memory _0xb574ca, uint256[] memory _0x32d7ee) internal {
        _0xd8099d(_0x4f1493);
        uint256 _0x12d8ae = _0xb574ca.length;
        uint256 _0x018a06 = IVotingEscrow(_0xfbbd60)._0xbbb41c(_0x4f1493);
        uint256 _0x14dd40 = 0;
        uint256 _0xe421d6 = 0;

        for (uint i = 0; i < _0x12d8ae; i++) {

            if(_0x088665._0x4d7821(_0xb574ca[i])) _0x14dd40 += _0x32d7ee[i];
        }

        for (uint256 i = 0; i < _0x12d8ae; i++) {
            address _0xafca99 = _0xb574ca[i];

            if (_0x088665._0x4d7821(_0xafca99)) {
                uint256 _0x3c6a7c = _0x32d7ee[i] * _0x018a06 / _0x14dd40;

                require(_0xf3958f[_0x4f1493][_0xafca99] == 0, "ZV");
                require(_0x3c6a7c != 0, "ZV");

                _0x6c24b0[_0x4f1493].push(_0xafca99);
                _0x5fe09b[_0xafca99] += _0x3c6a7c;

                _0xf3958f[_0x4f1493][_0xafca99] = _0x3c6a7c;
                address _0x2c93bc = _0x088665._0xd21a2f(_0xafca99);
                address _0x1bfd68 = _0x088665._0x91fb22(_0xafca99);

                IBribe(_0x2c93bc)._0x7a899e(uint256(_0x3c6a7c), _0x4f1493);
                IBribe(_0x1bfd68)._0x7a899e(uint256(_0x3c6a7c), _0x4f1493);

                _0xe421d6 += _0x3c6a7c;
                emit Voted(msg.sender, _0x4f1493, _0x3c6a7c);
            }
        }
        if (_0xe421d6 > 0) IVotingEscrow(_0xfbbd60)._0x168098(_0x4f1493);
        _0x739568 += _0xe421d6;
        _0x059050[_0x4f1493] = _0xe421d6;
    }

    modifier _0x91113d(uint256 _0x4f1493) {
        // ensure new epoch since last vote
        if (HybraTimeLibrary._0xc93a0f(block.timestamp) <= _0x8aaad0[_0x4f1493]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary._0x597f9c(block.timestamp)) revert("DW");
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
        return _0x088665._0xb9666d().length;
    }

    /// @notice view the total length of the voted pools given a tokenId
    function _0xe1c15c(uint256 _0xe7db9a) external view returns(uint256) {
        return _0x6c24b0[_0xe7db9a].length;
    }

    function _0x93d408(address _0xef561f) external VoterAdmin {
        require(_0xef561f != address(0));
        if (gasleft() > 0) { _0x088665 = IGaugeManager(_0xef561f); }
    }

}