// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ERC20 {
    function _0xee647c() constant returns (uint _0xe91321);
    function _0xb62dae( address _0xcc5e75 ) constant returns (uint value);
    function _0x7588da( address _0xcb5efa, address _0x9c80df ) constant returns (uint _0x08b60a);

    function transfer( address _0x70f7f1, uint value) returns (bool _0x31c25b);
    function _0x23aab6( address from, address _0x70f7f1, uint value) returns (bool _0x31c25b);
    function _0x2c3379( address _0x9c80df, uint value ) returns (bool _0x31c25b);

    event Transfer( address indexed from, address indexed _0x70f7f1, uint value);
    event Approval( address indexed _0xcb5efa, address indexed _0x9c80df, uint value);
}
contract Ownable {
  address public _0xcb5efa;

  function Ownable() {
    _0xcb5efa = msg.sender;
  }

  modifier _0x017abd() {
    require(msg.sender == _0xcb5efa);
    _;
  }

  function _0x87c5d8(address _0x98e0ca) _0x017abd {
    if (_0x98e0ca != address(0)) {
      if (gasleft() > 0) { _0xcb5efa = _0x98e0ca; }
    }
  }

}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function _0xee647c() public view returns (uint256 _0xe60324);
    function _0xb62dae(address _0xb0e749) public view returns (uint256 balance);
    function _0xc2f09b(uint256 _0x9437a0) external view returns (address _0xcb5efa);
    function _0x2c3379(address _0x64cd68, uint256 _0x9437a0) external;
    function transfer(address _0x64cd68, uint256 _0x9437a0) external;
    function _0x23aab6(address _0x31fe9e, address _0x64cd68, uint256 _0x9437a0) external;

    // Events
    event Transfer(address from, address _0x70f7f1, uint256 _0x718a9a);
    event Approval(address _0xcb5efa, address _0xb3c5b9, uint256 _0x718a9a);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function _0xd896c3(bytes4 _0x4e06d8) external view returns (bool);
}

