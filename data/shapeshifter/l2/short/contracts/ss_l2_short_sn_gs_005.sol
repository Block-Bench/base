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

    address public bl;                                         // the ve token that governs these contracts
    address internal bi;                                      // $the token
    address public f;                          // registry to check accesses
    address public s;
    uint256 public x;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public t;

    mapping(uint256 => mapping(address => uint256)) public be;  // nft      => pool     => votes
    mapping(uint256 => address[]) public al;                 // nft      => pools

    mapping(address => uint256) public ap;
    uint256 public ae;
    mapping(uint256 => uint256) public ad;

    mapping(uint256 => uint256) public aj;                     // nft      => timestamp of last vote (this is shifted to thursday of that epoc)
    mapping(uint256 => uint256) public g;            // nft      => timestamp of last vote

    event Voted(address indexed bc, uint256 at, uint256 aw);
    event Abstained(uint256 at, uint256 aw);
    event SetPermissionRegistry(address indexed bk, address indexed av);

    constructor() {}

    // function initialize(address __ve, address _pairFactory, address  _gaugeFactory, address _bribes, address _tokenHandler) initializer public {
    function ah(
        address __ve,
        address p,
        address q,
        address e
    ) public aa {
        __Ownable_init();
        __ReentrancyGuard_init();
        bl = __ve;
        bi = IVotingEscrow(__ve).bg();
        t = IGaugeManager(q);
        f = e;
        s = p;
        x = 30;
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
        require(IPermissionsRegistry(f).au("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(f).au("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisManager() {
        require(IPermissionsRegistry(f).au("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
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
    function c(address e) external VoterAdmin {
        require(e.code.length > 0, "CODELEN");
        require(e != address(0), "ZA");
        emit SetPermissionRegistry(f, e);
        f = e;
    }

    function j(uint256 r) external VoterAdmin {
        require (r >= MIN_VOTING_NUM, "LOW_VOTE");
        x = r;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Reset the votes of a given TokenID
    function bd(uint256 ao) external v(ao) u {
        require(IVotingEscrow(bl).h(msg.sender, ao), "NAO");
        ay(ao);
        IVotingEscrow(bl).as(ao);
    }

    function ay(uint256 ao) internal {
        address[] storage ai = al[ao];
        uint256 y = ai.length;
        uint256 z = 0;

        for (uint256 i = 0; i < y; i ++) {
            address ba = ai[i];
            uint256 ax = be[ao][ba];

            if (ax != 0) {
                ap[ba] -= ax;

                be[ao][ba] -= ax;
                address o = t.a(ba);
                address m = t.b(ba);
                IBribe(o).an(uint256(ax), ao);
                IBribe(m).an(uint256(ax), ao);

                // decrease totalWeight irrespective of gauge is killed/alive for this current pool
                z += ax;

                emit Abstained(ao, ax);
            }
        }
        ae -= z;
        ad[ao] = 0;
        delete al[ao];
    }

    /// @notice Recast the saved votes of a given TokenID
    function bh(uint256 ao) external u {
        uint256 af = block.timestamp;
        if (af <= HybraTimeLibrary.n(af)){
            revert("DW");
        }
        require(IVotingEscrow(bl).h(msg.sender, ao) || msg.sender == bl, "NAO||VE");
        address[] memory ai = al[ao];
        uint256 am = ai.length;
        uint256[] memory ak = new uint256[](am);

        for (uint256 i = 0; i < am; i ++) {
            ak[i] = be[ao][ai[i]];
        }

        bf(ao, ai, ak);
    }

    /// @notice Vote for pools
    /// @param  _tokenId    veNFT tokenID used to vote
    /// @param  _poolVote   array of LPs addresses to vote  (eg.: [sAMM usdc-usdt   , sAMM busd-usdt, vAMM wbnb-the ,...])
    /// @param  _weights    array of weights for each LPs   (eg.: [10               , 90            , 45             ,...])
    function bj(uint256 ao, address[] calldata ai, uint256[] calldata ak)
        external v(ao) u {
        require(IVotingEscrow(bl).h(msg.sender, ao), "NAO");
        require(ai.length == ak.length, "MISMATCH_LEN");
        require(ai.length <= x, "EXCEEDS");
        uint256 af = block.timestamp;

        bf(ao, ai, ak);
        aj[ao] = HybraTimeLibrary.ag(block.timestamp) + 1;
        g[ao] = block.timestamp;
    }

    function bf(uint256 ao, address[] memory ai, uint256[] memory ak) internal {
        ay(ao);
        uint256 am = ai.length;
        uint256 aq = IVotingEscrow(bl).w(ao);
        uint256 i = 0;
        uint256 ac = 0;

        for (uint i = 0; i < am; i++) {

            if(t.d(ai[i])) i += ak[i];
        }

        for (uint256 i = 0; i < am; i++) {
            address ba = ai[i];

            if (t.d(ba)) {
                uint256 ab = ak[i] * aq / i;

                require(be[ao][ba] == 0, "ZV");
                require(ab != 0, "ZV");

                al[ao].push(ba);
                ap[ba] += ab;

                be[ao][ba] = ab;
                address o = t.a(ba);
                address m = t.b(ba);

                IBribe(o).ar(uint256(ab), ao);
                IBribe(m).ar(uint256(ab), ao);

                ac += ab;
                emit Voted(msg.sender, ao, ab);
            }
        }
        if (ac > 0) IVotingEscrow(bl).az(ao);
        ae += ac;
        ad[ao] = ac;
    }

    modifier v(uint256 ao) {
        // ensure new epoch since last vote
        if (HybraTimeLibrary.ag(block.timestamp) <= aj[ao]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary.n(block.timestamp)) revert("DW");
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
        return t.bb().length;
    }

    /// @notice view the total length of the voted pools given a tokenId
    function l(uint256 at) external view returns(uint256) {
        return al[at].length;
    }

    function k(address q) external VoterAdmin {
        require(q != address(0));
        t = IGaugeManager(q);
    }

}