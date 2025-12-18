// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IERC721, IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import "./interfaces/IHybra.sol";
import {IHybraVotes} from "./interfaces/IHybraVotes.sol";
import {IVeArtProxy} from "./interfaces/IVeArtProxy.sol";
import {IVotingEscrow} from "./interfaces/IVotingEscrow.sol";
import {IVoter} from "./interfaces/IVoter.sol";
import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import {VotingDelegationLib} from "./libraries/VotingDelegationLib.sol";
import {VotingBalanceLogic} from "./libraries/VotingBalanceLogic.sol";

/// @title Voting Escrow
/// @notice veNFT implementation that escrows ERC-20 tokens in the form of an ERC-721 NFT
/// @notice Votes have a weight depending on time, so that users are committed to the future of (whatever they are voting for)
/// @author Modified from Solidly (https://github.com/solidlyexchange/solidly/blob/master/contracts/ve.sol)
/// @author Modified from Curve (https://github.com/curvefi/curve-dao-contracts/blob/master/contracts/VotingEscrow.vy)
/// @author Modified from Nouns DAO (https://github.com/withtally/my-nft-dao-project/blob/main/contracts/ERC721Checkpointable.sol)
/// @dev Vote weight decays linearly over time. Lock time cannot be more than `MAXTIME` (2 years).
contract VotingEscrow is IERC721, IERC721Metadata, IHybraVotes {
    enum DepositType {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(
        address indexed eq,
        uint fm,
        uint value,
        uint indexed ep,
        DepositType cb,
        uint hs
    );

    event Merge(
        address indexed fh,
        uint256 indexed gp,
        uint256 indexed hm,
        uint256 ce,
        uint256 ds,
        uint256 bo,
        uint256 ei,
        uint256 hk
    );
    event Split(
        uint256 indexed gp,
        uint256 indexed dr,
        uint256 indexed dy,
        address fh,
        uint256 bf,
        uint256 bh,
        uint256 ei,
        uint256 hk
    );

    event MultiSplit(
        uint256 indexed gp,
        uint256[] bt,
        address fh,
        uint256[] er,
        uint256 ei,
        uint256 hk
    );

    event MetadataUpdate(uint256 en);
    event BatchMetadataUpdate(uint256 bq, uint256 df);

    event Withdraw(address indexed eq, uint fm, uint value, uint hs);
    event LockPermanent(address indexed gj, uint256 indexed en, uint256 ge, uint256 hk);
    event UnlockPermanent(address indexed gj, uint256 indexed en, uint256 ge, uint256 hk);
    event Supply(uint dg, uint fy);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    address public immutable gv;
    address public hc;
    address public hj;
    address public ej;
    // address public burnTokenAddress=0x000000000000000000000000000000000000dEaD;

    uint public PRECISISON = 10000;

    /// @dev Mapping of interface id to bool about whether or not it's supported
    mapping(bytes4 => bool) internal k;
    mapping(uint => bool) internal ap;

    /// @dev ERC165 interface ID of ERC165
    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    /// @dev ERC165 interface ID of ERC721
    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;

    /// @dev ERC165 interface ID of ERC721Metadata
    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;

    /// @dev Current count of token
    uint internal fm;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal em;
    IHybra public go;

    // Instance of the library's storage struct
    VotingDelegationLib.Data private fz;

    VotingBalanceLogic.Data private d;

    /// @notice Contract constructor
    /// @param token_addr `BLACK` token address
    constructor(address dl, address eb) {
        gv = dl;
        hc = msg.sender;
        hj = msg.sender;
        ej = eb;
        WEEK = HybraTimeLibrary.WEEK;
        MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION;
        em = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION));

        d.bn[0].hp = block.number;
        d.bn[0].hs = block.timestamp;

        k[ERC165_INTERFACE_ID] = true;
        k[ERC721_INTERFACE_ID] = true;
        k[ERC721_METADATA_INTERFACE_ID] = true;
        go = IHybra(gv);

        // mint-ish
        emit Transfer(address(0), address(this), fm);
        // burn-ish
        emit Transfer(address(this), address(0), fm);
    }

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    uint8 internal constant bz = 1;
    uint8 internal constant es = 2;
    uint8 internal au = 1;
    modifier bu() {
        require(au == bz);
        au = es;
        _;
        au = bz;
    }

    modifier be(uint256 en) {
        require(!ap[en], "PNFT");
        _;
    }

    modifier br(uint gp) {
        require(fb[msg.sender] || fb[address(0)], "!SPLIT");
        require(cw[gp] == 0 && !gm[gp], "ATT");
        require(o(msg.sender, gp), "NAO");
        _;
    }

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string constant public hh = "veHYBR";
    string constant public gc = "veHYBR";
    string constant public fp = "1.0.0";
    uint8 constant public eo = 18;

    function fq(address gr) external {
        require(msg.sender == hj);
        hj = gr;
    }

    function co(address fx) external {
        require(msg.sender == hj);
        ej = fx;
        emit BatchMetadataUpdate(0, type(uint256).hn);
    }

    /// @param _tokenId The token ID to modify
    /// @param _isPartner Whether this should be a partner veNFT
    function ag(uint en, bool dc) external {
        require(msg.sender == hj, "NA");
        require(dw[en] != address(0), "DNE");
        ap[en] = dc;
    }

    /// @dev Returns current token URI metadata
    /// @param _tokenId Token ID to fetch URI for.
    function et(uint en) external view returns (string memory) {
        require(dw[en] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory fk = fv[en];

        return IVeArtProxy(ej).ea(en,VotingBalanceLogic.bs(en, block.timestamp, d),fk.hq,uint(int256(fk.ge)));
    }

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to the address that owns it.
    mapping(uint => address) internal dw;

    /// @dev Mapping from owner address to count of his tokens.
    mapping(address => uint) internal j;

    /// @dev Returns the address of the owner of the NFT.
    /// @param _tokenId The identifier for an NFT.
    function fe(uint en) public view returns (address) {
        return dw[en];
    }

    function e(address gz) public view returns (uint) {

        return j[gz];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned p to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function fc(address gj) internal view returns (uint) {
        return j[gj];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function dx(address gj) external view returns (uint) {
        return fc(gj);
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to approved address.
    mapping(uint => address) internal bb;

    /// @dev Mapping from owner address to mapping of operator addresses.
    mapping(address => mapping(address => bool)) internal ad;

    mapping(uint => uint) public ae;

    /// @dev Get the approved address for a single NFT.
    /// @param _tokenId ID of the NFT to query the approval of.
    function cr(uint en) external view returns (address) {
        return bb[en];
    }

    /// @dev Checks if `_operator` is an approved operator for `_owner`.
    /// @param _owner The address that owns the NFTs.
    /// @param _operator The address that acts on behalf of the owner.
    function z(address gj, address dp) external view returns (bool) {
        return (ad[gj])[dp];
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Set or reaffirm the approved address for an NFT. The zero address indicates there is no approved address.
    ///      Throws unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.
    ///      Throws if `_tokenId` is not a valid NFT. (NOTE: This is not written the EIP)
    ///      Throws if `_approved` is the current owner. (NOTE: This is not written the EIP)
    /// @param _approved Address to be approved for the given NFT ID.
    /// @param _tokenId ID of the token to be approved.
    function fi(address ec, uint en) public {
        address gz = dw[en];
        // Throws if `_tokenId` is not a valid NFT
        require(gz != address(0), "ZA");
        // Throws if `_approved` is the current owner
        require(ec != gz, "IA");
        // Check requirements
        bool az = (dw[en] == msg.sender);
        bool c = (ad[gz])[msg.sender];
        require(az || c, "NAO");
        // Set the approval
        bb[en] = ec;
        emit Approval(gz, ec, en);
    }

    /// @dev Enables or disables approval for a third party ("operator") to manage all of
    ///      `msg.sender`'s assets. It also emits the ApprovalForAll event.
    ///      Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
    /// @notice This works even if sender doesn't own any tokens at the time.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval.
    function v(address dp, bool ec) external {
        // Throws if `_operator` is the `msg.sender`
        assert(dp != msg.sender);
        ad[msg.sender][dp] = ec;
        emit ApprovalForAll(msg.sender, dp, ec);
    }

    /* TRANSFER FUNCTIONS */
    /// @dev Clear an approval of a given address
    ///      Throws if `_owner` is not the current owner.
    function at(address gj, uint en) internal {
        // Throws if `_owner` is not the current owner
        assert(dw[en] == gj);
        if (bb[en] != address(0)) {
            // Reset approvals
            bb[en] = address(0);
        }
    }

    /// @dev Returns whether the given spender can transfer a given token ID
    /// @param _spender address of the spender to query
    /// @param _tokenId uint ID of the token to be transferred
    /// @return bool whether the msg.sender is approved for the given token ID, is an operator of the owner, or is the owner of the token
    function o(address ey, uint en) internal view returns (bool) {
        address gz = dw[en];
        bool aq = gz == ey;
        bool u = ey == bb[en];
        bool b = (ad[gz])[ey];
        return aq || u || b;
    }

    function x(address ey, uint en) external view returns (bool) {
        return o(ey, en);
    }

    /// @dev Exeute transfer of a NFT.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
    ///      address for this NFT. (NOTE: `msg.sender` not allowed in internal function so pass `_sender`.)
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_tokenId` is not a valid NFT.
    function bk(
        address gp,
        address hm,
        uint en,
        address fh
    ) internal be(en) {
        require(cw[en] == 0 && !gm[en], "ATT");
        // Check requirements
        require(o(fh, en), "NAO");

        // Clear approval. Throws if `_from` is not the current owner
        at(gp, en);
        // Remove NFT. Throws if `_tokenId` is not a valid NFT
        ab(gp, en);
        // auto re-delegate
        VotingDelegationLib.n(fz, eh(gp), eh(hm), en, fe);
        // Add NFT
        cl(hm, en);
        // Set the block of ownership transfer (for Flash NFT protection)
        ae[en] = block.number;

        // Log the transfer
        emit Transfer(gp, hm, en);
    }

    /// @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_tokenId` is not a valid NFT.
    /// @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
    ///        they maybe be permanently lost.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    function cc(
        address gp,
        address hm,
        uint en
    ) external {
        bk(gp, hm, en, msg.sender);
    }

    /// @dev Transfers the ownership of an NFT from one address to another address.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the
    ///      approved address for this NFT.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_tokenId` is not a valid NFT.
    ///      If `_to` is a smart contract, it calls `onERC721Received` on `_to` and throws if
    ///      the return value is not `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    function aa(
        address gp,
        address hm,
        uint en
    ) external {
        aa(gp, hm, en, "");
    }

    function cn(address ff) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint hi;
        assembly {
            hi := extcodesize(ff)
        }
        return hi > 0;
    }

    /// @dev Transfers the ownership of an NFT from one address to another address.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the
    ///      approved address for this NFT.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_tokenId` is not a valid NFT.
    ///      If `_to` is a smart contract, it calls `onERC721Received` on `_to` and throws if
    ///      the return value is not `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    /// @param _data Additional data with no specified format, sent in call to `_to`.
    function aa(
        address gp,
        address hm,
        uint en,
        bytes memory ha
    ) public {
        bk(gp, hm, en, msg.sender);

        if (cn(hm)) {
            // Throws if transfer destination is a contract which does not implement 'onERC721Received'
            try IERC721Receiver(hm).ac(msg.sender, gp, en, ha) returns (bytes4 ex) {
                if (ex != IERC721Receiver(hm).ac.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory ga) {
                if (ga.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, ga), mload(ga))
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Interface identification is specified in ERC-165.
    /// @param _interfaceID Id of the interface
    function t(bytes4 bw) external view returns (bool) {
        return k[bw];
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from owner address to mapping of index to tokenIds
    mapping(address => mapping(uint => uint)) internal i;

    /// @dev Mapping from NFT ID to index of owner
    mapping(uint => uint) internal s;

    /// @dev  Get token by index
    function m(address gj, uint cm) public view returns (uint) {
        return i[gj][cm];
    }

    /// @dev Add a NFT to an index mapping to a given addressndashushun
    /// @param _to address of the receiver
    /// @param _tokenId uint ID Of the token to be added
    function h(address hm, uint en) internal {
        uint bc = fc(hm);

        i[hm][bc] = en;
        s[en] = bc;
    }

    /// @dev Add a NFT to a given address
    ///      Throws if `_tokenId` is owned by someone.
    function cl(address hm, uint en) internal {
        // Throws if `_tokenId` is owned by someone
        assert(dw[en] == address(0));
        // Change the owner
        dw[en] = hm;
        // Update owner token index tracking
        h(hm, en);
        // Change count tracking
        j[hm] += 1;
    }

    /// @dev Function to mint tokens
    ///      Throws if `_to` is zero address.
    ///      Throws if `_tokenId` is owned by someone.
    /// @param _to The address that will receive the minted tokens.
    /// @param _tokenId The token id to mint.
    /// @return A boolean that indicates if the operation was successful.
    function hb(address hm, uint en) internal returns (bool) {
        // Throws if `_to` is zero address
        assert(hm != address(0));
        // checkpoint for gov
        VotingDelegationLib.n(fz, address(0), eh(hm), en, fe);
        // Add NFT. Throws if `_tokenId` is owned by someone
        cl(hm, en);
        emit Transfer(address(0), hm, en);
        return true;
    }

    /// @dev Remove a NFT from an index mapping to a given address
    /// @param _from address of the sender
    /// @param _tokenId uint ID Of the token to be removed
    function a(address gp, uint en) internal {
        // Delete
        uint bc = fc(gp) - 1;
        uint bm = s[en];

        if (bc == bm) {
            // update ownerToNFTokenIdList
            i[gp][bc] = 0;
            // update tokenToOwnerIndex
            s[en] = 0;
        } else {
            uint cx = i[gp][bc];

            // Add
            // update ownerToNFTokenIdList
            i[gp][bm] = cx;
            // update tokenToOwnerIndex
            s[cx] = bm;

            // Delete
            // update ownerToNFTokenIdList
            i[gp][bc] = 0;
            // update tokenToOwnerIndex
            s[en] = 0;
        }
    }

    /// @dev Remove a NFT from a given address
    ///      Throws if `_from` is not the current owner.
    function ab(address gp, uint en) internal {
        // Throws if `_from` is not the current owner
        assert(dw[en] == gp);
        // Change the owner
        dw[en] = address(0);
        // Update owner token index tracking
        a(gp, en);
        // Change count tracking
        j[gp] -= 1;
    }

    function gt(uint en) internal {
        require(o(msg.sender, en), "NAO");

        address gz = fe(en);

        // Clear approval
        delete bb[en];
        // Remove token
        //_removeTokenFrom(msg.sender, _tokenId);
        ab(gz, en);
        // checkpoint for gov
        VotingDelegationLib.n(fz, eh(gz), address(0), en, fe);

        emit Transfer(gz, address(0), en);
    }

    /*//////////////////////////////////////////////////////////////
                             ESCROW STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint => IVotingEscrow.LockedBalance) public fv;
    uint public g;
    uint public gy;
    mapping(uint => int128) public bi; // time -> signed slope change
    uint public fy;
    mapping(address => bool) public fb;

    uint internal constant MULTIPLIER = 1 ether;

    /*//////////////////////////////////////////////////////////////
                              ESCROW LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the most recently recorded rate of voting power decrease for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @return Value of the slope
    function l(uint en) external view returns (int128) {
        uint fs = d.af[en];
        return d.p[en][fs].gw;
    }

    /// @notice Get the timestamp for checkpoint `_idx` for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function p(uint en, uint he) external view returns (IVotingEscrow.Point memory) {
        return d.p[en][he];
    }

    function bn(uint gy) external view returns (IVotingEscrow.Point memory) {
        return d.bn[gy];
    }

    function af(uint fm) external view returns (uint) {
        return d.af[fm];
    }

    /// @notice Record global and per-user data to checkpoint
    /// @param _tokenId NFT token ID. No user checkpoint if 0
    /// @param old_locked Pevious locked amount / end lock time for the user
    /// @param new_locked New locked amount / end lock time for the user
    function cs(
        uint en,
        IVotingEscrow.LockedBalance memory dk,
        IVotingEscrow.LockedBalance memory di
    ) internal {
        IVotingEscrow.Point memory gs;
        IVotingEscrow.Point memory gq;
        int128 de = 0;
        int128 db = 0;
        uint fu = gy;

        if (en != 0) {
            gq.ee = 0;

            if(di.ct){
                gq.ee = uint(int256(di.ge));
            }

            // Calculate slopes and biases
            // Kept at zero when they have to
            if (dk.hq > block.timestamp && dk.ge > 0) {
                gs.gw = dk.ge / em;
                gs.hf = gs.gw * int128(int256(dk.hq - block.timestamp));
            }
            if (di.hq > block.timestamp && di.ge > 0) {
                gq.gw = di.ge / em;
                gq.hf = gq.gw * int128(int256(di.hq - block.timestamp));
            }

            // Read values of scheduled changes in the slope
            // old_locked.end can be in the past and in the future
            // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            de = bi[dk.hq];
            if (di.hq != 0) {
                if (di.hq == dk.hq) {
                    db = de;
                } else {
                    db = bi[di.hq];
                }
            }
        }

        IVotingEscrow.Point memory da = IVotingEscrow.Point({hf: 0, gw: 0, hs: block.timestamp, hp: block.number, ee: 0});
        if (fu > 0) {
            da = d.bn[fu];
        }
        uint al = da.hs;
        // initial_last_point is used for extrapolation to calculate block number
        // (approximately, for *At methods) and save them
        // as we cannot figure that out exactly from inside the contract
        IVotingEscrow.Point memory q = da;
        uint cg = 0; // dblock/dt
        if (block.timestamp > da.hs) {
            cg = (MULTIPLIER * (block.number - da.hp)) / (block.timestamp - da.hs);
        }
        // If last point is already recorded in this block, slope=0
        // But that's ok b/c we know the block in such case

        // Go over weeks to fill history and calculate what the current point is
        {
            uint ho = (al / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {
                // Hopefully it won't happen that this won't get used in 5 years!
                // If it does, users will be able to withdraw but vote weight will be broken
                ho += WEEK;
                int128 fo = 0;
                if (ho > block.timestamp) {
                    ho = block.timestamp;
                } else {
                    fo = bi[ho];
                }
                da.hf -= da.gw * int128(int256(ho - al));
                da.gw += fo;
                if (da.hf < 0) {
                    // This can happen
                    da.hf = 0;
                }
                if (da.gw < 0) {
                    // This cannot happen - just in case
                    da.gw = 0;
                }
                al = ho;
                da.hs = ho;
                da.hp = q.hp + (cg * (ho - q.hs)) / MULTIPLIER;
                fu += 1;
                if (ho == block.timestamp) {
                    da.hp = block.number;
                    break;
                } else {
                    d.bn[fu] = da;
                }
            }
        }

        gy = fu;
        // Now point_history is filled until t=now

        if (en != 0) {
            // If last point was in this block, the slope change has been applied already
            // But in such case we have 0 slope(s)
            da.gw += (gq.gw - gs.gw);
            da.hf += (gq.hf - gs.hf);
            if (da.gw < 0) {
                da.gw = 0;
            }
            if (da.hf < 0) {
                da.hf = 0;
            }
            da.ee = g;
        }

        // Record the changed point into history
        d.bn[fu] = da;

        if (en != 0) {
            // Schedule the slope changes (slope is going down)
            // We subtract new_user_slope from [new_locked.end]
            // and add old_user_slope to [old_locked.end]
            if (dk.hq > block.timestamp) {
                // old_dslope was <something> - u_old.slope, so we cancel that
                de += gs.gw;
                if (di.hq == dk.hq) {
                    de -= gq.gw; // It was a new deposit, not extension
                }
                bi[dk.hq] = de;
            }

            if (di.hq > block.timestamp) {
                if (di.hq > dk.hq) {
                    db -= gq.gw; // old slope disappeared at this point
                    bi[di.hq] = db;
                }
                // else: we recorded it already in old_dslope
            }
            // Now handle user history
            uint dd = d.af[en] + 1;

            d.af[en] = dd;
            gq.hs = block.timestamp;
            gq.hp = block.number;
            d.p[en][dd] = gq;
        }
    }

    /// @notice Deposit and lock tokens for a user
    /// @param _tokenId NFT that holds lock
    /// @param _value Amount to deposit
    /// @param unlock_time New time when to unlock the tokens, or 0 if unchanged
    /// @param locked_balance Previous locked amount / timestamp
    /// @param deposit_type The type of deposit
    function ca(
        uint en,
        uint fw,
        uint cj,
        IVotingEscrow.LockedBalance memory ay,
        DepositType cb
    ) internal {
        IVotingEscrow.LockedBalance memory fk = ay;
        uint bl = fy;

        fy = bl + fw;
        IVotingEscrow.LockedBalance memory dk;
        (dk.ge, dk.hq, dk.ct) = (fk.ge, fk.hq, fk.ct);
        // Adding to existing lock, or if a lock is expired - creating a new one
        fk.ge += int128(int256(fw));

        if (cj != 0) {
            fk.hq = cj;
        }
        fv[en] = fk;

        // Possibilities:
        // Both old_locked.end could be current or expired (>/< block.timestamp)
        // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // _locked.end > block.timestamp (always)
        cs(en, dk, fk);

        address from = msg.sender;
        if (fw != 0) {
            assert(IERC20(gv).cc(from, address(this), fw));
        }

        emit Deposit(from, en, fw, fk.hq, cb, block.timestamp);
        emit Supply(bl, bl + fw);
    }

    /// @notice Record global data to checkpoint
    function dn() external {
        cs(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }

    /// @notice Deposit `_value` tokens for `_tokenId` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _tokenId lock NFT
    /// @param _value Amount to add to user's lock
    function ch(uint en, uint fw) external bu {
        IVotingEscrow.LockedBalance memory fk = fv[en];

        require(fw > 0, "ZV"); // dev: need non-zero value
        require(fk.ge > 0, 'ZL');
        require(fk.hq > block.timestamp || fk.ct, 'EXP');

        if (fk.ct) g += fw;

        ca(en, fw, 0, fk, DepositType.DEPOSIT_FOR_TYPE);

        if(gm[en]) {
            IVoter(hc).hg(en);
        }
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function bv(uint fw, uint ax, address hm) internal returns (uint) {
        uint cj = (block.timestamp + ax) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(fw > 0, "ZV"); // dev: need non-zero value
        require(cj > block.timestamp && (cj <= block.timestamp + MAXTIME), 'IUT');

        ++fm;
        uint en = fm;
        hb(hm, en);

        IVotingEscrow.LockedBalance memory fk = fv[en];

        ca(en, fw, cj, fk, DepositType.CREATE_LOCK_TYPE);
        return en;
    }

    /// @notice Deposit `_value` tokens for `msg.sender` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    function cf(uint fw, uint ax) external bu returns (uint) {
        return bv(fw, ax, msg.sender);
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function aj(uint fw, uint ax, address hm) external bu returns (uint) {
        return bv(fw, ax, hm);
    }

    /// @notice Deposit `_value` additional tokens for `_tokenId` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    function ah(uint en, uint fw) external bu {
        assert(o(msg.sender, en));

        IVotingEscrow.LockedBalance memory fk = fv[en];

        assert(fw > 0); // dev: need non-zero value
        require(fk.ge > 0, 'ZL');
        require(fk.hq > block.timestamp || fk.ct, 'EXP');

        if (fk.ct) g += fw;
        ca(en, fw, 0, fk, DepositType.INCREASE_LOCK_AMOUNT);

        // poke for the gained voting power
        if(gm[en]) {
            IVoter(hc).hg(en);
        }
        emit MetadataUpdate(en);
    }

    /// @notice Extend the unlock time for `_tokenId`
    /// @param _lock_duration New number of seconds until tokens unlock
    function f(uint en, uint ax) external bu {
        assert(o(msg.sender, en));

        IVotingEscrow.LockedBalance memory fk = fv[en];
        require(!fk.ct, "!NORM");
        uint cj = (block.timestamp + ax) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(fk.hq > block.timestamp && fk.ge > 0, 'EXP||ZV');
        require(cj > fk.hq && (cj <= block.timestamp + MAXTIME), 'IUT'); // IUT -> invalid unlock time

        ca(en, 0, cj, fk, DepositType.INCREASE_UNLOCK_TIME);

        // poke for the gained voting power
        if(gm[en]) {
            IVoter(hc).hg(en);
        }
        emit MetadataUpdate(en);
    }

    /// @notice Withdraw all tokens for `_tokenId`
    /// @dev Only possible if the lock has expired
    function eu(uint en) external bu {
        assert(o(msg.sender, en));
        require(cw[en] == 0 && !gm[en], "ATT");

        IVotingEscrow.LockedBalance memory fk = fv[en];
        require(!fk.ct, "!NORM");
        require(block.timestamp >= fk.hq, "!EXP");
        uint value = uint(int256(fk.ge));

        fv[en] = IVotingEscrow.LockedBalance(0, 0, false);
        uint bl = fy;
        fy = bl - value;

        // old_locked can have either expired <= timestamp or zero end
        // _locked has only 0 end
        // Both can have >= 0 amount
        cs(en, fk, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(gv).transfer(msg.sender, value));

        // Burn the NFT
        gt(en);

        emit Withdraw(msg.sender, en, value, block.timestamp);
        emit Supply(bl, bl - value);
    }

    function ba(uint en) external {
        address sender = msg.sender;
        require(o(sender, en), "NAO");

        IVotingEscrow.LockedBalance memory dh = fv[en];
        require(!dh.ct, "!NORM");
        require(dh.hq > block.timestamp, "EXP");
        require(dh.ge > 0, "ZV");

        uint fg = uint(int256(dh.ge));
        g += fg;
        dh.hq = 0;
        dh.ct = true;
        cs(en, fv[en], dh);
        fv[en] = dh;
        if(gm[en]) {
            IVoter(hc).hg(en);
        }
        emit LockPermanent(sender, en, fg, block.timestamp);
        emit MetadataUpdate(en);
    }

    function ai(uint en) external {
        address sender = msg.sender;
        require(o(msg.sender, en), "NAO");

        require(cw[en] == 0 && !gm[en], "ATT");
        IVotingEscrow.LockedBalance memory dh = fv[en];
        require(dh.ct, "!NORM");
        uint fg = uint(int256(dh.ge));
        g -= fg;
        dh.hq = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        dh.ct = false;

        cs(en, fv[en], dh);
        fv[en] = dh;

        emit UnlockPermanent(sender, en, fg, block.timestamp);
        emit MetadataUpdate(en);
    }

    /*///////////////////////////////////////////////////////////////
                           GAUGE VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    // The following ERC20/minime-compatible methods are not real balanceOf and supply!
    // They measure the weights for the purpose of voting, so they don't represent
    // real coins.

    function bs(uint en) external view returns (uint) {
        if (ae[en] == block.number) return 0;
        return VotingBalanceLogic.bs(en, block.timestamp, d);
    }

    function aw(uint en, uint hr) external view returns (uint) {
        return VotingBalanceLogic.bs(en, hr, d);
    }

    function as(uint en, uint ft) external view returns (uint) {
        return VotingBalanceLogic.as(en, ft, d, gy);
    }

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function bg(uint ft) external view returns (uint) {
        return VotingBalanceLogic.bg(ft, gy, d, bi);
    }

    function cp() external view returns (uint) {
        return ar(block.timestamp);
    }

    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    function ar(uint t) public view returns (uint) {
        return VotingBalanceLogic.ar(t, gy, bi,  d);
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE VOTING LOGIC
    //////////////////////////////////////////////////////////////*/

    mapping(uint => uint) public cw;
    mapping(uint => bool) public gm;

    function ez(address fr) external {
        require(msg.sender == hj);
        hc = fr;
    }

    function gh(uint en) external {
        require(msg.sender == hc);
        gm[en] = true;
    }

    function fl(uint en) external {
        require(msg.sender == hc, "NA");
        gm[en] = false;
    }

    function gg(uint en) external {
        require(msg.sender == hc, "NA");
        cw[en] = cw[en] + 1;
    }

    function gd(uint en) external {
        require(msg.sender == hc, "NA");
        cw[en] = cw[en] - 1;
    }

    function gu(uint gp, uint hm) external bu be(gp) {
        require(cw[gp] == 0 && !gm[gp], "ATT");
        require(gp != hm, "SAME");
        require(o(msg.sender, gp) &&
        o(msg.sender, hm), "NAO");

        IVotingEscrow.LockedBalance memory fd = fv[gp];
        IVotingEscrow.LockedBalance memory fa = fv[hm];
        require(fa.hq > block.timestamp ||  fa.ct,"EXP||PERM");
        require(fd.ct ? fa.ct : true, "!MERGE");

        uint gi = uint(int256(fd.ge));
        uint hq = fd.hq >= fa.hq ? fd.hq : fa.hq;

        fv[gp] = IVotingEscrow.LockedBalance(0, 0, false);
        cs(gp, fd, IVotingEscrow.LockedBalance(0, 0, false));
        gt(gp);

        IVotingEscrow.LockedBalance memory ci;
        ci.ct = fa.ct;

        if (ci.ct){
            ci.ge = fa.ge + fd.ge;
            if (!fd.ct) {  // Only add if source wasn't already permanent
                g += gi;
            }
        }else{
            ci.ge = fa.ge + fd.ge;
            ci.hq = hq;
        }

        //_checkpointDelegatee(_delegates[_to], value0, true);
        cs(hm, fa, ci);
        fv[hm] = ci;

        if(gm[hm]) {
            IVoter(hc).hg(hm);
        }
        emit Merge(
            msg.sender,
            gp,
            hm,
            uint(int256(fd.ge)),
            uint(int256(fa.ge)),
            uint(int256(ci.ge)),
            ci.hq,
            block.timestamp
        );
        emit MetadataUpdate(hm);
    }

    // function split(
    //     uint _from,
    //     uint _amount
    // ) external nonreentrant splitAllowed(_from) notPartnerNFT(_from) returns (uint256 _tokenId1, uint256 _tokenId2) {
    //     address owner = idToOwner[_from];

    //     IVotingEscrow.LockedBalance memory newLocked = locked[_from];
    //     require(newLocked.end > block.timestamp || newLocked.isPermanent, "EXP");

    //     int128 _splitAmount = int128(int256(_amount));

    //     require(_splitAmount != 0, "ZV");
    //     require(newLocked.amount > _splitAmount, "BIGVAL");

    //     locked[_from] = IVotingEscrow.LockedBalance(0, 0, false);
    //     _checkpoint(_from, newLocked, IVotingEscrow.LockedBalance(0, 0, false));
    //     _burn(_from);

    //     newLocked.amount -= _splitAmount;
    //     _tokenId1 = _createSplitNFT(owner, newLocked);

    //     newLocked.amount = _splitAmount;
    //     _tokenId2 = _createSplitNFT(owner, newLocked);

    //     // emit Split(
    //     //     _from,
    //     //     _tokenId1,
    //     //     _tokenId2,
    //     //     msg.sender,
    //     //     uint(int256(locked[_tokenId1].amount)),
    //     //     uint(int256(_splitAmount)),
    //     //     newLocked.end,
    //     //     block.timestamp
    //     // );
    // }

    /// @notice Split a veNFT into multiple new veNFTs with specified weight distribution
    /// @param _from The token ID to split
    /// @param amounts Array of weights for distributing the locked amount
    /// @return newTokenIds Array of newly created token IDs
    function cz(
        uint gp,
        uint[] memory fj
    ) external bu br(gp) be(gp) returns (uint256[] memory ck) {
        require(fj.length >= 2 && fj.length <= 10, "MIN2MAX10");

        address gz = dw[gp];

        IVotingEscrow.LockedBalance memory ao = fv[gp];
        require(ao.hq > block.timestamp || ao.ct, "EXP");
        require(ao.ge > 0, "ZV");

        // Calculate total weight
        uint cu = 0;
        for(uint i = 0; i < fj.length; i++) {
            require(fj[i] > 0, "ZW"); // Zero weight not allowed
            cu += fj[i];
        }

        // Burn the original NFT
        fv[gp] = IVotingEscrow.LockedBalance(0, 0, false);
        cs(gp, ao, IVotingEscrow.LockedBalance(0, 0, false));
        gt(gp);

        // Create new NFTs with proportional amounts
        ck = new uint256[](fj.length);
        uint[] memory bj = new uint[](fj.length);

        for(uint i = 0; i < fj.length; i++) {
            IVotingEscrow.LockedBalance memory dq = IVotingEscrow.LockedBalance({
                ge: int128(int256(uint256(int256(ao.ge)) * fj[i] / cu)),
                hq: ao.hq,
                ct: ao.ct
            });

            ck[i] = an(gz, dq);
            bj[i] = uint256(int256(dq.ge));
        }

        emit MultiSplit(
            gp,
            ck,
            msg.sender,
            bj,
            ao.hq,
            block.timestamp
        );
    }

    function an(address hm, IVotingEscrow.LockedBalance memory dh) private returns (uint256 en) {
        en = ++fm;
        fv[en] = dh;
        cs(en, IVotingEscrow.LockedBalance(0, 0, false), dh);
        hb(hm, en);
    }

    function cv(address ek, bool gx) external {
        require(msg.sender == hj);
        fb[ek] = gx;
    }

    /*///////////////////////////////////////////////////////////////
                            DAO VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = du("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = du("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of each accounts delegate
    mapping(address => address) private dm;

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint) public gb;

    /**
     * @notice Overrides the standard `Comp.sol` delegates mapping to return
     * the delegator's own address if they haven't delegated.
     * This avoids having to delegate to oneself.
     */
    function eh(address dz) public view returns (address) {
        address fn = dm[dz];
        return fn == address(0) ? dz : fn;
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function ew(address ff) external view returns (uint) {
        uint32 cd = fz.av[ff];
        if (cd == 0) {
            return 0;
        }
        uint[] storage ef = fz.cy[ff][cd - 1].ev;
        uint hd = 0;
        for (uint i = 0; i < ef.length; i++) {
            uint hl = ef[i];
            hd = hd + VotingBalanceLogic.bs(hl, block.timestamp, d);
        }
        return hd;
    }

    function bp(address ff, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 cq = VotingDelegationLib.y(fz, ff, timestamp);
        // Sum votes
        uint[] storage ef = fz.cy[ff][cq].ev;
        uint hd = 0;
        for (uint i = 0; i < ef.length; i++) {
            uint hl = ef[i];
            // Use the provided input timestamp here to get the right decay
            hd = hd + VotingBalanceLogic.bs(hl, timestamp,  d);
        }

        return hd;
    }

    function r(uint256 timestamp) external view returns (uint) {
        return ar(timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                             DAO VOTING LOGIC
    //////////////////////////////////////////////////////////////*/
    function eg(address dz, address ed) internal {
        /// @notice differs from `_delegate()` in `Comp.sol` to use `delegates` override method to simulate auto-delegation
        address ak = eh(dz);

        dm[dz] = ed;

        emit DelegateChanged(dz, ak, ed);
        VotingDelegationLib.TokenHelpers memory by = VotingDelegationLib.TokenHelpers({
            dt: fe,
            e: e,
            m:m
        });
        VotingDelegationLib.w(fz, dz, ak, ed, by);
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function el(address ed) public {
        if (ed == address(0)) ed = msg.sender;
        return eg(msg.sender, ed);
    }

    function bd(
        address ed,
        uint gn,
        uint gk,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(ed != msg.sender, "NA");
        require(ed != address(0), "ZA");

        bytes32 am = du(
            abi.gf(
                DOMAIN_TYPEHASH,
                du(bytes(hh)),
                du(bytes(fp)),
                block.chainid,
                address(this)
            )
        );
        bytes32 dj = du(
            abi.gf(DELEGATION_TYPEHASH, ed, gn, gk)
        );
        bytes32 gl = du(
            abi.bx("\x19\x01", am, dj)
        );
        address do = dv(gl, v, r, s);
        require(
            do != address(0),
            "ZA"
        );
        require(
            gn == gb[do]++,
            "!NONCE"
        );
        require(
            block.timestamp <= gk,
            "EXP"
        );
        return eg(do, ed);
    }

}