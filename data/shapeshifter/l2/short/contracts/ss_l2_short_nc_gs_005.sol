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
    address public g;
    address public v;
    uint256 public w;
    uint public EPOCH_DURATION;
    uint256 internal constant MIN_VOTING_NUM = 10;
    IGaugeManager public t;

    mapping(uint256 => mapping(address => uint256)) public ba;
    mapping(uint256 => address[]) public am;

    mapping(address => uint256) public ap;
    uint256 public ad;
    mapping(uint256 => uint256) public aa;

    mapping(uint256 => uint256) public aj;
    mapping(uint256 => uint256) public f;

    event Voted(address indexed bb, uint256 as, uint256 av);
    event Abstained(uint256 as, uint256 av);
    event SetPermissionRegistry(address indexed bl, address indexed az);

    constructor() {}


    function af(
        address __ve,
        address q,
        address r,
        address e
    ) public ab {
        __Ownable_init();
        __ReentrancyGuard_init();
        bk = __ve;
        bh = IVotingEscrow(__ve).bf();
        t = IGaugeManager(r);
        g = e;
        v = q;
        w = 30;
        EPOCH_DURATION = HybraTimeLibrary.WEEK;
    }


    modifier VoterAdmin() {
        require(IPermissionsRegistry(g).au("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(g).au("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisManager() {
        require(IPermissionsRegistry(g).au("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
        _;
    }


    function c(address e) external VoterAdmin {
        require(e.code.length > 0, "CODELEN");
        require(e != address(0), "ZA");
        emit SetPermissionRegistry(g, e);
        g = e;
    }

    function k(uint256 p) external VoterAdmin {
        require (p >= MIN_VOTING_NUM, "LOW_VOTE");
        w = p;
    }


    function be(uint256 ao) external z(ao) y {
        require(IVotingEscrow(bk).h(msg.sender, ao), "NAO");
        aw(ao);
        IVotingEscrow(bk).ar(ao);
    }

    function aw(uint256 ao) internal {
        address[] storage ai = am[ao];
        uint256 s = ai.length;
        uint256 u = 0;

        for (uint256 i = 0; i < s; i ++) {
            address bg = ai[i];
            uint256 ay = ba[ao][bg];

            if (ay != 0) {
                ap[bg] -= ay;

                ba[ao][bg] -= ay;
                address o = t.b(bg);
                address m = t.a(bg);
                IBribe(o).al(uint256(ay), ao);
                IBribe(m).al(uint256(ay), ao);


                u += ay;

                emit Abstained(ao, ay);
            }
        }
        ad -= u;
        aa[ao] = 0;
        delete am[ao];
    }


    function bi(uint256 ao) external y {
        uint256 ag = block.timestamp;
        if (ag <= HybraTimeLibrary.n(ag)){
            revert("DW");
        }
        require(IVotingEscrow(bk).h(msg.sender, ao) || msg.sender == bk, "NAO||VE");
        address[] memory ai = am[ao];
        uint256 ak = ai.length;
        uint256[] memory an = new uint256[](ak);

        for (uint256 i = 0; i < ak; i ++) {
            an[i] = ba[ao][ai[i]];
        }

        bd(ao, ai, an);
    }


    function bj(uint256 ao, address[] calldata ai, uint256[] calldata an)
        external z(ao) y {
        require(IVotingEscrow(bk).h(msg.sender, ao), "NAO");
        require(ai.length == an.length, "MISMATCH_LEN");
        require(ai.length <= w, "EXCEEDS");
        uint256 ag = block.timestamp;

        bd(ao, ai, an);
        aj[ao] = HybraTimeLibrary.ah(block.timestamp) + 1;
        f[ao] = block.timestamp;
    }

    function bd(uint256 ao, address[] memory ai, uint256[] memory an) internal {
        aw(ao);
        uint256 ak = ai.length;
        uint256 at = IVotingEscrow(bk).x(ao);
        uint256 i = 0;
        uint256 ae = 0;

        for (uint i = 0; i < ak; i++) {

            if(t.d(ai[i])) i += an[i];
        }

        for (uint256 i = 0; i < ak; i++) {
            address bg = ai[i];

            if (t.d(bg)) {
                uint256 ac = an[i] * at / i;

                require(ba[ao][bg] == 0, "ZV");
                require(ac != 0, "ZV");

                am[ao].push(bg);
                ap[bg] += ac;

                ba[ao][bg] = ac;
                address o = t.b(bg);
                address m = t.a(bg);

                IBribe(o).aq(uint256(ac), ao);
                IBribe(m).aq(uint256(ac), ao);

                ae += ac;
                emit Voted(msg.sender, ao, ac);
            }
        }
        if (ae > 0) IVotingEscrow(bk).ax(ao);
        ad += ae;
        aa[ao] = ae;
    }

    modifier z(uint256 ao) {

        if (HybraTimeLibrary.ah(block.timestamp) <= aj[ao]) revert("VOTED");
        if (block.timestamp <= HybraTimeLibrary.n(block.timestamp)) revert("DW");
        _;
    }


    function length() external view returns (uint256) {
        return t.bc().length;
    }


    function l(uint256 as) external view returns(uint256) {
        return am[as].length;
    }

    function j(address r) external VoterAdmin {
        require(r != address(0));
        t = IGaugeManager(r);
    }

}