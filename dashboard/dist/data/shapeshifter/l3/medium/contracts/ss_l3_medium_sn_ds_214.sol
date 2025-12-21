// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ERC20 {
    function _0xdb8844() constant returns (uint _0x4a287f);
    function _0x9028c4( address _0xd3d244 ) constant returns (uint value);
    function _0x262b99( address _0x0b1336, address _0xe6a582 ) constant returns (uint _0xdced59);

    function transfer( address _0x3efa74, uint value) returns (bool _0xf9887e);
    function _0x7edb83( address from, address _0x3efa74, uint value) returns (bool _0xf9887e);
    function _0x134ce7( address _0xe6a582, uint value ) returns (bool _0xf9887e);

    event Transfer( address indexed from, address indexed _0x3efa74, uint value);
    event Approval( address indexed _0x0b1336, address indexed _0xe6a582, uint value);
}
contract Ownable {
  address public _0x0b1336;

  function Ownable() {
    if (msg.sender != address(0) || msg.sender == address(0)) { _0x0b1336 = msg.sender; }
  }

  modifier _0x517506() {
    require(msg.sender == _0x0b1336);
    _;
  }

  function _0x210542(address _0x3e43c5) _0x517506 {
    if (_0x3e43c5 != address(0)) {
      _0x0b1336 = _0x3e43c5;
    }
  }

}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function _0xdb8844() public view returns (uint256 _0xceed70);
    function _0x9028c4(address _0x90c915) public view returns (uint256 balance);
    function _0xca4b21(uint256 _0x049778) external view returns (address _0x0b1336);
    function _0x134ce7(address _0x12afbb, uint256 _0x049778) external;
    function transfer(address _0x12afbb, uint256 _0x049778) external;
    function _0x7edb83(address _0xa37b1a, address _0x12afbb, uint256 _0x049778) external;

    // Events
    event Transfer(address from, address _0x3efa74, uint256 _0xf095ac);
    event Approval(address _0x0b1336, address _0xae7dcb, uint256 _0xf095ac);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function _0x7152ff(bytes4 _0xac23c9) external view returns (bool);
}

