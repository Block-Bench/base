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

    address public bk;
    address internal bh;
    address public f;
    address public u;
    uint256 public w;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public t;

    mapping(uint256 => mapping(address => uint256)) public be;
    mapping(uint256 => address[]) public an;

    mapping(address => uint256) public aq;
    uint256 public ae;
    mapping(uint256 => uint256) public ab;

    mapping(uint256 => uint256) public aj;
    mapping(uint256 => uint256) public g;

    event Voted(address indexed bb, uint256 as, uint256 aw);
    event Abstained(uint256 as, uint256 aw);
    event SetPermissionRegistry(address indexed bl, address indexed az);

    constructor() {}


    function ah(
        address __ve,
        address p,
        address r,
        address d
    ) public ac {
        __Ownable_init();
        __ReentrancyGuard_init();
        bk = __ve;
        bh = IVotingEscrow(__ve).ba();
        t = IGaugeManager(r);
        f = d;
        u = p;
        w = 30;
        EPOCH_DURATION = HybraTimeLibrary.WEEK;
    }


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


    function c(address d) external VoterAdmin {
        require(d.code.length > 0, "CODELEN");
        require(d != address(0), "ZA");
        emit SetPermissionRegistry(f, d);
        f = d;
    }

    function j(uint256 q) external VoterAdmin {
        require (q >= MIN_VOTING_NUM, "LOW_VOTE");
        w = q;
    }


    function bg(uint256 ak) external z(ak) y {
        require(IVotingEscrow(bk).h(msg.sender, ak), "NAO");
        ax(ak);
        IVotingEscrow(bk).ar(ak);
    }

    function ax(uint256 ak) internal {
        address[] storage ai = an[ak];
        uint256 s = ai.length;
        uint256 v = 0;

        for (uint256 i = 0; i < s; i ++) {
            address bf = ai[i];
            uint256 av = be[ak][bf];

            if (av != 0) {
                aq[bf] -= av;

                be[ak][bf] -= av;
                address n = t.a(bf);
                address o = t.b(bf);
                IBribe(n).ao(uint256(av), ak);
                IBribe(o).ao(uint256(av), ak);


                v += av;

                emit Abstained(ak, av);
            }
        }
        ae -= v;
        ab[ak] = 0;
        delete an[ak];
    }


    function bi(uint256 ak) external y {
        uint256 af = block.timestamp;
        if (af <= HybraTimeLibrary.l(af)){
            revert("DW");
        }
        require(IVotingEscrow(bk).h(msg.sender, ak) || msg.sender == bk, "NAO||VE");
        address[] memory ai = an[ak];
        uint256 al = ai.length;
        uint256[] memory am = new uint256[](al);

        for (uint256 i = 0; i < al; i ++) {
            am[i] = be[ak][ai[i]];
        }

        bd(ak, ai, am);
    }


    function bj(uint256 ak, address[] calldata ai, uint256[] calldata am)
        external z(ak) y {
        require(IVotingEscrow(bk).h(msg.sender, ak), "NAO");
        require(ai.length == am.length, "MISMATCH_LEN");
        require(ai.length <= w, "EXCEEDS");
        uint256 af = block.timestamp;

        bd(ak, ai, am);
        aj[ak] = HybraTimeLibrary.ag(block.timestamp) + 1;
        g[ak] = block.timestamp;
    }

    function bd(uint256 ak, address[] memory ai, uint256[] memory am) internal {
        ax(ak);
        uint256 al = ai.length;
        uint256 at = IVotingEscrow(bk).x(ak);
        uint256 i = 0;
        uint256 ad = 0;

        for (uint i = 0; i < al; i++) {

            if(t.e(ai[i])) i += am[i];
        }

        for (uint256 i = 0; i < al; i++) {
            address bf = ai[i];

            if (t.e(bf)) {
                uint256 aa = am[i] * at / i;

                require(be[ak][bf] == 0, "ZV");
                require(aa != 0, "ZV");

                an[ak].push(bf);
                aq[bf] += aa;

                be[ak][bf] = aa;
                address n = t.a(bf);
                address o = t.b(bf);

                IBribe(n).ap(uint256(aa), ak);
                IBribe(o).ap(uint256(aa), ak);

                ad += aa;
                emit Voted(msg.sender, ak, aa);
            }
        }
        if (ad > 0) IVotingEscrow(bk).ay(ak);
        ae += ad;
        ab[ak] = ad;
    }

    modifier z(uint256 ak) {

        if (HybraTimeLibrary.ag(block.timestamp) <= aj[ak]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary.l(block.timestamp)) revert("DW");
        _;
    }


    function length() external view returns (uint256) {
        return t.bc().length;
    }


    function m(uint256 as) external view returns(uint256) {
        return an[as].length;
    }

    function k(address r) external VoterAdmin {
        require(r != address(0));
        t = IGaugeManager(r);
    }

}