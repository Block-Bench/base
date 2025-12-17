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
        address indexed _0xa57699,
        uint _0xf9b79a,
        uint value,
        uint indexed _0x7b807b,
        DepositType _0x09a3bc,
        uint _0x3817a1
    );

    event Merge(
        address indexed _0x0a5fd7,
        uint256 indexed _0xf1bd82,
        uint256 indexed _0x86fe88,
        uint256 _0x3e7ef0,
        uint256 _0xc8f922,
        uint256 _0xf4920f,
        uint256 _0x991ab9,
        uint256 _0xb0122a
    );
    event Split(
        uint256 indexed _0xf1bd82,
        uint256 indexed _0x66c40e,
        uint256 indexed _0xddbb19,
        address _0x0a5fd7,
        uint256 _0xed3622,
        uint256 _0x63619f,
        uint256 _0x991ab9,
        uint256 _0xb0122a
    );

    event MultiSplit(
        uint256 indexed _0xf1bd82,
        uint256[] _0x65a0ee,
        address _0x0a5fd7,
        uint256[] _0x633778,
        uint256 _0x991ab9,
        uint256 _0xb0122a
    );

    event MetadataUpdate(uint256 _0xf4153c);
    event BatchMetadataUpdate(uint256 _0x2efb4e, uint256 _0x4ad7d6);

    event Withdraw(address indexed _0xa57699, uint _0xf9b79a, uint value, uint _0x3817a1);
    event LockPermanent(address indexed _0x739fe3, uint256 indexed _0xf4153c, uint256 _0x8eafe4, uint256 _0xb0122a);
    event UnlockPermanent(address indexed _0x739fe3, uint256 indexed _0xf4153c, uint256 _0x8eafe4, uint256 _0xb0122a);
    event Supply(uint _0x13159c, uint _0xd12c33);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    address public immutable _0xcb3865;
    address public _0x7103cf;
    address public _0xd8e71c;
    address public _0xc18e2b;
    // address public burnTokenAddress=0x000000000000000000000000000000000000dEaD;

    uint public PRECISISON = 10000;

    /// @dev Mapping of interface id to bool about whether or not it's supported
    mapping(bytes4 => bool) internal _0xd54dbd;
    mapping(uint => bool) internal _0x2f3ba2;

    /// @dev ERC165 interface ID of ERC165
    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    /// @dev ERC165 interface ID of ERC721
    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;

    /// @dev ERC165 interface ID of ERC721Metadata
    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;

    /// @dev Current count of token
    uint internal _0xf9b79a;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal _0x3a9b7c;
    IHybra public _0xd4ecb3;

    // Instance of the library's storage struct
    VotingDelegationLib.Data private _0xbb0530;

    VotingBalanceLogic.Data private _0x7bd7aa;

    /// @notice Contract constructor
    /// @param token_addr `BLACK` token address
    constructor(address _0x23608b, address _0xd96bc8) {
        _0xcb3865 = _0x23608b;
        _0x7103cf = msg.sender;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xd8e71c = msg.sender; }
        if (gasleft() > 0) { _0xc18e2b = _0xd96bc8; }
        WEEK = HybraTimeLibrary.WEEK;
        MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION;
        if (gasleft() > 0) { _0x3a9b7c = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION)); }

        _0x7bd7aa._0x0efeda[0]._0xed655a = block.number;
        _0x7bd7aa._0x0efeda[0]._0x3817a1 = block.timestamp;

        _0xd54dbd[ERC165_INTERFACE_ID] = true;
        _0xd54dbd[ERC721_INTERFACE_ID] = true;
        _0xd54dbd[ERC721_METADATA_INTERFACE_ID] = true;
        _0xd4ecb3 = IHybra(_0xcb3865);

        // mint-ish
        emit Transfer(address(0), address(this), _0xf9b79a);
        // burn-ish
        emit Transfer(address(this), address(0), _0xf9b79a);
    }

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    uint8 internal constant _0xd90791 = 1;
    uint8 internal constant _0xd9c2ef = 2;
    uint8 internal _0x28c106 = 1;
    modifier _0xdb48fe() {
        require(_0x28c106 == _0xd90791);
        _0x28c106 = _0xd9c2ef;
        _;
        _0x28c106 = _0xd90791;
    }

    modifier _0xe89367(uint256 _0xf4153c) {
        require(!_0x2f3ba2[_0xf4153c], "PNFT");
        _;
    }

    modifier _0xb6bbc7(uint _0xf1bd82) {
        require(_0xc3769f[msg.sender] || _0xc3769f[address(0)], "!SPLIT");
        require(_0x6ac856[_0xf1bd82] == 0 && !_0x6d233a[_0xf1bd82], "ATT");
        require(_0x013902(msg.sender, _0xf1bd82), "NAO");
        _;
    }

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string constant public _0x463e31 = "veHYBR";
    string constant public _0x202b6d = "veHYBR";
    string constant public _0x8116d2 = "1.0.0";
    uint8 constant public _0x0d49f8 = 18;

    function _0x88c554(address _0xc2a075) external {
        require(msg.sender == _0xd8e71c);
        if (1 == 1) { _0xd8e71c = _0xc2a075; }
    }

    function _0x68db9c(address _0xdc351c) external {
        require(msg.sender == _0xd8e71c);
        _0xc18e2b = _0xdc351c;
        emit BatchMetadataUpdate(0, type(uint256)._0x1043b9);
    }

    /// @param _tokenId The token ID to modify
    /// @param _isPartner Whether this should be a partner veNFT
    function _0x313fee(uint _0xf4153c, bool _0x269c90) external {
        require(msg.sender == _0xd8e71c, "NA");
        require(_0x4ffc79[_0xf4153c] != address(0), "DNE");
        _0x2f3ba2[_0xf4153c] = _0x269c90;
    }

    /// @dev Returns current token URI metadata
    /// @param _tokenId Token ID to fetch URI for.
    function _0x420fff(uint _0xf4153c) external view returns (string memory) {
        require(_0x4ffc79[_0xf4153c] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory _0xc3f976 = _0x5c55a4[_0xf4153c];

        return IVeArtProxy(_0xc18e2b)._0x621583(_0xf4153c,VotingBalanceLogic._0x1183d7(_0xf4153c, block.timestamp, _0x7bd7aa),_0xc3f976._0x779ba8,uint(int256(_0xc3f976._0x8eafe4)));
    }

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to the address that owns it.
    mapping(uint => address) internal _0x4ffc79;

    /// @dev Mapping from owner address to count of his tokens.
    mapping(address => uint) internal _0xea5ad4;

    /// @dev Returns the address of the owner of the NFT.
    /// @param _tokenId The identifier for an NFT.
    function _0xe48e84(uint _0xf4153c) public view returns (address) {
        return _0x4ffc79[_0xf4153c];
    }

    function _0x5e1a64(address _0xcdbcbe) public view returns (uint) {

        return _0xea5ad4[_0xcdbcbe];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned p to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _0xaceffc(address _0x739fe3) internal view returns (uint) {
        return _0xea5ad4[_0x739fe3];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _0x1a92e4(address _0x739fe3) external view returns (uint) {
        return _0xaceffc(_0x739fe3);
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to approved address.
    mapping(uint => address) internal _0x009b76;

    /// @dev Mapping from owner address to mapping of operator addresses.
    mapping(address => mapping(address => bool)) internal _0x0b7f62;

    mapping(uint => uint) public _0x91f392;

    /// @dev Get the approved address for a single NFT.
    /// @param _tokenId ID of the NFT to query the approval of.
    function _0xf47716(uint _0xf4153c) external view returns (address) {
        return _0x009b76[_0xf4153c];
    }

    /// @dev Checks if `_operator` is an approved operator for `_owner`.
    /// @param _owner The address that owns the NFTs.
    /// @param _operator The address that acts on behalf of the owner.
    function _0x7e8b03(address _0x739fe3, address _0xf722e4) external view returns (bool) {
        return (_0x0b7f62[_0x739fe3])[_0xf722e4];
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
    function _0x6a7459(address _0x2ac7b5, uint _0xf4153c) public {
        address _0xcdbcbe = _0x4ffc79[_0xf4153c];
        // Throws if `_tokenId` is not a valid NFT
        require(_0xcdbcbe != address(0), "ZA");
        // Throws if `_approved` is the current owner
        require(_0x2ac7b5 != _0xcdbcbe, "IA");
        // Check requirements
        bool _0x2bb6a3 = (_0x4ffc79[_0xf4153c] == msg.sender);
        bool _0xc7145b = (_0x0b7f62[_0xcdbcbe])[msg.sender];
        require(_0x2bb6a3 || _0xc7145b, "NAO");
        // Set the approval
        _0x009b76[_0xf4153c] = _0x2ac7b5;
        emit Approval(_0xcdbcbe, _0x2ac7b5, _0xf4153c);
    }

    /// @dev Enables or disables approval for a third party ("operator") to manage all of
    ///      `msg.sender`'s assets. It also emits the ApprovalForAll event.
    ///      Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
    /// @notice This works even if sender doesn't own any tokens at the time.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval.
    function _0xc8828c(address _0xf722e4, bool _0x2ac7b5) external {
        // Throws if `_operator` is the `msg.sender`
        assert(_0xf722e4 != msg.sender);
        _0x0b7f62[msg.sender][_0xf722e4] = _0x2ac7b5;
        emit ApprovalForAll(msg.sender, _0xf722e4, _0x2ac7b5);
    }

    /* TRANSFER FUNCTIONS */
    /// @dev Clear an approval of a given address
    ///      Throws if `_owner` is not the current owner.
    function _0xeb1035(address _0x739fe3, uint _0xf4153c) internal {
        // Throws if `_owner` is not the current owner
        assert(_0x4ffc79[_0xf4153c] == _0x739fe3);
        if (_0x009b76[_0xf4153c] != address(0)) {
            // Reset approvals
            _0x009b76[_0xf4153c] = address(0);
        }
    }

    /// @dev Returns whether the given spender can transfer a given token ID
    /// @param _spender address of the spender to query
    /// @param _tokenId uint ID of the token to be transferred
    /// @return bool whether the msg.sender is approved for the given token ID, is an operator of the owner, or is the owner of the token
    function _0x013902(address _0xe306cb, uint _0xf4153c) internal view returns (bool) {
        address _0xcdbcbe = _0x4ffc79[_0xf4153c];
        bool _0x385d8a = _0xcdbcbe == _0xe306cb;
        bool _0xea5663 = _0xe306cb == _0x009b76[_0xf4153c];
        bool _0xf701a9 = (_0x0b7f62[_0xcdbcbe])[_0xe306cb];
        return _0x385d8a || _0xea5663 || _0xf701a9;
    }

    function _0xf7adae(address _0xe306cb, uint _0xf4153c) external view returns (bool) {
        return _0x013902(_0xe306cb, _0xf4153c);
    }

    /// @dev Exeute transfer of a NFT.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
    ///      address for this NFT. (NOTE: `msg.sender` not allowed in internal function so pass `_sender`.)
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_tokenId` is not a valid NFT.
    function _0x9a7ec7(
        address _0xf1bd82,
        address _0x86fe88,
        uint _0xf4153c,
        address _0x0a5fd7
    ) internal _0xe89367(_0xf4153c) {
        require(_0x6ac856[_0xf4153c] == 0 && !_0x6d233a[_0xf4153c], "ATT");
        // Check requirements
        require(_0x013902(_0x0a5fd7, _0xf4153c), "NAO");

        // Clear approval. Throws if `_from` is not the current owner
        _0xeb1035(_0xf1bd82, _0xf4153c);
        // Remove NFT. Throws if `_tokenId` is not a valid NFT
        _0x54ad52(_0xf1bd82, _0xf4153c);
        // auto re-delegate
        VotingDelegationLib._0x9c78a8(_0xbb0530, _0xea6071(_0xf1bd82), _0xea6071(_0x86fe88), _0xf4153c, _0xe48e84);
        // Add NFT
        _0xd63a34(_0x86fe88, _0xf4153c);
        // Set the block of ownership transfer (for Flash NFT protection)
        _0x91f392[_0xf4153c] = block.number;

        // Log the transfer
        emit Transfer(_0xf1bd82, _0x86fe88, _0xf4153c);
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
    function _0x18b9ba(
        address _0xf1bd82,
        address _0x86fe88,
        uint _0xf4153c
    ) external {
        _0x9a7ec7(_0xf1bd82, _0x86fe88, _0xf4153c, msg.sender);
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
    function _0xfba11e(
        address _0xf1bd82,
        address _0x86fe88,
        uint _0xf4153c
    ) external {
        _0xfba11e(_0xf1bd82, _0x86fe88, _0xf4153c, "");
    }

    function _0x031006(address _0x0eb3e6) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint _0x2bbe07;
        assembly {
            _0x2bbe07 := extcodesize(_0x0eb3e6)
        }
        return _0x2bbe07 > 0;
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
    function _0xfba11e(
        address _0xf1bd82,
        address _0x86fe88,
        uint _0xf4153c,
        bytes memory _0x3f86a0
    ) public {
        _0x9a7ec7(_0xf1bd82, _0x86fe88, _0xf4153c, msg.sender);

        if (_0x031006(_0x86fe88)) {
            // Throws if transfer destination is a contract which does not implement 'onERC721Received'
            try IERC721Receiver(_0x86fe88)._0xce63a1(msg.sender, _0xf1bd82, _0xf4153c, _0x3f86a0) returns (bytes4 _0x636857) {
                if (_0x636857 != IERC721Receiver(_0x86fe88)._0xce63a1.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory _0x45d9e7) {
                if (_0x45d9e7.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, _0x45d9e7), mload(_0x45d9e7))
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
    function _0x894bc9(bytes4 _0xe76f22) external view returns (bool) {
        return _0xd54dbd[_0xe76f22];
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from owner address to mapping of index to tokenIds
    mapping(address => mapping(uint => uint)) internal _0x9eefbe;

    /// @dev Mapping from NFT ID to index of owner
    mapping(uint => uint) internal _0x917b38;

    /// @dev  Get token by index
    function _0x57d822(address _0x739fe3, uint _0x8044c2) public view returns (uint) {
        return _0x9eefbe[_0x739fe3][_0x8044c2];
    }

    /// @dev Add a NFT to an index mapping to a given addressndashushun
    /// @param _to address of the receiver
    /// @param _tokenId uint ID Of the token to be added
    function _0x7d34ae(address _0x86fe88, uint _0xf4153c) internal {
        uint _0x6bedf6 = _0xaceffc(_0x86fe88);

        _0x9eefbe[_0x86fe88][_0x6bedf6] = _0xf4153c;
        _0x917b38[_0xf4153c] = _0x6bedf6;
    }

    /// @dev Add a NFT to a given address
    ///      Throws if `_tokenId` is owned by someone.
    function _0xd63a34(address _0x86fe88, uint _0xf4153c) internal {
        // Throws if `_tokenId` is owned by someone
        assert(_0x4ffc79[_0xf4153c] == address(0));
        // Change the owner
        _0x4ffc79[_0xf4153c] = _0x86fe88;
        // Update owner token index tracking
        _0x7d34ae(_0x86fe88, _0xf4153c);
        // Change count tracking
        _0xea5ad4[_0x86fe88] += 1;
    }

    /// @dev Function to mint tokens
    ///      Throws if `_to` is zero address.
    ///      Throws if `_tokenId` is owned by someone.
    /// @param _to The address that will receive the minted tokens.
    /// @param _tokenId The token id to mint.
    /// @return A boolean that indicates if the operation was successful.
    function _0xaa1217(address _0x86fe88, uint _0xf4153c) internal returns (bool) {
        // Throws if `_to` is zero address
        assert(_0x86fe88 != address(0));
        // checkpoint for gov
        VotingDelegationLib._0x9c78a8(_0xbb0530, address(0), _0xea6071(_0x86fe88), _0xf4153c, _0xe48e84);
        // Add NFT. Throws if `_tokenId` is owned by someone
        _0xd63a34(_0x86fe88, _0xf4153c);
        emit Transfer(address(0), _0x86fe88, _0xf4153c);
        return true;
    }

    /// @dev Remove a NFT from an index mapping to a given address
    /// @param _from address of the sender
    /// @param _tokenId uint ID Of the token to be removed
    function _0x4dd452(address _0xf1bd82, uint _0xf4153c) internal {
        // Delete
        uint _0x6bedf6 = _0xaceffc(_0xf1bd82) - 1;
        uint _0xb1afb5 = _0x917b38[_0xf4153c];

        if (_0x6bedf6 == _0xb1afb5) {
            // update ownerToNFTokenIdList
            _0x9eefbe[_0xf1bd82][_0x6bedf6] = 0;
            // update tokenToOwnerIndex
            _0x917b38[_0xf4153c] = 0;
        } else {
            uint _0x388ac5 = _0x9eefbe[_0xf1bd82][_0x6bedf6];

            // Add
            // update ownerToNFTokenIdList
            _0x9eefbe[_0xf1bd82][_0xb1afb5] = _0x388ac5;
            // update tokenToOwnerIndex
            _0x917b38[_0x388ac5] = _0xb1afb5;

            // Delete
            // update ownerToNFTokenIdList
            _0x9eefbe[_0xf1bd82][_0x6bedf6] = 0;
            // update tokenToOwnerIndex
            _0x917b38[_0xf4153c] = 0;
        }
    }

    /// @dev Remove a NFT from a given address
    ///      Throws if `_from` is not the current owner.
    function _0x54ad52(address _0xf1bd82, uint _0xf4153c) internal {
        // Throws if `_from` is not the current owner
        assert(_0x4ffc79[_0xf4153c] == _0xf1bd82);
        // Change the owner
        _0x4ffc79[_0xf4153c] = address(0);
        // Update owner token index tracking
        _0x4dd452(_0xf1bd82, _0xf4153c);
        // Change count tracking
        _0xea5ad4[_0xf1bd82] -= 1;
    }

    function _0x7fd32c(uint _0xf4153c) internal {
        require(_0x013902(msg.sender, _0xf4153c), "NAO");

        address _0xcdbcbe = _0xe48e84(_0xf4153c);

        // Clear approval
        delete _0x009b76[_0xf4153c];
        // Remove token
        //_removeTokenFrom(msg.sender, _tokenId);
        _0x54ad52(_0xcdbcbe, _0xf4153c);
        // checkpoint for gov
        VotingDelegationLib._0x9c78a8(_0xbb0530, _0xea6071(_0xcdbcbe), address(0), _0xf4153c, _0xe48e84);

        emit Transfer(_0xcdbcbe, address(0), _0xf4153c);
    }

    /*//////////////////////////////////////////////////////////////
                             ESCROW STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint => IVotingEscrow.LockedBalance) public _0x5c55a4;
    uint public _0x295a03;
    uint public _0x2178ce;
    mapping(uint => int128) public _0x902170; // time -> signed slope change
    uint public _0xd12c33;
    mapping(address => bool) public _0xc3769f;

    uint internal constant MULTIPLIER = 1 ether;

    /*//////////////////////////////////////////////////////////////
                              ESCROW LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the most recently recorded rate of voting power decrease for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @return Value of the slope
    function _0xec8f70(uint _0xf4153c) external view returns (int128) {
        uint _0x846afb = _0x7bd7aa._0x542dd9[_0xf4153c];
        return _0x7bd7aa._0x60ef2f[_0xf4153c][_0x846afb]._0x2e811a;
    }

    /// @notice Get the timestamp for checkpoint `_idx` for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function _0x60ef2f(uint _0xf4153c, uint _0x5092c7) external view returns (IVotingEscrow.Point memory) {
        return _0x7bd7aa._0x60ef2f[_0xf4153c][_0x5092c7];
    }

    function _0x0efeda(uint _0x2178ce) external view returns (IVotingEscrow.Point memory) {
        return _0x7bd7aa._0x0efeda[_0x2178ce];
    }

    function _0x542dd9(uint _0xf9b79a) external view returns (uint) {
        return _0x7bd7aa._0x542dd9[_0xf9b79a];
    }

    /// @notice Record global and per-user data to checkpoint
    /// @param _tokenId NFT token ID. No user checkpoint if 0
    /// @param old_locked Pevious locked amount / end lock time for the user
    /// @param new_locked New locked amount / end lock time for the user
    function _0xfcbaa1(
        uint _0xf4153c,
        IVotingEscrow.LockedBalance memory _0x7c99c2,
        IVotingEscrow.LockedBalance memory _0xc51949
    ) internal {
        IVotingEscrow.Point memory _0xf41ab1;
        IVotingEscrow.Point memory _0x592b6d;
        int128 _0x65ea62 = 0;
        int128 _0x72e328 = 0;
        uint _0xa37be7 = _0x2178ce;

        if (_0xf4153c != 0) {
            _0x592b6d._0xc3653f = 0;

            if(_0xc51949._0x305b19){
                _0x592b6d._0xc3653f = uint(int256(_0xc51949._0x8eafe4));
            }

            // Calculate slopes and biases
            // Kept at zero when they have to
            if (_0x7c99c2._0x779ba8 > block.timestamp && _0x7c99c2._0x8eafe4 > 0) {
                _0xf41ab1._0x2e811a = _0x7c99c2._0x8eafe4 / _0x3a9b7c;
                _0xf41ab1._0x7a210c = _0xf41ab1._0x2e811a * int128(int256(_0x7c99c2._0x779ba8 - block.timestamp));
            }
            if (_0xc51949._0x779ba8 > block.timestamp && _0xc51949._0x8eafe4 > 0) {
                _0x592b6d._0x2e811a = _0xc51949._0x8eafe4 / _0x3a9b7c;
                _0x592b6d._0x7a210c = _0x592b6d._0x2e811a * int128(int256(_0xc51949._0x779ba8 - block.timestamp));
            }

            // Read values of scheduled changes in the slope
            // old_locked.end can be in the past and in the future
            // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            _0x65ea62 = _0x902170[_0x7c99c2._0x779ba8];
            if (_0xc51949._0x779ba8 != 0) {
                if (_0xc51949._0x779ba8 == _0x7c99c2._0x779ba8) {
                    _0x72e328 = _0x65ea62;
                } else {
                    _0x72e328 = _0x902170[_0xc51949._0x779ba8];
                }
            }
        }

        IVotingEscrow.Point memory _0x9752dd = IVotingEscrow.Point({_0x7a210c: 0, _0x2e811a: 0, _0x3817a1: block.timestamp, _0xed655a: block.number, _0xc3653f: 0});
        if (_0xa37be7 > 0) {
            _0x9752dd = _0x7bd7aa._0x0efeda[_0xa37be7];
        }
        uint _0x6990a4 = _0x9752dd._0x3817a1;
        // initial_last_point is used for extrapolation to calculate block number
        // (approximately, for *At methods) and save them
        // as we cannot figure that out exactly from inside the contract
        IVotingEscrow.Point memory _0x040068 = _0x9752dd;
        uint _0xc449e3 = 0; // dblock/dt
        if (block.timestamp > _0x9752dd._0x3817a1) {
            _0xc449e3 = (MULTIPLIER * (block.number - _0x9752dd._0xed655a)) / (block.timestamp - _0x9752dd._0x3817a1);
        }
        // If last point is already recorded in this block, slope=0
        // But that's ok b/c we know the block in such case

        // Go over weeks to fill history and calculate what the current point is
        {
            uint _0xbb92f6 = (_0x6990a4 / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {
                // Hopefully it won't happen that this won't get used in 5 years!
                // If it does, users will be able to withdraw but vote weight will be broken
                _0xbb92f6 += WEEK;
                int128 _0x7c069f = 0;
                if (_0xbb92f6 > block.timestamp) {
                    _0xbb92f6 = block.timestamp;
                } else {
                    _0x7c069f = _0x902170[_0xbb92f6];
                }
                _0x9752dd._0x7a210c -= _0x9752dd._0x2e811a * int128(int256(_0xbb92f6 - _0x6990a4));
                _0x9752dd._0x2e811a += _0x7c069f;
                if (_0x9752dd._0x7a210c < 0) {
                    // This can happen
                    _0x9752dd._0x7a210c = 0;
                }
                if (_0x9752dd._0x2e811a < 0) {
                    // This cannot happen - just in case
                    _0x9752dd._0x2e811a = 0;
                }
                _0x6990a4 = _0xbb92f6;
                _0x9752dd._0x3817a1 = _0xbb92f6;
                _0x9752dd._0xed655a = _0x040068._0xed655a + (_0xc449e3 * (_0xbb92f6 - _0x040068._0x3817a1)) / MULTIPLIER;
                _0xa37be7 += 1;
                if (_0xbb92f6 == block.timestamp) {
                    _0x9752dd._0xed655a = block.number;
                    break;
                } else {
                    _0x7bd7aa._0x0efeda[_0xa37be7] = _0x9752dd;
                }
            }
        }

        _0x2178ce = _0xa37be7;
        // Now point_history is filled until t=now

        if (_0xf4153c != 0) {
            // If last point was in this block, the slope change has been applied already
            // But in such case we have 0 slope(s)
            _0x9752dd._0x2e811a += (_0x592b6d._0x2e811a - _0xf41ab1._0x2e811a);
            _0x9752dd._0x7a210c += (_0x592b6d._0x7a210c - _0xf41ab1._0x7a210c);
            if (_0x9752dd._0x2e811a < 0) {
                _0x9752dd._0x2e811a = 0;
            }
            if (_0x9752dd._0x7a210c < 0) {
                _0x9752dd._0x7a210c = 0;
            }
            _0x9752dd._0xc3653f = _0x295a03;
        }

        // Record the changed point into history
        _0x7bd7aa._0x0efeda[_0xa37be7] = _0x9752dd;

        if (_0xf4153c != 0) {
            // Schedule the slope changes (slope is going down)
            // We subtract new_user_slope from [new_locked.end]
            // and add old_user_slope to [old_locked.end]
            if (_0x7c99c2._0x779ba8 > block.timestamp) {
                // old_dslope was <something> - u_old.slope, so we cancel that
                _0x65ea62 += _0xf41ab1._0x2e811a;
                if (_0xc51949._0x779ba8 == _0x7c99c2._0x779ba8) {
                    _0x65ea62 -= _0x592b6d._0x2e811a; // It was a new deposit, not extension
                }
                _0x902170[_0x7c99c2._0x779ba8] = _0x65ea62;
            }

            if (_0xc51949._0x779ba8 > block.timestamp) {
                if (_0xc51949._0x779ba8 > _0x7c99c2._0x779ba8) {
                    _0x72e328 -= _0x592b6d._0x2e811a; // old slope disappeared at this point
                    _0x902170[_0xc51949._0x779ba8] = _0x72e328;
                }
                // else: we recorded it already in old_dslope
            }
            // Now handle user history
            uint _0x0eb01f = _0x7bd7aa._0x542dd9[_0xf4153c] + 1;

            _0x7bd7aa._0x542dd9[_0xf4153c] = _0x0eb01f;
            _0x592b6d._0x3817a1 = block.timestamp;
            _0x592b6d._0xed655a = block.number;
            _0x7bd7aa._0x60ef2f[_0xf4153c][_0x0eb01f] = _0x592b6d;
        }
    }

    /// @notice Deposit and lock tokens for a user
    /// @param _tokenId NFT that holds lock
    /// @param _value Amount to deposit
    /// @param unlock_time New time when to unlock the tokens, or 0 if unchanged
    /// @param locked_balance Previous locked amount / timestamp
    /// @param deposit_type The type of deposit
    function _0xac88fd(
        uint _0xf4153c,
        uint _0x566660,
        uint _0xe29c8b,
        IVotingEscrow.LockedBalance memory _0xc06928,
        DepositType _0x09a3bc
    ) internal {
        IVotingEscrow.LockedBalance memory _0xc3f976 = _0xc06928;
        uint _0x83f80b = _0xd12c33;

        _0xd12c33 = _0x83f80b + _0x566660;
        IVotingEscrow.LockedBalance memory _0x7c99c2;
        (_0x7c99c2._0x8eafe4, _0x7c99c2._0x779ba8, _0x7c99c2._0x305b19) = (_0xc3f976._0x8eafe4, _0xc3f976._0x779ba8, _0xc3f976._0x305b19);
        // Adding to existing lock, or if a lock is expired - creating a new one
        _0xc3f976._0x8eafe4 += int128(int256(_0x566660));

        if (_0xe29c8b != 0) {
            _0xc3f976._0x779ba8 = _0xe29c8b;
        }
        _0x5c55a4[_0xf4153c] = _0xc3f976;

        // Possibilities:
        // Both old_locked.end could be current or expired (>/< block.timestamp)
        // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // _locked.end > block.timestamp (always)
        _0xfcbaa1(_0xf4153c, _0x7c99c2, _0xc3f976);

        address from = msg.sender;
        if (_0x566660 != 0) {
            assert(IERC20(_0xcb3865)._0x18b9ba(from, address(this), _0x566660));
        }

        emit Deposit(from, _0xf4153c, _0x566660, _0xc3f976._0x779ba8, _0x09a3bc, block.timestamp);
        emit Supply(_0x83f80b, _0x83f80b + _0x566660);
    }

    /// @notice Record global data to checkpoint
    function _0x369e14() external {
        _0xfcbaa1(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }

    /// @notice Deposit `_value` tokens for `_tokenId` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _tokenId lock NFT
    /// @param _value Amount to add to user's lock
    function _0x2351d2(uint _0xf4153c, uint _0x566660) external _0xdb48fe {
        IVotingEscrow.LockedBalance memory _0xc3f976 = _0x5c55a4[_0xf4153c];

        require(_0x566660 > 0, "ZV"); // dev: need non-zero value
        require(_0xc3f976._0x8eafe4 > 0, 'ZL');
        require(_0xc3f976._0x779ba8 > block.timestamp || _0xc3f976._0x305b19, 'EXP');

        if (_0xc3f976._0x305b19) _0x295a03 += _0x566660;

        _0xac88fd(_0xf4153c, _0x566660, 0, _0xc3f976, DepositType.DEPOSIT_FOR_TYPE);

        if(_0x6d233a[_0xf4153c]) {
            IVoter(_0x7103cf)._0xf01546(_0xf4153c);
        }
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _0x4c2a69(uint _0x566660, uint _0x878c6c, address _0x86fe88) internal returns (uint) {
        uint _0xe29c8b = (block.timestamp + _0x878c6c) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_0x566660 > 0, "ZV"); // dev: need non-zero value
        require(_0xe29c8b > block.timestamp && (_0xe29c8b <= block.timestamp + MAXTIME), 'IUT');

        ++_0xf9b79a;
        uint _0xf4153c = _0xf9b79a;
        _0xaa1217(_0x86fe88, _0xf4153c);

        IVotingEscrow.LockedBalance memory _0xc3f976 = _0x5c55a4[_0xf4153c];

        _0xac88fd(_0xf4153c, _0x566660, _0xe29c8b, _0xc3f976, DepositType.CREATE_LOCK_TYPE);
        return _0xf4153c;
    }

    /// @notice Deposit `_value` tokens for `msg.sender` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    function _0x0a3e35(uint _0x566660, uint _0x878c6c) external _0xdb48fe returns (uint) {
        return _0x4c2a69(_0x566660, _0x878c6c, msg.sender);
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _0xde5e5f(uint _0x566660, uint _0x878c6c, address _0x86fe88) external _0xdb48fe returns (uint) {
        return _0x4c2a69(_0x566660, _0x878c6c, _0x86fe88);
    }

    /// @notice Deposit `_value` additional tokens for `_tokenId` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    function _0x71597b(uint _0xf4153c, uint _0x566660) external _0xdb48fe {
        assert(_0x013902(msg.sender, _0xf4153c));

        IVotingEscrow.LockedBalance memory _0xc3f976 = _0x5c55a4[_0xf4153c];

        assert(_0x566660 > 0); // dev: need non-zero value
        require(_0xc3f976._0x8eafe4 > 0, 'ZL');
        require(_0xc3f976._0x779ba8 > block.timestamp || _0xc3f976._0x305b19, 'EXP');

        if (_0xc3f976._0x305b19) _0x295a03 += _0x566660;
        _0xac88fd(_0xf4153c, _0x566660, 0, _0xc3f976, DepositType.INCREASE_LOCK_AMOUNT);

        // poke for the gained voting power
        if(_0x6d233a[_0xf4153c]) {
            IVoter(_0x7103cf)._0xf01546(_0xf4153c);
        }
        emit MetadataUpdate(_0xf4153c);
    }

    /// @notice Extend the unlock time for `_tokenId`
    /// @param _lock_duration New number of seconds until tokens unlock
    function _0x61cce2(uint _0xf4153c, uint _0x878c6c) external _0xdb48fe {
        assert(_0x013902(msg.sender, _0xf4153c));

        IVotingEscrow.LockedBalance memory _0xc3f976 = _0x5c55a4[_0xf4153c];
        require(!_0xc3f976._0x305b19, "!NORM");
        uint _0xe29c8b = (block.timestamp + _0x878c6c) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_0xc3f976._0x779ba8 > block.timestamp && _0xc3f976._0x8eafe4 > 0, 'EXP||ZV');
        require(_0xe29c8b > _0xc3f976._0x779ba8 && (_0xe29c8b <= block.timestamp + MAXTIME), 'IUT'); // IUT -> invalid unlock time

        _0xac88fd(_0xf4153c, 0, _0xe29c8b, _0xc3f976, DepositType.INCREASE_UNLOCK_TIME);

        // poke for the gained voting power
        if(_0x6d233a[_0xf4153c]) {
            IVoter(_0x7103cf)._0xf01546(_0xf4153c);
        }
        emit MetadataUpdate(_0xf4153c);
    }

    /// @notice Withdraw all tokens for `_tokenId`
    /// @dev Only possible if the lock has expired
    function _0xdb4191(uint _0xf4153c) external _0xdb48fe {
        assert(_0x013902(msg.sender, _0xf4153c));
        require(_0x6ac856[_0xf4153c] == 0 && !_0x6d233a[_0xf4153c], "ATT");

        IVotingEscrow.LockedBalance memory _0xc3f976 = _0x5c55a4[_0xf4153c];
        require(!_0xc3f976._0x305b19, "!NORM");
        require(block.timestamp >= _0xc3f976._0x779ba8, "!EXP");
        uint value = uint(int256(_0xc3f976._0x8eafe4));

        _0x5c55a4[_0xf4153c] = IVotingEscrow.LockedBalance(0, 0, false);
        uint _0x83f80b = _0xd12c33;
        if (true) { _0xd12c33 = _0x83f80b - value; }

        // old_locked can have either expired <= timestamp or zero end
        // _locked has only 0 end
        // Both can have >= 0 amount
        _0xfcbaa1(_0xf4153c, _0xc3f976, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(_0xcb3865).transfer(msg.sender, value));

        // Burn the NFT
        _0x7fd32c(_0xf4153c);

        emit Withdraw(msg.sender, _0xf4153c, value, block.timestamp);
        emit Supply(_0x83f80b, _0x83f80b - value);
    }

    function _0xfef59a(uint _0xf4153c) external {
        address sender = msg.sender;
        require(_0x013902(sender, _0xf4153c), "NAO");

        IVotingEscrow.LockedBalance memory _0x6ead86 = _0x5c55a4[_0xf4153c];
        require(!_0x6ead86._0x305b19, "!NORM");
        require(_0x6ead86._0x779ba8 > block.timestamp, "EXP");
        require(_0x6ead86._0x8eafe4 > 0, "ZV");

        uint _0xfd32de = uint(int256(_0x6ead86._0x8eafe4));
        _0x295a03 += _0xfd32de;
        _0x6ead86._0x779ba8 = 0;
        _0x6ead86._0x305b19 = true;
        _0xfcbaa1(_0xf4153c, _0x5c55a4[_0xf4153c], _0x6ead86);
        _0x5c55a4[_0xf4153c] = _0x6ead86;
        if(_0x6d233a[_0xf4153c]) {
            IVoter(_0x7103cf)._0xf01546(_0xf4153c);
        }
        emit LockPermanent(sender, _0xf4153c, _0xfd32de, block.timestamp);
        emit MetadataUpdate(_0xf4153c);
    }

    function _0xad24fc(uint _0xf4153c) external {
        address sender = msg.sender;
        require(_0x013902(msg.sender, _0xf4153c), "NAO");

        require(_0x6ac856[_0xf4153c] == 0 && !_0x6d233a[_0xf4153c], "ATT");
        IVotingEscrow.LockedBalance memory _0x6ead86 = _0x5c55a4[_0xf4153c];
        require(_0x6ead86._0x305b19, "!NORM");
        uint _0xfd32de = uint(int256(_0x6ead86._0x8eafe4));
        _0x295a03 -= _0xfd32de;
        _0x6ead86._0x779ba8 = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _0x6ead86._0x305b19 = false;

        _0xfcbaa1(_0xf4153c, _0x5c55a4[_0xf4153c], _0x6ead86);
        _0x5c55a4[_0xf4153c] = _0x6ead86;

        emit UnlockPermanent(sender, _0xf4153c, _0xfd32de, block.timestamp);
        emit MetadataUpdate(_0xf4153c);
    }

    /*///////////////////////////////////////////////////////////////
                           GAUGE VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    // The following ERC20/minime-compatible methods are not real balanceOf and supply!
    // They measure the weights for the purpose of voting, so they don't represent
    // real coins.

    function _0x1183d7(uint _0xf4153c) external view returns (uint) {
        if (_0x91f392[_0xf4153c] == block.number) return 0;
        return VotingBalanceLogic._0x1183d7(_0xf4153c, block.timestamp, _0x7bd7aa);
    }

    function _0x4c083e(uint _0xf4153c, uint _0x13fbab) external view returns (uint) {
        return VotingBalanceLogic._0x1183d7(_0xf4153c, _0x13fbab, _0x7bd7aa);
    }

    function _0x3fa352(uint _0xf4153c, uint _0x519a62) external view returns (uint) {
        return VotingBalanceLogic._0x3fa352(_0xf4153c, _0x519a62, _0x7bd7aa, _0x2178ce);
    }

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function _0xfe200c(uint _0x519a62) external view returns (uint) {
        return VotingBalanceLogic._0xfe200c(_0x519a62, _0x2178ce, _0x7bd7aa, _0x902170);
    }

    function _0x91c6bb() external view returns (uint) {
        return _0x6c9c07(block.timestamp);
    }

    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    function _0x6c9c07(uint t) public view returns (uint) {
        return VotingBalanceLogic._0x6c9c07(t, _0x2178ce, _0x902170,  _0x7bd7aa);
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE VOTING LOGIC
    //////////////////////////////////////////////////////////////*/

    mapping(uint => uint) public _0x6ac856;
    mapping(uint => bool) public _0x6d233a;

    function _0xc159b5(address _0x6fb619) external {
        require(msg.sender == _0xd8e71c);
        _0x7103cf = _0x6fb619;
    }

    function _0xbc5fd4(uint _0xf4153c) external {
        require(msg.sender == _0x7103cf);
        _0x6d233a[_0xf4153c] = true;
    }

    function _0x68df64(uint _0xf4153c) external {
        require(msg.sender == _0x7103cf, "NA");
        _0x6d233a[_0xf4153c] = false;
    }

    function _0xd7863d(uint _0xf4153c) external {
        require(msg.sender == _0x7103cf, "NA");
        _0x6ac856[_0xf4153c] = _0x6ac856[_0xf4153c] + 1;
    }

    function _0xb1b758(uint _0xf4153c) external {
        require(msg.sender == _0x7103cf, "NA");
        _0x6ac856[_0xf4153c] = _0x6ac856[_0xf4153c] - 1;
    }

    function _0x36b721(uint _0xf1bd82, uint _0x86fe88) external _0xdb48fe _0xe89367(_0xf1bd82) {
        require(_0x6ac856[_0xf1bd82] == 0 && !_0x6d233a[_0xf1bd82], "ATT");
        require(_0xf1bd82 != _0x86fe88, "SAME");
        require(_0x013902(msg.sender, _0xf1bd82) &&
        _0x013902(msg.sender, _0x86fe88), "NAO");

        IVotingEscrow.LockedBalance memory _0xc3c7a8 = _0x5c55a4[_0xf1bd82];
        IVotingEscrow.LockedBalance memory _0x3dd92c = _0x5c55a4[_0x86fe88];
        require(_0x3dd92c._0x779ba8 > block.timestamp ||  _0x3dd92c._0x305b19,"EXP||PERM");
        require(_0xc3c7a8._0x305b19 ? _0x3dd92c._0x305b19 : true, "!MERGE");

        uint _0x1d48aa = uint(int256(_0xc3c7a8._0x8eafe4));
        uint _0x779ba8 = _0xc3c7a8._0x779ba8 >= _0x3dd92c._0x779ba8 ? _0xc3c7a8._0x779ba8 : _0x3dd92c._0x779ba8;

        _0x5c55a4[_0xf1bd82] = IVotingEscrow.LockedBalance(0, 0, false);
        _0xfcbaa1(_0xf1bd82, _0xc3c7a8, IVotingEscrow.LockedBalance(0, 0, false));
        _0x7fd32c(_0xf1bd82);

        IVotingEscrow.LockedBalance memory _0x04c2d3;
        _0x04c2d3._0x305b19 = _0x3dd92c._0x305b19;

        if (_0x04c2d3._0x305b19){
            _0x04c2d3._0x8eafe4 = _0x3dd92c._0x8eafe4 + _0xc3c7a8._0x8eafe4;
            if (!_0xc3c7a8._0x305b19) {  // Only add if source wasn't already permanent
                _0x295a03 += _0x1d48aa;
            }
        }else{
            _0x04c2d3._0x8eafe4 = _0x3dd92c._0x8eafe4 + _0xc3c7a8._0x8eafe4;
            _0x04c2d3._0x779ba8 = _0x779ba8;
        }

        //_checkpointDelegatee(_delegates[_to], value0, true);
        _0xfcbaa1(_0x86fe88, _0x3dd92c, _0x04c2d3);
        _0x5c55a4[_0x86fe88] = _0x04c2d3;

        if(_0x6d233a[_0x86fe88]) {
            IVoter(_0x7103cf)._0xf01546(_0x86fe88);
        }
        emit Merge(
            msg.sender,
            _0xf1bd82,
            _0x86fe88,
            uint(int256(_0xc3c7a8._0x8eafe4)),
            uint(int256(_0x3dd92c._0x8eafe4)),
            uint(int256(_0x04c2d3._0x8eafe4)),
            _0x04c2d3._0x779ba8,
            block.timestamp
        );
        emit MetadataUpdate(_0x86fe88);
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
    function _0xe9ee73(
        uint _0xf1bd82,
        uint[] memory _0x6bec2b
    ) external _0xdb48fe _0xb6bbc7(_0xf1bd82) _0xe89367(_0xf1bd82) returns (uint256[] memory _0xa17014) {
        require(_0x6bec2b.length >= 2 && _0x6bec2b.length <= 10, "MIN2MAX10");

        address _0xcdbcbe = _0x4ffc79[_0xf1bd82];

        IVotingEscrow.LockedBalance memory _0x31ff67 = _0x5c55a4[_0xf1bd82];
        require(_0x31ff67._0x779ba8 > block.timestamp || _0x31ff67._0x305b19, "EXP");
        require(_0x31ff67._0x8eafe4 > 0, "ZV");

        // Calculate total weight
        uint _0x29ef5c = 0;
        for(uint i = 0; i < _0x6bec2b.length; i++) {
            require(_0x6bec2b[i] > 0, "ZW"); // Zero weight not allowed
            _0x29ef5c += _0x6bec2b[i];
        }

        // Burn the original NFT
        _0x5c55a4[_0xf1bd82] = IVotingEscrow.LockedBalance(0, 0, false);
        _0xfcbaa1(_0xf1bd82, _0x31ff67, IVotingEscrow.LockedBalance(0, 0, false));
        _0x7fd32c(_0xf1bd82);

        // Create new NFTs with proportional amounts
        _0xa17014 = new uint256[](_0x6bec2b.length);
        uint[] memory _0x860d54 = new uint[](_0x6bec2b.length);

        for(uint i = 0; i < _0x6bec2b.length; i++) {
            IVotingEscrow.LockedBalance memory _0x8af79e = IVotingEscrow.LockedBalance({
                _0x8eafe4: int128(int256(uint256(int256(_0x31ff67._0x8eafe4)) * _0x6bec2b[i] / _0x29ef5c)),
                _0x779ba8: _0x31ff67._0x779ba8,
                _0x305b19: _0x31ff67._0x305b19
            });

            _0xa17014[i] = _0x528ee1(_0xcdbcbe, _0x8af79e);
            _0x860d54[i] = uint256(int256(_0x8af79e._0x8eafe4));
        }

        emit MultiSplit(
            _0xf1bd82,
            _0xa17014,
            msg.sender,
            _0x860d54,
            _0x31ff67._0x779ba8,
            block.timestamp
        );
    }

    function _0x528ee1(address _0x86fe88, IVotingEscrow.LockedBalance memory _0x6ead86) private returns (uint256 _0xf4153c) {
        if (true) { _0xf4153c = ++_0xf9b79a; }
        _0x5c55a4[_0xf4153c] = _0x6ead86;
        _0xfcbaa1(_0xf4153c, IVotingEscrow.LockedBalance(0, 0, false), _0x6ead86);
        _0xaa1217(_0x86fe88, _0xf4153c);
    }

    function _0x568638(address _0x816550, bool _0xdc1db2) external {
        require(msg.sender == _0xd8e71c);
        _0xc3769f[_0x816550] = _0xdc1db2;
    }

    /*///////////////////////////////////////////////////////////////
                            DAO VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = _0xb4e977("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = _0xb4e977("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of each accounts delegate
    mapping(address => address) private _0xaa9640;

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint) public _0x765dad;

    /**
     * @notice Overrides the standard `Comp.sol` delegates mapping to return
     * the delegator's own address if they haven't delegated.
     * This avoids having to delegate to oneself.
     */
    function _0xea6071(address _0x9f0a41) public view returns (address) {
        address _0x56a7c3 = _0xaa9640[_0x9f0a41];
        return _0x56a7c3 == address(0) ? _0x9f0a41 : _0x56a7c3;
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function _0x89a7e2(address _0x0eb3e6) external view returns (uint) {
        uint32 _0x8936bc = _0xbb0530._0x008c14[_0x0eb3e6];
        if (_0x8936bc == 0) {
            return 0;
        }
        uint[] storage _0xd1cd94 = _0xbb0530._0x451e48[_0x0eb3e6][_0x8936bc - 1]._0xbb706d;
        uint _0x51359f = 0;
        for (uint i = 0; i < _0xd1cd94.length; i++) {
            uint _0x9d90c9 = _0xd1cd94[i];
            _0x51359f = _0x51359f + VotingBalanceLogic._0x1183d7(_0x9d90c9, block.timestamp, _0x7bd7aa);
        }
        return _0x51359f;
    }

    function _0xde9b9c(address _0x0eb3e6, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 _0x0bcac8 = VotingDelegationLib._0x791337(_0xbb0530, _0x0eb3e6, timestamp);
        // Sum votes
        uint[] storage _0xd1cd94 = _0xbb0530._0x451e48[_0x0eb3e6][_0x0bcac8]._0xbb706d;
        uint _0x51359f = 0;
        for (uint i = 0; i < _0xd1cd94.length; i++) {
            uint _0x9d90c9 = _0xd1cd94[i];
            // Use the provided input timestamp here to get the right decay
            _0x51359f = _0x51359f + VotingBalanceLogic._0x1183d7(_0x9d90c9, timestamp,  _0x7bd7aa);
        }

        return _0x51359f;
    }

    function _0x875783(uint256 timestamp) external view returns (uint) {
        return _0x6c9c07(timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                             DAO VOTING LOGIC
    //////////////////////////////////////////////////////////////*/
    function _0x42573e(address _0x9f0a41, address _0x7cb8ab) internal {
        /// @notice differs from `_delegate()` in `Comp.sol` to use `delegates` override method to simulate auto-delegation
        address _0x9a7c2e = _0xea6071(_0x9f0a41);

        _0xaa9640[_0x9f0a41] = _0x7cb8ab;

        emit DelegateChanged(_0x9f0a41, _0x9a7c2e, _0x7cb8ab);
        VotingDelegationLib.TokenHelpers memory _0xfa103a = VotingDelegationLib.TokenHelpers({
            _0x09e11c: _0xe48e84,
            _0x5e1a64: _0x5e1a64,
            _0x57d822:_0x57d822
        });
        VotingDelegationLib._0xae4b9d(_0xbb0530, _0x9f0a41, _0x9a7c2e, _0x7cb8ab, _0xfa103a);
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function _0xcb9069(address _0x7cb8ab) public {
        if (_0x7cb8ab == address(0)) _0x7cb8ab = msg.sender;
        return _0x42573e(msg.sender, _0x7cb8ab);
    }

    function _0x61f7c6(
        address _0x7cb8ab,
        uint _0xc8f290,
        uint _0xe6a642,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(_0x7cb8ab != msg.sender, "NA");
        require(_0x7cb8ab != address(0), "ZA");

        bytes32 _0xd95cac = _0xb4e977(
            abi._0x1fbd30(
                DOMAIN_TYPEHASH,
                _0xb4e977(bytes(_0x463e31)),
                _0xb4e977(bytes(_0x8116d2)),
                block.chainid,
                address(this)
            )
        );
        bytes32 _0x7c5691 = _0xb4e977(
            abi._0x1fbd30(DELEGATION_TYPEHASH, _0x7cb8ab, _0xc8f290, _0xe6a642)
        );
        bytes32 _0xa42f92 = _0xb4e977(
            abi._0x87cb04("\x19\x01", _0xd95cac, _0x7c5691)
        );
        address _0x40ef0e = _0x04b114(_0xa42f92, v, r, s);
        require(
            _0x40ef0e != address(0),
            "ZA"
        );
        require(
            _0xc8f290 == _0x765dad[_0x40ef0e]++,
            "!NONCE"
        );
        require(
            block.timestamp <= _0xe6a642,
            "EXP"
        );
        return _0x42573e(_0x40ef0e, _0x7cb8ab);
    }

}