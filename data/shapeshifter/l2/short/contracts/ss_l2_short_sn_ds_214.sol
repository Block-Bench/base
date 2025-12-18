// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ERC20 {
    function dk() constant returns (uint hi);
    function ev( address ja ) constant returns (uint value);
    function eo( address ii, address gq ) constant returns (uint ds);

    function transfer( address jk, uint value) returns (bool jj);
    function cr( address from, address jk, uint value) returns (bool jj);
    function gj( address gq, uint value ) returns (bool jj);

    event Transfer( address indexed from, address indexed jk, uint value);
    event Approval( address indexed ii, address indexed gq, uint value);
}
contract Ownable {
  address public ii;

  function Ownable() {
    ii = msg.sender;
  }

  modifier ff() {
    require(msg.sender == ii);
    _;
  }

  function ao(address fx) ff {
    if (fx != address(0)) {
      ii = fx;
    }
  }

}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function dk() public view returns (uint256 ih);
    function ev(address hr) public view returns (uint256 balance);
    function gd(uint256 fp) external view returns (address ii);
    function gj(address iy, uint256 fp) external;
    function transfer(address iy, uint256 fp) external;
    function cr(address hy, address iy, uint256 fp) external;

    // Events
    event Transfer(address from, address jk, uint256 gs);
    event Approval(address ii, address fs, uint256 gs);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function ak(bytes4 cl) external view returns (bool);
}

contract GeneScienceInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function cb() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @return the genes that are supposed to be passed down the child
    function fk(uint256[2] hc, uint256[2] hd,uint256 ji,uint256 jl, uint256 dp) public returns (uint256[2]);

    function ba(uint256[2] it) public view returns(uint256);

    /// @dev get sex from genes 0: female 1: male
    function hl(uint256[2] it) public view returns(uint256);

    /// @dev get wizz type from gene
    function cy(uint256[2] it) public view returns(uint256);

    function bu(uint256[2] ia) public returns(uint256[2]);
}