contract GeneScienceInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function _0x5ee0b9() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @return the genes that are supposed to be passed down the child
    function _0x77a4ca(uint256[2] _0x2af0e1, uint256[2] _0x31d0d4,uint256 _0xfbc7dc,uint256 _0xafb38c, uint256 _0xc2bb43) public returns (uint256[2]);

    function _0x8d0142(uint256[2] _0x8298f6) public view returns(uint256);

    /// @dev get sex from genes 0: female 1: male
    function _0xe9cd63(uint256[2] _0x8298f6) public view returns(uint256);

    /// @dev get wizz type from gene
    function _0x2f25a0(uint256[2] _0x8298f6) public view returns(uint256);

    function _0xb28bb5(uint256[2] _0xe4f88e) public returns(uint256[2]);
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
    event ContractUpgrade(address _0x0d5cbe);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public _0x1df02a;
    address public _0x5f6ced;
    address public _0x122dce;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public _0x7b2f24 = false;

    /// @dev Access modifier for CEO-only functionality
    modifier _0x20e9d6() {
        require(msg.sender == _0x1df02a);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier _0x3fba34() {
        require(msg.sender == _0x5f6ced);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier _0xb96194() {
        require(msg.sender == _0x122dce);
        _;
    }

    modifier _0x8aee9d() {
        require(
            msg.sender == _0x122dce ||
            msg.sender == _0x1df02a ||
            msg.sender == _0x5f6ced
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function _0x804293(address _0x66309b) external _0x20e9d6 {
        require(_0x66309b != address(0));

        _0x1df02a = _0x66309b;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function _0x4568fc(address _0x057016) external _0x20e9d6 {
        require(_0x057016 != address(0));

        if (1 == 1) { _0x5f6ced = _0x057016; }
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function _0x1f69a6(address _0x890298) external _0x20e9d6 {
        require(_0x890298 != address(0));

        _0x122dce = _0x890298;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier _0xcd2c4d() {
        require(!_0x7b2f24);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier _0x80ec37 {
        require(_0x7b2f24);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    function _0x50b0cf() external _0x8aee9d _0xcd2c4d {
        _0x7b2f24 = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function _0x50447b() public _0x20e9d6 _0x80ec37 {
        // can't unpause if contract was upgraded
        _0x7b2f24 = false;
    }
}

/// @title Base contract for CryptoPandas. Holds all common structs, events and base variables.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaBase is PandaAccessControl {
    /*** EVENTS ***/

    uint256 public constant GEN0_TOTAL_COUNT = 16200;
    uint256 public _0x2545d4;

    /// @dev The Birth event is fired whenever a new kitten comes into existence. This obviously
    ///  includes any time a cat is created through the giveBirth method, but it is also called
    ///  when a new gen0 cat is created.
    event Birth(address _0x0b1336, uint256 _0x8ad6f4, uint256 _0x083499, uint256 _0xaf24ed, uint256[2] _0xcb80f9);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a kitten
    ///  ownership is assigned, including births.
    event Transfer(address from, address _0x3efa74, uint256 _0xf095ac);

    /*** DATA TYPES ***/

    /// @dev The main Panda struct. Every cat in CryptoPandas is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Panda {
        // The Panda's genetic code is packed into these 256-bits, the format is
        // sooper-sekret! A cat's genes never change.
        uint256[2] _0xcb80f9;

        // The timestamp from the block when this cat came into existence.
        uint64 _0x7e502a;

        // The minimum timestamp after which this cat can engage in breeding
        // activities again. This same timestamp is used for the pregnancy
        // timer (for matrons) as well as the siring cooldown.
        uint64 _0x510cf0;

        // The ID of the parents of this panda, set to 0 for gen0 cats.
        // Note that using 32-bit unsigned integers limits us to a "mere"
        // 4 billion cats. This number might seem small until you realize
        // that Ethereum currently has a limit of about 500 million
        // transactions per year! So, this definitely won't be a problem
        // for several years (even as Ethereum learns to scale).
        uint32 _0x083499;
        uint32 _0xaf24ed;

        // Set to the ID of the sire cat for matrons that are pregnant,
        // zero otherwise. A non-zero value here is how we know a cat
        // is pregnant. Used to retrieve the genetic material for the new
        // kitten when the birth transpires.
        uint32 _0xe669a8;

        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this Panda. This starts at zero
        // for gen0 cats, and is initialized to floor(generation/2) for others.
        // Incremented by one for each successful breeding action, regardless
        // of whether this cat is acting as matron or sire.
        uint16 _0x2a3cd7;

        // The "generation number" of this cat. Cats minted by the CK contract
        // for sale are called "gen0" and have a generation number of 0. The
        // generation number of all other cats is the larger of the two generation
        // numbers of their parents, plus one.
        // (i.e. max(matron.generation, sire.generation) + 1)
        uint16 _0x76e375;
    }

    /*** CONSTANTS ***/

    /// @dev A lookup table indicating the cooldown duration after any successful
    ///  breeding action, called "pregnancy time" for matrons and "siring cooldown"
    ///  for sires. Designed such that the cooldown roughly doubles each time a cat
    ///  is bred, encouraging owners not to just keep breeding the same cat over
    ///  and over again. Caps out at one week (a cat can breed an unbounded number
    ///  of times, and the maximum cooldown is always seven days).
    uint32[9] public _0x8d7f8a = [
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
    uint256 public _0xb384d2 = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Panda struct for all Pandas in existence. The ID
    ///  of each cat is actually an index into this array. Note that ID 0 is a negacat,
    ///  the unPanda, the mythical beast that is the parent of all gen0 cats. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, cat ID 0 is invalid... ;-)
    Panda[] _0xc533e7;

    /// @dev A mapping from cat IDs to the address that owns them. All cats have
    ///  some valid owner address, even gen0 cats are created with a non-zero owner.
    mapping (uint256 => address) public _0xc987a5;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) _0xc1e264;

    /// @dev A mapping from PandaIDs to an address that has been approved to call
    ///  transferFrom(). Each Panda can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public _0x4ee770;

    /// @dev A mapping from PandaIDs to an address that has been approved to use
    ///  this Panda for siring via breedWith(). Each Panda can only have one approved
    ///  address for siring at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public _0xd87028;

    /// @dev The address of the ClockAuction contract that handles sales of Pandas. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public _0x9d61a8;

    /// @dev The address of a custom ClockAuction subclassed contract that handles siring
    ///  auctions. Needs to be separate from saleAuction because the actions taken on success
    ///  after a sales and siring auction are quite different.
    SiringClockAuction public _0x14383e;

    /// @dev The address of the sibling contract that is used to implement the sooper-sekret
    ///  genetic combination algorithm.
    GeneScienceInterface public _0x893437;

    SaleClockAuctionERC20 public _0x999e41;

    // wizz panda total
    mapping (uint256 => uint256) public _0x45cb49;
    mapping (uint256 => uint256) public _0xaf955e;

    /// wizz panda control
    function _0x04f7e7(uint256 _0xb44bf2) view external returns(uint256) {
        return _0x45cb49[_0xb44bf2];
    }

    function _0x45665c(uint256 _0xb44bf2) view external returns(uint256) {
        return _0xaf955e[_0xb44bf2];
    }

    function _0xeff829(uint256 _0xb44bf2,uint256 _0xec527d) external _0x8aee9d {
        require (_0x45cb49[_0xb44bf2]==0);
        require (_0xec527d==uint256(uint32(_0xec527d)));
        _0x45cb49[_0xb44bf2] = _0xec527d;
    }

    function _0x7b4cdf(uint256 _0xb0fb98) view external returns(uint256) {
        Panda memory _0xb33104 = _0xc533e7[_0xb0fb98];
        return _0x893437._0x2f25a0(_0xb33104._0xcb80f9);
    }

    /// @dev Assigns ownership of a specific Panda to an address.
    function _0xe798af(address _0xa37b1a, address _0x12afbb, uint256 _0x049778) internal {

        _0xc1e264[_0x12afbb]++;
        // transfer ownership
        _0xc987a5[_0x049778] = _0x12afbb;
        // When creating new kittens _from is 0x0, but we can't account that address.
        if (_0xa37b1a != address(0)) {
            _0xc1e264[_0xa37b1a]--;
            // once the kitten is transferred also clear sire allowances
            delete _0xd87028[_0x049778];
            // clear any previously approved ownership exchange
            delete _0x4ee770[_0x049778];
        }
        // Emit the transfer event.
        Transfer(_0xa37b1a, _0x12afbb, _0x049778);
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
    function _0xc08487(
        uint256 _0x5fa965,
        uint256 _0x6b7f19,
        uint256 _0xd0df00,
        uint256[2] _0x3e0e5d,
        address _0x90c915
    )
        internal
        returns (uint)
    {
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createPanda() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        require(_0x5fa965 == uint256(uint32(_0x5fa965)));
        require(_0x6b7f19 == uint256(uint32(_0x6b7f19)));
        require(_0xd0df00 == uint256(uint16(_0xd0df00)));

        // New panda starts with the same cooldown as parent gen/2
        uint16 _0x2a3cd7 = 0;
        // when contract creation, geneScience ref is null
        if (_0xc533e7.length>0){
            uint16 _0x73b732 = uint16(_0x893437._0x8d0142(_0x3e0e5d));
            if (_0x73b732==0) {
                _0x73b732 = 1;
            }
            _0x2a3cd7 = 1000/_0x73b732;
            if (_0x2a3cd7%10 < 5){
                _0x2a3cd7 = _0x2a3cd7/10;
            }else{
                _0x2a3cd7 = _0x2a3cd7/10 + 1;
            }
            _0x2a3cd7 = _0x2a3cd7 - 1;
            if (_0x2a3cd7 > 8) {
                _0x2a3cd7 = 8;
            }
            uint256 _0xb44bf2 = _0x893437._0x2f25a0(_0x3e0e5d);
            if (_0xb44bf2>0 && _0x45cb49[_0xb44bf2]<=_0xaf955e[_0xb44bf2]) {
                _0x3e0e5d = _0x893437._0xb28bb5(_0x3e0e5d);
                _0xb44bf2 = 0;
            }
            // gensis panda cooldownIndex should be 24 hours
            if (_0xb44bf2 == 1){
                _0x2a3cd7 = 5;
            }

            // increase wizz counter
            if (_0xb44bf2>0){
                _0xaf955e[_0xb44bf2] = _0xaf955e[_0xb44bf2] + 1;
            }
            // all gen0&gen1 except gensis
            if (_0xd0df00 <= 1 && _0xb44bf2 != 1){
                require(_0x2545d4<GEN0_TOTAL_COUNT);
                _0x2545d4++;
            }
        }

        Panda memory _0x83767d = Panda({
            _0xcb80f9: _0x3e0e5d,
            _0x7e502a: uint64(_0x512f80),
            _0x510cf0: 0,
            _0x083499: uint32(_0x5fa965),
            _0xaf24ed: uint32(_0x6b7f19),
            _0xe669a8: 0,
            _0x2a3cd7: _0x2a3cd7,
            _0x76e375: uint16(_0xd0df00)
        });
        uint256 _0x66a508 = _0xc533e7.push(_0x83767d) - 1;

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(_0x66a508 == uint256(uint32(_0x66a508)));

        // emit the birth event
        Birth(
            _0x90c915,
            _0x66a508,
            uint256(_0x83767d._0x083499),
            uint256(_0x83767d._0xaf24ed),
            _0x83767d._0xcb80f9
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _0xe798af(0, _0x90c915, _0x66a508);

        return _0x66a508;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function _0x3bbee0(uint256 _0xf2fb38) external _0x8aee9d {
        require(_0xf2fb38 < _0x8d7f8a[0]);
        if (gasleft() > 0) { _0xb384d2 = _0xf2fb38; }
    }
}
/// @title The external contract that is responsible for generating metadata for the pandas,
///  it has one function that will return the data as bytes.
contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function _0xf86fdb(uint256 _0x049778, string) public view returns (bytes32[4] _0xacf169, uint256 _0xdbea9d) {
        if (_0x049778 == 1) {
            _0xacf169[0] = "Hello World! :D";
            _0xdbea9d = 15;
        } else if (_0x049778 == 2) {
            _0xacf169[0] = "I would definitely choose a medi";
            _0xacf169[1] = "um length string.";
            _0xdbea9d = 49;
        } else if (_0x049778 == 3) {
            _0xacf169[0] = "Lorem ipsum dolor sit amet, mi e";
            _0xacf169[1] = "st accumsan dapibus augue lorem,";
            _0xacf169[2] = " tristique vestibulum id, libero";
            _0xacf169[3] = " suscipit varius sapien aliquam.";
            _0xdbea9d = 128;
        }
    }
}

/// @title The facet of the CryptoPandas core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaOwnership is PandaBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant _0xa20022 = "PandaEarth";
    string public constant _0xd73048 = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(_0x8f603b('_0x7152ff(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(_0x8f603b('_0xa20022()')) ^
        bytes4(_0x8f603b('_0xd73048()')) ^
        bytes4(_0x8f603b('_0xdb8844()')) ^
        bytes4(_0x8f603b('_0x9028c4(address)')) ^
        bytes4(_0x8f603b('_0xca4b21(uint256)')) ^
        bytes4(_0x8f603b('_0x134ce7(address,uint256)')) ^
        bytes4(_0x8f603b('transfer(address,uint256)')) ^
        bytes4(_0x8f603b('_0x7edb83(address,address,uint256)')) ^
        bytes4(_0x8f603b('_0xdbecbe(address)')) ^
        bytes4(_0x8f603b('tokenMetadata(uint256,string)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function _0x7152ff(bytes4 _0xac23c9) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_0xac23c9 == InterfaceSignature_ERC165) || (_0xac23c9 == InterfaceSignature_ERC721));
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Panda.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId kitten id, only valid when > 0
    function _0x29a9ac(address _0xd134a4, uint256 _0x049778) internal view returns (bool) {
        return _0xc987a5[_0x049778] == _0xd134a4;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Panda.
    /// @param _claimant the address we are confirming kitten is approved for.
    /// @param _tokenId kitten id, only valid when > 0
    function _0x41da49(address _0xd134a4, uint256 _0x049778) internal view returns (bool) {
        return _0x4ee770[_0x049778] == _0xd134a4;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Pandas on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _0xb9517b(uint256 _0x049778, address _0x65ddca) internal {
        _0x4ee770[_0x049778] = _0x65ddca;
    }

    /// @notice Returns the number of Pandas owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function _0x9028c4(address _0x90c915) public view returns (uint256 _0xdbea9d) {
        return _0xc1e264[_0x90c915];
    }

    /// @notice Transfers a Panda to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoPandas specifically) or your Panda may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Panda to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address _0x12afbb,
        uint256 _0x049778
    )
        external
        _0xcd2c4d
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_0x12afbb != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any pandas (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_0x12afbb != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of pandas
        // through the allow + transferFrom flow.
        require(_0x12afbb != address(_0x9d61a8));
        require(_0x12afbb != address(_0x14383e));

        // You can only send your own cat.
        require(_0x29a9ac(msg.sender, _0x049778));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _0xe798af(msg.sender, _0x12afbb, _0x049778);
    }

    /// @notice Grant another address the right to transfer a specific Panda via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Panda that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function _0x134ce7(
        address _0x12afbb,
        uint256 _0x049778
    )
        external
        _0xcd2c4d
    {
        // Only an owner can grant transfer approval.
        require(_0x29a9ac(msg.sender, _0x049778));

        // Register the approval (replacing any previous approval).
        _0xb9517b(_0x049778, _0x12afbb);

        // Emit approval event.
        Approval(msg.sender, _0x12afbb, _0x049778);
    }

    /// @notice Transfer a Panda owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Panda to be transfered.
    /// @param _to The address that should take ownership of the Panda. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Panda to be transferred.
    /// @dev Required for ERC-721 compliance.
    function _0x7edb83(
        address _0xa37b1a,
        address _0x12afbb,
        uint256 _0x049778
    )
        external
        _0xcd2c4d
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_0x12afbb != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any pandas (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_0x12afbb != address(this));
        // Check for approval and valid ownership
        require(_0x41da49(msg.sender, _0x049778));
        require(_0x29a9ac(_0xa37b1a, _0x049778));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _0xe798af(_0xa37b1a, _0x12afbb, _0x049778);
    }

    /// @notice Returns the total number of Pandas currently in existence.
    /// @dev Required for ERC-721 compliance.
    function _0xdb8844() public view returns (uint) {
        return _0xc533e7.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Panda.
    /// @dev Required for ERC-721 compliance.
    function _0xca4b21(uint256 _0x049778)
        external
        view
        returns (address _0x0b1336)
    {
        _0x0b1336 = _0xc987a5[_0x049778];

        require(_0x0b1336 != address(0));
    }

    /// @notice Returns a list of all Panda IDs assigned to an address.
    /// @param _owner The owner whose Pandas we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Panda array looking for cats belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function _0xdbecbe(address _0x90c915) external view returns(uint256[] _0x0a6961) {
        uint256 _0x3a2120 = _0x9028c4(_0x90c915);

        if (_0x3a2120 == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory _0x4edfbf = new uint256[](_0x3a2120);
            uint256 _0xb19406 = _0xdb8844();
            uint256 _0x1a8461 = 0;

            // We count on the fact that all cats have IDs starting at 1 and increasing
            // sequentially up to the totalCat count.
            uint256 _0x28ce45;

            for (_0x28ce45 = 1; _0x28ce45 <= _0xb19406; _0x28ce45++) {
                if (_0xc987a5[_0x28ce45] == _0x90c915) {
                    _0x4edfbf[_0x1a8461] = _0x28ce45;
                    _0x1a8461++;
                }
            }

            return _0x4edfbf;
        }
    }

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _0x3a69f6(uint _0x20c036, uint _0x4faa3d, uint _0x8598bf) private view {
        // Copy word-length chunks while possible
        for(; _0x8598bf >= 32; _0x8598bf -= 32) {
            assembly {
                mstore(_0x20c036, mload(_0x4faa3d))
            }
            _0x20c036 += 32;
            _0x4faa3d += 32;
        }

        // Copy remaining bytes
        uint256 _0x84ce9c = 256 ** (32 - _0x8598bf) - 1;
        assembly {
            let _0x6bac39 := and(mload(_0x4faa3d), not(_0x84ce9c))
            let _0x52934f := and(mload(_0x20c036), _0x84ce9c)
            mstore(_0x20c036, or(_0x52934f, _0x6bac39))
        }
    }

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _0x7b0649(bytes32[4] _0xcbc6b0, uint256 _0xf6a031) private view returns (string) {
        var _0xace83c = new string(_0xf6a031);
        uint256 _0x983fe3;
        uint256 _0x7725b1;

        assembly {
            _0x983fe3 := add(_0xace83c, 32)
            _0x7725b1 := _0xcbc6b0
        }

        _0x3a69f6(_0x983fe3, _0x7725b1, _0xf6a031);

        return _0xace83c;
    }

}

/// @title A facet of PandaCore that manages Panda siring, gestation, and birth.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaBreeding is PandaOwnership {

    uint256 public constant GENSIS_TOTAL_COUNT = 100;

    /// @dev The Pregnant event is fired when two cats successfully breed and the pregnancy
    ///  timer begins for the matron.
    event Pregnant(address _0x0b1336, uint256 _0x083499, uint256 _0xaf24ed, uint256 _0x510cf0);
    /// @dev The Abortion event is fired when two cats breed failed.
    event Abortion(address _0x0b1336, uint256 _0x083499, uint256 _0xaf24ed);

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public _0xa3b5d9 = 2 finney;

    // Keeps track of number of pregnant pandas.
    uint256 public _0xf4fb3e;

    mapping(uint256 => address) _0xe930f3;

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a GeneScience contract instance to be used from this point forward.
    function _0x4746ed(address _0x7c1b7d) external _0x20e9d6 {
        GeneScienceInterface _0x44ded6 = GeneScienceInterface(_0x7c1b7d);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0x44ded6._0x5ee0b9());

        // Set the new contract address
        _0x893437 = _0x44ded6;
    }

    /// @dev Checks that a given kitten is able to breed. Requires that the
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function _0x228e89(Panda _0xcb8d5e) internal view returns(bool) {
        // In addition to checking the cooldownEndBlock, we also need to check to see if
        // the cat has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_0xcb8d5e._0xe669a8 == 0) && (_0xcb8d5e._0x510cf0 <= uint64(block.number));
    }

    /// @dev Check if a sire has authorized breeding with this matron. True if both sire
    ///  and matron have the same owner, or if the sire has given siring permission to
    ///  the matron's owner (via approveSiring()).
    function _0xa5716a(uint256 _0x6b7f19, uint256 _0x5fa965) internal view returns(bool) {
        address _0x253e89 = _0xc987a5[_0x5fa965];
        address _0xbd057a = _0xc987a5[_0x6b7f19];

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (_0x253e89 == _0xbd057a || _0xd87028[_0x6b7f19] == _0x253e89);
    }

    /// @dev Set the cooldownEndTime for the given Panda, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _kitten A reference to the Panda in storage which needs its timer started.
    function _0x00cf8c(Panda storage _0x7ec266) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
        _0x7ec266._0x510cf0 = uint64((_0x8d7f8a[_0x7ec266._0x2a3cd7] / _0xb384d2) + block.number);

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_0x7ec266._0x2a3cd7 < 8 && _0x893437._0x2f25a0(_0x7ec266._0xcb80f9) != 1) {
            _0x7ec266._0x2a3cd7 += 1;
        }
    }

    /// @notice Grants approval to another user to sire with one of your Pandas.
    /// @param _addr The address that will be able to sire with your Panda. Set to
    ///  address(0) to clear all siring approvals for this Panda.
    /// @param _sireId A Panda that you own that _addr will now be able to sire with.
    function _0x2518d0(address _0xf63c19, uint256 _0x6b7f19)
    external
    _0xcd2c4d {
        require(_0x29a9ac(msg.sender, _0x6b7f19));
        _0xd87028[_0x6b7f19] = _0xf63c19;
    }

    /// @dev Updates the minimum payment required for calling giveBirthAuto(). Can only
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred
    ///  by the autobirth daemon).
    function _0x365018(uint256 _0x9c7ea9) external _0xb96194 {
        if (gasleft() > 0) { _0xa3b5d9 = _0x9c7ea9; }
    }

    /// @dev Checks to see if a given Panda is pregnant and (if so) if the gestation
    ///  period has passed.
    function _0x7119b3(Panda _0xe3da68) private view returns(bool) {
        return (_0xe3da68._0xe669a8 != 0) && (_0xe3da68._0x510cf0 <= uint64(block.number));
    }

    /// @notice Checks that a given kitten is able to breed (i.e. it is not pregnant or
    ///  in the middle of a siring cooldown).
    /// @param _pandaId reference the id of the kitten, any user can inquire about it
    function _0x31c887(uint256 _0xc2b2df)
    public
    view
    returns(bool) {
        require(_0xc2b2df > 0);
        Panda storage _0x80abe0 = _0xc533e7[_0xc2b2df];
        return _0x228e89(_0x80abe0);
    }

    /// @dev Checks whether a panda is currently pregnant.
    /// @param _pandaId reference the id of the kitten, any user can inquire about it
    function _0x522f42(uint256 _0xc2b2df)
    public
    view
    returns(bool) {
        require(_0xc2b2df > 0);
        // A panda is pregnant if and only if this field is set
        return _0xc533e7[_0xc2b2df]._0xe669a8 != 0;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the Panda struct of the potential matron.
    /// @param _matronId The matron's ID.
    /// @param _sire A reference to the Panda struct of the potential sire.
    /// @param _sireId The sire's ID
    function _0x2b8af3(
        Panda storage _0xe3da68,
        uint256 _0x5fa965,
        Panda storage _0xf3472a,
        uint256 _0x6b7f19
    )
    private
    view
    returns(bool) {
        // A Panda can't breed with itself!
        if (_0x5fa965 == _0x6b7f19) {
            return false;
        }

        // Pandas can't breed with their parents.
        if (_0xe3da68._0x083499 == _0x6b7f19 || _0xe3da68._0xaf24ed == _0x6b7f19) {
            return false;
        }
        if (_0xf3472a._0x083499 == _0x5fa965 || _0xf3472a._0xaf24ed == _0x5fa965) {
            return false;
        }

        // We can short circuit the sibling check (below) if either cat is
        // gen zero (has a matron ID of zero).
        if (_0xf3472a._0x083499 == 0 || _0xe3da68._0x083499 == 0) {
            return true;
        }

        // Pandas can't breed with full or half siblings.
        if (_0xf3472a._0x083499 == _0xe3da68._0x083499 || _0xf3472a._0x083499 == _0xe3da68._0xaf24ed) {
            return false;
        }
        if (_0xf3472a._0xaf24ed == _0xe3da68._0x083499 || _0xf3472a._0xaf24ed == _0xe3da68._0xaf24ed) {
            return false;
        }

        // male should get breed with female
        if (_0x893437._0xe9cd63(_0xe3da68._0xcb80f9) + _0x893437._0xe9cd63(_0xf3472a._0xcb80f9) != 1) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair for
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function _0x2a3a84(uint256 _0x5fa965, uint256 _0x6b7f19)
    internal
    view
    returns(bool) {
        Panda storage _0x7f8a0b = _0xc533e7[_0x5fa965];
        Panda storage _0xdbd379 = _0xc533e7[_0x6b7f19];
        return _0x2b8af3(_0x7f8a0b, _0x5fa965, _0xdbd379, _0x6b7f19);
    }

    /// @notice Checks to see if two cats can breed together, including checks for
    ///  ownership and siring approvals. Does NOT check that both cats are ready for
    ///  breeding (i.e. breedWith could still fail until the cooldowns are finished).
    ///  TODO: Shouldn't this check pregnancy and cooldowns?!?
    /// @param _matronId The ID of the proposed matron.
    /// @param _sireId The ID of the proposed sire.
    function _0x491d9b(uint256 _0x5fa965, uint256 _0x6b7f19)
    external
    view
    returns(bool) {
        require(_0x5fa965 > 0);
        require(_0x6b7f19 > 0);
        Panda storage _0x7f8a0b = _0xc533e7[_0x5fa965];
        Panda storage _0xdbd379 = _0xc533e7[_0x6b7f19];
        return _0x2b8af3(_0x7f8a0b, _0x5fa965, _0xdbd379, _0x6b7f19) &&
            _0xa5716a(_0x6b7f19, _0x5fa965);
    }

    function _0x6d800f(uint256 _0x5fa965, uint256 _0x6b7f19) internal returns(uint256, uint256) {
        if (_0x893437._0xe9cd63(_0xc533e7[_0x5fa965]._0xcb80f9) == 1) {
            return (_0x6b7f19, _0x5fa965);
        } else {
            return (_0x5fa965, _0x6b7f19);
        }
    }

    /// @dev Internal utility function to initiate breeding, assumes that all breeding
    ///  requirements have been checked.
    function _0xf50ffe(uint256 _0x5fa965, uint256 _0x6b7f19, address _0x90c915) internal {
        // make id point real gender
        (_0x5fa965, _0x6b7f19) = _0x6d800f(_0x5fa965, _0x6b7f19);
        // Grab a reference to the Pandas from storage.
        Panda storage _0xdbd379 = _0xc533e7[_0x6b7f19];
        Panda storage _0x7f8a0b = _0xc533e7[_0x5fa965];

        // Mark the matron as pregnant, keeping track of who the sire is.
        _0x7f8a0b._0xe669a8 = uint32(_0x6b7f19);

        // Trigger the cooldown for both parents.
        _0x00cf8c(_0xdbd379);
        _0x00cf8c(_0x7f8a0b);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete _0xd87028[_0x5fa965];
        delete _0xd87028[_0x6b7f19];

        // Every time a panda gets pregnant, counter is incremented.
        _0xf4fb3e++;

        _0xe930f3[_0x5fa965] = _0x90c915;

        // Emit the pregnancy event.
        Pregnant(_0xc987a5[_0x5fa965], _0x5fa965, _0x6b7f19, _0x7f8a0b._0x510cf0);
    }

    /// @notice Breed a Panda you own (as matron) with a sire that you own, or for which you
    ///  have previously been given Siring approval. Will either make your cat pregnant, or will
    ///  fail entirely. Requires a pre-payment of the fee given out to the first caller of giveBirth()
    /// @param _matronId The ID of the Panda acting as matron (will end up pregnant if successful)
    /// @param _sireId The ID of the Panda acting as sire (will begin its siring cooldown if successful)
    function _0xb91a11(uint256 _0x5fa965, uint256 _0x6b7f19)
    external
    payable
    _0xcd2c4d {
        // Checks for payment.
        require(msg.value >= _0xa3b5d9);

        // Caller must own the matron.
        require(_0x29a9ac(msg.sender, _0x5fa965));

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
        require(_0xa5716a(_0x6b7f19, _0x5fa965));

        // Grab a reference to the potential matron
        Panda storage _0x7f8a0b = _0xc533e7[_0x5fa965];

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(_0x228e89(_0x7f8a0b));

        // Grab a reference to the potential sire
        Panda storage _0xdbd379 = _0xc533e7[_0x6b7f19];

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(_0x228e89(_0xdbd379));

        // Test that these cats are a valid mating pair.
        require(_0x2b8af3(
            _0x7f8a0b,
            _0x5fa965,
            _0xdbd379,
            _0x6b7f19
        ));

        // All checks passed, panda gets pregnant!
        _0xf50ffe(_0x5fa965, _0x6b7f19, msg.sender);
    }

    /// @notice Have a pregnant Panda give birth!
    /// @param _matronId A Panda ready to give birth.
    /// @return The Panda ID of the new kitten.
    /// @dev Looks at a given Panda and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new kitten. The new Panda is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the

    ///  are willing to pay the gas!), but the new kitten always goes to the mother's owner.
    function _0xb99ccb(uint256 _0x5fa965, uint256[2] _0x905e7a, uint256[2] _0xbf3fd9)
    external
    _0xcd2c4d
    _0x8aee9d
    returns(uint256) {
        // Grab a reference to the matron in storage.
        Panda storage _0x7f8a0b = _0xc533e7[_0x5fa965];

        // Check that the matron is a valid cat.
        require(_0x7f8a0b._0x7e502a != 0);

        // Check that the matron is pregnant, and that its time has come!
        require(_0x7119b3(_0x7f8a0b));

        // Grab a reference to the sire in storage.
        uint256 _0xaf24ed = _0x7f8a0b._0xe669a8;
        Panda storage _0xdbd379 = _0xc533e7[_0xaf24ed];

        // Determine the higher generation number of the two parents
        uint16 _0xed54ff = _0x7f8a0b._0x76e375;
        if (_0xdbd379._0x76e375 > _0x7f8a0b._0x76e375) {
            _0xed54ff = _0xdbd379._0x76e375;
        }

        // Call the sooper-sekret gene mixing operation.
        //uint256[2] memory childGenes = geneScience.mixGenes(matron.genes, sire.genes,matron.generation,sire.generation, matron.cooldownEndBlock - 1);
        uint256[2] memory _0x879e8a = _0x905e7a;

        uint256 _0x6ecde4 = 0;

        // birth failed
        uint256 _0x11d750 = (_0x893437._0x8d0142(_0x7f8a0b._0xcb80f9) + _0x893437._0x8d0142(_0xdbd379._0xcb80f9)) / 2 + _0xbf3fd9[0];
        if (_0x11d750 >= (_0xed54ff + 1) * _0xbf3fd9[1]) {
            _0x11d750 = _0x11d750 - (_0xed54ff + 1) * _0xbf3fd9[1];
        } else {
            _0x11d750 = 0;
        }
        if (_0xed54ff == 0 && _0x2545d4 == GEN0_TOTAL_COUNT) {
            _0x11d750 = 0;
        }
        if (uint256(_0x8f603b(block.blockhash(block.number - 2), _0x512f80)) % 100 < _0x11d750) {
            // Make the new kitten!
            address _0x0b1336 = _0xe930f3[_0x5fa965];
            _0x6ecde4 = _0xc08487(_0x5fa965, _0x7f8a0b._0xe669a8, _0xed54ff + 1, _0x879e8a, _0x0b1336);
        } else {
            Abortion(_0xc987a5[_0x5fa965], _0x5fa965, _0xaf24ed);
        }
        // Make the new kitten!
        //address owner = pandaIndexToOwner[_matronId];
        //address owner = childOwner[_matronId];
        //uint256 kittenId = _createPanda(_matronId, matron.siringWithId, parentGen + 1, childGenes, owner);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete _0x7f8a0b._0xe669a8;

        // Every time a panda gives birth counter is decremented.
        _0xf4fb3e--;

        // Send the balance fee to the person who made birth happen.
        msg.sender.send(_0xa3b5d9);

        delete _0xe930f3[_0x5fa965];

        // return the new kitten's ID
        return _0x6ecde4;
    }
}

/// @title Auction Core
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuctionBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address _0xb3314b;
        // Price (in wei) at beginning of auction
        uint128 _0x1f2716;
        // Price (in wei) at end of auction
        uint128 _0x2293d7;
        // Duration (in seconds) of auction
        uint64 _0x8d058b;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 _0x8b399a;
        // is this auction for gen0 panda
        uint64 _0xe1e433;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public _0xfaeabf;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public _0xfe2e52;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) _0x2080c0;

    event AuctionCreated(uint256 _0xf095ac, uint256 _0x1f2716, uint256 _0x2293d7, uint256 _0x8d058b);
    event AuctionSuccessful(uint256 _0xf095ac, uint256 _0x6dc0b0, address _0xd10610);
    event AuctionCancelled(uint256 _0xf095ac);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _0x29a9ac(address _0xd134a4, uint256 _0x049778) internal view returns (bool) {
        return (_0xfaeabf._0xca4b21(_0x049778) == _0xd134a4);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _0x7a19d5(address _0x90c915, uint256 _0x049778) internal {
        // it will throw if transfer fails
        _0xfaeabf._0x7edb83(_0x90c915, this, _0x049778);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _0xe798af(address _0x8002d1, uint256 _0x049778) internal {
        // it will throw if transfer fails
        _0xfaeabf.transfer(_0x8002d1, _0x049778);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _0x0037d8(uint256 _0x049778, Auction _0x5bed0c) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_0x5bed0c._0x8d058b >= 1 minutes);

        _0x2080c0[_0x049778] = _0x5bed0c;

        AuctionCreated(
            uint256(_0x049778),
            uint256(_0x5bed0c._0x1f2716),
            uint256(_0x5bed0c._0x2293d7),
            uint256(_0x5bed0c._0x8d058b)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _0x6ee978(uint256 _0x049778, address _0x6adb42) internal {
        _0xa50752(_0x049778);
        _0xe798af(_0x6adb42, _0x049778);
        AuctionCancelled(_0x049778);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _0x021cd6(uint256 _0x049778, uint256 _0x21b099)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage _0x70ed48 = _0x2080c0[_0x049778];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_0x3b6e6b(_0x70ed48));

        // Check that the bid is greater than or equal to the current price
        uint256 _0x58ecc0 = _0x12efe8(_0x70ed48);
        require(_0x21b099 >= _0x58ecc0);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address _0xb3314b = _0x70ed48._0xb3314b;

        // The bid is good! Remove the auction before sending the fees
        _0xa50752(_0x049778);

        // Transfer proceeds to seller (if there are any!)
        if (_0x58ecc0 > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 _0x8ba325 = _0x77dec1(_0x58ecc0);
            uint256 _0x5639f4 = _0x58ecc0 - _0x8ba325;

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // a contract with an invalid fallback function. We explicitly
            // before calling transfer(), and the only thing the seller

            // accident, they can call cancelAuction(). )
            _0xb3314b.transfer(_0x5639f4);
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or

        uint256 _0x45820f = _0x21b099 - _0x58ecc0;

        // Return the funds. Similar to the previous transfer, this is
        // removed before any transfers occur.
        msg.sender.transfer(_0x45820f);

        // Tell the world!
        AuctionSuccessful(_0x049778, _0x58ecc0, msg.sender);

        return _0x58ecc0;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function _0xa50752(uint256 _0x049778) internal {
        delete _0x2080c0[_0x049778];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _0x3b6e6b(Auction storage _0x5bed0c) internal view returns (bool) {
        return (_0x5bed0c._0x8b399a > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _0x12efe8(Auction storage _0x5bed0c)
        internal
        view
        returns (uint256)
    {
        uint256 _0xdeebe1 = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (_0x512f80 > _0x5bed0c._0x8b399a) {
            _0xdeebe1 = _0x512f80 - _0x5bed0c._0x8b399a;
        }

        return _0xa317bd(
            _0x5bed0c._0x1f2716,
            _0x5bed0c._0x2293d7,
            _0x5bed0c._0x8d058b,
            _0xdeebe1
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _0xa317bd(
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d,
        uint256 _0x0236c7
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
        if (_0x0236c7 >= _0x35394d) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _0xa1cc3b;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 _0xbbead0 = int256(_0xa1cc3b) - int256(_0x2e060f);

            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 _0x142f34 = _0xbbead0 * int256(_0x0236c7) / int256(_0x35394d);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 _0x6b4681 = int256(_0x2e060f) + _0x142f34;

            return uint256(_0x6b4681);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _0x77dec1(uint256 _0x52f8b0) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _0x52f8b0 * _0xfe2e52 / 10000;
    }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0x7b2f24 = false;

  modifier _0xcd2c4d() {
    require(!_0x7b2f24);
    _;
  }

  modifier _0x80ec37 {
    require(_0x7b2f24);
    _;
  }

  function _0x50b0cf() _0x517506 _0xcd2c4d returns (bool) {
    if (block.timestamp > 0) { _0x7b2f24 = true; }
    Pause();
    return true;
  }

  function _0x50447b() _0x517506 _0x80ec37 returns (bool) {
    if (true) { _0x7b2f24 = false; }
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
    function ClockAuction(address _0x643ee7, uint256 _0x12f479) public {
        require(_0x12f479 <= 10000);
        _0xfe2e52 = _0x12f479;

        ERC721 _0x44ded6 = ERC721(_0x643ee7);
        require(_0x44ded6._0x7152ff(InterfaceSignature_ERC721));
        if (1 == 1) { _0xfaeabf = _0x44ded6; }
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function _0x93111a() external {
        address _0x296e7a = address(_0xfaeabf);

        require(
            msg.sender == _0x0b1336 ||
            msg.sender == _0x296e7a
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool _0x05911b = _0x296e7a.send(this.balance);
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x36521f(
        uint256 _0x049778,
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d,
        address _0x6adb42
    )
        external
        _0xcd2c4d
    {

        // to store them in the auction struct.
        require(_0x2e060f == uint256(uint128(_0x2e060f)));
        require(_0xa1cc3b == uint256(uint128(_0xa1cc3b)));
        require(_0x35394d == uint256(uint64(_0x35394d)));

        require(_0x29a9ac(msg.sender, _0x049778));
        _0x7a19d5(msg.sender, _0x049778);
        Auction memory _0x70ed48 = Auction(
            _0x6adb42,
            uint128(_0x2e060f),
            uint128(_0xa1cc3b),
            uint64(_0x35394d),
            uint64(_0x512f80),
            0
        );
        _0x0037d8(_0x049778, _0x70ed48);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function _0x74d815(uint256 _0x049778)
        external
        payable
        _0xcd2c4d
    {
        // _bid will throw if the bid or funds transfer fails
        _0x021cd6(_0x049778, msg.value);
        _0xe798af(msg.sender, _0x049778);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function _0xf4946e(uint256 _0x049778)
        external
    {
        Auction storage _0x70ed48 = _0x2080c0[_0x049778];
        require(_0x3b6e6b(_0x70ed48));
        address _0xb3314b = _0x70ed48._0xb3314b;
        require(msg.sender == _0xb3314b);
        _0x6ee978(_0x049778, _0xb3314b);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function _0xc26ca3(uint256 _0x049778)
        _0x80ec37
        _0x517506
        external
    {
        Auction storage _0x70ed48 = _0x2080c0[_0x049778];
        require(_0x3b6e6b(_0x70ed48));
        _0x6ee978(_0x049778, _0x70ed48._0xb3314b);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function _0x0302aa(uint256 _0x049778)
        external
        view
        returns
    (
        address _0xb3314b,
        uint256 _0x1f2716,
        uint256 _0x2293d7,
        uint256 _0x8d058b,
        uint256 _0x8b399a
    ) {
        Auction storage _0x70ed48 = _0x2080c0[_0x049778];
        require(_0x3b6e6b(_0x70ed48));
        return (
            _0x70ed48._0xb3314b,
            _0x70ed48._0x1f2716,
            _0x70ed48._0x2293d7,
            _0x70ed48._0x8d058b,
            _0x70ed48._0x8b399a
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function _0xbea2cf(uint256 _0x049778)
        external
        view
        returns (uint256)
    {
        Auction storage _0x70ed48 = _0x2080c0[_0x049778];
        require(_0x3b6e6b(_0x70ed48));
        return _0x12efe8(_0x70ed48);
    }

}

/// @title Reverse auction modified for siring
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SiringClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSiringAuctionAddress() call.
    bool public _0xa12e4a = true;

    // Delegate constructor
    function SiringClockAuction(address _0x75d52e, uint256 _0x12f479) public
        ClockAuction(_0x75d52e, _0x12f479) {}

    /// @dev Creates and begins a new auction. Since this function is wrapped,
    /// require sender to be PandaCore contract.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x36521f(
        uint256 _0x049778,
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d,
        address _0x6adb42
    )
        external
    {

        // to store them in the auction struct.
        require(_0x2e060f == uint256(uint128(_0x2e060f)));
        require(_0xa1cc3b == uint256(uint128(_0xa1cc3b)));
        require(_0x35394d == uint256(uint64(_0x35394d)));

        require(msg.sender == address(_0xfaeabf));
        _0x7a19d5(_0x6adb42, _0x049778);
        Auction memory _0x70ed48 = Auction(
            _0x6adb42,
            uint128(_0x2e060f),
            uint128(_0xa1cc3b),
            uint64(_0x35394d),
            uint64(_0x512f80),
            0
        );
        _0x0037d8(_0x049778, _0x70ed48);
    }

    /// @dev Places a bid for siring. Requires the sender
    /// is the PandaCore contract because all bid methods
    /// should be wrapped. Also returns the panda to the
    /// seller rather than the winner.
    function _0x74d815(uint256 _0x049778)
        external
        payable
    {
        require(msg.sender == address(_0xfaeabf));
        address _0xb3314b = _0x2080c0[_0x049778]._0xb3314b;
        // _bid checks that token ID is valid and will throw if bid fails
        _0x021cd6(_0x049778, msg.value);
        // We transfer the panda back to the seller, the winner will get
        // the offspring
        _0xe798af(_0xb3314b, _0x049778);
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public _0x54d5fe = true;

    // Tracks last 5 sale price of gen0 panda sales
    uint256 public _0xfca44d;
    uint256[5] public _0xbbac3a;
    uint256 public constant SurpriseValue = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaIndex;
    uint256   RarePandaIndex;

    // Delegate constructor
    function SaleClockAuction(address _0x75d52e, uint256 _0x12f479) public
        ClockAuction(_0x75d52e, _0x12f479) {
            CommonPandaIndex = 1;
            RarePandaIndex   = 1;
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x36521f(
        uint256 _0x049778,
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d,
        address _0x6adb42
    )
        external
    {

        // to store them in the auction struct.
        require(_0x2e060f == uint256(uint128(_0x2e060f)));
        require(_0xa1cc3b == uint256(uint128(_0xa1cc3b)));
        require(_0x35394d == uint256(uint64(_0x35394d)));

        require(msg.sender == address(_0xfaeabf));
        _0x7a19d5(_0x6adb42, _0x049778);
        Auction memory _0x70ed48 = Auction(
            _0x6adb42,
            uint128(_0x2e060f),
            uint128(_0xa1cc3b),
            uint64(_0x35394d),
            uint64(_0x512f80),
            0
        );
        _0x0037d8(_0x049778, _0x70ed48);
    }

    function _0x5be602(
        uint256 _0x049778,
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d,
        address _0x6adb42
    )
        external
    {

        // to store them in the auction struct.
        require(_0x2e060f == uint256(uint128(_0x2e060f)));
        require(_0xa1cc3b == uint256(uint128(_0xa1cc3b)));
        require(_0x35394d == uint256(uint64(_0x35394d)));

        require(msg.sender == address(_0xfaeabf));
        _0x7a19d5(_0x6adb42, _0x049778);
        Auction memory _0x70ed48 = Auction(
            _0x6adb42,
            uint128(_0x2e060f),
            uint128(_0xa1cc3b),
            uint64(_0x35394d),
            uint64(_0x512f80),
            1
        );
        _0x0037d8(_0x049778, _0x70ed48);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function _0x74d815(uint256 _0x049778)
        external
        payable
    {
        // _bid verifies token ID size
        uint64 _0xe1e433 = _0x2080c0[_0x049778]._0xe1e433;
        uint256 _0x58ecc0 = _0x021cd6(_0x049778, msg.value);
        _0xe798af(msg.sender, _0x049778);

        // If not a gen0 auction, exit
        if (_0xe1e433 == 1) {
            // Track gen0 sale prices
            _0xbbac3a[_0xfca44d % 5] = _0x58ecc0;
            _0xfca44d++;
        }
    }

    function _0x597820(uint256 _0x049778,uint256 _0x9904f3)
        external
    {
        require(msg.sender == address(_0xfaeabf));
        if (_0x9904f3 == 0) {
            CommonPanda.push(_0x049778);
        }else {
            RarePanda.push(_0x049778);
        }
    }

    function _0x97cb70()
        external
        payable
    {
        bytes32 _0x5b4bcd = _0x8f603b(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaIndex;
        if (_0x5b4bcd[25] > 0xC8) {
            require(uint256(RarePanda.length) >= RarePandaIndex);
            PandaIndex = RarePandaIndex;
            RarePandaIndex ++;

        } else{
            require(uint256(CommonPanda.length) >= CommonPandaIndex);
            PandaIndex = CommonPandaIndex;
            CommonPandaIndex ++;
        }
        _0xe798af(msg.sender,PandaIndex);
    }

    function _0x743230() external view returns(uint256 _0x93ef0e,uint256 _0x768a6f) {
        if (1 == 1) { _0x93ef0e   = CommonPanda.length + 1 - CommonPandaIndex; }
        _0x768a6f = RarePanda.length + 1 - RarePandaIndex;
    }

    function _0x0227b9() external view returns (uint256) {
        uint256 _0xa56371 = 0;
        for (uint256 i = 0; i < 5; i++) {
            _0xa56371 += _0xbbac3a[i];
        }
        return _0xa56371 / 5;
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 _0xf095ac, uint256 _0x1f2716, uint256 _0x2293d7, uint256 _0x8d058b, address _0x1885cb);

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public _0x8b272b = true;

    mapping (uint256 => address) public _0xf0a0e7;

    mapping (address => uint256) public _0x9e3cd1;

    mapping (address => uint256) public _0x52e8c3;

    // Delegate constructor
    function SaleClockAuctionERC20(address _0x75d52e, uint256 _0x12f479) public
        ClockAuction(_0x75d52e, _0x12f479) {}

    function _0x3c0db4(address _0x79ea74, uint256 _0x80e4a4) external{
        require (msg.sender == address(_0xfaeabf));

        require (_0x79ea74 != address(0));

        _0x9e3cd1[_0x79ea74] = _0x80e4a4;
    }
    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function _0x36521f(
        uint256 _0x049778,
        address _0xe11838,
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d,
        address _0x6adb42
    )
        external
    {

        // to store them in the auction struct.
        require(_0x2e060f == uint256(uint128(_0x2e060f)));
        require(_0xa1cc3b == uint256(uint128(_0xa1cc3b)));
        require(_0x35394d == uint256(uint64(_0x35394d)));

        require(msg.sender == address(_0xfaeabf));

        require (_0x9e3cd1[_0xe11838] > 0);

        _0x7a19d5(_0x6adb42, _0x049778);
        Auction memory _0x70ed48 = Auction(
            _0x6adb42,
            uint128(_0x2e060f),
            uint128(_0xa1cc3b),
            uint64(_0x35394d),
            uint64(_0x512f80),
            0
        );
        _0x5e8333(_0x049778, _0x70ed48, _0xe11838);
        _0xf0a0e7[_0x049778] = _0xe11838;
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _0x5e8333(uint256 _0x049778, Auction _0x5bed0c, address _0x79ea74) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_0x5bed0c._0x8d058b >= 1 minutes);

        _0x2080c0[_0x049778] = _0x5bed0c;

        AuctionERC20Created(
            uint256(_0x049778),
            uint256(_0x5bed0c._0x1f2716),
            uint256(_0x5bed0c._0x2293d7),
            uint256(_0x5bed0c._0x8d058b),
            _0x79ea74
        );
    }

    function _0x74d815(uint256 _0x049778)
        external
        payable{
            // do nothing
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function _0xcd851c(uint256 _0x049778,uint256 _0x33c6e5)
        external
    {
        // _bid verifies token ID size
        address _0xb3314b = _0x2080c0[_0x049778]._0xb3314b;
        address _0x79ea74 = _0xf0a0e7[_0x049778];
        require (_0x79ea74 != address(0));
        uint256 _0x58ecc0 = _0xb1b5e7(_0x79ea74,msg.sender,_0x049778, _0x33c6e5);
        _0xe798af(msg.sender, _0x049778);
        delete _0xf0a0e7[_0x049778];
    }

    function _0xf4946e(uint256 _0x049778)
        external
    {
        Auction storage _0x70ed48 = _0x2080c0[_0x049778];
        require(_0x3b6e6b(_0x70ed48));
        address _0xb3314b = _0x70ed48._0xb3314b;
        require(msg.sender == _0xb3314b);
        _0x6ee978(_0x049778, _0xb3314b);
        delete _0xf0a0e7[_0x049778];
    }

    function _0x358923(address _0xe11838, address _0x12afbb) external returns(bool _0x05911b)  {
        require (_0x52e8c3[_0xe11838] > 0);
        require(msg.sender == address(_0xfaeabf));
        ERC20(_0xe11838).transfer(_0x12afbb, _0x52e8c3[_0xe11838]);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _0xb1b5e7(address _0xe11838,address _0xac0294, uint256 _0x049778, uint256 _0x21b099)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage _0x70ed48 = _0x2080c0[_0x049778];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_0x3b6e6b(_0x70ed48));

        require (_0xe11838 != address(0) && _0xe11838 == _0xf0a0e7[_0x049778]);

        // Check that the bid is greater than or equal to the current price
        uint256 _0x58ecc0 = _0x12efe8(_0x70ed48);
        require(_0x21b099 >= _0x58ecc0);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address _0xb3314b = _0x70ed48._0xb3314b;

        // The bid is good! Remove the auction before sending the fees
        _0xa50752(_0x049778);

        // Transfer proceeds to seller (if there are any!)
        if (_0x58ecc0 > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 _0x8ba325 = _0x77dec1(_0x58ecc0);
            uint256 _0x5639f4 = _0x58ecc0 - _0x8ba325;

            // Send Erc20 Token to seller should call Erc20 contract
            // Reference to contract
            require(ERC20(_0xe11838)._0x7edb83(_0xac0294,_0xb3314b,_0x5639f4));
            if (_0x8ba325 > 0){
                require(ERC20(_0xe11838)._0x7edb83(_0xac0294,address(this),_0x8ba325));
                _0x52e8c3[_0xe11838] += _0x8ba325;
            }
        }

        // Tell the world!
        AuctionSuccessful(_0x049778, _0x58ecc0, msg.sender);

        return _0x58ecc0;
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
    function _0xe37317(address _0x7c1b7d) external _0x20e9d6 {
        SaleClockAuction _0x44ded6 = SaleClockAuction(_0x7c1b7d);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0x44ded6._0x54d5fe());

        // Set the new contract address
        if (block.timestamp > 0) { _0x9d61a8 = _0x44ded6; }
    }

    function _0x918687(address _0x7c1b7d) external _0x20e9d6 {
        SaleClockAuctionERC20 _0x44ded6 = SaleClockAuctionERC20(_0x7c1b7d);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0x44ded6._0x8b272b());

        // Set the new contract address
        _0x999e41 = _0x44ded6;
    }

    /// @dev Sets the reference to the siring auction.
    /// @param _address - Address of siring contract.
    function _0x62f938(address _0x7c1b7d) external _0x20e9d6 {
        SiringClockAuction _0x44ded6 = SiringClockAuction(_0x7c1b7d);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(_0x44ded6._0xa12e4a());

        // Set the new contract address
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x14383e = _0x44ded6; }
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function _0x510ede(
        uint256 _0xc2b2df,
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d
    )
        external
        _0xcd2c4d
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x29a9ac(msg.sender, _0xc2b2df));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!_0x522f42(_0xc2b2df));
        _0xb9517b(_0xc2b2df, _0x9d61a8);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x9d61a8._0x36521f(
            _0xc2b2df,
            _0x2e060f,
            _0xa1cc3b,
            _0x35394d,
            msg.sender
        );
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function _0x6129dd(
        uint256 _0xc2b2df,
        address _0x79ea74,
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d
    )
        external
        _0xcd2c4d
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x29a9ac(msg.sender, _0xc2b2df));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!_0x522f42(_0xc2b2df));
        _0xb9517b(_0xc2b2df, _0x999e41);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x999e41._0x36521f(
            _0xc2b2df,
            _0x79ea74,
            _0x2e060f,
            _0xa1cc3b,
            _0x35394d,
            msg.sender
        );
    }

    function _0xd1d6e5(address _0x79ea74, uint256 _0x80e4a4) external _0xb96194{
        _0x999e41._0x3c0db4(_0x79ea74,_0x80e4a4);
    }

    /// @dev Put a panda up for auction to be sire.
    ///  Performs checks to ensure the panda can be sired, then
    ///  delegates to reverse auction.
    function _0x1223af(
        uint256 _0xc2b2df,
        uint256 _0x2e060f,
        uint256 _0xa1cc3b,
        uint256 _0x35394d
    )
        external
        _0xcd2c4d
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_0x29a9ac(msg.sender, _0xc2b2df));
        require(_0x31c887(_0xc2b2df));
        _0xb9517b(_0xc2b2df, _0x14383e);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        _0x14383e._0x36521f(
            _0xc2b2df,
            _0x2e060f,
            _0xa1cc3b,
            _0x35394d,
            msg.sender
        );
    }

    /// @dev Completes a siring auction by bidding.
    ///  Immediately breeds the winning matron with the sire on auction.
    /// @param _sireId - ID of the sire on auction.
    /// @param _matronId - ID of the matron owned by the bidder.
    function _0x7a96d0(
        uint256 _0x6b7f19,
        uint256 _0x5fa965
    )
        external
        payable
        _0xcd2c4d
    {
        // Auction contract checks input sizes
        require(_0x29a9ac(msg.sender, _0x5fa965));
        require(_0x31c887(_0x5fa965));
        require(_0x2a3a84(_0x5fa965, _0x6b7f19));

        // Define the current price of the auction.
        uint256 _0x6b4681 = _0x14383e._0xbea2cf(_0x6b7f19);
        require(msg.value >= _0x6b4681 + _0xa3b5d9);

        // Siring auction will throw if the bid fails.
        _0x14383e._0x74d815.value(msg.value - _0xa3b5d9)(_0x6b7f19);
        _0xf50ffe(uint32(_0x5fa965), uint32(_0x6b7f19), msg.sender);
    }

    /// @dev Transfers the balance of the sale auction contract
    /// to the PandaCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function _0xc22ab3() external _0x8aee9d {
        _0x9d61a8._0x93111a();
        _0x14383e._0x93111a();
    }

    function _0x358923(address _0xe11838, address _0x12afbb) external _0x8aee9d {
        require(_0x999e41 != address(0));
        _0x999e41._0x358923(_0xe11838,_0x12afbb);
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
    function _0x8e39a6(uint256[2] _0x3e0e5d, uint256 _0xd0df00, address _0x90c915) external _0xb96194 {
        address _0x38c7ae = _0x90c915;
        if (_0x38c7ae == address(0)) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x38c7ae = _0x122dce; }
        }

        _0xc08487(0, 0, _0xd0df00, _0x3e0e5d, _0x38c7ae);
    }

    /// @dev create pandaWithGenes
    /// @param _genes panda genes
    /// @param _type  0 common 1 rare
    function _0x597820(uint256[2] _0x3e0e5d,uint256 _0xd0df00,uint256 _0x9904f3)
        external
        payable
        _0xb96194
        _0xcd2c4d
    {
        require(msg.value >= OPEN_PACKAGE_PRICE);
        uint256 _0x6ecde4 = _0xc08487(0, 0, _0xd0df00, _0x3e0e5d, _0x9d61a8);
        _0x9d61a8._0x597820(_0x6ecde4,_0x9904f3);
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

    function _0x5be602(uint256 _0xc2b2df) external _0xb96194 {
        require(_0x29a9ac(msg.sender, _0xc2b2df));
        //require(pandas[_pandaId].generation==1);

        _0xb9517b(_0xc2b2df, _0x9d61a8);

        _0x9d61a8._0x5be602(
            _0xc2b2df,
            _0xada0b0(),
            0,
            GEN0_AUCTION_DURATION,
            msg.sender
        );
    }

    /// @dev Computes the next gen0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function _0xada0b0() internal view returns(uint256) {
        uint256 _0x1e73e0 = _0x9d61a8._0x0227b9();

        require(_0x1e73e0 == uint256(uint128(_0x1e73e0)));

        uint256 _0x84aba8 = _0x1e73e0 + (_0x1e73e0 / 2);

        // We never auction for less than starting price
        if (_0x84aba8 < GEN0_STARTING_PRICE) {
            _0x84aba8 = GEN0_STARTING_PRICE;
        }

        return _0x84aba8;
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
    address public _0x7c770b;

    /// @notice Creates the main CryptoPandas smart contract instance.
    function PandaCore() public {
        // Starts paused.
        _0x7b2f24 = true;

        // the creator of the contract is the initial CEO
        _0x1df02a = msg.sender;

        // the creator of the contract is also the initial COO
        _0x122dce = msg.sender;

        // move these code to init(), so we not excceed gas limit
        //uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        //wizzPandaQuota[1] = 100;

        //_createPanda(0, 0, 0, _genes, address(0));
    }

    /// init contract
    function _0xd01dc8() external _0x20e9d6 _0x80ec37 {
        // make sure init() only run once
        require(_0xc533e7.length == 0);
        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        uint256[2] memory _0x3e0e5d = [uint256(-1),uint256(-1)];

        _0x45cb49[1] = 100;
       _0xc08487(0, 0, 0, _0x3e0e5d, address(0));
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious

    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function _0x94c8db(address _0xbd9d64) external _0x20e9d6 _0x80ec37 {
        // See README.md for updgrade plan
        _0x7c770b = _0xbd9d64;
        ContractUpgrade(_0xbd9d64);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(_0x9d61a8) ||
            msg.sender == address(_0x14383e)
        );
    }

    /// @notice Returns all the relevant information about a specific panda.
    /// @param _id The ID of the panda of interest.
    function _0xc4da0b(uint256 _0xb0fb98)
        external
        view
        returns (
        bool _0xc6c8c1,
        bool _0x8aa901,
        uint256 _0x2a3cd7,
        uint256 _0x3804f9,
        uint256 _0xe669a8,
        uint256 _0x7e502a,
        uint256 _0x083499,
        uint256 _0xaf24ed,
        uint256 _0x76e375,
        uint256[2] _0xcb80f9
    ) {
        Panda storage _0x80abe0 = _0xc533e7[_0xb0fb98];

        // if this variable is 0 then it's not gestating
        _0xc6c8c1 = (_0x80abe0._0xe669a8 != 0);
        _0x8aa901 = (_0x80abe0._0x510cf0 <= block.number);
        _0x2a3cd7 = uint256(_0x80abe0._0x2a3cd7);
        _0x3804f9 = uint256(_0x80abe0._0x510cf0);
        _0xe669a8 = uint256(_0x80abe0._0xe669a8);
        _0x7e502a = uint256(_0x80abe0._0x7e502a);
        _0x083499 = uint256(_0x80abe0._0x083499);
        _0xaf24ed = uint256(_0x80abe0._0xaf24ed);
        _0x76e375 = uint256(_0x80abe0._0x76e375);
        _0xcb80f9 = _0x80abe0._0xcb80f9;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function _0x50447b() public _0x20e9d6 _0x80ec37 {
        require(_0x9d61a8 != address(0));
        require(_0x14383e != address(0));
        require(_0x893437 != address(0));
        require(_0x7c770b == address(0));

        // Actually unpause the contract.
        super._0x50447b();
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function _0x93111a() external _0x3fba34 {
        uint256 balance = this.balance;
        // Subtract all the currently pregnant kittens we have, plus 1 of margin.
        uint256 _0xdba29c = (_0xf4fb3e + 1) * _0xa3b5d9;

        if (balance > _0xdba29c) {
            _0x5f6ced.send(balance - _0xdba29c);
        }
    }
}
