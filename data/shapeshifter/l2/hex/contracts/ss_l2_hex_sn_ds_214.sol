// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ERC20 {
    function _0x12565b() constant returns (uint _0x967fa0);
    function _0x405e22( address _0x780122 ) constant returns (uint value);
    function _0x74e3d0( address _0x8220f4, address _0x78b30a ) constant returns (uint _0x16fff4);

    function transfer( address _0xa2fa22, uint value) returns (bool _0xe53bea);
    function _0xfabc8e( address from, address _0xa2fa22, uint value) returns (bool _0xe53bea);
    function _0x6001c8( address _0x78b30a, uint value ) returns (bool _0xe53bea);

    event Transfer( address indexed from, address indexed _0xa2fa22, uint value);
    event Approval( address indexed _0x8220f4, address indexed _0x78b30a, uint value);
}
contract Ownable {
  address public _0x8220f4;

  function Ownable() {
    _0x8220f4 = msg.sender;
  }

  modifier _0x41354a() {
    require(msg.sender == _0x8220f4);
    _;
  }

  function _0xe2b947(address _0x28b1eb) _0x41354a {
    if (_0x28b1eb != address(0)) {
      _0x8220f4 = _0x28b1eb;
    }
  }

}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function _0x12565b() public view returns (uint256 _0xffa95f);
    function _0x405e22(address _0xa1f990) public view returns (uint256 balance);
    function _0x6aa502(uint256 _0x2a0fb7) external view returns (address _0x8220f4);
    function _0x6001c8(address _0x546d79, uint256 _0x2a0fb7) external;
    function transfer(address _0x546d79, uint256 _0x2a0fb7) external;
    function _0xfabc8e(address _0xdf6bc8, address _0x546d79, uint256 _0x2a0fb7) external;

    // Events
    event Transfer(address from, address _0xa2fa22, uint256 _0x943848);
    event Approval(address _0x8220f4, address _0x111e70, uint256 _0x943848);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function _0xc3fbe0(bytes4 _0x3bf5b5) external view returns (bool);
}