/// @title A facet of PandaCore that manages special access privileges.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaAccessControl {
    // This facet controls access control for CryptoPandas. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the PandaCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from PandaCore and its auction contracts.
    //
    //     - The COO: The COO can release gen0 pandas to auction, and mint promo cats.
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event ContractUpgrade(address dg);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ed;
    address public ej;
    address public ei;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public hm = false;

    /// @dev Access modifier for CEO-only functionality
    modifier go() {
        require(msg.sender == ed);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier gx() {
        require(msg.sender == ej);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier gf() {
        require(msg.sender == ei);
        _;
    }

    modifier ef() {
        require(
            msg.sender == ei ||
            msg.sender == ed ||
            msg.sender == ej
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function hu(address gv) external go {
        require(gv != address(0));

        ed = gv;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function ho(address gm) external go {
        require(gm != address(0));

        ej = gm;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function hn(address gk) external go {
        require(gk != address(0));

        ei = gk;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier bt() {
        require(!hm);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier dx {
        require(hm);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    function ik() external ef bt {
        hm = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function gp() public go dx {
        // can't unpause if contract was upgraded
        hm = false;
    }
}

/// @title Base contract for CryptoPandas. Holds all common structs, events and base variables.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaBase is PandaAccessControl {
    /*** EVENTS ***/

    uint256 public constant GEN0_TOTAL_COUNT = 16200;
    uint256 public aw;

    /// @dev The Birth event is fired whenever a new kitten comes into existence. This obviously
    ///  includes any time a cat is created through the giveBirth method, but it is also called
    ///  when a new gen0 cat is created.
    event Birth(address ii, uint256 gt, uint256 fi, uint256 ht, uint256[2] ic);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a kitten
    ///  ownership is assigned, including births.
    event Transfer(address from, address jk, uint256 gs);

    /*** DATA TYPES ***/

    /// @dev The main Panda struct. Every cat in CryptoPandas is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Panda {
        // The Panda's genetic code is packed into these 256-bits, the format is
        // sooper-sekret! A cat's genes never change.
        uint256[2] ic;

        // The timestamp from the block when this cat came into existence.
        uint64 et;

        // The minimum timestamp after which this cat can engage in breeding
        // activities again. This same timestamp is used for the pregnancy
        // timer (for matrons) as well as the siring cooldown.
        uint64 at;

        // The ID of the parents of this panda, set to 0 for gen0 cats.
        // Note that using 32-bit unsigned integers limits us to a "mere"
        // 4 billion cats. This number might seem small until you realize
        // that Ethereum currently has a limit of about 500 million
        // transactions per year! So, this definitely won't be a problem
        // for several years (even as Ethereum learns to scale).
        uint32 fi;
        uint32 ht;

        // Set to the ID of the sire cat for matrons that are pregnant,
        // zero otherwise. A non-zero value here is how we know a cat
        // is pregnant. Used to retrieve the genetic material for the new
        // kitten when the birth transpires.
        uint32 cu;

        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this Panda. This starts at zero
        // for gen0 cats, and is initialized to floor(generation/2) for others.
        // Incremented by one for each successful breeding action, regardless
        // of whether this cat is acting as matron or sire.
        uint16 bv;

        // The "generation number" of this cat. Cats minted by the CK contract
        // for sale are called "gen0" and have a generation number of 0. The
        // generation number of all other cats is the larger of the two generation
        // numbers of their parents, plus one.
        // (i.e. max(matron.generation, sire.generation) + 1)
        uint16 dt;
    }

    /*** CONSTANTS ***/

    /// @dev A lookup table indicating the cooldown duration after any successful
    ///  breeding action, called "pregnancy time" for matrons and "siring cooldown"
    ///  for sires. Designed such that the cooldown roughly doubles each time a cat
    ///  is bred, encouraging owners not to just keep breeding the same cat over
    ///  and over again. Caps out at one week (a cat can breed an unbounded number
    ///  of times, and the maximum cooldown is always seven days).
    uint32[9] public ep = [
        uint32(5 minutes),
        uint32(30 minutes),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(24 hours),
        uint32(48 hours),
        uint32(72 hours),
        uint32(7 days)
    ];

    // An approximation of currently how many seconds are in between blocks.
    uint256 public ax = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Panda struct for all Pandas in existence. The ID
    ///  of each cat is actually an index into this array. Note that ID 0 is a negacat,
    ///  the unPanda, the mythical beast that is the parent of all gen0 cats. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, cat ID 0 is invalid... ;-)
    Panda[] hg;

    /// @dev A mapping from cat IDs to the address that owns them. All cats have
    ///  some valid owner address, even gen0 cats are created with a non-zero owner.
    mapping (uint256 => address) public am;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) w;

    /// @dev A mapping from PandaIDs to an address that has been approved to call
    ///  transferFrom(). Each Panda can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public p;

    /// @dev A mapping from PandaIDs to an address that has been approved to use
    ///  this Panda for siring via breedWith(). Each Panda can only have one approved
    ///  address for siring at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public o;

    /// @dev The address of the ClockAuction contract that handles sales of Pandas. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public db;

    /// @dev The address of a custom ClockAuction subclassed contract that handles siring
    ///  auctions. Needs to be separate from saleAuction because the actions taken on success
    ///  after a sales and siring auction are quite different.
    SiringClockAuction public bq;

    /// @dev The address of the sibling contract that is used to implement the sooper-sekret
    ///  genetic combination algorithm.
    GeneScienceInterface public de;

    SaleClockAuctionERC20 public av;

    // wizz panda total
    mapping (uint256 => uint256) public bf;
    mapping (uint256 => uint256) public bg;

    /// wizz panda control
    function ab(uint256 jf) view external returns(uint256) {
        return bf[jf];
    }

    function z(uint256 jf) view external returns(uint256) {
        return bg[jf];
    }

    function x(uint256 jf,uint256 gz) external ef {
        require (bf[jf]==0);
        require (gz==uint256(uint32(gz)));
        bf[jf] = gz;
    }

    function by(uint256 jb) view external returns(uint256) {
        Panda memory jh = hg[jb];
        return de.cy(jh.ic);
    }

    /// @dev Assigns ownership of a specific Panda to an address.
    function fe(address hy, address iy, uint256 fp) internal {

        w[iy]++;
        // transfer ownership
        am[fp] = iy;
        // When creating new kittens _from is 0x0, but we can't account that address.
        if (hy != address(0)) {
            w[hy]--;
            // once the kitten is transferred also clear sire allowances
            delete o[fp];
            // clear any previously approved ownership exchange
            delete p[fp];
        }
        // Emit the transfer event.
        Transfer(hy, iy, fp);
    }

    /// @dev An internal method that creates a new panda and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Birth event
    ///  and a Transfer event.
    /// @param _matronId The panda ID of the matron of this cat (zero for gen0)
    /// @param _sireId The panda ID of the sire of this cat (zero for gen0)
    /// @param _generation The generation number of this cat, must be computed by caller.
    /// @param _genes The panda's genetic code.
    /// @param _owner The inital owner of this cat, must be non-zero (except for the unPanda, ID 0)
    function cv(
        uint256 fd,
        uint256 gn,
        uint256 dl,
        uint256[2] hf,
        address hr
    )
        internal
        returns (uint)
    {
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createPanda() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        require(fd == uint256(uint32(fd)));
        require(gn == uint256(uint32(gn)));
        require(dl == uint256(uint16(dl)));

        // New panda starts with the same cooldown as parent gen/2
        uint16 bv = 0;
        // when contract creation, geneScience ref is null
        if (hg.length>0){
            uint16 ek = uint16(de.ba(hf));
            if (ek==0) {
                ek = 1;
            }
            bv = 1000/ek;
            if (bv%10 < 5){
                bv = bv/10;
            }else{
                bv = bv/10 + 1;
            }
            bv = bv - 1;
            if (bv > 8) {
                bv = 8;
            }
            uint256 jf = de.cy(hf);
            if (jf>0 && bf[jf]<=bg[jf]) {
                hf = de.bu(hf);
                jf = 0;
            }
            // gensis panda cooldownIndex should be 24 hours
            if (jf == 1){
                bv = 5;
            }

            // increase wizz counter
            if (jf>0){
                bg[jf] = bg[jf] + 1;
            }
            // all gen0&gen1 except gensis
            if (dl <= 1 && jf != 1){
                require(aw<GEN0_TOTAL_COUNT);
                aw++;
            }
        }

        Panda memory hq = Panda({
            ic: hf,
            et: uint64(jg),
            at: 0,
            fi: uint32(fd),
            ht: uint32(gn),
            cu: 0,
            bv: bv,
            dt: uint16(dl)
        });
        uint256 dh = hg.push(hq) - 1;

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(dh == uint256(uint32(dh)));

        // emit the birth event
        Birth(
            hr,
            dh,
            uint256(hq.fi),
            uint256(hq.ht),
            hq.ic
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        fe(0, hr, dh);

        return dh;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function ai(uint256 ip) external ef {
        require(ip < ep[0]);
        ax = ip;
    }
}
/// @title The external contract that is responsible for generating metadata for the pandas,
///  it has one function that will return the data as bytes.
contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function dm(uint256 fp, string) public view returns (bytes32[4] he, uint256 hz) {
        if (fp == 1) {
            he[0] = "Hello World! :D";
            hz = 15;
        } else if (fp == 2) {
            he[0] = "I would definitely choose a medi";
            he[1] = "um length string.";
            hz = 49;
        } else if (fp == 3) {
            he[0] = "Lorem ipsum dolor sit amet, mi e";
            he[1] = "st accumsan dapibus augue lorem,";
            he[2] = " tristique vestibulum id, libero";
            he[3] = " suscipit varius sapien aliquam.";
            hz = 128;
        }
    }
}

/// @title The facet of the CryptoPandas core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaOwnership is PandaBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant is = "PandaEarth";
    string public constant hk = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(es('ak(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(es('is()')) ^
        bytes4(es('hk()')) ^
        bytes4(es('dk()')) ^
        bytes4(es('ev(address)')) ^
        bytes4(es('gd(uint256)')) ^
        bytes4(es('gj(address,uint256)')) ^
        bytes4(es('transfer(address,uint256)')) ^
        bytes4(es('cr(address,address,uint256)')) ^
        bytes4(es('bp(address)')) ^
        bytes4(es('tokenMetadata(uint256,string)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function ak(bytes4 cl) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((cl == InterfaceSignature_ERC165) || (cl == InterfaceSignature_ERC721));
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Panda.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId kitten id, only valid when > 0
    function ie(address fb, uint256 fp) internal view returns (bool) {
        return am[fp] == fb;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Panda.
    /// @param _claimant the address we are confirming kitten is approved for.
    /// @param _tokenId kitten id, only valid when > 0
    function ck(address fb, uint256 fp) internal view returns (bool) {
        return p[fp] == fb;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Pandas on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function fn(uint256 fp, address ey) internal {
        p[fp] = ey;
    }

    /// @notice Returns the number of Pandas owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function ev(address hr) public view returns (uint256 hz) {
        return w[hr];
    }

    /// @notice Transfers a Panda to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoPandas specifically) or your Panda may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Panda to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address iy,
        uint256 fp
    )
        external
        bt
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(iy != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any pandas (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(iy != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of pandas
        // through the allow + transferFrom flow.
        require(iy != address(db));
        require(iy != address(bq));

        // You can only send your own cat.
        require(ie(msg.sender, fp));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        fe(msg.sender, iy, fp);
    }

    /// @notice Grant another address the right to transfer a specific Panda via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Panda that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function gj(
        address iy,
        uint256 fp
    )
        external
        bt
    {
        // Only an owner can grant transfer approval.
        require(ie(msg.sender, fp));

        // Register the approval (replacing any previous approval).
        fn(fp, iy);

        // Emit approval event.
        Approval(msg.sender, iy, fp);
    }

    /// @notice Transfer a Panda owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Panda to be transfered.
    /// @param _to The address that should take ownership of the Panda. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Panda to be transferred.
    /// @dev Required for ERC-721 compliance.
    function cr(
        address hy,
        address iy,
        uint256 fp
    )
        external
        bt
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(iy != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any pandas (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(iy != address(this));
        // Check for approval and valid ownership
        require(ck(msg.sender, fp));
        require(ie(hy, fp));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        fe(hy, iy, fp);
    }

    /// @notice Returns the total number of Pandas currently in existence.
    /// @dev Required for ERC-721 compliance.
    function dk() public view returns (uint) {
        return hg.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Panda.
    /// @dev Required for ERC-721 compliance.
    function gd(uint256 fp)
        external
        view
        returns (address ii)
    {
        ii = am[fp];

        require(ii != address(0));
    }

    /// @notice Returns a list of all Panda IDs assigned to an address.
    /// @param _owner The owner whose Pandas we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Panda array looking for cats belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function bp(address hr) external view returns(uint256[] cz) {
        uint256 du = ev(hr);

        if (du == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory hh = new uint256[](du);
            uint256 er = dk();
            uint256 da = 0;

            // We count on the fact that all cats have IDs starting at 1 and increasing
            // sequentially up to the totalCat count.
            uint256 ig;

            for (ig = 1; ig <= er; ig++) {
                if (am[ig] == hr) {
                    hh[da] = ig;
                    da++;
                }
            }

            return hh;
        }
    }

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function gy(uint id, uint ir, uint iu) private view {
        // Copy word-length chunks while possible
        for(; iu >= 32; iu -= 32) {
            assembly {
                mstore(id, mload(ir))
            }
            id += 32;
            ir += 32;
        }

        // Copy remaining bytes
        uint256 io = 256 ** (32 - iu) - 1;
        assembly {
            let gr := and(mload(ir), not(io))
            let ga := and(mload(id), io)
            mstore(id, or(ga, gr))
        }
    }

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function en(bytes32[4] ex, uint256 bw) private view returns (string) {
        var cq = new string(bw);
        uint256 em;
        uint256 fy;

        assembly {
            em := add(cq, 32)
            fy := ex
        }

        gy(em, fy, bw);

        return cq;
    }

}

/// @title A facet of PandaCore that manages Panda siring, gestation, and birth.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaBreeding is PandaOwnership {

    uint256 public constant GENSIS_TOTAL_COUNT = 100;

    /// @dev The Pregnant event is fired when two cats successfully breed and the pregnancy
    ///  timer begins for the matron.
    event Pregnant(address ii, uint256 fi, uint256 ht, uint256 at);
    /// @dev The Abortion event is fired when two cats breed failed.
    event Abortion(address ii, uint256 fi, uint256 ht);

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public cx = 2 finney;

    // Keeps track of number of pregnant pandas.
    uint256 public bl;

    mapping(uint256 => address) eh;

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a GeneScience contract instance to be used from this point forward.
    function k(address fj) external go {
        GeneScienceInterface ap = GeneScienceInterface(fj);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(ap.cb());

        // Set the new contract address
        de = ap;
    }

    /// @dev Checks that a given kitten is able to breed. Requires that the
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function bc(Panda iw) internal view returns(bool) {
        // In addition to checking the cooldownEndBlock, we also need to check to see if
        // the cat has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (iw.cu == 0) && (iw.at <= uint64(block.number));
    }

    /// @dev Check if a sire has authorized breeding with this matron. True if both sire
    ///  and matron have the same owner, or if the sire has given siring permission to
    ///  the matron's owner (via approveSiring()).
    function aj(uint256 gn, uint256 fd) internal view returns(bool) {
        address do = am[fd];
        address eu = am[gn];

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (do == eu || o[gn] == do);
    }

    /// @dev Set the cooldownEndTime for the given Panda, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _kitten A reference to the Panda in storage which needs its timer started.
    function au(Panda storage gl) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
        gl.at = uint64((ep[gl.bv] / ax) + block.number);

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (gl.bv < 8 && de.cy(gl.ic) != 1) {
            gl.bv += 1;
        }
    }

    /// @notice Grants approval to another user to sire with one of your Pandas.
    /// @param _addr The address that will be able to sire with your Panda. Set to
    ///  address(0) to clear all siring approvals for this Panda.
    /// @param _sireId A Panda that you own that _addr will now be able to sire with.
    function br(address hx, uint256 gn)
    external
    bt {
        require(ie(msg.sender, gn));
        o[gn] = hx;
    }

    /// @dev Updates the minimum payment required for calling giveBirthAuto(). Can only
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred
    ///  by the autobirth daemon).
    function bb(uint256 jd) external gf {
        cx = jd;
    }

    /// @dev Checks to see if a given Panda is pregnant and (if so) if the gestation
    ///  period has passed.
    function y(Panda gh) private view returns(bool) {
        return (gh.cu != 0) && (gh.at <= uint64(block.number));
    }

    /// @notice Checks that a given kitten is able to breed (i.e. it is not pregnant or
    ///  in the middle of a siring cooldown).
    /// @param _pandaId reference the id of the kitten, any user can inquire about it
    function bj(uint256 gc)
    public
    view
    returns(bool) {
        require(gc > 0);
        Panda storage jc = hg[gc];
        return bc(jc);
    }

    /// @dev Checks whether a panda is currently pregnant.
    /// @param _pandaId reference the id of the kitten, any user can inquire about it
    function ec(uint256 gc)
    public
    view
    returns(bool) {
        require(gc > 0);
        // A panda is pregnant if and only if this field is set
        return hg[gc].cu != 0;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the Panda struct of the potential matron.
    /// @param _matronId The matron's ID.
    /// @param _sire A reference to the Panda struct of the potential sire.
    /// @param _sireId The sire's ID
    function ag(
        Panda storage gh,
        uint256 fd,
        Panda storage if,
        uint256 gn
    )
    private
    view
    returns(bool) {
        // A Panda can't breed with itself!
        if (fd == gn) {
            return false;
        }

        // Pandas can't breed with their parents.
        if (gh.fi == gn || gh.ht == gn) {
            return false;
        }
        if (if.fi == fd || if.ht == fd) {
            return false;
        }

        // We can short circuit the sibling check (below) if either cat is
        // gen zero (has a matron ID of zero).
        if (if.fi == 0 || gh.fi == 0) {
            return true;
        }

        // Pandas can't breed with full or half siblings.
        if (if.fi == gh.fi || if.fi == gh.ht) {
            return false;
        }
        if (if.ht == gh.fi || if.ht == gh.ht) {
            return false;
        }

        // male should get breed with female
        if (de.hl(gh.ic) + de.hl(if.ic) != 1) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair for
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function d(uint256 fd, uint256 gn)
    internal
    view
    returns(bool) {
        Panda storage ha = hg[fd];
        Panda storage im = hg[gn];
        return ag(ha, fd, im, gn);
    }

    /// @notice Checks to see if two cats can breed together, including checks for
    ///  ownership and siring approvals. Does NOT check that both cats are ready for
    ///  breeding (i.e. breedWith could still fail until the cooldowns are finished).
    ///  TODO: Shouldn't this check pregnancy and cooldowns?!?
    /// @param _matronId The ID of the proposed matron.
    /// @param _sireId The ID of the proposed sire.
    function cp(uint256 fd, uint256 gn)
    external
    view
    returns(bool) {
        require(fd > 0);
        require(gn > 0);
        Panda storage ha = hg[fd];
        Panda storage im = hg[gn];
        return ag(ha, fd, im, gn) &&
            aj(gn, fd);
    }

    function n(uint256 fd, uint256 gn) internal returns(uint256, uint256) {
        if (de.hl(hg[fd].ic) == 1) {
            return (gn, fd);
        } else {
            return (fd, gn);
        }
    }

    /// @dev Internal utility function to initiate breeding, assumes that all breeding
    ///  requirements have been checked.
    function dv(uint256 fd, uint256 gn, address hr) internal {
        // make id point real gender
        (fd, gn) = n(fd, gn);
        // Grab a reference to the Pandas from storage.
        Panda storage im = hg[gn];
        Panda storage ha = hg[fd];

        // Mark the matron as pregnant, keeping track of who the sire is.
        ha.cu = uint32(gn);

        // Trigger the cooldown for both parents.
        au(im);
        au(ha);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete o[fd];
        delete o[gn];

        // Every time a panda gets pregnant, counter is incremented.
        bl++;

        eh[fd] = hr;

        // Emit the pregnancy event.
        Pregnant(am[fd], fd, gn, ha.at);
    }

    /// @notice Breed a Panda you own (as matron) with a sire that you own, or for which you
    ///  have previously been given Siring approval. Will either make your cat pregnant, or will
    ///  fail entirely. Requires a pre-payment of the fee given out to the first caller of giveBirth()
    /// @param _matronId The ID of the Panda acting as matron (will end up pregnant if successful)
    /// @param _sireId The ID of the Panda acting as sire (will begin its siring cooldown if successful)
    function bz(uint256 fd, uint256 gn)
    external
    payable
    bt {
        // Checks for payment.
        require(msg.value >= cx);

        // Caller must own the matron.
        require(ie(msg.sender, fd));

        // Neither sire nor matron are allowed to be on auction during a normal
        // breeding operation, but we don't need to check that explicitly.
        // For matron: The caller of this function can't be the owner of the matron
        //   because the owner of a Panda on auction is the auction house, and the
        //   auction house will never call breedWith().
        // For sire: Similarly, a sire on auction will be owned by the auction house
        //   and the act of transferring ownership will have cleared any oustanding
        //   siring approval.
        // Thus we don't need to spend gas explicitly checking to see if either cat
        // is on auction.

        // Check that matron and sire are both owned by caller, or that the sire
        // has given siring permission to caller (i.e. matron's owner).
        // Will fail for _sireId = 0
        require(aj(gn, fd));

        // Grab a reference to the potential matron
        Panda storage ha = hg[fd];

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(bc(ha));

        // Grab a reference to the potential sire
        Panda storage im = hg[gn];

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(bc(im));

        // Test that these cats are a valid mating pair.
        require(ag(
            ha,
            fd,
            im,
            gn
        ));

        // All checks passed, panda gets pregnant!
        dv(fd, gn, msg.sender);
    }

    /// @notice Have a pregnant Panda give birth!
    /// @param _matronId A Panda ready to give birth.
    /// @return The Panda ID of the new kitten.
    /// @dev Looks at a given Panda and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new kitten. The new Panda is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the

    ///  are willing to pay the gas!), but the new kitten always goes to the mother's owner.
    function ez(uint256 fd, uint256[2] dj, uint256[2] fw)
    external
    bt
    ef
    returns(uint256) {
        // Grab a reference to the matron in storage.
        Panda storage ha = hg[fd];

        // Check that the matron is a valid cat.
        require(ha.et != 0);

        // Check that the matron is pregnant, and that its time has come!
        require(y(ha));

        // Grab a reference to the sire in storage.
        uint256 ht = ha.cu;
        Panda storage im = hg[ht];

        // Determine the higher generation number of the two parents
        uint16 fa = ha.dt;
        if (im.dt > ha.dt) {
            fa = im.dt;
        }

        // Call the sooper-sekret gene mixing operation.
        //uint256[2] memory childGenes = geneScience.mixGenes(matron.genes, sire.genes,matron.generation,sire.generation, matron.cooldownEndBlock - 1);
        uint256[2] memory dw = dj;

        uint256 fr = 0;

        // birth failed
        uint256 di = (de.ba(ha.ic) + de.ba(im.ic)) / 2 + fw[0];
        if (di >= (fa + 1) * fw[1]) {
            di = di - (fa + 1) * fw[1];
        } else {
            di = 0;
        }
        if (fa == 0 && aw == GEN0_TOTAL_COUNT) {
            di = 0;
        }
        if (uint256(es(block.blockhash(block.number - 2), jg)) % 100 < di) {
            // Make the new kitten!
            address ii = eh[fd];
            fr = cv(fd, ha.cu, fa + 1, dw, ii);
        } else {
            Abortion(am[fd], fd, ht);
        }
        // Make the new kitten!
        //address owner = pandaIndexToOwner[_matronId];
        //address owner = childOwner[_matronId];
        //uint256 kittenId = _createPanda(_matronId, matron.siringWithId, parentGen + 1, childGenes, owner);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete ha.cu;

        // Every time a panda gives birth counter is decremented.
        bl--;

        // Send the balance fee to the person who made birth happen.
        msg.sender.send(cx);

        delete eh[fd];

        // return the new kitten's ID
        return fr;
    }
}

/// @title Auction Core
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuctionBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address hp;
        // Price (in wei) at beginning of auction
        uint128 ce;
        // Price (in wei) at end of auction
        uint128 dd;
        // Duration (in seconds) of auction
        uint64 fl;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 fh;
        // is this auction for gen0 panda
        uint64 hj;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public u;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public fq;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) ar;

    event AuctionCreated(uint256 gs, uint256 ce, uint256 dd, uint256 fl);
    event AuctionSuccessful(uint256 gs, uint256 eg, address hb);
    event AuctionCancelled(uint256 gs);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function ie(address fb, uint256 fp) internal view returns (bool) {
        return (u.gd(fp) == fb);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function gu(address hr, uint256 fp) internal {
        // it will throw if transfer fails
        u.cr(hr, this, fp);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function fe(address el, uint256 fp) internal {
        // it will throw if transfer fails
        u.transfer(el, fp);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function df(uint256 fp, Auction gb) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(gb.fl >= 1 minutes);

        ar[fp] = gb;

        AuctionCreated(
            uint256(fp),
            uint256(gb.ce),
            uint256(gb.dd),
            uint256(gb.fl)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function be(uint256 fp, address gw) internal {
        bi(fp);
        fe(gw, fp);
        AuctionCancelled(fp);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function in(uint256 fp, uint256 dz)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage gi = ar[fp];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(ct(gi));

        // Check that the bid is greater than or equal to the current price
        uint256 il = ch(gi);
        require(dz >= il);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address hp = gi.hp;

        // The bid is good! Remove the auction before sending the fees
        bi(fp);

        // Transfer proceeds to seller (if there are any!)
        if (il > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 cc = dc(il);
            uint256 bh = il - cc;

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // a contract with an invalid fallback function. We explicitly
            // before calling transfer(), and the only thing the seller

            // accident, they can call cancelAuction(). )
            hp.transfer(bh);
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or

        uint256 ew = dz - il;

        // Return the funds. Similar to the previous transfer, this is
        // removed before any transfers occur.
        msg.sender.transfer(ew);

        // Tell the world!
        AuctionSuccessful(fp, il, msg.sender);

        return il;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function bi(uint256 fp) internal {
        delete ar[fp];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function ct(Auction storage gb) internal view returns (bool) {
        return (gb.fh > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function ch(Auction storage gb)
        internal
        view
        returns (uint256)
    {
        uint256 cj = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (jg > gb.fh) {
            cj = jg - gb.fh;
        }

        return t(
            gb.ce,
            gb.dd,
            gb.fl,
            cj
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function t(
        uint256 bk,
        uint256 co,
        uint256 fc,
        uint256 bm
    )
        internal
        pure
        returns (uint256)
    {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our public functions carefully cap the maximum values for
        //  time (at 64-bits) and currency (at 128-bits). _duration is
        //  also known to be non-zero (see the require() statement in
        //  _addAuction())
        if (bm >= fc) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return co;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 aq = int256(co) - int256(bk);

            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 ae = aq * int256(bm) / int256(fc);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 cm = int256(bk) + ae;

            return uint256(cm);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function dc(uint256 hw) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return hw * fq / 10000;
    }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public hm = false;

  modifier bt() {
    require(!hm);
    _;
  }

  modifier dx {
    require(hm);
    _;
  }

  function ik() ff bt returns (bool) {
    hm = true;
    Pause();
    return true;
  }

  function gp() ff dx returns (bool) {
    hm = false;
    Unpause();
    return true;
  }
}

/// @title Clock auction for non-fungible tokens.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuction is Pausable, ClockAuctionBase {

    /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _nftAddress - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    /// @param _cut - percent cut the owner takes on each auction, must be
    ///  between 0-10,000.
    function ClockAuction(address dn, uint256 iv) public {
        require(iv <= 10000);
        fq = iv;

        ERC721 ap = ERC721(dn);
        require(ap.ak(InterfaceSignature_ERC721));
        u = ap;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function az() external {
        address eb = address(u);

        require(
            msg.sender == ii ||
            msg.sender == eb
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool iz = eb.send(this.balance);
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function ca(
        uint256 fp,
        uint256 bk,
        uint256 co,
        uint256 fc,
        address gw
    )
        external
        bt
    {

        // to store them in the auction struct.
        require(bk == uint256(uint128(bk)));
        require(co == uint256(uint128(co)));
        require(fc == uint256(uint64(fc)));

        require(ie(msg.sender, fp));
        gu(msg.sender, fp);
        Auction memory gi = Auction(
            gw,
            uint128(bk),
            uint128(co),
            uint64(fc),
            uint64(jg),
            0
        );
        df(fp, gi);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function je(uint256 fp)
        external
        payable
        bt
    {
        // _bid will throw if the bid or funds transfer fails
        in(fp, msg.value);
        fe(msg.sender, fp);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cd(uint256 fp)
        external
    {
        Auction storage gi = ar[fp];
        require(ct(gi));
        address hp = gi.hp;
        require(msg.sender == hp);
        be(fp, hp);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function c(uint256 fp)
        dx
        ff
        external
    {
        Auction storage gi = ar[fp];
        require(ct(gi));
        be(fp, gi.hp);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function ee(uint256 fp)
        external
        view
        returns
    (
        address hp,
        uint256 ce,
        uint256 dd,
        uint256 fl,
        uint256 fh
    ) {
        Auction storage gi = ar[fp];
        require(ct(gi));
        return (
            gi.hp,
            gi.ce,
            gi.dd,
            gi.fl,
            gi.fh
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function ay(uint256 fp)
        external
        view
        returns (uint256)
    {
        Auction storage gi = ar[fp];
        require(ct(gi));
        return ch(gi);
    }

}

/// @title Reverse auction modified for siring
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SiringClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSiringAuctionAddress() call.
    bool public r = true;

    // Delegate constructor
    function SiringClockAuction(address fz, uint256 iv) public
        ClockAuction(fz, iv) {}

    /// @dev Creates and begins a new auction. Since this function is wrapped,
    /// require sender to be PandaCore contract.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function ca(
        uint256 fp,
        uint256 bk,
        uint256 co,
        uint256 fc,
        address gw
    )
        external
    {

        // to store them in the auction struct.
        require(bk == uint256(uint128(bk)));
        require(co == uint256(uint128(co)));
        require(fc == uint256(uint64(fc)));

        require(msg.sender == address(u));
        gu(gw, fp);
        Auction memory gi = Auction(
            gw,
            uint128(bk),
            uint128(co),
            uint64(fc),
            uint64(jg),
            0
        );
        df(fp, gi);
    }

    /// @dev Places a bid for siring. Requires the sender
    /// is the PandaCore contract because all bid methods
    /// should be wrapped. Also returns the panda to the
    /// seller rather than the winner.
    function je(uint256 fp)
        external
        payable
    {
        require(msg.sender == address(u));
        address hp = ar[fp].hp;
        // _bid checks that token ID is valid and will throw if bid fails
        in(fp, msg.value);
        // We transfer the panda back to the seller, the winner will get
        // the offspring
        fe(hp, fp);
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public ac = true;

    // Tracks last 5 sale price of gen0 panda sales
    uint256 public bs;
    uint256[5] public af;
    uint256 public constant SurpriseValue = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaIndex;
    uint256   RarePandaIndex;

    // Delegate constructor
    function SaleClockAuction(address fz, uint256 iv) public
        ClockAuction(fz, iv) {
            CommonPandaIndex = 1;
            RarePandaIndex   = 1;
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function ca(
        uint256 fp,
        uint256 bk,
        uint256 co,
        uint256 fc,
        address gw
    )
        external
    {

        // to store them in the auction struct.
        require(bk == uint256(uint128(bk)));
        require(co == uint256(uint128(co)));
        require(fc == uint256(uint64(fc)));

        require(msg.sender == address(u));
        gu(gw, fp);
        Auction memory gi = Auction(
            gw,
            uint128(bk),
            uint128(co),
            uint64(fc),
            uint64(jg),
            0
        );
        df(fp, gi);
    }

    function an(
        uint256 fp,
        uint256 bk,
        uint256 co,
        uint256 fc,
        address gw
    )
        external
    {

        // to store them in the auction struct.
        require(bk == uint256(uint128(bk)));
        require(co == uint256(uint128(co)));
        require(fc == uint256(uint64(fc)));

        require(msg.sender == address(u));
        gu(gw, fp);
        Auction memory gi = Auction(
            gw,
            uint128(bk),
            uint128(co),
            uint64(fc),
            uint64(jg),
            1
        );
        df(fp, gi);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function je(uint256 fp)
        external
        payable
    {
        // _bid verifies token ID size
        uint64 hj = ar[fp].hj;
        uint256 il = in(fp, msg.value);
        fe(msg.sender, fp);

        // If not a gen0 auction, exit
        if (hj == 1) {
            // Track gen0 sale prices
            af[bs % 5] = il;
            bs++;
        }
    }

    function dq(uint256 fp,uint256 ij)
        external
    {
        require(msg.sender == address(u));
        if (ij == 0) {
            CommonPanda.push(fp);
        }else {
            RarePanda.push(fp);
        }
    }

    function bx()
        external
        payable
    {
        bytes32 ib = es(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaIndex;
        if (ib[25] > 0xC8) {
            require(uint256(RarePanda.length) >= RarePandaIndex);
            PandaIndex = RarePandaIndex;
            RarePandaIndex ++;

        } else{
            require(uint256(CommonPanda.length) >= CommonPandaIndex);
            PandaIndex = CommonPandaIndex;
            CommonPandaIndex ++;
        }
        fe(msg.sender,PandaIndex);
    }

    function cn() external view returns(uint256 hs,uint256 fm) {
        hs   = CommonPanda.length + 1 - CommonPandaIndex;
        fm = RarePanda.length + 1 - RarePandaIndex;
    }

    function s() external view returns (uint256) {
        uint256 ix = 0;
        for (uint256 i = 0; i < 5; i++) {
            ix += af[i];
        }
        return ix / 5;
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 gs, uint256 ce, uint256 dd, uint256 fl, address cg);

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public f = true;

    mapping (uint256 => address) public m;

    mapping (address => uint256) public i;

    mapping (address => uint256) public fv;

    // Delegate constructor
    function SaleClockAuctionERC20(address fz, uint256 iv) public
        ClockAuction(fz, iv) {}

    function v(address bn, uint256 hv) external{
        require (msg.sender == address(u));

        require (bn != address(0));

        i[bn] = hv;
    }
    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function ca(
        uint256 fp,
        address cf,
        uint256 bk,
        uint256 co,
        uint256 fc,
        address gw
    )
        external
    {

        // to store them in the auction struct.
        require(bk == uint256(uint128(bk)));
        require(co == uint256(uint128(co)));
        require(fc == uint256(uint64(fc)));

        require(msg.sender == address(u));

        require (i[cf] > 0);

        gu(gw, fp);
        Auction memory gi = Auction(
            gw,
            uint128(bk),
            uint128(co),
            uint64(fc),
            uint64(jg),
            0
        );
        as(fp, gi, cf);
        m[fp] = cf;
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function as(uint256 fp, Auction gb, address bn) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(gb.fl >= 1 minutes);

        ar[fp] = gb;

        AuctionERC20Created(
            uint256(fp),
            uint256(gb.ce),
            uint256(gb.dd),
            uint256(gb.fl),
            bn
        );
    }

    function je(uint256 fp)
        external
        payable{
            // do nothing
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function ft(uint256 fp,uint256 gg)
        external
    {
        // _bid verifies token ID size
        address hp = ar[fp].hp;
        address bn = m[fp];
        require (bn != address(0));
        uint256 il = fg(bn,msg.sender,fp, gg);
        fe(msg.sender, fp);
        delete m[fp];
    }

    function cd(uint256 fp)
        external
    {
        Auction storage gi = ar[fp];
        require(ct(gi));
        address hp = gi.hp;
        require(msg.sender == hp);
        be(fp, hp);
        delete m[fp];
    }

    function q(address cf, address iy) external returns(bool iz)  {
        require (fv[cf] > 0);
        require(msg.sender == address(u));
        ERC20(cf).transfer(iy, fv[cf]);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function fg(address cf,address bo, uint256 fp, uint256 dz)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage gi = ar[fp];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(ct(gi));

        require (cf != address(0) && cf == m[fp]);

        // Check that the bid is greater than or equal to the current price
        uint256 il = ch(gi);
        require(dz >= il);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address hp = gi.hp;

        // The bid is good! Remove the auction before sending the fees
        bi(fp);

        // Transfer proceeds to seller (if there are any!)
        if (il > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 cc = dc(il);
            uint256 bh = il - cc;

            // Send Erc20 Token to seller should call Erc20 contract
            // Reference to contract
            require(ERC20(cf).cr(bo,hp,bh));
            if (cc > 0){
                require(ERC20(cf).cr(bo,address(this),cc));
                fv[cf] += cc;
            }
        }

        // Tell the world!
        AuctionSuccessful(fp, il, msg.sender);

        return il;
    }
}

/// @title Handles creating auctions for sale and siring of pandas.
///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract PandaAuction is PandaBreeding {

    // @notice The auction contract variables are defined in PandaBase to allow
    //  us to refer to them in PandaOwnership to prevent accidental transfers.
    // `saleAuction` refers to the auction for gen0 and p2p sale of pandas.
    // `siringAuction` refers to the auction for siring rights of pandas.

    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function l(address fj) external go {
        SaleClockAuction ap = SaleClockAuction(fj);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(ap.ac());

        // Set the new contract address
        db = ap;
    }

    function a(address fj) external go {
        SaleClockAuctionERC20 ap = SaleClockAuctionERC20(fj);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(ap.f());

        // Set the new contract address
        av = ap;
    }

    /// @dev Sets the reference to the siring auction.
    /// @param _address - Address of siring contract.
    function e(address fj) external go {
        SiringClockAuction ap = SiringClockAuction(fj);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(ap.r());

        // Set the new contract address
        bq = ap;
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function al(
        uint256 gc,
        uint256 bk,
        uint256 co,
        uint256 fc
    )
        external
        bt
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(ie(msg.sender, gc));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!ec(gc));
        fn(gc, db);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        db.ca(
            gc,
            bk,
            co,
            fc,
            msg.sender
        );
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function h(
        uint256 gc,
        address bn,
        uint256 bk,
        uint256 co,
        uint256 fc
    )
        external
        bt
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(ie(msg.sender, gc));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!ec(gc));
        fn(gc, av);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        av.ca(
            gc,
            bn,
            bk,
            co,
            fc,
            msg.sender
        );
    }

    function b(address bn, uint256 hv) external gf{
        av.v(bn,hv);
    }

    /// @dev Put a panda up for auction to be sire.
    ///  Performs checks to ensure the panda can be sired, then
    ///  delegates to reverse auction.
    function aa(
        uint256 gc,
        uint256 bk,
        uint256 co,
        uint256 fc
    )
        external
        bt
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(ie(msg.sender, gc));
        require(bj(gc));
        fn(gc, bq);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        bq.ca(
            gc,
            bk,
            co,
            fc,
            msg.sender
        );
    }

    /// @dev Completes a siring auction by bidding.
    ///  Immediately breeds the winning matron with the sire on auction.
    /// @param _sireId - ID of the sire on auction.
    /// @param _matronId - ID of the matron owned by the bidder.
    function ad(
        uint256 gn,
        uint256 fd
    )
        external
        payable
        bt
    {
        // Auction contract checks input sizes
        require(ie(msg.sender, fd));
        require(bj(fd));
        require(d(fd, gn));

        // Define the current price of the auction.
        uint256 cm = bq.ay(gn);
        require(msg.value >= cm + cx);

        // Siring auction will throw if the bid fails.
        bq.je.value(msg.value - cx)(gn);
        dv(uint32(fd), uint32(gn), msg.sender);
    }

    /// @dev Transfers the balance of the sale auction contract
    /// to the PandaCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function g() external ef {
        db.az();
        bq.az();
    }

    function q(address cf, address iy) external ef {
        require(av != address(0));
        av.q(cf,iy);
    }
}

/// @title all functions related to creating kittens
contract PandaMinting is PandaAuction {

    // Limits the number of cats the contract owner can ever create.
    //uint256 public constant PROMO_CREATION_LIMIT = 5000;
    uint256 public constant GEN0_CREATION_LIMIT = 45000;

    // Constants for gen0 auctions.
    uint256 public constant GEN0_STARTING_PRICE = 100 finney;
    uint256 public constant GEN0_AUCTION_DURATION = 1 days;
    uint256 public constant OPEN_PACKAGE_PRICE = 10 finney;

    // Counts the number of cats the contract owner has created.
    //uint256 public promoCreatedCount;

    /// @dev we can create promo kittens, up to a limit. Only callable by COO
    /// @param _genes the encoded genes of the kitten to be created, any value is accepted
    /// @param _owner the future owner of the created kittens. Default to contract COO
    function bd(uint256[2] hf, uint256 dl, address hr) external gf {
        address ea = hr;
        if (ea == address(0)) {
            ea = ei;
        }

        cv(0, 0, dl, hf, ea);
    }

    /// @dev create pandaWithGenes
    /// @param _genes panda genes
    /// @param _type  0 common 1 rare
    function dq(uint256[2] hf,uint256 dl,uint256 ij)
        external
        payable
        gf
        bt
    {
        require(msg.value >= OPEN_PACKAGE_PRICE);
        uint256 fr = cv(0, 0, dl, hf, db);
        db.dq(fr,ij);
    }

    //function buyPandaERC20(address _erc20Address, address _buyerAddress, uint256 _pandaID, uint256 _amount)
    //external
    //onlyCOO
    //whenNotPaused {
    //    saleAuctionERC20.bid(_erc20Address, _buyerAddress, _pandaID, _amount);
    //}

    /// @dev Creates a new gen0 panda with the given genes and
    ///  creates an auction for it.
    //function createGen0Auction(uint256[2] _genes) external onlyCOO {
    //    require(gen0CreatedCount < GEN0_CREATION_LIMIT);
    //
    //    uint256 pandaId = _createPanda(0, 0, 0, _genes, address(this));
    //    _approve(pandaId, saleAuction);
    //
    //    saleAuction.createAuction(
    //        pandaId,
    //        _computeNextGen0Price(),
    //        0,
    //        GEN0_AUCTION_DURATION,
    //        address(this)
    //    );
    //
    //    gen0CreatedCount++;
    //}

    function an(uint256 gc) external gf {
        require(ie(msg.sender, gc));
        //require(pandas[_pandaId].generation==1);

        fn(gc, db);

        db.an(
            gc,
            j(),
            0,
            GEN0_AUCTION_DURATION,
            msg.sender
        );
    }

    /// @dev Computes the next gen0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function j() internal view returns(uint256) {
        uint256 fu = db.s();

        require(fu == uint256(uint128(fu)));

        uint256 eq = fu + (fu / 2);

        // We never auction for less than starting price
        if (eq < GEN0_STARTING_PRICE) {
            eq = GEN0_STARTING_PRICE;
        }

        return eq;
    }
}

/// @title CryptoPandas: Collectible, breedable, and oh-so-adorable cats on the Ethereum blockchain.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev The main CryptoPandas contract, keeps track of kittens so they don't wander around and get lost.
contract PandaCore is PandaMinting {

    // This is the main CryptoPandas contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle auctions and our super-top-secret genetic combination algorithm. The auctions are
    // seperate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // panda ownership. The genetic combination algorithm is kept seperate so we can open-source all of
    // the rest of our code without making it _too_ easy for folks to figure out how the genetics work.
    // Don't worry, I'm sure someone will reverse engineer it soon enough!
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of CK. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - PandaBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - PandaAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - PandaOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - PandaBreeding: This file contains the methods necessary to breed cats together, including
    //             keeping track of siring offers, and relies on an external genetic combination contract.
    //
    //      - PandaAuctions: Here we have the public methods for auctioning or bidding on cats or siring
    //             services. The actual auction functionality is handled in two sibling contracts (one
    //             for sales and one for siring), while auction creation and bidding is mostly mediated
    //             through this facet of the core contract.
    //
    //      - PandaMinting: This final facet contains the functionality we use for creating new gen0 cats.
    //             the community is new), and all others can only be created and then immediately put up
    //             for auction via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 50k gen0 cats. After that, it's all up to the
    //             community to breed, breed, breed!

    // Set in case the core contract is broken and an upgrade is required
    address public ah;

    /// @notice Creates the main CryptoPandas smart contract instance.
    function PandaCore() public {
        // Starts paused.
        hm = true;

        // the creator of the contract is the initial CEO
        ed = msg.sender;

        // the creator of the contract is also the initial COO
        ei = msg.sender;

        // move these code to init(), so we not excceed gas limit
        //uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        //wizzPandaQuota[1] = 100;

        //_createPanda(0, 0, 0, _genes, address(0));
    }

    /// init contract
    function iq() external go dx {
        // make sure init() only run once
        require(hg.length == 0);
        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        uint256[2] memory hf = [uint256(-1),uint256(-1)];

        bf[1] = 100;
       cv(0, 0, 0, hf, address(0));
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious

    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function ci(address dy) external go dx {
        // See README.md for updgrade plan
        ah = dy;
        ContractUpgrade(dy);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(db) ||
            msg.sender == address(bq)
        );
    }

    /// @notice Returns all the relevant information about a specific panda.
    /// @param _id The ID of the panda of interest.
    function fo(uint256 jb)
        external
        view
        returns (
        bool dr,
        bool ge,
        uint256 bv,
        uint256 cw,
        uint256 cu,
        uint256 et,
        uint256 fi,
        uint256 ht,
        uint256 dt,
        uint256[2] ic
    ) {
        Panda storage jc = hg[jb];

        // if this variable is 0 then it's not gestating
        dr = (jc.cu != 0);
        ge = (jc.at <= block.number);
        bv = uint256(jc.bv);
        cw = uint256(jc.at);
        cu = uint256(jc.cu);
        et = uint256(jc.et);
        fi = uint256(jc.fi);
        ht = uint256(jc.ht);
        dt = uint256(jc.dt);
        ic = jc.ic;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function gp() public go dx {
        require(db != address(0));
        require(bq != address(0));
        require(de != address(0));
        require(ah == address(0));

        // Actually unpause the contract.
        super.gp();
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function az() external gx {
        uint256 balance = this.balance;
        // Subtract all the currently pregnant kittens we have, plus 1 of margin.
        uint256 cs = (bl + 1) * cx;

        if (balance > cs) {
            ej.send(balance - cs);
        }
    }
}