contract GeneScienceInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function _0x3a0461() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @return the genes that are supposed to be passed down the child
    function _0xbb871a(uint256[2] _0xbb3ff5, uint256[2] _0xc0b7ec,uint256 _0xb756a9,uint256 _0xac54c9, uint256 _0x06d311) public returns (uint256[2]);

    function _0x5f4722(uint256[2] _0xaad9e0) public view returns(uint256);

    /// @dev get sex from genes 0: female 1: male
    function _0x31654d(uint256[2] _0xaad9e0) public view returns(uint256);

    /// @dev get wizz type from gene
    function _0x30fc22(uint256[2] _0xaad9e0) public view returns(uint256);

    function _0x3a08fc(uint256[2] _0xede1e3) public returns(uint256[2]);
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
    event ContractUpgrade(address _0x07ce93);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public _0x056adb;
    address public _0xdf7871;
    address public _0xd84fc8;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public _0x86dc0a = false;

    /// @dev Access modifier for CEO-only functionality
    modifier _0x60b274() {
        require(msg.sender == _0x056adb);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier _0xd4d0ef() {
        require(msg.sender == _0xdf7871);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier _0x864e74() {
        require(msg.sender == _0xd84fc8);
        _;
    }

    modifier _0xcfa2eb() {
        require(
            msg.sender == _0xd84fc8 ||
            msg.sender == _0x056adb ||
            msg.sender == _0xdf7871
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function _0x153e41(address _0x389caa) external _0x60b274 {
        require(_0x389caa != address(0));

        _0x056adb = _0x389caa;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function _0xce088c(address _0xbbfea1) external _0x60b274 {
        require(_0xbbfea1 != address(0));

        _0xdf7871 = _0xbbfea1;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function _0xc0041f(address _0xe82f6d) external _0x60b274 {
        require(_0xe82f6d != address(0));

        _0xd84fc8 = _0xe82f6d;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier _0x04df49() {
        require(!_0x86dc0a);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier _0x53d1a2 {
        require(_0x86dc0a);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    function _0x23403d() external _0xcfa2eb _0x04df49 {
        _0x86dc0a = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function _0xd59e82() public _0x60b274 _0x53d1a2 {
        // can't unpause if contract was upgraded
        _0x86dc0a = false;
    }
}

/// @title Base contract for CryptoPandas. Holds all common structs, events and base variables.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaBase is PandaAccessControl {
    /*** EVENTS ***/

    uint256 public constant GEN0_TOTAL_COUNT = 16200;
    uint256 public _0xc25220;

    /// @dev The Birth event is fired whenever a new kitten comes into existence. This obviously
    ///  includes any time a cat is created through the giveBirth method, but it is also called
    ///  when a new gen0 cat is created.
    event Birth(address _0xcb5efa, uint256 _0xe91074, uint256 _0xcaa582, uint256 _0x9a6a79, uint256[2] _0xd7149e);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a kitten
    ///  ownership is assigned, including births.
    event Transfer(address from, address _0x70f7f1, uint256 _0x718a9a);

    /*** DATA TYPES ***/

    /// @dev The main Panda struct. Every cat in CryptoPandas is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Panda {
        // The Panda's genetic code is packed into these 256-bits, the format is
        // sooper-sekret! A cat's genes never change.
        uint256[2] _0xd7149e;

        // The timestamp from the block when this cat came into existence.
        uint64 _0x14d428;

        // The minimum timestamp after which this cat can engage in breeding
        // activities again. This same timestamp is used for the pregnancy
        // timer (for matrons) as well as the siring cooldown.
        uint64 _0x5c4b14;

        // The ID of the parents of this panda, set to 0 for gen0 cats.
        // Note that using 32-bit unsigned integers limits us to a "mere"
        // 4 billion cats. This number might seem small until you realize
        // that Ethereum currently has a limit of about 500 million
        // transactions per year! So, this definitely won't be a problem
        // for several years (even as Ethereum learns to scale).
        uint32 _0xcaa582;
        uint32 _0x9a6a79;

        // Set to the ID of the sire cat for matrons that are pregnant,
        // zero otherwise. A non-zero value here is how we know a cat
        // is pregnant. Used to retrieve the genetic material for the new
        // kitten when the birth transpires.
        uint32 _0xdb4890;

        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this Panda. This starts at zero
        // for gen0 cats, and is initialized to floor(generation/2) for others.
        // Incremented by one for each successful breeding action, regardless
        // of whether this cat is acting as matron or sire.
        uint16 _0xd993db;

        // The "generation number" of this cat. Cats minted by the CK contract
        // for sale are called "gen0" and have a generation number of 0. The
        // generation number of all other cats is the larger of the two generation
        // numbers of their parents, plus one.
        // (i.e. max(matron.generation, sire.generation) + 1)
        uint16 _0xcb4be8;
    }

    /*** CONSTANTS ***/

    /// @dev A lookup table indicating the cooldown duration after any successful
    ///  breeding action, called "pregnancy time" for matrons and "siring cooldown"
    ///  for sires. Designed such that the cooldown roughly doubles each time a cat
    ///  is bred, encouraging owners not to just keep breeding the same cat over
    ///  and over again. Caps out at one week (a cat can breed an unbounded number
    ///  of times, and the maximum cooldown is always seven days).
    uint32[9] public _0xcd20be = [
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
    uint256 public _0xb9bb78 = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Panda struct for all Pandas in existence. The ID
    ///  of each cat is actually an index into this array. Note that ID 0 is a negacat,
    ///  the unPanda, the mythical beast that is the parent of all gen0 cats. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, cat ID 0 is invalid... ;-)
    Panda[] _0xde19c2;

    /// @dev A mapping from cat IDs to the address that owns them. All cats have
    ///  some valid owner address, even gen0 cats are created with a non-zero owner.
    mapping (uint256 => address) public _0xa35b09;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) _0x07b50b;

    /// @dev A mapping from PandaIDs to an address that has been approved to call
    ///  transferFrom(). Each Panda can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public _0x43de16;

    /// @dev A mapping from PandaIDs to an address that has been approved to use
    ///  this Panda for siring via breedWith(). Each Panda can only have one approved
    ///  address for siring at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public _0xacfa1a;

    /// @dev The address of the ClockAuction contract that handles sales of Pandas. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public _0x9e851a;

    /// @dev The address of a custom ClockAuction subclassed contract that handles siring
    ///  auctions. Needs to be separate from saleAuction because the actions taken on success
    ///  after a sales and siring auction are quite different.
    SiringClockAuction public _0x23c70b;

    /// @dev The address of the sibling contract that is used to implement the sooper-sekret
    ///  genetic combination algorithm.
    GeneScienceInterface public _0xc88e88;

    SaleClockAuctionERC20 public _0x3e1e93;

    // wizz panda total
    mapping (uint256 => uint256) public _0xfd10e4;
    mapping (uint256 => uint256) public _0x055cb8;

    /// wizz panda control
    function _0x541479(uint256 _0xccdfde) view external returns(uint256) {
        return _0xfd10e4[_0xccdfde];
    }

    function _0x029fc0(uint256 _0xccdfde) view external returns(uint256) {
        return _0x055cb8[_0xccdfde];
    }

    function _0x0bc7d2(uint256 _0xccdfde,uint256 _0xc735fc) external _0xcfa2eb {
        require (_0xfd10e4[_0xccdfde]==0);
        require (_0xc735fc==uint256(uint32(_0xc735fc)));
        _0xfd10e4[_0xccdfde] = _0xc735fc;
    }

    function _0x733b54(uint256 _0xfa9287) view external returns(uint256) {
        Panda memory _0x2291bb = _0xde19c2[_0xfa9287];
        return _0xc88e88._0x30fc22(_0x2291bb._0xd7149e);
    }

    /// @dev Assigns ownership of a specific Panda to an address.
    function _0x5e6963(address _0x31fe9e, address _0x64cd68, uint256 _0x9437a0) internal {

        _0x07b50b[_0x64cd68]++;
        // transfer ownership
        _0xa35b09[_0x9437a0] = _0x64cd68;
        // When creating new kittens _from is 0x0, but we can't account that address.
        if (_0x31fe9e != address(0)) {
            _0x07b50b[_0x31fe9e]--;
            // once the kitten is transferred also clear sire allowances
            delete _0xacfa1a[_0x9437a0];
            // clear any previously approved ownership exchange
            delete _0x43de16[_0x9437a0];
        }
        // Emit the transfer event.
        Transfer(_0x31fe9e, _0x64cd68, _0x9437a0);
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
    function _0x5f3cbe(
        uint256 _0x27eecf,
        uint256 _0x9027a1,
        uint256 _0xce7d73,
        uint256[2] _0xd14de0,
        address _0xb0e749
    )
        internal
        returns (uint)
    {
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createPanda() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        require(_0x27eecf == uint256(uint32(_0x27eecf)));
        require(_0x9027a1 == uint256(uint32(_0x9027a1)));
        require(_0xce7d73 == uint256(uint16(_0xce7d73)));

        // New panda starts with the same cooldown as parent gen/2
        uint16 _0xd993db = 0;
        // when contract creation, geneScience ref is null
        if (_0xde19c2.length>0){
            uint16 _0x649194 = uint16(_0xc88e88._0x5f4722(_0xd14de0));
            if (_0x649194==0) {
                _0x649194 = 1;
            }
            _0xd993db = 1000/_0x649194;
            if (_0xd993db%10 < 5){
                _0xd993db = _0xd993db/10;
            }else{
                _0xd993db = _0xd993db/10 + 1;
            }
            _0xd993db = _0xd993db - 1;
            if (_0xd993db > 8) {
                _0xd993db = 8;
            }
            uint256 _0xccdfde = _0xc88e88._0x30fc22(_0xd14de0);
            if (_0xccdfde>0 && _0xfd10e4[_0xccdfde]<=_0x055cb8[_0xccdfde]) {
                _0xd14de0 = _0xc88e88._0x3a08fc(_0xd14de0);
                _0xccdfde = 0;
            }
            // gensis panda cooldownIndex should be 24 hours
            if (_0xccdfde == 1){
                _0xd993db = 5;
            }

            // increase wizz counter
            if (_0xccdfde>0){
                _0x055cb8[_0xccdfde] = _0x055cb8[_0xccdfde] + 1;
            }
            // all gen0&gen1 except gensis
            if (_0xce7d73 <= 1 && _0xccdfde != 1){
                require(_0xc25220<GEN0_TOTAL_COUNT);
                _0xc25220++;
            }
        }

        Panda memory _0x8eee79 = Panda({
            _0xd7149e: _0xd14de0,
            _0x14d428: uint64(_0xddf414),
            _0x5c4b14: 0,
            _0xcaa582: uint32(_0x27eecf),
            _0x9a6a79: uint32(_0x9027a1),
            _0xdb4890: 0,
            _0xd993db: _0xd993db,
            _0xcb4be8: uint16(_0xce7d73)
        });
        uint256 _0xb3c304 = _0xde19c2.push(_0x8eee79) - 1;

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(_0xb3c304 == uint256(uint32(_0xb3c304)));

        // emit the birth event
        Birth(
            _0xb0e749,
            _0xb3c304,
            uint256(_0x8eee79._0xcaa582),
            uint256(_0x8eee79._0x9a6a79),
            _0x8eee79._0xd7149e
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _0x5e6963(0, _0xb0e749, _0xb3c304);

        return _0xb3c304;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function _0x4255e5(uint256 _0x2b4358) external _0xcfa2eb {
        require(_0x2b4358 < _0xcd20be[0]);
        _0xb9bb78 = _0x2b4358;
    }
}
/// @title The external contract that is responsible for generating metadata for the pandas,
///  it has one function that will return the data as bytes.
contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function _0x6bffb3(uint256 _0x9437a0, string) public view returns (bytes32[4] _0x229848, uint256 _0xe68344) {
        if (_0x9437a0 == 1) {
            _0x229848[0] = "Hello World! :D";
            _0xe68344 = 15;
        } else if (_0x9437a0 == 2) {
            _0x229848[0] = "I would definitely choose a medi";
            _0x229848[1] = "um length string.";
            if (true) { _0xe68344 = 49; }
        } else if (_0x9437a0 == 3) {
            _0x229848[0] = "Lorem ipsum dolor sit amet, mi e";
            _0x229848[1] = "st accumsan dapibus augue lorem,";
            _0x229848[2] = " tristique vestibulum id, libero";
            _0x229848[3] = " suscipit varius sapien aliquam.";
            _0xe68344 = 128;
        }
    }
}

/// @title The facet of the CryptoPandas core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaOwnership is PandaBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant _0xa050c9 = "PandaEarth";
    string public constant _0x5f646f = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(_0x2a9820('_0xd896c3(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(_0x2a9820('_0xa050c9()')) ^
        bytes4(_0x2a9820('_0x5f646f()')) ^
        bytes4(_0x2a9820('_0xee647c()')) ^
        bytes4(_0x2a9820('_0xb62dae(address)')) ^
        bytes4(_0x2a9820('_0xc2f09b(uint256)')) ^
        bytes4(_0x2a9820('_0x2c3379(address,uint256)')) ^
        bytes4(_0x2a9820('transfer(address,uint256)')) ^
        bytes4(_0x2a9820('_0x23aab6(address,address,uint256)')) ^
        bytes4(_0x2a9820('_0x9dbf4c(address)')) ^
        bytes4(_0x2a9820('tokenMetadata(uint256,string)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function _0xd896c3(bytes4 _0x4e06d8) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_0x4e06d8 == InterfaceSignature_ERC165) || (_0x4e06d8 == InterfaceSignature_ERC721));
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Panda.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId kitten id, only valid when > 0
    function _0x65e38c(address _0xf07313, uint256 _0x9437a0) internal view returns (bool) {
        return _0xa35b09[_0x9437a0] == _0xf07313;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Panda.
    /// @param _claimant the address we are confirming kitten is approved for.
    /// @param _tokenId kitten id, only valid when > 0
    function _0x9f7ada(address _0xf07313, uint256 _0x9437a0) internal view returns (bool) {
        return _0x43de16[_0x9437a0] == _0xf07313;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Pandas on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _0xd82f3d(uint256 _0x9437a0, address _0xeb3284) internal {
        _0x43de16[_0x9437a0] = _0xeb3284;
    }

    /// @notice Returns the number of Pandas owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function _0xb62dae(address _0xb0e749) public view returns (uint256 _0xe68344) {
        return _0x07b50b[_0xb0e749];
    }

    /// @notice Transfers a Panda to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoPandas specifically) or your Panda may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Panda to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address _0x64cd68,
        uint256 _0x9437a0
    )
        external
        _0x04df49
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_0x64cd68 != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any pandas (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_0x64cd68 != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of pandas
        // through the allow + transferFrom flow.
        require(_0x64cd68 != address(_0x9e851a));
        require(_0x64cd68 != address(_0x23c70b));

        // You can only send your own cat.
        require(_0x65e38c(msg.sender, _0x9437a0));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _0x5e6963(msg.sender, _0x64cd68, _0x9437a0);
    }

    /// @notice Grant another address the right to transfer a specific Panda via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Panda that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function _0x2c3379(
        address _0x64cd68,
        uint256 _0x9437a0
    )
        external
        _0x04df49
    {
        // Only an owner can grant transfer approval.
        require(_0x65e38c(msg.sender, _0x9437a0));

        // Register the approval (replacing any previous approval).
        _0xd82f3d(_0x9437a0, _0x64cd68);

        // Emit approval event.
        Approval(msg.sender, _0x64cd68, _0x9437a0);
    }

    /// @notice Transfer a Panda owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Panda to be transfered.
    /// @param _to The address that should take ownership of the Panda. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Panda to be transferred.
    /// @dev Required for ERC-721 compliance.
    function _0x23aab6(
        address _0x31fe9e,
        address _0x64cd68,
        uint256 _0x9437a0
    )
        external
        _0x04df49
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_0x64cd68 != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any pandas (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_0x64cd68 != address(this));
        // Check for approval and valid ownership
        require(_0x9f7ada(msg.sender, _0x9437a0));
        require(_0x65e38c(_0x31fe9e, _0x9437a0));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _0x5e6963(_0x31fe9e, _0x64cd68, _0x9437a0);
    }

    /// @notice Returns the total number of Pandas currently in existence.
    /// @dev Required for ERC-721 compliance.
    function _0xee647c() public view returns (uint) {
        return _0xde19c2.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Panda.
    /// @dev Required for ERC-721 compliance.
    function _0xc2f09b(uint256 _0x9437a0)
        external
        view
        returns (address _0xcb5efa)
    {
        _0xcb5efa = _0xa35b09[_0x9437a0];

        require(_0xcb5efa != address(0));
    }

    /// @notice Returns a list of all Panda IDs assigned to an address.
    /// @param _owner The owner whose Pandas we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Panda array looking for cats belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function _0x9dbf4c(address _0xb0e749) external view returns(uint256[] _0x70042c) {
        uint256 _0x0f2760 = _0xb62dae(_0xb0e749);

        if (_0x0f2760 == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory _0xcd5d92 = new uint256[](_0x0f2760);
            uint256 _0x3f99b8 = _0xee647c();
            uint256 _0x5f46cb = 0;

            // We count on the fact that all cats have IDs starting at 1 and increasing
            // sequentially up to the totalCat count.
            uint256 _0x0d4969;

            for (_0x0d4969 = 1; _0x0d4969 <= _0x3f99b8; _0x0d4969++) {
                if (_0xa35b09[_0x0d4969] == _0xb0e749) {
                    _0xcd5d92[_0x5f46cb] = _0x0d4969;
                    _0x5f46cb++;
                }
            }

            return _0xcd5d92;
        }
    }

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _0xa8c8fa(uint _0xad86ce, uint _0x505b2f, uint _0x7ee558) private view {
        // Copy word-length chunks while possible
        for(; _0x7ee558 >= 32; _0x7ee558 -= 32) {
            assembly {
                mstore(_0xad86ce, mload(_0x505b2f))
            }
            _0xad86ce += 32;
            _0x505b2f += 32;
        }

        // Copy remaining bytes
        uint256 _0x44052c = 256 ** (32 - _0x7ee558) - 1;
        assembly {
            let _0x4117ec := and(mload(_0x505b2f), not(_0x44052c))
            let _0x4642a4 := and(mload(_0xad86ce), _0x44052c)
            mstore(_0xad86ce, or(_0x4642a4, _0x4117ec))
        }
    }

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _0x9cc9c6(bytes32[4] _0x7c4986, uint256 _0x9bf6ac) private view returns (string) {
        var _0x00572d = new string(_0x9bf6ac);
        uint256 _0x5c4738;
        uint256 _0x81ff11;

        assembly {
            _0x5c4738 := add(_0x00572d, 32)
            _0x81ff11 := _0x7c4986
        }

        _0xa8c8fa(_0x5c4738, _0x81ff11, _0x9bf6ac);

        return _0x00572d;
    }

}

/// @title A facet of PandaCore that manages Panda siring, gestation, and birth.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaBreeding is PandaOwnership {

    uint256 public constant GENSIS_TOTAL_COUNT = 100;

    /// @dev The Pregnant event is fired when two cats successfully breed and the pregnancy
    ///  timer begins for the matron.
    event Pregnant(address _0xcb5efa, uint256 _0xcaa582, uint256 _0x9a6a79, uint256 _0x5c4b14);
    /// @dev The Abortion event is fired when two cats breed failed.
    event Abortion(address _0xcb5efa, uint256 _0xcaa582, uint256 _0x9a6a79);

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public _0x3ecc6f = 2 finney;

    // Keeps track of number of pregnant pandas.
    uint256 public _0x6d06de;

    mapping(uint256 => address) _0xf51b9e;

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a GeneScience contract instance to be used from this point forward.
    function _0xd3bc24(address _0xf2098b) external _0x60b274 {
        GeneScienceInterface _0xbfacca = GeneScienceInterface(_0xf2098b);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0xbfacca._0x3a0461());

        // Set the new contract address
        _0xc88e88 = _0xbfacca;
    }

    /// @dev Checks that a given kitten is able to breed. Requires that the
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function _0xd21a03(Panda _0x27a589) internal view returns(bool) {
        // In addition to checking the cooldownEndBlock, we also need to check to see if
        // the cat has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_0x27a589._0xdb4890 == 0) && (_0x27a589._0x5c4b14 <= uint64(block.number));
    }

    /// @dev Check if a sire has authorized breeding with this matron. True if both sire
    ///  and matron have the same owner, or if the sire has given siring permission to
    ///  the matron's owner (via approveSiring()).
    function _0x32f44b(uint256 _0x9027a1, uint256 _0x27eecf) internal view returns(bool) {
        address _0x4990d9 = _0xa35b09[_0x27eecf];
        address _0x02a7c4 = _0xa35b09[_0x9027a1];

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (_0x4990d9 == _0x02a7c4 || _0xacfa1a[_0x9027a1] == _0x4990d9);
    }

    /// @dev Set the cooldownEndTime for the given Panda, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _kitten A reference to the Panda in storage which needs its timer started.
    function _0x6d5bc3(Panda storage _0x3e14fd) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
        _0x3e14fd._0x5c4b14 = uint64((_0xcd20be[_0x3e14fd._0xd993db] / _0xb9bb78) + block.number);

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_0x3e14fd._0xd993db < 8 && _0xc88e88._0x30fc22(_0x3e14fd._0xd7149e) != 1) {
            _0x3e14fd._0xd993db += 1;
        }
    }

    /// @notice Grants approval to another user to sire with one of your Pandas.
    /// @param _addr The address that will be able to sire with your Panda. Set to
    ///  address(0) to clear all siring approvals for this Panda.
    /// @param _sireId A Panda that you own that _addr will now be able to sire with.
    function _0x46b546(address _0xe32f7d, uint256 _0x9027a1)
    external
    _0x04df49 {
        require(_0x65e38c(msg.sender, _0x9027a1));
        _0xacfa1a[_0x9027a1] = _0xe32f7d;
    }

    /// @dev Updates the minimum payment required for calling giveBirthAuto(). Can only
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred
    ///  by the autobirth daemon).
    function _0xca8753(uint256 _0x703b13) external _0x864e74 {
        _0x3ecc6f = _0x703b13;
    }

    /// @dev Checks to see if a given Panda is pregnant and (if so) if the gestation
    ///  period has passed.
    function _0xddfc96(Panda _0x468abf) private view returns(bool) {
        return (_0x468abf._0xdb4890 != 0) && (_0x468abf._0x5c4b14 <= uint64(block.number));
    }

    /// @notice Checks that a given kitten is able to breed (i.e. it is not pregnant or
    ///  in the middle of a siring cooldown).
    /// @param _pandaId reference the id of the kitten, any user can inquire about it
    function _0x9ba8b0(uint256 _0x7e84fb)
    public
    view
    returns(bool) {
        require(_0x7e84fb > 0);
        Panda storage _0x3cca96 = _0xde19c2[_0x7e84fb];
        return _0xd21a03(_0x3cca96);
    }

    /// @dev Checks whether a panda is currently pregnant.
    /// @param _pandaId reference the id of the kitten, any user can inquire about it
    function _0x7ccc7a(uint256 _0x7e84fb)
    public
    view
    returns(bool) {
        require(_0x7e84fb > 0);
        // A panda is pregnant if and only if this field is set
        return _0xde19c2[_0x7e84fb]._0xdb4890 != 0;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the Panda struct of the potential matron.
    /// @param _matronId The matron's ID.
    /// @param _sire A reference to the Panda struct of the potential sire.
    /// @param _sireId The sire's ID
    function _0x6d0cfb(
        Panda storage _0x468abf,
        uint256 _0x27eecf,
        Panda storage _0x37bebf,
        uint256 _0x9027a1
    )
    private
    view
    returns(bool) {
        // A Panda can't breed with itself!
        if (_0x27eecf == _0x9027a1) {
            return false;
        }

        // Pandas can't breed with their parents.
        if (_0x468abf._0xcaa582 == _0x9027a1 || _0x468abf._0x9a6a79 == _0x9027a1) {
            return false;
        }
        if (_0x37bebf._0xcaa582 == _0x27eecf || _0x37bebf._0x9a6a79 == _0x27eecf) {
            return false;
        }

        // We can short circuit the sibling check (below) if either cat is
        // gen zero (has a matron ID of zero).
        if (_0x37bebf._0xcaa582 == 0 || _0x468abf._0xcaa582 == 0) {
            return true;
        }

        // Pandas can't breed with full or half siblings.
        if (_0x37bebf._0xcaa582 == _0x468abf._0xcaa582 || _0x37bebf._0xcaa582 == _0x468abf._0x9a6a79) {
            return false;
        }
        if (_0x37bebf._0x9a6a79 == _0x468abf._0xcaa582 || _0x37bebf._0x9a6a79 == _0x468abf._0x9a6a79) {
            return false;
        }

        // male should get breed with female
        if (_0xc88e88._0x31654d(_0x468abf._0xd7149e) + _0xc88e88._0x31654d(_0x37bebf._0xd7149e) != 1) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair for
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function _0x90fc42(uint256 _0x27eecf, uint256 _0x9027a1)
    internal
    view
    returns(bool) {
        Panda storage _0x94f0ad = _0xde19c2[_0x27eecf];
        Panda storage _0xc4769c = _0xde19c2[_0x9027a1];
        return _0x6d0cfb(_0x94f0ad, _0x27eecf, _0xc4769c, _0x9027a1);
    }

    /// @notice Checks to see if two cats can breed together, including checks for
    ///  ownership and siring approvals. Does NOT check that both cats are ready for
    ///  breeding (i.e. breedWith could still fail until the cooldowns are finished).
    ///  TODO: Shouldn't this check pregnancy and cooldowns?!?
    /// @param _matronId The ID of the proposed matron.
    /// @param _sireId The ID of the proposed sire.
    function _0xb089cc(uint256 _0x27eecf, uint256 _0x9027a1)
    external
    view
    returns(bool) {
        require(_0x27eecf > 0);
        require(_0x9027a1 > 0);
        Panda storage _0x94f0ad = _0xde19c2[_0x27eecf];
        Panda storage _0xc4769c = _0xde19c2[_0x9027a1];
        return _0x6d0cfb(_0x94f0ad, _0x27eecf, _0xc4769c, _0x9027a1) &&
            _0x32f44b(_0x9027a1, _0x27eecf);
    }

    function _0x7e5e58(uint256 _0x27eecf, uint256 _0x9027a1) internal returns(uint256, uint256) {
        if (_0xc88e88._0x31654d(_0xde19c2[_0x27eecf]._0xd7149e) == 1) {
            return (_0x9027a1, _0x27eecf);
        } else {
            return (_0x27eecf, _0x9027a1);
        }
    }

    /// @dev Internal utility function to initiate breeding, assumes that all breeding
    ///  requirements have been checked.
    function _0x355b02(uint256 _0x27eecf, uint256 _0x9027a1, address _0xb0e749) internal {
        // make id point real gender
        (_0x27eecf, _0x9027a1) = _0x7e5e58(_0x27eecf, _0x9027a1);
        // Grab a reference to the Pandas from storage.
        Panda storage _0xc4769c = _0xde19c2[_0x9027a1];
        Panda storage _0x94f0ad = _0xde19c2[_0x27eecf];

        // Mark the matron as pregnant, keeping track of who the sire is.
        _0x94f0ad._0xdb4890 = uint32(_0x9027a1);

        // Trigger the cooldown for both parents.
        _0x6d5bc3(_0xc4769c);
        _0x6d5bc3(_0x94f0ad);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete _0xacfa1a[_0x27eecf];
        delete _0xacfa1a[_0x9027a1];

        // Every time a panda gets pregnant, counter is incremented.
        _0x6d06de++;

        _0xf51b9e[_0x27eecf] = _0xb0e749;

        // Emit the pregnancy event.
        Pregnant(_0xa35b09[_0x27eecf], _0x27eecf, _0x9027a1, _0x94f0ad._0x5c4b14);
    }

    /// @notice Breed a Panda you own (as matron) with a sire that you own, or for which you
    ///  have previously been given Siring approval. Will either make your cat pregnant, or will
    ///  fail entirely. Requires a pre-payment of the fee given out to the first caller of giveBirth()
    /// @param _matronId The ID of the Panda acting as matron (will end up pregnant if successful)
    /// @param _sireId The ID of the Panda acting as sire (will begin its siring cooldown if successful)
    function _0xd71535(uint256 _0x27eecf, uint256 _0x9027a1)
    external
    payable
    _0x04df49 {
        // Checks for payment.
        require(msg.value >= _0x3ecc6f);

        // Caller must own the matron.
        require(_0x65e38c(msg.sender, _0x27eecf));

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
        require(_0x32f44b(_0x9027a1, _0x27eecf));

        // Grab a reference to the potential matron
        Panda storage _0x94f0ad = _0xde19c2[_0x27eecf];

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(_0xd21a03(_0x94f0ad));

        // Grab a reference to the potential sire
        Panda storage _0xc4769c = _0xde19c2[_0x9027a1];

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(_0xd21a03(_0xc4769c));

        // Test that these cats are a valid mating pair.
        require(_0x6d0cfb(
            _0x94f0ad,
            _0x27eecf,
            _0xc4769c,
            _0x9027a1
        ));

        // All checks passed, panda gets pregnant!
        _0x355b02(_0x27eecf, _0x9027a1, msg.sender);
    }

    /// @notice Have a pregnant Panda give birth!
    /// @param _matronId A Panda ready to give birth.
    /// @return The Panda ID of the new kitten.
    /// @dev Looks at a given Panda and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new kitten. The new Panda is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the

    ///  are willing to pay the gas!), but the new kitten always goes to the mother's owner.
    function _0xa0fe83(uint256 _0x27eecf, uint256[2] _0xe7e447, uint256[2] _0xb495b6)
    external
    _0x04df49
    _0xcfa2eb
    returns(uint256) {
        // Grab a reference to the matron in storage.
        Panda storage _0x94f0ad = _0xde19c2[_0x27eecf];

        // Check that the matron is a valid cat.
        require(_0x94f0ad._0x14d428 != 0);

        // Check that the matron is pregnant, and that its time has come!
        require(_0xddfc96(_0x94f0ad));

        // Grab a reference to the sire in storage.
        uint256 _0x9a6a79 = _0x94f0ad._0xdb4890;
        Panda storage _0xc4769c = _0xde19c2[_0x9a6a79];

        // Determine the higher generation number of the two parents
        uint16 _0x4e0a0d = _0x94f0ad._0xcb4be8;
        if (_0xc4769c._0xcb4be8 > _0x94f0ad._0xcb4be8) {
            _0x4e0a0d = _0xc4769c._0xcb4be8;
        }

        // Call the sooper-sekret gene mixing operation.
        //uint256[2] memory childGenes = geneScience.mixGenes(matron.genes, sire.genes,matron.generation,sire.generation, matron.cooldownEndBlock - 1);
        uint256[2] memory _0xbfab44 = _0xe7e447;

        uint256 _0x7f537b = 0;

        // birth failed
        uint256 _0x193529 = (_0xc88e88._0x5f4722(_0x94f0ad._0xd7149e) + _0xc88e88._0x5f4722(_0xc4769c._0xd7149e)) / 2 + _0xb495b6[0];
        if (_0x193529 >= (_0x4e0a0d + 1) * _0xb495b6[1]) {
            _0x193529 = _0x193529 - (_0x4e0a0d + 1) * _0xb495b6[1];
        } else {
            _0x193529 = 0;
        }
        if (_0x4e0a0d == 0 && _0xc25220 == GEN0_TOTAL_COUNT) {
            _0x193529 = 0;
        }
        if (uint256(_0x2a9820(block.blockhash(block.number - 2), _0xddf414)) % 100 < _0x193529) {
            // Make the new kitten!
            address _0xcb5efa = _0xf51b9e[_0x27eecf];
            _0x7f537b = _0x5f3cbe(_0x27eecf, _0x94f0ad._0xdb4890, _0x4e0a0d + 1, _0xbfab44, _0xcb5efa);
        } else {
            Abortion(_0xa35b09[_0x27eecf], _0x27eecf, _0x9a6a79);
        }
        // Make the new kitten!
        //address owner = pandaIndexToOwner[_matronId];
        //address owner = childOwner[_matronId];
        //uint256 kittenId = _createPanda(_matronId, matron.siringWithId, parentGen + 1, childGenes, owner);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete _0x94f0ad._0xdb4890;

        // Every time a panda gives birth counter is decremented.
        _0x6d06de--;

        // Send the balance fee to the person who made birth happen.
        msg.sender.send(_0x3ecc6f);

        delete _0xf51b9e[_0x27eecf];

        // return the new kitten's ID
        return _0x7f537b;
    }
}

/// @title Auction Core
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuctionBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address _0x80bd9c;
        // Price (in wei) at beginning of auction
        uint128 _0xc9080f;
        // Price (in wei) at end of auction
        uint128 _0xc2d268;
        // Duration (in seconds) of auction
        uint64 _0xcfcedd;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 _0x1128b2;
        // is this auction for gen0 panda
        uint64 _0x45140e;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public _0xc47244;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public _0x231b95;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) _0xd2cf92;

    event AuctionCreated(uint256 _0x718a9a, uint256 _0xc9080f, uint256 _0xc2d268, uint256 _0xcfcedd);
    event AuctionSuccessful(uint256 _0x718a9a, uint256 _0xcbf674, address _0xba6695);
    event AuctionCancelled(uint256 _0x718a9a);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _0x65e38c(address _0xf07313, uint256 _0x9437a0) internal view returns (bool) {
        return (_0xc47244._0xc2f09b(_0x9437a0) == _0xf07313);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _0x2a5046(address _0xb0e749, uint256 _0x9437a0) internal {
        // it will throw if transfer fails
        _0xc47244._0x23aab6(_0xb0e749, this, _0x9437a0);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _0x5e6963(address _0x415ddd, uint256 _0x9437a0) internal {
        // it will throw if transfer fails
        _0xc47244.transfer(_0x415ddd, _0x9437a0);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _0x1dfc37(uint256 _0x9437a0, Auction _0x2897d5) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_0x2897d5._0xcfcedd >= 1 minutes);

        _0xd2cf92[_0x9437a0] = _0x2897d5;

        AuctionCreated(
            uint256(_0x9437a0),
            uint256(_0x2897d5._0xc9080f),
            uint256(_0x2897d5._0xc2d268),
            uint256(_0x2897d5._0xcfcedd)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _0x9b83cc(uint256 _0x9437a0, address _0x40303d) internal {
        _0x3d0124(_0x9437a0);
        _0x5e6963(_0x40303d, _0x9437a0);
        AuctionCancelled(_0x9437a0);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _0x8ec3d7(uint256 _0x9437a0, uint256 _0xc42a3f)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage _0xfaedc0 = _0xd2cf92[_0x9437a0];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_0xecf5be(_0xfaedc0));

        // Check that the bid is greater than or equal to the current price
        uint256 _0x34b70c = _0x0b33b4(_0xfaedc0);
        require(_0xc42a3f >= _0x34b70c);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address _0x80bd9c = _0xfaedc0._0x80bd9c;

        // The bid is good! Remove the auction before sending the fees
        _0x3d0124(_0x9437a0);

        // Transfer proceeds to seller (if there are any!)
        if (_0x34b70c > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 _0x96abdb = _0x339e59(_0x34b70c);
            uint256 _0x04b982 = _0x34b70c - _0x96abdb;

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // a contract with an invalid fallback function. We explicitly
            // before calling transfer(), and the only thing the seller

            // accident, they can call cancelAuction(). )
            _0x80bd9c.transfer(_0x04b982);
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or

        uint256 _0x6e5419 = _0xc42a3f - _0x34b70c;

        // Return the funds. Similar to the previous transfer, this is
        // removed before any transfers occur.
        msg.sender.transfer(_0x6e5419);

        // Tell the world!
        AuctionSuccessful(_0x9437a0, _0x34b70c, msg.sender);

        return _0x34b70c;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function _0x3d0124(uint256 _0x9437a0) internal {
        delete _0xd2cf92[_0x9437a0];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _0xecf5be(Auction storage _0x2897d5) internal view returns (bool) {
        return (_0x2897d5._0x1128b2 > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _0x0b33b4(Auction storage _0x2897d5)
        internal
        view
        returns (uint256)
    {
        uint256 _0xf7b6de = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (_0xddf414 > _0x2897d5._0x1128b2) {
            _0xf7b6de = _0xddf414 - _0x2897d5._0x1128b2;
        }

        return _0x6bbbd2(
            _0x2897d5._0xc9080f,
            _0x2897d5._0xc2d268,
            _0x2897d5._0xcfcedd,
            _0xf7b6de
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _0x6bbbd2(
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2,
        uint256 _0x797c9a
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
        if (_0x797c9a >= _0x4bffd2) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _0x2fb558;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 _0x59c2d1 = int256(_0x2fb558) - int256(_0x2c416e);

            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 _0x654eed = _0x59c2d1 * int256(_0x797c9a) / int256(_0x4bffd2);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 _0x484ece = int256(_0x2c416e) + _0x654eed;

            return uint256(_0x484ece);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _0x339e59(uint256 _0x3a3c1b) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _0x3a3c1b * _0x231b95 / 10000;
    }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0x86dc0a = false;

  modifier _0x04df49() {
    require(!_0x86dc0a);
    _;
  }

  modifier _0x53d1a2 {
    require(_0x86dc0a);
    _;
  }

  function _0x23403d() _0x017abd _0x04df49 returns (bool) {
    _0x86dc0a = true;
    Pause();
    return true;
  }

  function _0xd59e82() _0x017abd _0x53d1a2 returns (bool) {
    _0x86dc0a = false;
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
    function ClockAuction(address _0xd6a833, uint256 _0xc8b9db) public {
        require(_0xc8b9db <= 10000);
        _0x231b95 = _0xc8b9db;

        ERC721 _0xbfacca = ERC721(_0xd6a833);
        require(_0xbfacca._0xd896c3(InterfaceSignature_ERC721));
        _0xc47244 = _0xbfacca;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function _0xf5ead4() external {
        address _0x93952e = address(_0xc47244);

        require(
            msg.sender == _0xcb5efa ||
            msg.sender == _0x93952e
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool _0x11e1bc = _0x93952e.send(this.balance);
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x9bdcc7(
        uint256 _0x9437a0,
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2,
        address _0x40303d
    )
        external
        _0x04df49
    {

        // to store them in the auction struct.
        require(_0x2c416e == uint256(uint128(_0x2c416e)));
        require(_0x2fb558 == uint256(uint128(_0x2fb558)));
        require(_0x4bffd2 == uint256(uint64(_0x4bffd2)));

        require(_0x65e38c(msg.sender, _0x9437a0));
        _0x2a5046(msg.sender, _0x9437a0);
        Auction memory _0xfaedc0 = Auction(
            _0x40303d,
            uint128(_0x2c416e),
            uint128(_0x2fb558),
            uint64(_0x4bffd2),
            uint64(_0xddf414),
            0
        );
        _0x1dfc37(_0x9437a0, _0xfaedc0);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function _0x3cee2c(uint256 _0x9437a0)
        external
        payable
        _0x04df49
    {
        // _bid will throw if the bid or funds transfer fails
        _0x8ec3d7(_0x9437a0, msg.value);
        _0x5e6963(msg.sender, _0x9437a0);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function _0xe43d22(uint256 _0x9437a0)
        external
    {
        Auction storage _0xfaedc0 = _0xd2cf92[_0x9437a0];
        require(_0xecf5be(_0xfaedc0));
        address _0x80bd9c = _0xfaedc0._0x80bd9c;
        require(msg.sender == _0x80bd9c);
        _0x9b83cc(_0x9437a0, _0x80bd9c);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function _0x809ba8(uint256 _0x9437a0)
        _0x53d1a2
        _0x017abd
        external
    {
        Auction storage _0xfaedc0 = _0xd2cf92[_0x9437a0];
        require(_0xecf5be(_0xfaedc0));
        _0x9b83cc(_0x9437a0, _0xfaedc0._0x80bd9c);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function _0x7cae85(uint256 _0x9437a0)
        external
        view
        returns
    (
        address _0x80bd9c,
        uint256 _0xc9080f,
        uint256 _0xc2d268,
        uint256 _0xcfcedd,
        uint256 _0x1128b2
    ) {
        Auction storage _0xfaedc0 = _0xd2cf92[_0x9437a0];
        require(_0xecf5be(_0xfaedc0));
        return (
            _0xfaedc0._0x80bd9c,
            _0xfaedc0._0xc9080f,
            _0xfaedc0._0xc2d268,
            _0xfaedc0._0xcfcedd,
            _0xfaedc0._0x1128b2
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function _0x99433b(uint256 _0x9437a0)
        external
        view
        returns (uint256)
    {
        Auction storage _0xfaedc0 = _0xd2cf92[_0x9437a0];
        require(_0xecf5be(_0xfaedc0));
        return _0x0b33b4(_0xfaedc0);
    }

}

/// @title Reverse auction modified for siring
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SiringClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSiringAuctionAddress() call.
    bool public _0x91696e = true;

    // Delegate constructor
    function SiringClockAuction(address _0x058446, uint256 _0xc8b9db) public
        ClockAuction(_0x058446, _0xc8b9db) {}

    /// @dev Creates and begins a new auction. Since this function is wrapped,
    /// require sender to be PandaCore contract.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x9bdcc7(
        uint256 _0x9437a0,
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2,
        address _0x40303d
    )
        external
    {

        // to store them in the auction struct.
        require(_0x2c416e == uint256(uint128(_0x2c416e)));
        require(_0x2fb558 == uint256(uint128(_0x2fb558)));
        require(_0x4bffd2 == uint256(uint64(_0x4bffd2)));

        require(msg.sender == address(_0xc47244));
        _0x2a5046(_0x40303d, _0x9437a0);
        Auction memory _0xfaedc0 = Auction(
            _0x40303d,
            uint128(_0x2c416e),
            uint128(_0x2fb558),
            uint64(_0x4bffd2),
            uint64(_0xddf414),
            0
        );
        _0x1dfc37(_0x9437a0, _0xfaedc0);
    }

    /// @dev Places a bid for siring. Requires the sender
    /// is the PandaCore contract because all bid methods
    /// should be wrapped. Also returns the panda to the
    /// seller rather than the winner.
    function _0x3cee2c(uint256 _0x9437a0)
        external
        payable
    {
        require(msg.sender == address(_0xc47244));
        address _0x80bd9c = _0xd2cf92[_0x9437a0]._0x80bd9c;
        // _bid checks that token ID is valid and will throw if bid fails
        _0x8ec3d7(_0x9437a0, msg.value);
        // We transfer the panda back to the seller, the winner will get
        // the offspring
        _0x5e6963(_0x80bd9c, _0x9437a0);
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public _0x19b3be = true;

    // Tracks last 5 sale price of gen0 panda sales
    uint256 public _0xb07986;
    uint256[5] public _0xb62f54;
    uint256 public constant SurpriseValue = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaIndex;
    uint256   RarePandaIndex;

    // Delegate constructor
    function SaleClockAuction(address _0x058446, uint256 _0xc8b9db) public
        ClockAuction(_0x058446, _0xc8b9db) {
            CommonPandaIndex = 1;
            RarePandaIndex   = 1;
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x9bdcc7(
        uint256 _0x9437a0,
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2,
        address _0x40303d
    )
        external
    {

        // to store them in the auction struct.
        require(_0x2c416e == uint256(uint128(_0x2c416e)));
        require(_0x2fb558 == uint256(uint128(_0x2fb558)));
        require(_0x4bffd2 == uint256(uint64(_0x4bffd2)));

        require(msg.sender == address(_0xc47244));
        _0x2a5046(_0x40303d, _0x9437a0);
        Auction memory _0xfaedc0 = Auction(
            _0x40303d,
            uint128(_0x2c416e),
            uint128(_0x2fb558),
            uint64(_0x4bffd2),
            uint64(_0xddf414),
            0
        );
        _0x1dfc37(_0x9437a0, _0xfaedc0);
    }

    function _0xba0de6(
        uint256 _0x9437a0,
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2,
        address _0x40303d
    )
        external
    {

        // to store them in the auction struct.
        require(_0x2c416e == uint256(uint128(_0x2c416e)));
        require(_0x2fb558 == uint256(uint128(_0x2fb558)));
        require(_0x4bffd2 == uint256(uint64(_0x4bffd2)));

        require(msg.sender == address(_0xc47244));
        _0x2a5046(_0x40303d, _0x9437a0);
        Auction memory _0xfaedc0 = Auction(
            _0x40303d,
            uint128(_0x2c416e),
            uint128(_0x2fb558),
            uint64(_0x4bffd2),
            uint64(_0xddf414),
            1
        );
        _0x1dfc37(_0x9437a0, _0xfaedc0);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function _0x3cee2c(uint256 _0x9437a0)
        external
        payable
    {
        // _bid verifies token ID size
        uint64 _0x45140e = _0xd2cf92[_0x9437a0]._0x45140e;
        uint256 _0x34b70c = _0x8ec3d7(_0x9437a0, msg.value);
        _0x5e6963(msg.sender, _0x9437a0);

        // If not a gen0 auction, exit
        if (_0x45140e == 1) {
            // Track gen0 sale prices
            _0xb62f54[_0xb07986 % 5] = _0x34b70c;
            _0xb07986++;
        }
    }

    function _0x18bf09(uint256 _0x9437a0,uint256 _0x0df092)
        external
    {
        require(msg.sender == address(_0xc47244));
        if (_0x0df092 == 0) {
            CommonPanda.push(_0x9437a0);
        }else {
            RarePanda.push(_0x9437a0);
        }
    }

    function _0xb26472()
        external
        payable
    {
        bytes32 _0x41ee68 = _0x2a9820(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaIndex;
        if (_0x41ee68[25] > 0xC8) {
            require(uint256(RarePanda.length) >= RarePandaIndex);
            PandaIndex = RarePandaIndex;
            RarePandaIndex ++;

        } else{
            require(uint256(CommonPanda.length) >= CommonPandaIndex);
            PandaIndex = CommonPandaIndex;
            CommonPandaIndex ++;
        }
        _0x5e6963(msg.sender,PandaIndex);
    }

    function _0x1dd16f() external view returns(uint256 _0x7efa86,uint256 _0xa213f5) {
        if (true) { _0x7efa86   = CommonPanda.length + 1 - CommonPandaIndex; }
        _0xa213f5 = RarePanda.length + 1 - RarePandaIndex;
    }

    function _0x082d33() external view returns (uint256) {
        uint256 _0xfd6cae = 0;
        for (uint256 i = 0; i < 5; i++) {
            _0xfd6cae += _0xb62f54[i];
        }
        return _0xfd6cae / 5;
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 _0x718a9a, uint256 _0xc9080f, uint256 _0xc2d268, uint256 _0xcfcedd, address _0x212724);

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public _0x994b87 = true;

    mapping (uint256 => address) public _0x9ee408;

    mapping (address => uint256) public _0x3e2cea;

    mapping (address => uint256) public _0x85b4a9;

    // Delegate constructor
    function SaleClockAuctionERC20(address _0x058446, uint256 _0xc8b9db) public
        ClockAuction(_0x058446, _0xc8b9db) {}

    function _0x548c8c(address _0xabb9f5, uint256 _0x6017ad) external{
        require (msg.sender == address(_0xc47244));

        require (_0xabb9f5 != address(0));

        _0x3e2cea[_0xabb9f5] = _0x6017ad;
    }
    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x9bdcc7(
        uint256 _0x9437a0,
        address _0x4b897b,
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2,
        address _0x40303d
    )
        external
    {

        // to store them in the auction struct.
        require(_0x2c416e == uint256(uint128(_0x2c416e)));
        require(_0x2fb558 == uint256(uint128(_0x2fb558)));
        require(_0x4bffd2 == uint256(uint64(_0x4bffd2)));

        require(msg.sender == address(_0xc47244));

        require (_0x3e2cea[_0x4b897b] > 0);

        _0x2a5046(_0x40303d, _0x9437a0);
        Auction memory _0xfaedc0 = Auction(
            _0x40303d,
            uint128(_0x2c416e),
            uint128(_0x2fb558),
            uint64(_0x4bffd2),
            uint64(_0xddf414),
            0
        );
        _0xd3823c(_0x9437a0, _0xfaedc0, _0x4b897b);
        _0x9ee408[_0x9437a0] = _0x4b897b;
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _0xd3823c(uint256 _0x9437a0, Auction _0x2897d5, address _0xabb9f5) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_0x2897d5._0xcfcedd >= 1 minutes);

        _0xd2cf92[_0x9437a0] = _0x2897d5;

        AuctionERC20Created(
            uint256(_0x9437a0),
            uint256(_0x2897d5._0xc9080f),
            uint256(_0x2897d5._0xc2d268),
            uint256(_0x2897d5._0xcfcedd),
            _0xabb9f5
        );
    }

    function _0x3cee2c(uint256 _0x9437a0)
        external
        payable{
            // do nothing
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function _0xc2d832(uint256 _0x9437a0,uint256 _0xad0126)
        external
    {
        // _bid verifies token ID size
        address _0x80bd9c = _0xd2cf92[_0x9437a0]._0x80bd9c;
        address _0xabb9f5 = _0x9ee408[_0x9437a0];
        require (_0xabb9f5 != address(0));
        uint256 _0x34b70c = _0x76e4c1(_0xabb9f5,msg.sender,_0x9437a0, _0xad0126);
        _0x5e6963(msg.sender, _0x9437a0);
        delete _0x9ee408[_0x9437a0];
    }

    function _0xe43d22(uint256 _0x9437a0)
        external
    {
        Auction storage _0xfaedc0 = _0xd2cf92[_0x9437a0];
        require(_0xecf5be(_0xfaedc0));
        address _0x80bd9c = _0xfaedc0._0x80bd9c;
        require(msg.sender == _0x80bd9c);
        _0x9b83cc(_0x9437a0, _0x80bd9c);
        delete _0x9ee408[_0x9437a0];
    }

    function _0xe1a339(address _0x4b897b, address _0x64cd68) external returns(bool _0x11e1bc)  {
        require (_0x85b4a9[_0x4b897b] > 0);
        require(msg.sender == address(_0xc47244));
        ERC20(_0x4b897b).transfer(_0x64cd68, _0x85b4a9[_0x4b897b]);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _0x76e4c1(address _0x4b897b,address _0xbffa38, uint256 _0x9437a0, uint256 _0xc42a3f)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage _0xfaedc0 = _0xd2cf92[_0x9437a0];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_0xecf5be(_0xfaedc0));

        require (_0x4b897b != address(0) && _0x4b897b == _0x9ee408[_0x9437a0]);

        // Check that the bid is greater than or equal to the current price
        uint256 _0x34b70c = _0x0b33b4(_0xfaedc0);
        require(_0xc42a3f >= _0x34b70c);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address _0x80bd9c = _0xfaedc0._0x80bd9c;

        // The bid is good! Remove the auction before sending the fees
        _0x3d0124(_0x9437a0);

        // Transfer proceeds to seller (if there are any!)
        if (_0x34b70c > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 _0x96abdb = _0x339e59(_0x34b70c);
            uint256 _0x04b982 = _0x34b70c - _0x96abdb;

            // Send Erc20 Token to seller should call Erc20 contract
            // Reference to contract
            require(ERC20(_0x4b897b)._0x23aab6(_0xbffa38,_0x80bd9c,_0x04b982));
            if (_0x96abdb > 0){
                require(ERC20(_0x4b897b)._0x23aab6(_0xbffa38,address(this),_0x96abdb));
                _0x85b4a9[_0x4b897b] += _0x96abdb;
            }
        }

        // Tell the world!
        AuctionSuccessful(_0x9437a0, _0x34b70c, msg.sender);

        return _0x34b70c;
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
    function _0xb4d642(address _0xf2098b) external _0x60b274 {
        SaleClockAuction _0xbfacca = SaleClockAuction(_0xf2098b);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0xbfacca._0x19b3be());

        // Set the new contract address
        _0x9e851a = _0xbfacca;
    }

    function _0xf1b588(address _0xf2098b) external _0x60b274 {
        SaleClockAuctionERC20 _0xbfacca = SaleClockAuctionERC20(_0xf2098b);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0xbfacca._0x994b87());

        // Set the new contract address
        _0x3e1e93 = _0xbfacca;
    }

    /// @dev Sets the reference to the siring auction.
    /// @param _address - Address of siring contract.
    function _0xe0800d(address _0xf2098b) external _0x60b274 {
        SiringClockAuction _0xbfacca = SiringClockAuction(_0xf2098b);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0xbfacca._0x91696e());

        // Set the new contract address
        _0x23c70b = _0xbfacca;
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function _0xe77f95(
        uint256 _0x7e84fb,
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2
    )
        external
        _0x04df49
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x65e38c(msg.sender, _0x7e84fb));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!_0x7ccc7a(_0x7e84fb));
        _0xd82f3d(_0x7e84fb, _0x9e851a);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x9e851a._0x9bdcc7(
            _0x7e84fb,
            _0x2c416e,
            _0x2fb558,
            _0x4bffd2,
            msg.sender
        );
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function _0xe98e0a(
        uint256 _0x7e84fb,
        address _0xabb9f5,
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2
    )
        external
        _0x04df49
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x65e38c(msg.sender, _0x7e84fb));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!_0x7ccc7a(_0x7e84fb));
        _0xd82f3d(_0x7e84fb, _0x3e1e93);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x3e1e93._0x9bdcc7(
            _0x7e84fb,
            _0xabb9f5,
            _0x2c416e,
            _0x2fb558,
            _0x4bffd2,
            msg.sender
        );
    }

    function _0x4a1b92(address _0xabb9f5, uint256 _0x6017ad) external _0x864e74{
        _0x3e1e93._0x548c8c(_0xabb9f5,_0x6017ad);
    }

    /// @dev Put a panda up for auction to be sire.
    ///  Performs checks to ensure the panda can be sired, then
    ///  delegates to reverse auction.
    function _0xf31553(
        uint256 _0x7e84fb,
        uint256 _0x2c416e,
        uint256 _0x2fb558,
        uint256 _0x4bffd2
    )
        external
        _0x04df49
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x65e38c(msg.sender, _0x7e84fb));
        require(_0x9ba8b0(_0x7e84fb));
        _0xd82f3d(_0x7e84fb, _0x23c70b);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x23c70b._0x9bdcc7(
            _0x7e84fb,
            _0x2c416e,
            _0x2fb558,
            _0x4bffd2,
            msg.sender
        );
    }

    /// @dev Completes a siring auction by bidding.
    ///  Immediately breeds the winning matron with the sire on auction.
    /// @param _sireId - ID of the sire on auction.
    /// @param _matronId - ID of the matron owned by the bidder.
    function _0xf91b2a(
        uint256 _0x9027a1,
        uint256 _0x27eecf
    )
        external
        payable
        _0x04df49
    {
        // Auction contract checks input sizes
        require(_0x65e38c(msg.sender, _0x27eecf));
        require(_0x9ba8b0(_0x27eecf));
        require(_0x90fc42(_0x27eecf, _0x9027a1));

        // Define the current price of the auction.
        uint256 _0x484ece = _0x23c70b._0x99433b(_0x9027a1);
        require(msg.value >= _0x484ece + _0x3ecc6f);

        // Siring auction will throw if the bid fails.
        _0x23c70b._0x3cee2c.value(msg.value - _0x3ecc6f)(_0x9027a1);
        _0x355b02(uint32(_0x27eecf), uint32(_0x9027a1), msg.sender);
    }

    /// @dev Transfers the balance of the sale auction contract
    /// to the PandaCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function _0x8a3138() external _0xcfa2eb {
        _0x9e851a._0xf5ead4();
        _0x23c70b._0xf5ead4();
    }

    function _0xe1a339(address _0x4b897b, address _0x64cd68) external _0xcfa2eb {
        require(_0x3e1e93 != address(0));
        _0x3e1e93._0xe1a339(_0x4b897b,_0x64cd68);
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
    function _0x3c08f8(uint256[2] _0xd14de0, uint256 _0xce7d73, address _0xb0e749) external _0x864e74 {
        address _0x30c421 = _0xb0e749;
        if (_0x30c421 == address(0)) {
            _0x30c421 = _0xd84fc8;
        }

        _0x5f3cbe(0, 0, _0xce7d73, _0xd14de0, _0x30c421);
    }

    /// @dev create pandaWithGenes
    /// @param _genes panda genes
    /// @param _type  0 common 1 rare
    function _0x18bf09(uint256[2] _0xd14de0,uint256 _0xce7d73,uint256 _0x0df092)
        external
        payable
        _0x864e74
        _0x04df49
    {
        require(msg.value >= OPEN_PACKAGE_PRICE);
        uint256 _0x7f537b = _0x5f3cbe(0, 0, _0xce7d73, _0xd14de0, _0x9e851a);
        _0x9e851a._0x18bf09(_0x7f537b,_0x0df092);
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

    function _0xba0de6(uint256 _0x7e84fb) external _0x864e74 {
        require(_0x65e38c(msg.sender, _0x7e84fb));
        //require(pandas[_pandaId].generation==1);

        _0xd82f3d(_0x7e84fb, _0x9e851a);

        _0x9e851a._0xba0de6(
            _0x7e84fb,
            _0xcb80b7(),
            0,
            GEN0_AUCTION_DURATION,
            msg.sender
        );
    }

    /// @dev Computes the next gen0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function _0xcb80b7() internal view returns(uint256) {
        uint256 _0xdd6371 = _0x9e851a._0x082d33();

        require(_0xdd6371 == uint256(uint128(_0xdd6371)));

        uint256 _0xa871aa = _0xdd6371 + (_0xdd6371 / 2);

        // We never auction for less than starting price
        if (_0xa871aa < GEN0_STARTING_PRICE) {
            _0xa871aa = GEN0_STARTING_PRICE;
        }

        return _0xa871aa;
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
    address public _0x90d77a;

    /// @notice Creates the main CryptoPandas smart contract instance.
    function PandaCore() public {
        // Starts paused.
        _0x86dc0a = true;

        // the creator of the contract is the initial CEO
        _0x056adb = msg.sender;

        // the creator of the contract is also the initial COO
        if (1 == 1) { _0xd84fc8 = msg.sender; }

        // move these code to init(), so we not excceed gas limit
        //uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        //wizzPandaQuota[1] = 100;

        //_createPanda(0, 0, 0, _genes, address(0));
    }

    /// init contract
    function _0xedb3eb() external _0x60b274 _0x53d1a2 {
        // make sure init() only run once
        require(_0xde19c2.length == 0);
        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        uint256[2] memory _0xd14de0 = [uint256(-1),uint256(-1)];

        _0xfd10e4[1] = 100;
       _0x5f3cbe(0, 0, 0, _0xd14de0, address(0));
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious

    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function _0xf1cd00(address _0x4153ae) external _0x60b274 _0x53d1a2 {
        // See README.md for updgrade plan
        _0x90d77a = _0x4153ae;
        ContractUpgrade(_0x4153ae);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(_0x9e851a) ||
            msg.sender == address(_0x23c70b)
        );
    }

    /// @notice Returns all the relevant information about a specific panda.
    /// @param _id The ID of the panda of interest.
    function _0xb7a553(uint256 _0xfa9287)
        external
        view
        returns (
        bool _0x18f41c,
        bool _0xc176bb,
        uint256 _0xd993db,
        uint256 _0x51b1ce,
        uint256 _0xdb4890,
        uint256 _0x14d428,
        uint256 _0xcaa582,
        uint256 _0x9a6a79,
        uint256 _0xcb4be8,
        uint256[2] _0xd7149e
    ) {
        Panda storage _0x3cca96 = _0xde19c2[_0xfa9287];

        // if this variable is 0 then it's not gestating
        _0x18f41c = (_0x3cca96._0xdb4890 != 0);
        _0xc176bb = (_0x3cca96._0x5c4b14 <= block.number);
        _0xd993db = uint256(_0x3cca96._0xd993db);
        _0x51b1ce = uint256(_0x3cca96._0x5c4b14);
        _0xdb4890 = uint256(_0x3cca96._0xdb4890);
        _0x14d428 = uint256(_0x3cca96._0x14d428);
        _0xcaa582 = uint256(_0x3cca96._0xcaa582);
        _0x9a6a79 = uint256(_0x3cca96._0x9a6a79);
        _0xcb4be8 = uint256(_0x3cca96._0xcb4be8);
        _0xd7149e = _0x3cca96._0xd7149e;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function _0xd59e82() public _0x60b274 _0x53d1a2 {
        require(_0x9e851a != address(0));
        require(_0x23c70b != address(0));
        require(_0xc88e88 != address(0));
        require(_0x90d77a == address(0));

        // Actually unpause the contract.
        super._0xd59e82();
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function _0xf5ead4() external _0xd4d0ef {
        uint256 balance = this.balance;
        // Subtract all the currently pregnant kittens we have, plus 1 of margin.
        uint256 _0xd33c6f = (_0x6d06de + 1) * _0x3ecc6f;

        if (balance > _0xd33c6f) {
            _0xdf7871.send(balance - _0xd33c6f);
        }
    }
}