contract GeneScienceInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function _0x63d297() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @return the genes that are supposed to be passed down the child
    function _0xf5394f(uint256[2] _0xd2038f, uint256[2] _0xfb6662,uint256 _0xaa95b9,uint256 _0xa70d7d, uint256 _0xc2202a) public returns (uint256[2]);

    function _0x30469b(uint256[2] _0x9d825e) public view returns(uint256);

    /// @dev get sex from genes 0: female 1: male
    function _0xa34681(uint256[2] _0x9d825e) public view returns(uint256);

    /// @dev get wizz type from gene
    function _0x10f542(uint256[2] _0x9d825e) public view returns(uint256);

    function _0xd2430b(uint256[2] _0x2af24c) public returns(uint256[2]);
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
    event ContractUpgrade(address _0xbef38a);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public _0x4d531c;
    address public _0x52de96;
    address public _0xf36c1e;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public _0x4fadec = false;

    /// @dev Access modifier for CEO-only functionality
    modifier _0x0057d3() {
        require(msg.sender == _0x4d531c);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier _0xf9975c() {
        require(msg.sender == _0x52de96);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier _0x6c655d() {
        require(msg.sender == _0xf36c1e);
        _;
    }

    modifier _0x57543d() {
        require(
            msg.sender == _0xf36c1e ||
            msg.sender == _0x4d531c ||
            msg.sender == _0x52de96
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function _0xacac04(address _0x4a7db6) external _0x0057d3 {
        require(_0x4a7db6 != address(0));

        _0x4d531c = _0x4a7db6;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function _0x02048a(address _0xb64cf6) external _0x0057d3 {
        require(_0xb64cf6 != address(0));

        _0x52de96 = _0xb64cf6;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function _0xe09479(address _0x816e1f) external _0x0057d3 {
        require(_0x816e1f != address(0));

        _0xf36c1e = _0x816e1f;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier _0xd08088() {
        require(!_0x4fadec);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier _0xea5b37 {
        require(_0x4fadec);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    function _0xf06dd1() external _0x57543d _0xd08088 {
        _0x4fadec = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function _0x29c399() public _0x0057d3 _0xea5b37 {
        // can't unpause if contract was upgraded
        _0x4fadec = false;
    }
}

/// @title Base contract for CryptoPandas. Holds all common structs, events and base variables.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaBase is PandaAccessControl {
    /*** EVENTS ***/

    uint256 public constant GEN0_TOTAL_COUNT = 16200;
    uint256 public _0xc031eb;

    /// @dev The Birth event is fired whenever a new kitten comes into existence. This obviously
    ///  includes any time a cat is created through the giveBirth method, but it is also called
    ///  when a new gen0 cat is created.
    event Birth(address _0x8220f4, uint256 _0xe7bc09, uint256 _0x1cc8d3, uint256 _0xe9c19a, uint256[2] _0x2e8019);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a kitten
    ///  ownership is assigned, including births.
    event Transfer(address from, address _0xa2fa22, uint256 _0x943848);

    /*** DATA TYPES ***/

    /// @dev The main Panda struct. Every cat in CryptoPandas is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Panda {
        // The Panda's genetic code is packed into these 256-bits, the format is
        // sooper-sekret! A cat's genes never change.
        uint256[2] _0x2e8019;

        // The timestamp from the block when this cat came into existence.
        uint64 _0x9a305c;

        // The minimum timestamp after which this cat can engage in breeding
        // activities again. This same timestamp is used for the pregnancy
        // timer (for matrons) as well as the siring cooldown.
        uint64 _0xf8b55f;

        // The ID of the parents of this panda, set to 0 for gen0 cats.
        // Note that using 32-bit unsigned integers limits us to a "mere"
        // 4 billion cats. This number might seem small until you realize
        // that Ethereum currently has a limit of about 500 million
        // transactions per year! So, this definitely won't be a problem
        // for several years (even as Ethereum learns to scale).
        uint32 _0x1cc8d3;
        uint32 _0xe9c19a;

        // Set to the ID of the sire cat for matrons that are pregnant,
        // zero otherwise. A non-zero value here is how we know a cat
        // is pregnant. Used to retrieve the genetic material for the new
        // kitten when the birth transpires.
        uint32 _0x9c00e1;

        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this Panda. This starts at zero
        // for gen0 cats, and is initialized to floor(generation/2) for others.
        // Incremented by one for each successful breeding action, regardless
        // of whether this cat is acting as matron or sire.
        uint16 _0x990f40;

        // The "generation number" of this cat. Cats minted by the CK contract
        // for sale are called "gen0" and have a generation number of 0. The
        // generation number of all other cats is the larger of the two generation
        // numbers of their parents, plus one.
        // (i.e. max(matron.generation, sire.generation) + 1)
        uint16 _0x121419;
    }

    /*** CONSTANTS ***/

    /// @dev A lookup table indicating the cooldown duration after any successful
    ///  breeding action, called "pregnancy time" for matrons and "siring cooldown"
    ///  for sires. Designed such that the cooldown roughly doubles each time a cat
    ///  is bred, encouraging owners not to just keep breeding the same cat over
    ///  and over again. Caps out at one week (a cat can breed an unbounded number
    ///  of times, and the maximum cooldown is always seven days).
    uint32[9] public _0x56d799 = [
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
    uint256 public _0x48a966 = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Panda struct for all Pandas in existence. The ID
    ///  of each cat is actually an index into this array. Note that ID 0 is a negacat,
    ///  the unPanda, the mythical beast that is the parent of all gen0 cats. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, cat ID 0 is invalid... ;-)
    Panda[] _0xccbc26;

    /// @dev A mapping from cat IDs to the address that owns them. All cats have
    ///  some valid owner address, even gen0 cats are created with a non-zero owner.
    mapping (uint256 => address) public _0x1489f4;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) _0x5f4b33;

    /// @dev A mapping from PandaIDs to an address that has been approved to call
    ///  transferFrom(). Each Panda can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public _0x60477d;

    /// @dev A mapping from PandaIDs to an address that has been approved to use
    ///  this Panda for siring via breedWith(). Each Panda can only have one approved
    ///  address for siring at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public _0x39db11;

    /// @dev The address of the ClockAuction contract that handles sales of Pandas. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public _0x09557d;

    /// @dev The address of a custom ClockAuction subclassed contract that handles siring
    ///  auctions. Needs to be separate from saleAuction because the actions taken on success
    ///  after a sales and siring auction are quite different.
    SiringClockAuction public _0x286f88;

    /// @dev The address of the sibling contract that is used to implement the sooper-sekret
    ///  genetic combination algorithm.
    GeneScienceInterface public _0xfb86db;

    SaleClockAuctionERC20 public _0x74715e;

    // wizz panda total
    mapping (uint256 => uint256) public _0x7c3e5b;
    mapping (uint256 => uint256) public _0xa981b7;

    /// wizz panda control
    function _0x97f917(uint256 _0x0db4cf) view external returns(uint256) {
        return _0x7c3e5b[_0x0db4cf];
    }

    function _0xc4daf7(uint256 _0x0db4cf) view external returns(uint256) {
        return _0xa981b7[_0x0db4cf];
    }

    function _0x3c0c81(uint256 _0x0db4cf,uint256 _0x97d39e) external _0x57543d {
        require (_0x7c3e5b[_0x0db4cf]==0);
        require (_0x97d39e==uint256(uint32(_0x97d39e)));
        _0x7c3e5b[_0x0db4cf] = _0x97d39e;
    }

    function _0x2369a6(uint256 _0x6ddf15) view external returns(uint256) {
        Panda memory _0x7d97e5 = _0xccbc26[_0x6ddf15];
        return _0xfb86db._0x10f542(_0x7d97e5._0x2e8019);
    }

    /// @dev Assigns ownership of a specific Panda to an address.
    function _0x54f595(address _0xdf6bc8, address _0x546d79, uint256 _0x2a0fb7) internal {

        _0x5f4b33[_0x546d79]++;
        // transfer ownership
        _0x1489f4[_0x2a0fb7] = _0x546d79;
        // When creating new kittens _from is 0x0, but we can't account that address.
        if (_0xdf6bc8 != address(0)) {
            _0x5f4b33[_0xdf6bc8]--;
            // once the kitten is transferred also clear sire allowances
            delete _0x39db11[_0x2a0fb7];
            // clear any previously approved ownership exchange
            delete _0x60477d[_0x2a0fb7];
        }
        // Emit the transfer event.
        Transfer(_0xdf6bc8, _0x546d79, _0x2a0fb7);
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
    function _0x65ca7b(
        uint256 _0x159240,
        uint256 _0xa47ccb,
        uint256 _0x527278,
        uint256[2] _0x5b953b,
        address _0xa1f990
    )
        internal
        returns (uint)
    {
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createPanda() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        require(_0x159240 == uint256(uint32(_0x159240)));
        require(_0xa47ccb == uint256(uint32(_0xa47ccb)));
        require(_0x527278 == uint256(uint16(_0x527278)));

        // New panda starts with the same cooldown as parent gen/2
        uint16 _0x990f40 = 0;
        // when contract creation, geneScience ref is null
        if (_0xccbc26.length>0){
            uint16 _0x8764c1 = uint16(_0xfb86db._0x30469b(_0x5b953b));
            if (_0x8764c1==0) {
                _0x8764c1 = 1;
            }
            _0x990f40 = 1000/_0x8764c1;
            if (_0x990f40%10 < 5){
                _0x990f40 = _0x990f40/10;
            }else{
                _0x990f40 = _0x990f40/10 + 1;
            }
            _0x990f40 = _0x990f40 - 1;
            if (_0x990f40 > 8) {
                _0x990f40 = 8;
            }
            uint256 _0x0db4cf = _0xfb86db._0x10f542(_0x5b953b);
            if (_0x0db4cf>0 && _0x7c3e5b[_0x0db4cf]<=_0xa981b7[_0x0db4cf]) {
                _0x5b953b = _0xfb86db._0xd2430b(_0x5b953b);
                _0x0db4cf = 0;
            }
            // gensis panda cooldownIndex should be 24 hours
            if (_0x0db4cf == 1){
                _0x990f40 = 5;
            }

            // increase wizz counter
            if (_0x0db4cf>0){
                _0xa981b7[_0x0db4cf] = _0xa981b7[_0x0db4cf] + 1;
            }
            // all gen0&gen1 except gensis
            if (_0x527278 <= 1 && _0x0db4cf != 1){
                require(_0xc031eb<GEN0_TOTAL_COUNT);
                _0xc031eb++;
            }
        }

        Panda memory _0xbc844b = Panda({
            _0x2e8019: _0x5b953b,
            _0x9a305c: uint64(_0x9e380d),
            _0xf8b55f: 0,
            _0x1cc8d3: uint32(_0x159240),
            _0xe9c19a: uint32(_0xa47ccb),
            _0x9c00e1: 0,
            _0x990f40: _0x990f40,
            _0x121419: uint16(_0x527278)
        });
        uint256 _0x4f8623 = _0xccbc26.push(_0xbc844b) - 1;

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(_0x4f8623 == uint256(uint32(_0x4f8623)));

        // emit the birth event
        Birth(
            _0xa1f990,
            _0x4f8623,
            uint256(_0xbc844b._0x1cc8d3),
            uint256(_0xbc844b._0xe9c19a),
            _0xbc844b._0x2e8019
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _0x54f595(0, _0xa1f990, _0x4f8623);

        return _0x4f8623;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function _0x9948fa(uint256 _0xeb6bf9) external _0x57543d {
        require(_0xeb6bf9 < _0x56d799[0]);
        _0x48a966 = _0xeb6bf9;
    }
}
/// @title The external contract that is responsible for generating metadata for the pandas,
///  it has one function that will return the data as bytes.
contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function _0x1d6fe3(uint256 _0x2a0fb7, string) public view returns (bytes32[4] _0xd8ee50, uint256 _0x46e9e7) {
        if (_0x2a0fb7 == 1) {
            _0xd8ee50[0] = "Hello World! :D";
            _0x46e9e7 = 15;
        } else if (_0x2a0fb7 == 2) {
            _0xd8ee50[0] = "I would definitely choose a medi";
            _0xd8ee50[1] = "um length string.";
            _0x46e9e7 = 49;
        } else if (_0x2a0fb7 == 3) {
            _0xd8ee50[0] = "Lorem ipsum dolor sit amet, mi e";
            _0xd8ee50[1] = "st accumsan dapibus augue lorem,";
            _0xd8ee50[2] = " tristique vestibulum id, libero";
            _0xd8ee50[3] = " suscipit varius sapien aliquam.";
            _0x46e9e7 = 128;
        }
    }
}

/// @title The facet of the CryptoPandas core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaOwnership is PandaBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant _0x87b646 = "PandaEarth";
    string public constant _0x5dab3b = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(_0xf96263('_0xc3fbe0(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(_0xf96263('_0x87b646()')) ^
        bytes4(_0xf96263('_0x5dab3b()')) ^
        bytes4(_0xf96263('_0x12565b()')) ^
        bytes4(_0xf96263('_0x405e22(address)')) ^
        bytes4(_0xf96263('_0x6aa502(uint256)')) ^
        bytes4(_0xf96263('_0x6001c8(address,uint256)')) ^
        bytes4(_0xf96263('transfer(address,uint256)')) ^
        bytes4(_0xf96263('_0xfabc8e(address,address,uint256)')) ^
        bytes4(_0xf96263('_0x08d2f4(address)')) ^
        bytes4(_0xf96263('tokenMetadata(uint256,string)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function _0xc3fbe0(bytes4 _0x3bf5b5) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_0x3bf5b5 == InterfaceSignature_ERC165) || (_0x3bf5b5 == InterfaceSignature_ERC721));
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Panda.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId kitten id, only valid when > 0
    function _0x4b1122(address _0xd71144, uint256 _0x2a0fb7) internal view returns (bool) {
        return _0x1489f4[_0x2a0fb7] == _0xd71144;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Panda.
    /// @param _claimant the address we are confirming kitten is approved for.
    /// @param _tokenId kitten id, only valid when > 0
    function _0x877213(address _0xd71144, uint256 _0x2a0fb7) internal view returns (bool) {
        return _0x60477d[_0x2a0fb7] == _0xd71144;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Pandas on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _0xa63ae3(uint256 _0x2a0fb7, address _0xb0e841) internal {
        _0x60477d[_0x2a0fb7] = _0xb0e841;
    }

    /// @notice Returns the number of Pandas owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function _0x405e22(address _0xa1f990) public view returns (uint256 _0x46e9e7) {
        return _0x5f4b33[_0xa1f990];
    }

    /// @notice Transfers a Panda to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoPandas specifically) or your Panda may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Panda to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address _0x546d79,
        uint256 _0x2a0fb7
    )
        external
        _0xd08088
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_0x546d79 != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any pandas (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_0x546d79 != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of pandas
        // through the allow + transferFrom flow.
        require(_0x546d79 != address(_0x09557d));
        require(_0x546d79 != address(_0x286f88));

        // You can only send your own cat.
        require(_0x4b1122(msg.sender, _0x2a0fb7));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _0x54f595(msg.sender, _0x546d79, _0x2a0fb7);
    }

    /// @notice Grant another address the right to transfer a specific Panda via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Panda that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function _0x6001c8(
        address _0x546d79,
        uint256 _0x2a0fb7
    )
        external
        _0xd08088
    {
        // Only an owner can grant transfer approval.
        require(_0x4b1122(msg.sender, _0x2a0fb7));

        // Register the approval (replacing any previous approval).
        _0xa63ae3(_0x2a0fb7, _0x546d79);

        // Emit approval event.
        Approval(msg.sender, _0x546d79, _0x2a0fb7);
    }

    /// @notice Transfer a Panda owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Panda to be transfered.
    /// @param _to The address that should take ownership of the Panda. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Panda to be transferred.
    /// @dev Required for ERC-721 compliance.
    function _0xfabc8e(
        address _0xdf6bc8,
        address _0x546d79,
        uint256 _0x2a0fb7
    )
        external
        _0xd08088
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_0x546d79 != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any pandas (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_0x546d79 != address(this));
        // Check for approval and valid ownership
        require(_0x877213(msg.sender, _0x2a0fb7));
        require(_0x4b1122(_0xdf6bc8, _0x2a0fb7));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _0x54f595(_0xdf6bc8, _0x546d79, _0x2a0fb7);
    }

    /// @notice Returns the total number of Pandas currently in existence.
    /// @dev Required for ERC-721 compliance.
    function _0x12565b() public view returns (uint) {
        return _0xccbc26.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Panda.
    /// @dev Required for ERC-721 compliance.
    function _0x6aa502(uint256 _0x2a0fb7)
        external
        view
        returns (address _0x8220f4)
    {
        _0x8220f4 = _0x1489f4[_0x2a0fb7];

        require(_0x8220f4 != address(0));
    }

    /// @notice Returns a list of all Panda IDs assigned to an address.
    /// @param _owner The owner whose Pandas we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Panda array looking for cats belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function _0x08d2f4(address _0xa1f990) external view returns(uint256[] _0x6e0bbc) {
        uint256 _0x9bc79c = _0x405e22(_0xa1f990);

        if (_0x9bc79c == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory _0x614e89 = new uint256[](_0x9bc79c);
            uint256 _0x59751c = _0x12565b();
            uint256 _0xe929a1 = 0;

            // We count on the fact that all cats have IDs starting at 1 and increasing
            // sequentially up to the totalCat count.
            uint256 _0xc26877;

            for (_0xc26877 = 1; _0xc26877 <= _0x59751c; _0xc26877++) {
                if (_0x1489f4[_0xc26877] == _0xa1f990) {
                    _0x614e89[_0xe929a1] = _0xc26877;
                    _0xe929a1++;
                }
            }

            return _0x614e89;
        }
    }

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _0x28465f(uint _0xbce0c8, uint _0x8efd19, uint _0xe7132d) private view {
        // Copy word-length chunks while possible
        for(; _0xe7132d >= 32; _0xe7132d -= 32) {
            assembly {
                mstore(_0xbce0c8, mload(_0x8efd19))
            }
            _0xbce0c8 += 32;
            _0x8efd19 += 32;
        }

        // Copy remaining bytes
        uint256 _0x48e956 = 256 ** (32 - _0xe7132d) - 1;
        assembly {
            let _0x16aa68 := and(mload(_0x8efd19), not(_0x48e956))
            let _0xc3f4b5 := and(mload(_0xbce0c8), _0x48e956)
            mstore(_0xbce0c8, or(_0xc3f4b5, _0x16aa68))
        }
    }

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _0xe7b1f9(bytes32[4] _0xaec75e, uint256 _0x60e71c) private view returns (string) {
        var _0x719cb5 = new string(_0x60e71c);
        uint256 _0x4da290;
        uint256 _0x20c478;

        assembly {
            _0x4da290 := add(_0x719cb5, 32)
            _0x20c478 := _0xaec75e
        }

        _0x28465f(_0x4da290, _0x20c478, _0x60e71c);

        return _0x719cb5;
    }

}

/// @title A facet of PandaCore that manages Panda siring, gestation, and birth.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaBreeding is PandaOwnership {

    uint256 public constant GENSIS_TOTAL_COUNT = 100;

    /// @dev The Pregnant event is fired when two cats successfully breed and the pregnancy
    ///  timer begins for the matron.
    event Pregnant(address _0x8220f4, uint256 _0x1cc8d3, uint256 _0xe9c19a, uint256 _0xf8b55f);
    /// @dev The Abortion event is fired when two cats breed failed.
    event Abortion(address _0x8220f4, uint256 _0x1cc8d3, uint256 _0xe9c19a);

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public _0x331967 = 2 finney;

    // Keeps track of number of pregnant pandas.
    uint256 public _0xada84f;

    mapping(uint256 => address) _0x9e1bbe;

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a GeneScience contract instance to be used from this point forward.
    function _0x0dd545(address _0x528740) external _0x0057d3 {
        GeneScienceInterface _0x4ccd8f = GeneScienceInterface(_0x528740);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0x4ccd8f._0x63d297());

        // Set the new contract address
        _0xfb86db = _0x4ccd8f;
    }

    /// @dev Checks that a given kitten is able to breed. Requires that the
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function _0x947dff(Panda _0xa77a49) internal view returns(bool) {
        // In addition to checking the cooldownEndBlock, we also need to check to see if
        // the cat has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_0xa77a49._0x9c00e1 == 0) && (_0xa77a49._0xf8b55f <= uint64(block.number));
    }

    /// @dev Check if a sire has authorized breeding with this matron. True if both sire
    ///  and matron have the same owner, or if the sire has given siring permission to
    ///  the matron's owner (via approveSiring()).
    function _0xb4d690(uint256 _0xa47ccb, uint256 _0x159240) internal view returns(bool) {
        address _0x6195d4 = _0x1489f4[_0x159240];
        address _0x10b52b = _0x1489f4[_0xa47ccb];

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (_0x6195d4 == _0x10b52b || _0x39db11[_0xa47ccb] == _0x6195d4);
    }

    /// @dev Set the cooldownEndTime for the given Panda, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _kitten A reference to the Panda in storage which needs its timer started.
    function _0xb06e32(Panda storage _0xaafd3c) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
        _0xaafd3c._0xf8b55f = uint64((_0x56d799[_0xaafd3c._0x990f40] / _0x48a966) + block.number);

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_0xaafd3c._0x990f40 < 8 && _0xfb86db._0x10f542(_0xaafd3c._0x2e8019) != 1) {
            _0xaafd3c._0x990f40 += 1;
        }
    }

    /// @notice Grants approval to another user to sire with one of your Pandas.
    /// @param _addr The address that will be able to sire with your Panda. Set to
    ///  address(0) to clear all siring approvals for this Panda.
    /// @param _sireId A Panda that you own that _addr will now be able to sire with.
    function _0xd1072c(address _0xc9c990, uint256 _0xa47ccb)
    external
    _0xd08088 {
        require(_0x4b1122(msg.sender, _0xa47ccb));
        _0x39db11[_0xa47ccb] = _0xc9c990;
    }

    /// @dev Updates the minimum payment required for calling giveBirthAuto(). Can only
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred
    ///  by the autobirth daemon).
    function _0x4f156b(uint256 _0x457d97) external _0x6c655d {
        _0x331967 = _0x457d97;
    }

    /// @dev Checks to see if a given Panda is pregnant and (if so) if the gestation
    ///  period has passed.
    function _0x7b96fa(Panda _0x681327) private view returns(bool) {
        return (_0x681327._0x9c00e1 != 0) && (_0x681327._0xf8b55f <= uint64(block.number));
    }

    /// @notice Checks that a given kitten is able to breed (i.e. it is not pregnant or
    ///  in the middle of a siring cooldown).
    /// @param _pandaId reference the id of the kitten, any user can inquire about it
    function _0x666fed(uint256 _0xea2db4)
    public
    view
    returns(bool) {
        require(_0xea2db4 > 0);
        Panda storage _0x88a094 = _0xccbc26[_0xea2db4];
        return _0x947dff(_0x88a094);
    }

    /// @dev Checks whether a panda is currently pregnant.
    /// @param _pandaId reference the id of the kitten, any user can inquire about it
    function _0x7d2fb6(uint256 _0xea2db4)
    public
    view
    returns(bool) {
        require(_0xea2db4 > 0);
        // A panda is pregnant if and only if this field is set
        return _0xccbc26[_0xea2db4]._0x9c00e1 != 0;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the Panda struct of the potential matron.
    /// @param _matronId The matron's ID.
    /// @param _sire A reference to the Panda struct of the potential sire.
    /// @param _sireId The sire's ID
    function _0x75f075(
        Panda storage _0x681327,
        uint256 _0x159240,
        Panda storage _0x3f35b4,
        uint256 _0xa47ccb
    )
    private
    view
    returns(bool) {
        // A Panda can't breed with itself!
        if (_0x159240 == _0xa47ccb) {
            return false;
        }

        // Pandas can't breed with their parents.
        if (_0x681327._0x1cc8d3 == _0xa47ccb || _0x681327._0xe9c19a == _0xa47ccb) {
            return false;
        }
        if (_0x3f35b4._0x1cc8d3 == _0x159240 || _0x3f35b4._0xe9c19a == _0x159240) {
            return false;
        }

        // We can short circuit the sibling check (below) if either cat is
        // gen zero (has a matron ID of zero).
        if (_0x3f35b4._0x1cc8d3 == 0 || _0x681327._0x1cc8d3 == 0) {
            return true;
        }

        // Pandas can't breed with full or half siblings.
        if (_0x3f35b4._0x1cc8d3 == _0x681327._0x1cc8d3 || _0x3f35b4._0x1cc8d3 == _0x681327._0xe9c19a) {
            return false;
        }
        if (_0x3f35b4._0xe9c19a == _0x681327._0x1cc8d3 || _0x3f35b4._0xe9c19a == _0x681327._0xe9c19a) {
            return false;
        }

        // male should get breed with female
        if (_0xfb86db._0xa34681(_0x681327._0x2e8019) + _0xfb86db._0xa34681(_0x3f35b4._0x2e8019) != 1) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair for
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function _0x21c919(uint256 _0x159240, uint256 _0xa47ccb)
    internal
    view
    returns(bool) {
        Panda storage _0xe3dcec = _0xccbc26[_0x159240];
        Panda storage _0xa9d265 = _0xccbc26[_0xa47ccb];
        return _0x75f075(_0xe3dcec, _0x159240, _0xa9d265, _0xa47ccb);
    }

    /// @notice Checks to see if two cats can breed together, including checks for
    ///  ownership and siring approvals. Does NOT check that both cats are ready for
    ///  breeding (i.e. breedWith could still fail until the cooldowns are finished).
    ///  TODO: Shouldn't this check pregnancy and cooldowns?!?
    /// @param _matronId The ID of the proposed matron.
    /// @param _sireId The ID of the proposed sire.
    function _0x6bf1ad(uint256 _0x159240, uint256 _0xa47ccb)
    external
    view
    returns(bool) {
        require(_0x159240 > 0);
        require(_0xa47ccb > 0);
        Panda storage _0xe3dcec = _0xccbc26[_0x159240];
        Panda storage _0xa9d265 = _0xccbc26[_0xa47ccb];
        return _0x75f075(_0xe3dcec, _0x159240, _0xa9d265, _0xa47ccb) &&
            _0xb4d690(_0xa47ccb, _0x159240);
    }

    function _0x05c032(uint256 _0x159240, uint256 _0xa47ccb) internal returns(uint256, uint256) {
        if (_0xfb86db._0xa34681(_0xccbc26[_0x159240]._0x2e8019) == 1) {
            return (_0xa47ccb, _0x159240);
        } else {
            return (_0x159240, _0xa47ccb);
        }
    }

    /// @dev Internal utility function to initiate breeding, assumes that all breeding
    ///  requirements have been checked.
    function _0x248711(uint256 _0x159240, uint256 _0xa47ccb, address _0xa1f990) internal {
        // make id point real gender
        (_0x159240, _0xa47ccb) = _0x05c032(_0x159240, _0xa47ccb);
        // Grab a reference to the Pandas from storage.
        Panda storage _0xa9d265 = _0xccbc26[_0xa47ccb];
        Panda storage _0xe3dcec = _0xccbc26[_0x159240];

        // Mark the matron as pregnant, keeping track of who the sire is.
        _0xe3dcec._0x9c00e1 = uint32(_0xa47ccb);

        // Trigger the cooldown for both parents.
        _0xb06e32(_0xa9d265);
        _0xb06e32(_0xe3dcec);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete _0x39db11[_0x159240];
        delete _0x39db11[_0xa47ccb];

        // Every time a panda gets pregnant, counter is incremented.
        _0xada84f++;

        _0x9e1bbe[_0x159240] = _0xa1f990;

        // Emit the pregnancy event.
        Pregnant(_0x1489f4[_0x159240], _0x159240, _0xa47ccb, _0xe3dcec._0xf8b55f);
    }

    /// @notice Breed a Panda you own (as matron) with a sire that you own, or for which you
    ///  have previously been given Siring approval. Will either make your cat pregnant, or will
    ///  fail entirely. Requires a pre-payment of the fee given out to the first caller of giveBirth()
    /// @param _matronId The ID of the Panda acting as matron (will end up pregnant if successful)
    /// @param _sireId The ID of the Panda acting as sire (will begin its siring cooldown if successful)
    function _0x6ca36f(uint256 _0x159240, uint256 _0xa47ccb)
    external
    payable
    _0xd08088 {
        // Checks for payment.
        require(msg.value >= _0x331967);

        // Caller must own the matron.
        require(_0x4b1122(msg.sender, _0x159240));

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
        require(_0xb4d690(_0xa47ccb, _0x159240));

        // Grab a reference to the potential matron
        Panda storage _0xe3dcec = _0xccbc26[_0x159240];

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(_0x947dff(_0xe3dcec));

        // Grab a reference to the potential sire
        Panda storage _0xa9d265 = _0xccbc26[_0xa47ccb];

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(_0x947dff(_0xa9d265));

        // Test that these cats are a valid mating pair.
        require(_0x75f075(
            _0xe3dcec,
            _0x159240,
            _0xa9d265,
            _0xa47ccb
        ));

        // All checks passed, panda gets pregnant!
        _0x248711(_0x159240, _0xa47ccb, msg.sender);
    }

    /// @notice Have a pregnant Panda give birth!
    /// @param _matronId A Panda ready to give birth.
    /// @return The Panda ID of the new kitten.
    /// @dev Looks at a given Panda and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new kitten. The new Panda is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the

    ///  are willing to pay the gas!), but the new kitten always goes to the mother's owner.
    function _0xc70cea(uint256 _0x159240, uint256[2] _0x1fe607, uint256[2] _0x5cb52e)
    external
    _0xd08088
    _0x57543d
    returns(uint256) {
        // Grab a reference to the matron in storage.
        Panda storage _0xe3dcec = _0xccbc26[_0x159240];

        // Check that the matron is a valid cat.
        require(_0xe3dcec._0x9a305c != 0);

        // Check that the matron is pregnant, and that its time has come!
        require(_0x7b96fa(_0xe3dcec));

        // Grab a reference to the sire in storage.
        uint256 _0xe9c19a = _0xe3dcec._0x9c00e1;
        Panda storage _0xa9d265 = _0xccbc26[_0xe9c19a];

        // Determine the higher generation number of the two parents
        uint16 _0xe7632f = _0xe3dcec._0x121419;
        if (_0xa9d265._0x121419 > _0xe3dcec._0x121419) {
            _0xe7632f = _0xa9d265._0x121419;
        }

        // Call the sooper-sekret gene mixing operation.
        //uint256[2] memory childGenes = geneScience.mixGenes(matron.genes, sire.genes,matron.generation,sire.generation, matron.cooldownEndBlock - 1);
        uint256[2] memory _0x9f2392 = _0x1fe607;

        uint256 _0xc6d621 = 0;

        // birth failed
        uint256 _0xa832c4 = (_0xfb86db._0x30469b(_0xe3dcec._0x2e8019) + _0xfb86db._0x30469b(_0xa9d265._0x2e8019)) / 2 + _0x5cb52e[0];
        if (_0xa832c4 >= (_0xe7632f + 1) * _0x5cb52e[1]) {
            _0xa832c4 = _0xa832c4 - (_0xe7632f + 1) * _0x5cb52e[1];
        } else {
            _0xa832c4 = 0;
        }
        if (_0xe7632f == 0 && _0xc031eb == GEN0_TOTAL_COUNT) {
            _0xa832c4 = 0;
        }
        if (uint256(_0xf96263(block.blockhash(block.number - 2), _0x9e380d)) % 100 < _0xa832c4) {
            // Make the new kitten!
            address _0x8220f4 = _0x9e1bbe[_0x159240];
            _0xc6d621 = _0x65ca7b(_0x159240, _0xe3dcec._0x9c00e1, _0xe7632f + 1, _0x9f2392, _0x8220f4);
        } else {
            Abortion(_0x1489f4[_0x159240], _0x159240, _0xe9c19a);
        }
        // Make the new kitten!
        //address owner = pandaIndexToOwner[_matronId];
        //address owner = childOwner[_matronId];
        //uint256 kittenId = _createPanda(_matronId, matron.siringWithId, parentGen + 1, childGenes, owner);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete _0xe3dcec._0x9c00e1;

        // Every time a panda gives birth counter is decremented.
        _0xada84f--;

        // Send the balance fee to the person who made birth happen.
        msg.sender.send(_0x331967);

        delete _0x9e1bbe[_0x159240];

        // return the new kitten's ID
        return _0xc6d621;
    }
}

/// @title Auction Core
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuctionBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address _0x90f826;
        // Price (in wei) at beginning of auction
        uint128 _0x5807e4;
        // Price (in wei) at end of auction
        uint128 _0xd31b85;
        // Duration (in seconds) of auction
        uint64 _0xd2874f;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 _0x64601a;
        // is this auction for gen0 panda
        uint64 _0xec42d1;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public _0x8fe97c;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public _0xd3261f;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) _0xb96fb1;

    event AuctionCreated(uint256 _0x943848, uint256 _0x5807e4, uint256 _0xd31b85, uint256 _0xd2874f);
    event AuctionSuccessful(uint256 _0x943848, uint256 _0x68fc79, address _0x58f25a);
    event AuctionCancelled(uint256 _0x943848);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _0x4b1122(address _0xd71144, uint256 _0x2a0fb7) internal view returns (bool) {
        return (_0x8fe97c._0x6aa502(_0x2a0fb7) == _0xd71144);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _0xe5ccba(address _0xa1f990, uint256 _0x2a0fb7) internal {
        // it will throw if transfer fails
        _0x8fe97c._0xfabc8e(_0xa1f990, this, _0x2a0fb7);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _0x54f595(address _0xbb38a5, uint256 _0x2a0fb7) internal {
        // it will throw if transfer fails
        _0x8fe97c.transfer(_0xbb38a5, _0x2a0fb7);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _0x23df7e(uint256 _0x2a0fb7, Auction _0x1ed53c) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_0x1ed53c._0xd2874f >= 1 minutes);

        _0xb96fb1[_0x2a0fb7] = _0x1ed53c;

        AuctionCreated(
            uint256(_0x2a0fb7),
            uint256(_0x1ed53c._0x5807e4),
            uint256(_0x1ed53c._0xd31b85),
            uint256(_0x1ed53c._0xd2874f)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _0xe9165e(uint256 _0x2a0fb7, address _0xa5d202) internal {
        _0x850d63(_0x2a0fb7);
        _0x54f595(_0xa5d202, _0x2a0fb7);
        AuctionCancelled(_0x2a0fb7);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _0xe84084(uint256 _0x2a0fb7, uint256 _0x5c2f09)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage _0x48f123 = _0xb96fb1[_0x2a0fb7];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_0x625a36(_0x48f123));

        // Check that the bid is greater than or equal to the current price
        uint256 _0x6865b3 = _0x2793c4(_0x48f123);
        require(_0x5c2f09 >= _0x6865b3);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address _0x90f826 = _0x48f123._0x90f826;

        // The bid is good! Remove the auction before sending the fees
        _0x850d63(_0x2a0fb7);

        // Transfer proceeds to seller (if there are any!)
        if (_0x6865b3 > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 _0xe6a0ee = _0x9db62b(_0x6865b3);
            uint256 _0x303dd3 = _0x6865b3 - _0xe6a0ee;

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // a contract with an invalid fallback function. We explicitly
            // before calling transfer(), and the only thing the seller

            // accident, they can call cancelAuction(). )
            _0x90f826.transfer(_0x303dd3);
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or

        uint256 _0xc20f78 = _0x5c2f09 - _0x6865b3;

        // Return the funds. Similar to the previous transfer, this is
        // removed before any transfers occur.
        msg.sender.transfer(_0xc20f78);

        // Tell the world!
        AuctionSuccessful(_0x2a0fb7, _0x6865b3, msg.sender);

        return _0x6865b3;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function _0x850d63(uint256 _0x2a0fb7) internal {
        delete _0xb96fb1[_0x2a0fb7];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _0x625a36(Auction storage _0x1ed53c) internal view returns (bool) {
        return (_0x1ed53c._0x64601a > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _0x2793c4(Auction storage _0x1ed53c)
        internal
        view
        returns (uint256)
    {
        uint256 _0x37403d = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (_0x9e380d > _0x1ed53c._0x64601a) {
            _0x37403d = _0x9e380d - _0x1ed53c._0x64601a;
        }

        return _0x08b972(
            _0x1ed53c._0x5807e4,
            _0x1ed53c._0xd31b85,
            _0x1ed53c._0xd2874f,
            _0x37403d
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _0x08b972(
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66,
        uint256 _0x98b1fb
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
        if (_0x98b1fb >= _0x738e66) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _0x0713a2;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 _0xe4d803 = int256(_0x0713a2) - int256(_0xabaf22);

            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 _0xe57619 = _0xe4d803 * int256(_0x98b1fb) / int256(_0x738e66);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 _0xdcc091 = int256(_0xabaf22) + _0xe57619;

            return uint256(_0xdcc091);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _0x9db62b(uint256 _0x88da80) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _0x88da80 * _0xd3261f / 10000;
    }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0x4fadec = false;

  modifier _0xd08088() {
    require(!_0x4fadec);
    _;
  }

  modifier _0xea5b37 {
    require(_0x4fadec);
    _;
  }

  function _0xf06dd1() _0x41354a _0xd08088 returns (bool) {
    _0x4fadec = true;
    Pause();
    return true;
  }

  function _0x29c399() _0x41354a _0xea5b37 returns (bool) {
    _0x4fadec = false;
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
    function ClockAuction(address _0x178fd7, uint256 _0x8bc9ec) public {
        require(_0x8bc9ec <= 10000);
        _0xd3261f = _0x8bc9ec;

        ERC721 _0x4ccd8f = ERC721(_0x178fd7);
        require(_0x4ccd8f._0xc3fbe0(InterfaceSignature_ERC721));
        _0x8fe97c = _0x4ccd8f;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function _0xe9244c() external {
        address _0xff8058 = address(_0x8fe97c);

        require(
            msg.sender == _0x8220f4 ||
            msg.sender == _0xff8058
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool _0xa1b3cb = _0xff8058.send(this.balance);
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x717db7(
        uint256 _0x2a0fb7,
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66,
        address _0xa5d202
    )
        external
        _0xd08088
    {

        // to store them in the auction struct.
        require(_0xabaf22 == uint256(uint128(_0xabaf22)));
        require(_0x0713a2 == uint256(uint128(_0x0713a2)));
        require(_0x738e66 == uint256(uint64(_0x738e66)));

        require(_0x4b1122(msg.sender, _0x2a0fb7));
        _0xe5ccba(msg.sender, _0x2a0fb7);
        Auction memory _0x48f123 = Auction(
            _0xa5d202,
            uint128(_0xabaf22),
            uint128(_0x0713a2),
            uint64(_0x738e66),
            uint64(_0x9e380d),
            0
        );
        _0x23df7e(_0x2a0fb7, _0x48f123);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function _0xfa3b41(uint256 _0x2a0fb7)
        external
        payable
        _0xd08088
    {
        // _bid will throw if the bid or funds transfer fails
        _0xe84084(_0x2a0fb7, msg.value);
        _0x54f595(msg.sender, _0x2a0fb7);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function _0x23d753(uint256 _0x2a0fb7)
        external
    {
        Auction storage _0x48f123 = _0xb96fb1[_0x2a0fb7];
        require(_0x625a36(_0x48f123));
        address _0x90f826 = _0x48f123._0x90f826;
        require(msg.sender == _0x90f826);
        _0xe9165e(_0x2a0fb7, _0x90f826);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function _0xc5fc64(uint256 _0x2a0fb7)
        _0xea5b37
        _0x41354a
        external
    {
        Auction storage _0x48f123 = _0xb96fb1[_0x2a0fb7];
        require(_0x625a36(_0x48f123));
        _0xe9165e(_0x2a0fb7, _0x48f123._0x90f826);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function _0xa02f1d(uint256 _0x2a0fb7)
        external
        view
        returns
    (
        address _0x90f826,
        uint256 _0x5807e4,
        uint256 _0xd31b85,
        uint256 _0xd2874f,
        uint256 _0x64601a
    ) {
        Auction storage _0x48f123 = _0xb96fb1[_0x2a0fb7];
        require(_0x625a36(_0x48f123));
        return (
            _0x48f123._0x90f826,
            _0x48f123._0x5807e4,
            _0x48f123._0xd31b85,
            _0x48f123._0xd2874f,
            _0x48f123._0x64601a
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function _0x0270f4(uint256 _0x2a0fb7)
        external
        view
        returns (uint256)
    {
        Auction storage _0x48f123 = _0xb96fb1[_0x2a0fb7];
        require(_0x625a36(_0x48f123));
        return _0x2793c4(_0x48f123);
    }

}

/// @title Reverse auction modified for siring
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SiringClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSiringAuctionAddress() call.
    bool public _0x8042c1 = true;

    // Delegate constructor
    function SiringClockAuction(address _0x045b6f, uint256 _0x8bc9ec) public
        ClockAuction(_0x045b6f, _0x8bc9ec) {}

    /// @dev Creates and begins a new auction. Since this function is wrapped,
    /// require sender to be PandaCore contract.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x717db7(
        uint256 _0x2a0fb7,
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66,
        address _0xa5d202
    )
        external
    {

        // to store them in the auction struct.
        require(_0xabaf22 == uint256(uint128(_0xabaf22)));
        require(_0x0713a2 == uint256(uint128(_0x0713a2)));
        require(_0x738e66 == uint256(uint64(_0x738e66)));

        require(msg.sender == address(_0x8fe97c));
        _0xe5ccba(_0xa5d202, _0x2a0fb7);
        Auction memory _0x48f123 = Auction(
            _0xa5d202,
            uint128(_0xabaf22),
            uint128(_0x0713a2),
            uint64(_0x738e66),
            uint64(_0x9e380d),
            0
        );
        _0x23df7e(_0x2a0fb7, _0x48f123);
    }

    /// @dev Places a bid for siring. Requires the sender
    /// is the PandaCore contract because all bid methods
    /// should be wrapped. Also returns the panda to the
    /// seller rather than the winner.
    function _0xfa3b41(uint256 _0x2a0fb7)
        external
        payable
    {
        require(msg.sender == address(_0x8fe97c));
        address _0x90f826 = _0xb96fb1[_0x2a0fb7]._0x90f826;
        // _bid checks that token ID is valid and will throw if bid fails
        _0xe84084(_0x2a0fb7, msg.value);
        // We transfer the panda back to the seller, the winner will get
        // the offspring
        _0x54f595(_0x90f826, _0x2a0fb7);
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public _0xf35dbf = true;

    // Tracks last 5 sale price of gen0 panda sales
    uint256 public _0xfad7df;
    uint256[5] public _0x8da879;
    uint256 public constant SurpriseValue = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaIndex;
    uint256   RarePandaIndex;

    // Delegate constructor
    function SaleClockAuction(address _0x045b6f, uint256 _0x8bc9ec) public
        ClockAuction(_0x045b6f, _0x8bc9ec) {
            CommonPandaIndex = 1;
            RarePandaIndex   = 1;
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x717db7(
        uint256 _0x2a0fb7,
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66,
        address _0xa5d202
    )
        external
    {

        // to store them in the auction struct.
        require(_0xabaf22 == uint256(uint128(_0xabaf22)));
        require(_0x0713a2 == uint256(uint128(_0x0713a2)));
        require(_0x738e66 == uint256(uint64(_0x738e66)));

        require(msg.sender == address(_0x8fe97c));
        _0xe5ccba(_0xa5d202, _0x2a0fb7);
        Auction memory _0x48f123 = Auction(
            _0xa5d202,
            uint128(_0xabaf22),
            uint128(_0x0713a2),
            uint64(_0x738e66),
            uint64(_0x9e380d),
            0
        );
        _0x23df7e(_0x2a0fb7, _0x48f123);
    }

    function _0x32f6c5(
        uint256 _0x2a0fb7,
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66,
        address _0xa5d202
    )
        external
    {

        // to store them in the auction struct.
        require(_0xabaf22 == uint256(uint128(_0xabaf22)));
        require(_0x0713a2 == uint256(uint128(_0x0713a2)));
        require(_0x738e66 == uint256(uint64(_0x738e66)));

        require(msg.sender == address(_0x8fe97c));
        _0xe5ccba(_0xa5d202, _0x2a0fb7);
        Auction memory _0x48f123 = Auction(
            _0xa5d202,
            uint128(_0xabaf22),
            uint128(_0x0713a2),
            uint64(_0x738e66),
            uint64(_0x9e380d),
            1
        );
        _0x23df7e(_0x2a0fb7, _0x48f123);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function _0xfa3b41(uint256 _0x2a0fb7)
        external
        payable
    {
        // _bid verifies token ID size
        uint64 _0xec42d1 = _0xb96fb1[_0x2a0fb7]._0xec42d1;
        uint256 _0x6865b3 = _0xe84084(_0x2a0fb7, msg.value);
        _0x54f595(msg.sender, _0x2a0fb7);

        // If not a gen0 auction, exit
        if (_0xec42d1 == 1) {
            // Track gen0 sale prices
            _0x8da879[_0xfad7df % 5] = _0x6865b3;
            _0xfad7df++;
        }
    }

    function _0xa3b2ee(uint256 _0x2a0fb7,uint256 _0x6c813d)
        external
    {
        require(msg.sender == address(_0x8fe97c));
        if (_0x6c813d == 0) {
            CommonPanda.push(_0x2a0fb7);
        }else {
            RarePanda.push(_0x2a0fb7);
        }
    }

    function _0xd11bc8()
        external
        payable
    {
        bytes32 _0x2614ec = _0xf96263(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaIndex;
        if (_0x2614ec[25] > 0xC8) {
            require(uint256(RarePanda.length) >= RarePandaIndex);
            PandaIndex = RarePandaIndex;
            RarePandaIndex ++;

        } else{
            require(uint256(CommonPanda.length) >= CommonPandaIndex);
            PandaIndex = CommonPandaIndex;
            CommonPandaIndex ++;
        }
        _0x54f595(msg.sender,PandaIndex);
    }

    function _0xf9d215() external view returns(uint256 _0xee5283,uint256 _0x9a710c) {
        _0xee5283   = CommonPanda.length + 1 - CommonPandaIndex;
        _0x9a710c = RarePanda.length + 1 - RarePandaIndex;
    }

    function _0x6443ca() external view returns (uint256) {
        uint256 _0xdce758 = 0;
        for (uint256 i = 0; i < 5; i++) {
            _0xdce758 += _0x8da879[i];
        }
        return _0xdce758 / 5;
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 _0x943848, uint256 _0x5807e4, uint256 _0xd31b85, uint256 _0xd2874f, address _0xf2de6f);

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public _0x848770 = true;

    mapping (uint256 => address) public _0xe57b35;

    mapping (address => uint256) public _0xe649b0;

    mapping (address => uint256) public _0x423c03;

    // Delegate constructor
    function SaleClockAuctionERC20(address _0x045b6f, uint256 _0x8bc9ec) public
        ClockAuction(_0x045b6f, _0x8bc9ec) {}

    function _0x4e37eb(address _0x7d3779, uint256 _0xe4f6e7) external{
        require (msg.sender == address(_0x8fe97c));

        require (_0x7d3779 != address(0));

        _0xe649b0[_0x7d3779] = _0xe4f6e7;
    }
    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x717db7(
        uint256 _0x2a0fb7,
        address _0xbc65ac,
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66,
        address _0xa5d202
    )
        external
    {

        // to store them in the auction struct.
        require(_0xabaf22 == uint256(uint128(_0xabaf22)));
        require(_0x0713a2 == uint256(uint128(_0x0713a2)));
        require(_0x738e66 == uint256(uint64(_0x738e66)));

        require(msg.sender == address(_0x8fe97c));

        require (_0xe649b0[_0xbc65ac] > 0);

        _0xe5ccba(_0xa5d202, _0x2a0fb7);
        Auction memory _0x48f123 = Auction(
            _0xa5d202,
            uint128(_0xabaf22),
            uint128(_0x0713a2),
            uint64(_0x738e66),
            uint64(_0x9e380d),
            0
        );
        _0xd16c6a(_0x2a0fb7, _0x48f123, _0xbc65ac);
        _0xe57b35[_0x2a0fb7] = _0xbc65ac;
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _0xd16c6a(uint256 _0x2a0fb7, Auction _0x1ed53c, address _0x7d3779) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_0x1ed53c._0xd2874f >= 1 minutes);

        _0xb96fb1[_0x2a0fb7] = _0x1ed53c;

        AuctionERC20Created(
            uint256(_0x2a0fb7),
            uint256(_0x1ed53c._0x5807e4),
            uint256(_0x1ed53c._0xd31b85),
            uint256(_0x1ed53c._0xd2874f),
            _0x7d3779
        );
    }

    function _0xfa3b41(uint256 _0x2a0fb7)
        external
        payable{
            // do nothing
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function _0xc0a153(uint256 _0x2a0fb7,uint256 _0x9f9fe9)
        external
    {
        // _bid verifies token ID size
        address _0x90f826 = _0xb96fb1[_0x2a0fb7]._0x90f826;
        address _0x7d3779 = _0xe57b35[_0x2a0fb7];
        require (_0x7d3779 != address(0));
        uint256 _0x6865b3 = _0xf1c7e2(_0x7d3779,msg.sender,_0x2a0fb7, _0x9f9fe9);
        _0x54f595(msg.sender, _0x2a0fb7);
        delete _0xe57b35[_0x2a0fb7];
    }

    function _0x23d753(uint256 _0x2a0fb7)
        external
    {
        Auction storage _0x48f123 = _0xb96fb1[_0x2a0fb7];
        require(_0x625a36(_0x48f123));
        address _0x90f826 = _0x48f123._0x90f826;
        require(msg.sender == _0x90f826);
        _0xe9165e(_0x2a0fb7, _0x90f826);
        delete _0xe57b35[_0x2a0fb7];
    }

    function _0x800540(address _0xbc65ac, address _0x546d79) external returns(bool _0xa1b3cb)  {
        require (_0x423c03[_0xbc65ac] > 0);
        require(msg.sender == address(_0x8fe97c));
        ERC20(_0xbc65ac).transfer(_0x546d79, _0x423c03[_0xbc65ac]);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _0xf1c7e2(address _0xbc65ac,address _0x9d7ce8, uint256 _0x2a0fb7, uint256 _0x5c2f09)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage _0x48f123 = _0xb96fb1[_0x2a0fb7];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_0x625a36(_0x48f123));

        require (_0xbc65ac != address(0) && _0xbc65ac == _0xe57b35[_0x2a0fb7]);

        // Check that the bid is greater than or equal to the current price
        uint256 _0x6865b3 = _0x2793c4(_0x48f123);
        require(_0x5c2f09 >= _0x6865b3);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address _0x90f826 = _0x48f123._0x90f826;

        // The bid is good! Remove the auction before sending the fees
        _0x850d63(_0x2a0fb7);

        // Transfer proceeds to seller (if there are any!)
        if (_0x6865b3 > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 _0xe6a0ee = _0x9db62b(_0x6865b3);
            uint256 _0x303dd3 = _0x6865b3 - _0xe6a0ee;

            // Send Erc20 Token to seller should call Erc20 contract
            // Reference to contract
            require(ERC20(_0xbc65ac)._0xfabc8e(_0x9d7ce8,_0x90f826,_0x303dd3));
            if (_0xe6a0ee > 0){
                require(ERC20(_0xbc65ac)._0xfabc8e(_0x9d7ce8,address(this),_0xe6a0ee));
                _0x423c03[_0xbc65ac] += _0xe6a0ee;
            }
        }

        // Tell the world!
        AuctionSuccessful(_0x2a0fb7, _0x6865b3, msg.sender);

        return _0x6865b3;
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
    function _0x4213e9(address _0x528740) external _0x0057d3 {
        SaleClockAuction _0x4ccd8f = SaleClockAuction(_0x528740);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0x4ccd8f._0xf35dbf());

        // Set the new contract address
        _0x09557d = _0x4ccd8f;
    }

    function _0x976607(address _0x528740) external _0x0057d3 {
        SaleClockAuctionERC20 _0x4ccd8f = SaleClockAuctionERC20(_0x528740);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0x4ccd8f._0x848770());

        // Set the new contract address
        _0x74715e = _0x4ccd8f;
    }

    /// @dev Sets the reference to the siring auction.
    /// @param _address - Address of siring contract.
    function _0x44f254(address _0x528740) external _0x0057d3 {
        SiringClockAuction _0x4ccd8f = SiringClockAuction(_0x528740);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0x4ccd8f._0x8042c1());

        // Set the new contract address
        _0x286f88 = _0x4ccd8f;
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function _0xe7f71b(
        uint256 _0xea2db4,
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66
    )
        external
        _0xd08088
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x4b1122(msg.sender, _0xea2db4));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!_0x7d2fb6(_0xea2db4));
        _0xa63ae3(_0xea2db4, _0x09557d);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x09557d._0x717db7(
            _0xea2db4,
            _0xabaf22,
            _0x0713a2,
            _0x738e66,
            msg.sender
        );
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function _0xcc11d5(
        uint256 _0xea2db4,
        address _0x7d3779,
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66
    )
        external
        _0xd08088
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x4b1122(msg.sender, _0xea2db4));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!_0x7d2fb6(_0xea2db4));
        _0xa63ae3(_0xea2db4, _0x74715e);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x74715e._0x717db7(
            _0xea2db4,
            _0x7d3779,
            _0xabaf22,
            _0x0713a2,
            _0x738e66,
            msg.sender
        );
    }

    function _0x421643(address _0x7d3779, uint256 _0xe4f6e7) external _0x6c655d{
        _0x74715e._0x4e37eb(_0x7d3779,_0xe4f6e7);
    }

    /// @dev Put a panda up for auction to be sire.
    ///  Performs checks to ensure the panda can be sired, then
    ///  delegates to reverse auction.
    function _0x99abcc(
        uint256 _0xea2db4,
        uint256 _0xabaf22,
        uint256 _0x0713a2,
        uint256 _0x738e66
    )
        external
        _0xd08088
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x4b1122(msg.sender, _0xea2db4));
        require(_0x666fed(_0xea2db4));
        _0xa63ae3(_0xea2db4, _0x286f88);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x286f88._0x717db7(
            _0xea2db4,
            _0xabaf22,
            _0x0713a2,
            _0x738e66,
            msg.sender
        );
    }

    /// @dev Completes a siring auction by bidding.
    ///  Immediately breeds the winning matron with the sire on auction.
    /// @param _sireId - ID of the sire on auction.
    /// @param _matronId - ID of the matron owned by the bidder.
    function _0x8aa274(
        uint256 _0xa47ccb,
        uint256 _0x159240
    )
        external
        payable
        _0xd08088
    {
        // Auction contract checks input sizes
        require(_0x4b1122(msg.sender, _0x159240));
        require(_0x666fed(_0x159240));
        require(_0x21c919(_0x159240, _0xa47ccb));

        // Define the current price of the auction.
        uint256 _0xdcc091 = _0x286f88._0x0270f4(_0xa47ccb);
        require(msg.value >= _0xdcc091 + _0x331967);

        // Siring auction will throw if the bid fails.
        _0x286f88._0xfa3b41.value(msg.value - _0x331967)(_0xa47ccb);
        _0x248711(uint32(_0x159240), uint32(_0xa47ccb), msg.sender);
    }

    /// @dev Transfers the balance of the sale auction contract
    /// to the PandaCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function _0x5e9172() external _0x57543d {
        _0x09557d._0xe9244c();
        _0x286f88._0xe9244c();
    }

    function _0x800540(address _0xbc65ac, address _0x546d79) external _0x57543d {
        require(_0x74715e != address(0));
        _0x74715e._0x800540(_0xbc65ac,_0x546d79);
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
    function _0x1524cb(uint256[2] _0x5b953b, uint256 _0x527278, address _0xa1f990) external _0x6c655d {
        address _0xcfa38d = _0xa1f990;
        if (_0xcfa38d == address(0)) {
            _0xcfa38d = _0xf36c1e;
        }

        _0x65ca7b(0, 0, _0x527278, _0x5b953b, _0xcfa38d);
    }

    /// @dev create pandaWithGenes
    /// @param _genes panda genes
    /// @param _type  0 common 1 rare
    function _0xa3b2ee(uint256[2] _0x5b953b,uint256 _0x527278,uint256 _0x6c813d)
        external
        payable
        _0x6c655d
        _0xd08088
    {
        require(msg.value >= OPEN_PACKAGE_PRICE);
        uint256 _0xc6d621 = _0x65ca7b(0, 0, _0x527278, _0x5b953b, _0x09557d);
        _0x09557d._0xa3b2ee(_0xc6d621,_0x6c813d);
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

    function _0x32f6c5(uint256 _0xea2db4) external _0x6c655d {
        require(_0x4b1122(msg.sender, _0xea2db4));
        //require(pandas[_pandaId].generation==1);

        _0xa63ae3(_0xea2db4, _0x09557d);

        _0x09557d._0x32f6c5(
            _0xea2db4,
            _0x8599da(),
            0,
            GEN0_AUCTION_DURATION,
            msg.sender
        );
    }

    /// @dev Computes the next gen0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function _0x8599da() internal view returns(uint256) {
        uint256 _0xec909d = _0x09557d._0x6443ca();

        require(_0xec909d == uint256(uint128(_0xec909d)));

        uint256 _0xb3f6ea = _0xec909d + (_0xec909d / 2);

        // We never auction for less than starting price
        if (_0xb3f6ea < GEN0_STARTING_PRICE) {
            _0xb3f6ea = GEN0_STARTING_PRICE;
        }

        return _0xb3f6ea;
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
    address public _0x54bfc7;

    /// @notice Creates the main CryptoPandas smart contract instance.
    function PandaCore() public {
        // Starts paused.
        _0x4fadec = true;

        // the creator of the contract is the initial CEO
        _0x4d531c = msg.sender;

        // the creator of the contract is also the initial COO
        _0xf36c1e = msg.sender;

        // move these code to init(), so we not excceed gas limit
        //uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        //wizzPandaQuota[1] = 100;

        //_createPanda(0, 0, 0, _genes, address(0));
    }

    /// init contract
    function _0xcafe55() external _0x0057d3 _0xea5b37 {
        // make sure init() only run once
        require(_0xccbc26.length == 0);
        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        uint256[2] memory _0x5b953b = [uint256(-1),uint256(-1)];

        _0x7c3e5b[1] = 100;
       _0x65ca7b(0, 0, 0, _0x5b953b, address(0));
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious

    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function _0xe41800(address _0x492f3f) external _0x0057d3 _0xea5b37 {
        // See README.md for updgrade plan
        _0x54bfc7 = _0x492f3f;
        ContractUpgrade(_0x492f3f);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(_0x09557d) ||
            msg.sender == address(_0x286f88)
        );
    }

    /// @notice Returns all the relevant information about a specific panda.
    /// @param _id The ID of the panda of interest.
    function _0x94e412(uint256 _0x6ddf15)
        external
        view
        returns (
        bool _0xf3aa16,
        bool _0x951518,
        uint256 _0x990f40,
        uint256 _0xed65d1,
        uint256 _0x9c00e1,
        uint256 _0x9a305c,
        uint256 _0x1cc8d3,
        uint256 _0xe9c19a,
        uint256 _0x121419,
        uint256[2] _0x2e8019
    ) {
        Panda storage _0x88a094 = _0xccbc26[_0x6ddf15];

        // if this variable is 0 then it's not gestating
        _0xf3aa16 = (_0x88a094._0x9c00e1 != 0);
        _0x951518 = (_0x88a094._0xf8b55f <= block.number);
        _0x990f40 = uint256(_0x88a094._0x990f40);
        _0xed65d1 = uint256(_0x88a094._0xf8b55f);
        _0x9c00e1 = uint256(_0x88a094._0x9c00e1);
        _0x9a305c = uint256(_0x88a094._0x9a305c);
        _0x1cc8d3 = uint256(_0x88a094._0x1cc8d3);
        _0xe9c19a = uint256(_0x88a094._0xe9c19a);
        _0x121419 = uint256(_0x88a094._0x121419);
        _0x2e8019 = _0x88a094._0x2e8019;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function _0x29c399() public _0x0057d3 _0xea5b37 {
        require(_0x09557d != address(0));
        require(_0x286f88 != address(0));
        require(_0xfb86db != address(0));
        require(_0x54bfc7 == address(0));

        // Actually unpause the contract.
        super._0x29c399();
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function _0xe9244c() external _0xf9975c {
        uint256 balance = this.balance;
        // Subtract all the currently pregnant kittens we have, plus 1 of margin.
        uint256 _0xaa3003 = (_0xada84f + 1) * _0x331967;

        if (balance > _0xaa3003) {
            _0x52de96.send(balance - _0xaa3003);
        }
    }
}
