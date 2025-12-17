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

    address public _0x6fa09b;                                         // the ve token that governs these contracts
    address internal _0x7d440d;                                      // $the token
    address public _0xddf6fa;                          // registry to check accesses
    address public _0x9619d2;
    uint256 public _0xf30a34;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public _0x274bc7;

    mapping(uint256 => mapping(address => uint256)) public _0x54fde2;  // nft      => pool     => votes
    mapping(uint256 => address[]) public _0x68a852;                 // nft      => pools

    mapping(address => uint256) public _0x2fcb25;
    uint256 public _0xcc7489;
    mapping(uint256 => uint256) public _0xecf93c;

    mapping(uint256 => uint256) public _0xcd4c8b;                     // nft      => timestamp of last vote (this is shifted to thursday of that epoc)
    mapping(uint256 => uint256) public _0x6b27c3;            // nft      => timestamp of last vote

    event Voted(address indexed _0xd6e28c, uint256 _0xda489b, uint256 _0x22d0a2);
    event Abstained(uint256 _0xda489b, uint256 _0x22d0a2);
    event SetPermissionRegistry(address indexed _0x940bc7, address indexed _0x928650);

    constructor() {}

    // function initialize(address __ve, address _pairFactory, address  _gaugeFactory, address _bribes, address _tokenHandler) initializer public {
    function _0x4cd392(
        address __ve,
        address _0x1e1518,
        address _0xb01f3d,
        address _0x2895d9
    ) public _0xac4ba8 {
        __Ownable_init();
        __ReentrancyGuard_init();
        _0x6fa09b = __ve;
        if (gasleft() > 0) { _0x7d440d = IVotingEscrow(__ve)._0xbebe92(); }
        _0x274bc7 = IGaugeManager(_0xb01f3d);
        _0xddf6fa = _0x2895d9;
        _0x9619d2 = _0x1e1518;
        if (gasleft() > 0) { _0xf30a34 = 30; }
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
        require(IPermissionsRegistry(_0xddf6fa)._0x8beed8("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(_0xddf6fa)._0x8beed8("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisManager() {
        require(IPermissionsRegistry(_0xddf6fa)._0x8beed8("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
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
    function _0x6cc6cc(address _0x2895d9) external VoterAdmin {
        require(_0x2895d9.code.length > 0, "CODELEN");
        require(_0x2895d9 != address(0), "ZA");
        emit SetPermissionRegistry(_0xddf6fa, _0x2895d9);
        _0xddf6fa = _0x2895d9;
    }

    function _0x15df49(uint256 _0xf959e4) external VoterAdmin {
        require (_0xf959e4 >= MIN_VOTING_NUM, "LOW_VOTE");
        _0xf30a34 = _0xf959e4;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Reset the votes of a given TokenID
    function _0xadf2bb(uint256 _0x5dc30e) external _0xf8cee0(_0x5dc30e) _0x13c365 {
        require(IVotingEscrow(_0x6fa09b)._0x1a78bc(msg.sender, _0x5dc30e), "NAO");
        _0x1064c0(_0x5dc30e);
        IVotingEscrow(_0x6fa09b)._0x858603(_0x5dc30e);
    }

    function _0x1064c0(uint256 _0x5dc30e) internal {
        address[] storage _0x387252 = _0x68a852[_0x5dc30e];
        uint256 _0xd8e50b = _0x387252.length;
        uint256 _0x14b8fa = 0;

        for (uint256 i = 0; i < _0xd8e50b; i ++) {
            address _0x13ccf4 = _0x387252[i];
            uint256 _0xb121cb = _0x54fde2[_0x5dc30e][_0x13ccf4];

            if (_0xb121cb != 0) {
                _0x2fcb25[_0x13ccf4] -= _0xb121cb;

                _0x54fde2[_0x5dc30e][_0x13ccf4] -= _0xb121cb;
                address _0x4634e7 = _0x274bc7._0xa361b1(_0x13ccf4);
                address _0xc3fbb6 = _0x274bc7._0x8798e4(_0x13ccf4);
                IBribe(_0x4634e7)._0x4fd59e(uint256(_0xb121cb), _0x5dc30e);
                IBribe(_0xc3fbb6)._0x4fd59e(uint256(_0xb121cb), _0x5dc30e);

                // decrease totalWeight irrespective of gauge is killed/alive for this current pool
                _0x14b8fa += _0xb121cb;

                emit Abstained(_0x5dc30e, _0xb121cb);
            }
        }
        _0xcc7489 -= _0x14b8fa;
        _0xecf93c[_0x5dc30e] = 0;
        delete _0x68a852[_0x5dc30e];
    }

    /// @notice Recast the saved votes of a given TokenID
    function _0x563058(uint256 _0x5dc30e) external _0x13c365 {
        uint256 _0x9c1191 = block.timestamp;
        if (_0x9c1191 <= HybraTimeLibrary._0x708539(_0x9c1191)){
            revert("DW");
        }
        require(IVotingEscrow(_0x6fa09b)._0x1a78bc(msg.sender, _0x5dc30e) || msg.sender == _0x6fa09b, "NAO||VE");
        address[] memory _0x387252 = _0x68a852[_0x5dc30e];
        uint256 _0x4b6967 = _0x387252.length;
        uint256[] memory _0x2b4332 = new uint256[](_0x4b6967);

        for (uint256 i = 0; i < _0x4b6967; i ++) {
            _0x2b4332[i] = _0x54fde2[_0x5dc30e][_0x387252[i]];
        }

        _0x5edc85(_0x5dc30e, _0x387252, _0x2b4332);
    }

    /// @notice Vote for pools
    /// @param  _tokenId    veNFT tokenID used to vote
    /// @param  _poolVote   array of LPs addresses to vote  (eg.: [sAMM usdc-usdt   , sAMM busd-usdt, vAMM wbnb-the ,...])
    /// @param  _weights    array of weights for each LPs   (eg.: [10               , 90            , 45             ,...])
    function _0x2ba2ec(uint256 _0x5dc30e, address[] calldata _0x387252, uint256[] calldata _0x2b4332)
        external _0xf8cee0(_0x5dc30e) _0x13c365 {
        require(IVotingEscrow(_0x6fa09b)._0x1a78bc(msg.sender, _0x5dc30e), "NAO");
        require(_0x387252.length == _0x2b4332.length, "MISMATCH_LEN");
        require(_0x387252.length <= _0xf30a34, "EXCEEDS");
        uint256 _0x9c1191 = block.timestamp;

        _0x5edc85(_0x5dc30e, _0x387252, _0x2b4332);
        _0xcd4c8b[_0x5dc30e] = HybraTimeLibrary._0xf6485f(block.timestamp) + 1;
        _0x6b27c3[_0x5dc30e] = block.timestamp;
    }

    function _0x5edc85(uint256 _0x5dc30e, address[] memory _0x387252, uint256[] memory _0x2b4332) internal {
        _0x1064c0(_0x5dc30e);
        uint256 _0x4b6967 = _0x387252.length;
        uint256 _0xa69d4e = IVotingEscrow(_0x6fa09b)._0x227cb5(_0x5dc30e);
        uint256 _0x71db0f = 0;
        uint256 _0x7f7007 = 0;

        for (uint i = 0; i < _0x4b6967; i++) {

            if(_0x274bc7._0x7971d3(_0x387252[i])) _0x71db0f += _0x2b4332[i];
        }

        for (uint256 i = 0; i < _0x4b6967; i++) {
            address _0x13ccf4 = _0x387252[i];

            if (_0x274bc7._0x7971d3(_0x13ccf4)) {
                uint256 _0x88fa47 = _0x2b4332[i] * _0xa69d4e / _0x71db0f;

                require(_0x54fde2[_0x5dc30e][_0x13ccf4] == 0, "ZV");
                require(_0x88fa47 != 0, "ZV");

                _0x68a852[_0x5dc30e].push(_0x13ccf4);
                _0x2fcb25[_0x13ccf4] += _0x88fa47;

                _0x54fde2[_0x5dc30e][_0x13ccf4] = _0x88fa47;
                address _0x4634e7 = _0x274bc7._0xa361b1(_0x13ccf4);
                address _0xc3fbb6 = _0x274bc7._0x8798e4(_0x13ccf4);

                IBribe(_0x4634e7)._0xc077e7(uint256(_0x88fa47), _0x5dc30e);
                IBribe(_0xc3fbb6)._0xc077e7(uint256(_0x88fa47), _0x5dc30e);

                _0x7f7007 += _0x88fa47;
                emit Voted(msg.sender, _0x5dc30e, _0x88fa47);
            }
        }
        if (_0x7f7007 > 0) IVotingEscrow(_0x6fa09b)._0x9594f4(_0x5dc30e);
        _0xcc7489 += _0x7f7007;
        _0xecf93c[_0x5dc30e] = _0x7f7007;
    }

    modifier _0xf8cee0(uint256 _0x5dc30e) {
        // ensure new epoch since last vote
        if (HybraTimeLibrary._0xf6485f(block.timestamp) <= _0xcd4c8b[_0x5dc30e]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary._0x708539(block.timestamp)) revert("DW");
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
        return _0x274bc7._0x688fd9().length;
    }

    /// @notice view the total length of the voted pools given a tokenId
    function _0x5957d2(uint256 _0xda489b) external view returns(uint256) {
        return _0x68a852[_0xda489b].length;
    }

    function _0x9a8b39(address _0xb01f3d) external VoterAdmin {
        require(_0xb01f3d != address(0));
        if (true) { _0x274bc7 = IGaugeManager(_0xb01f3d); }
    }

}