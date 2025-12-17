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
        address indexed _0x378a1a,
        uint _0xa09499,
        uint value,
        uint indexed _0x732bba,
        DepositType _0xdf513e,
        uint _0xcd5a26
    );

    event Merge(
        address indexed _0x172b63,
        uint256 indexed _0x926a34,
        uint256 indexed _0x5d1a15,
        uint256 _0x74bdb0,
        uint256 _0xadabd1,
        uint256 _0x961e9b,
        uint256 _0xe26c1b,
        uint256 _0xadd04e
    );
    event Split(
        uint256 indexed _0x926a34,
        uint256 indexed _0xe73705,
        uint256 indexed _0x68d257,
        address _0x172b63,
        uint256 _0xea3733,
        uint256 _0xc3f76b,
        uint256 _0xe26c1b,
        uint256 _0xadd04e
    );

    event MultiSplit(
        uint256 indexed _0x926a34,
        uint256[] _0x5182ca,
        address _0x172b63,
        uint256[] _0x1fd7f7,
        uint256 _0xe26c1b,
        uint256 _0xadd04e
    );

    event MetadataUpdate(uint256 _0x5df481);
    event BatchMetadataUpdate(uint256 _0x9090a0, uint256 _0x8cdd89);

    event Withdraw(address indexed _0x378a1a, uint _0xa09499, uint value, uint _0xcd5a26);
    event LockPermanent(address indexed _0xcbad60, uint256 indexed _0x5df481, uint256 _0x4284c8, uint256 _0xadd04e);
    event UnlockPermanent(address indexed _0xcbad60, uint256 indexed _0x5df481, uint256 _0x4284c8, uint256 _0xadd04e);
    event Supply(uint _0x4801a9, uint _0x743a0f);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    address public immutable _0x0ca0d4;
    address public _0x3dd917;
    address public _0x0b0202;
    address public _0xa7958a;
    // address public burnTokenAddress=0x000000000000000000000000000000000000dEaD;

    uint public PRECISISON = 10000;

    /// @dev Mapping of interface id to bool about whether or not it's supported
    mapping(bytes4 => bool) internal _0x8f36bc;
    mapping(uint => bool) internal _0x503743;

    /// @dev ERC165 interface ID of ERC165
    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    /// @dev ERC165 interface ID of ERC721
    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;

    /// @dev ERC165 interface ID of ERC721Metadata
    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;

    /// @dev Current count of token
    uint internal _0xa09499;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal _0x915f19;
    IHybra public _0x25a9a4;

    // Instance of the library's storage struct
    VotingDelegationLib.Data private _0x14872c;

    VotingBalanceLogic.Data private _0x38ef44;

    /// @notice Contract constructor
    /// @param token_addr `BLACK` token address
    constructor(address _0x9da803, address _0x49c699) {
        if (1 == 1) { _0x0ca0d4 = _0x9da803; }
        if (gasleft() > 0) { _0x3dd917 = msg.sender; }
        if (true) { _0x0b0202 = msg.sender; }
        _0xa7958a = _0x49c699;
        WEEK = HybraTimeLibrary.WEEK;
        if (msg.sender != address(0) || msg.sender == address(0)) { MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION; }
        _0x915f19 = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION));

        _0x38ef44._0xef96cd[0]._0x61d546 = block.number;
        _0x38ef44._0xef96cd[0]._0xcd5a26 = block.timestamp;

        _0x8f36bc[ERC165_INTERFACE_ID] = true;
        _0x8f36bc[ERC721_INTERFACE_ID] = true;
        _0x8f36bc[ERC721_METADATA_INTERFACE_ID] = true;
        _0x25a9a4 = IHybra(_0x0ca0d4);

        // mint-ish
        emit Transfer(address(0), address(this), _0xa09499);
        // burn-ish
        emit Transfer(address(this), address(0), _0xa09499);
    }

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    uint8 internal constant _0x27fc60 = 1;
    uint8 internal constant _0x3be27d = 2;
    uint8 internal _0x9a5900 = 1;
    modifier _0x42237d() {
        require(_0x9a5900 == _0x27fc60);
        _0x9a5900 = _0x3be27d;
        _;
        _0x9a5900 = _0x27fc60;
    }

    modifier _0x36539f(uint256 _0x5df481) {
        require(!_0x503743[_0x5df481], "PNFT");
        _;
    }

    modifier _0x94aa52(uint _0x926a34) {
        require(_0x5adf69[msg.sender] || _0x5adf69[address(0)], "!SPLIT");
        require(_0x45015f[_0x926a34] == 0 && !_0x91e191[_0x926a34], "ATT");
        require(_0x090c25(msg.sender, _0x926a34), "NAO");
        _;
    }

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string constant public _0x3776a6 = "veHYBR";
    string constant public _0xa3208b = "veHYBR";
    string constant public _0xa28113 = "1.0.0";
    uint8 constant public _0x45282b = 18;

    function _0xa53d9d(address _0x73f926) external {
        bool _flag1 = false;
        bool _flag2 = false;
        require(msg.sender == _0x0b0202);
        _0x0b0202 = _0x73f926;
    }

    function _0xb34922(address _0xe80253) external {
        if (false) { revert(); }
        if (false) { revert(); }
        require(msg.sender == _0x0b0202);
        _0xa7958a = _0xe80253;
        emit BatchMetadataUpdate(0, type(uint256)._0x6ed9e9);
    }

    /// @param _tokenId The token ID to modify
    /// @param _isPartner Whether this should be a partner veNFT
    function _0x50b58e(uint _0x5df481, bool _0x38c90d) external {
        require(msg.sender == _0x0b0202, "NA");
        require(_0xa3b03d[_0x5df481] != address(0), "DNE");
        _0x503743[_0x5df481] = _0x38c90d;
    }

    /// @dev Returns current token URI metadata
    /// @param _tokenId Token ID to fetch URI for.
    function _0x9f2cc5(uint _0x5df481) external view returns (string memory) {
        require(_0xa3b03d[_0x5df481] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory _0x0a02a8 = _0xabcf2a[_0x5df481];

        return IVeArtProxy(_0xa7958a)._0x3b9531(_0x5df481,VotingBalanceLogic._0xf768b3(_0x5df481, block.timestamp, _0x38ef44),_0x0a02a8._0xcab435,uint(int256(_0x0a02a8._0x4284c8)));
    }

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to the address that owns it.
    mapping(uint => address) internal _0xa3b03d;

    /// @dev Mapping from owner address to count of his tokens.
    mapping(address => uint) internal _0xd0dc6b;

    /// @dev Returns the address of the owner of the NFT.
    /// @param _tokenId The identifier for an NFT.
    function _0x686137(uint _0x5df481) public view returns (address) {
        return _0xa3b03d[_0x5df481];
    }

    function _0xe9033f(address _0xdc2230) public view returns (uint) {

        return _0xd0dc6b[_0xdc2230];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned p to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _0xa5ebb8(address _0xcbad60) internal view returns (uint) {
        return _0xd0dc6b[_0xcbad60];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _0x456354(address _0xcbad60) external view returns (uint) {
        return _0xa5ebb8(_0xcbad60);
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to approved address.
    mapping(uint => address) internal _0x1d4965;

    /// @dev Mapping from owner address to mapping of operator addresses.
    mapping(address => mapping(address => bool)) internal _0x8e8e9f;

    mapping(uint => uint) public _0x5bc75c;

    /// @dev Get the approved address for a single NFT.
    /// @param _tokenId ID of the NFT to query the approval of.
    function _0x52daae(uint _0x5df481) external view returns (address) {
        return _0x1d4965[_0x5df481];
    }

    /// @dev Checks if `_operator` is an approved operator for `_owner`.
    /// @param _owner The address that owns the NFTs.
    /// @param _operator The address that acts on behalf of the owner.
    function _0x06b160(address _0xcbad60, address _0xd22674) external view returns (bool) {
        return (_0x8e8e9f[_0xcbad60])[_0xd22674];
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
    function _0xff84e0(address _0xd524e5, uint _0x5df481) public {
        address _0xdc2230 = _0xa3b03d[_0x5df481];
        // Throws if `_tokenId` is not a valid NFT
        require(_0xdc2230 != address(0), "ZA");
        // Throws if `_approved` is the current owner
        require(_0xd524e5 != _0xdc2230, "IA");
        // Check requirements
        bool _0x44c6ee = (_0xa3b03d[_0x5df481] == msg.sender);
        bool _0xff2727 = (_0x8e8e9f[_0xdc2230])[msg.sender];
        require(_0x44c6ee || _0xff2727, "NAO");
        // Set the approval
        _0x1d4965[_0x5df481] = _0xd524e5;
        emit Approval(_0xdc2230, _0xd524e5, _0x5df481);
    }

    /// @dev Enables or disables approval for a third party ("operator") to manage all of
    ///      `msg.sender`'s assets. It also emits the ApprovalForAll event.
    ///      Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
    /// @notice This works even if sender doesn't own any tokens at the time.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval.
    function _0x7349f7(address _0xd22674, bool _0xd524e5) external {
        // Throws if `_operator` is the `msg.sender`
        assert(_0xd22674 != msg.sender);
        _0x8e8e9f[msg.sender][_0xd22674] = _0xd524e5;
        emit ApprovalForAll(msg.sender, _0xd22674, _0xd524e5);
    }

    /* TRANSFER FUNCTIONS */
    /// @dev Clear an approval of a given address
    ///      Throws if `_owner` is not the current owner.
    function _0x089840(address _0xcbad60, uint _0x5df481) internal {
        // Throws if `_owner` is not the current owner
        assert(_0xa3b03d[_0x5df481] == _0xcbad60);
        if (_0x1d4965[_0x5df481] != address(0)) {
            // Reset approvals
            _0x1d4965[_0x5df481] = address(0);
        }
    }

    /// @dev Returns whether the given spender can transfer a given token ID
    /// @param _spender address of the spender to query
    /// @param _tokenId uint ID of the token to be transferred
    /// @return bool whether the msg.sender is approved for the given token ID, is an operator of the owner, or is the owner of the token
    function _0x090c25(address _0xfaa387, uint _0x5df481) internal view returns (bool) {
        address _0xdc2230 = _0xa3b03d[_0x5df481];
        bool _0x9ef348 = _0xdc2230 == _0xfaa387;
        bool _0x613e78 = _0xfaa387 == _0x1d4965[_0x5df481];
        bool _0x3ff80c = (_0x8e8e9f[_0xdc2230])[_0xfaa387];
        return _0x9ef348 || _0x613e78 || _0x3ff80c;
    }

    function _0x3c6e17(address _0xfaa387, uint _0x5df481) external view returns (bool) {
        return _0x090c25(_0xfaa387, _0x5df481);
    }

    /// @dev Exeute transfer of a NFT.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
    ///      address for this NFT. (NOTE: `msg.sender` not allowed in internal function so pass `_sender`.)
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_tokenId` is not a valid NFT.
    function _0x649e9a(
        address _0x926a34,
        address _0x5d1a15,
        uint _0x5df481,
        address _0x172b63
    ) internal _0x36539f(_0x5df481) {
        require(_0x45015f[_0x5df481] == 0 && !_0x91e191[_0x5df481], "ATT");
        // Check requirements
        require(_0x090c25(_0x172b63, _0x5df481), "NAO");

        // Clear approval. Throws if `_from` is not the current owner
        _0x089840(_0x926a34, _0x5df481);
        // Remove NFT. Throws if `_tokenId` is not a valid NFT
        _0xd1a6da(_0x926a34, _0x5df481);
        // auto re-delegate
        VotingDelegationLib._0xbf2e9b(_0x14872c, _0x7f3cc6(_0x926a34), _0x7f3cc6(_0x5d1a15), _0x5df481, _0x686137);
        // Add NFT
        _0x581a7c(_0x5d1a15, _0x5df481);
        // Set the block of ownership transfer (for Flash NFT protection)
        _0x5bc75c[_0x5df481] = block.number;

        // Log the transfer
        emit Transfer(_0x926a34, _0x5d1a15, _0x5df481);
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
    function _0xf8cb4b(
        address _0x926a34,
        address _0x5d1a15,
        uint _0x5df481
    ) external {
        _0x649e9a(_0x926a34, _0x5d1a15, _0x5df481, msg.sender);
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
    function _0x49347d(
        address _0x926a34,
        address _0x5d1a15,
        uint _0x5df481
    ) external {
        _0x49347d(_0x926a34, _0x5d1a15, _0x5df481, "");
    }

    function _0x74fefa(address _0xe2f196) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint _0xabdfff;
        assembly {
            _0xabdfff := extcodesize(_0xe2f196)
        }
        return _0xabdfff > 0;
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
    function _0x49347d(
        address _0x926a34,
        address _0x5d1a15,
        uint _0x5df481,
        bytes memory _0xfb97fd
    ) public {
        _0x649e9a(_0x926a34, _0x5d1a15, _0x5df481, msg.sender);

        if (_0x74fefa(_0x5d1a15)) {
            // Throws if transfer destination is a contract which does not implement 'onERC721Received'
            try IERC721Receiver(_0x5d1a15)._0xdc2c97(msg.sender, _0x926a34, _0x5df481, _0xfb97fd) returns (bytes4 _0x9aa8fb) {
                if (_0x9aa8fb != IERC721Receiver(_0x5d1a15)._0xdc2c97.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory _0x86e3e6) {
                if (_0x86e3e6.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, _0x86e3e6), mload(_0x86e3e6))
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
    function _0x0aabbb(bytes4 _0x883fba) external view returns (bool) {
        return _0x8f36bc[_0x883fba];
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from owner address to mapping of index to tokenIds
    mapping(address => mapping(uint => uint)) internal _0x97ca44;

    /// @dev Mapping from NFT ID to index of owner
    mapping(uint => uint) internal _0x0c0286;

    /// @dev  Get token by index
    function _0x3a052a(address _0xcbad60, uint _0x586271) public view returns (uint) {
        return _0x97ca44[_0xcbad60][_0x586271];
    }

    /// @dev Add a NFT to an index mapping to a given addressndashushun
    /// @param _to address of the receiver
    /// @param _tokenId uint ID Of the token to be added
    function _0x1af70a(address _0x5d1a15, uint _0x5df481) internal {
        uint _0x81102c = _0xa5ebb8(_0x5d1a15);

        _0x97ca44[_0x5d1a15][_0x81102c] = _0x5df481;
        _0x0c0286[_0x5df481] = _0x81102c;
    }

    /// @dev Add a NFT to a given address
    ///      Throws if `_tokenId` is owned by someone.
    function _0x581a7c(address _0x5d1a15, uint _0x5df481) internal {
        // Throws if `_tokenId` is owned by someone
        assert(_0xa3b03d[_0x5df481] == address(0));
        // Change the owner
        _0xa3b03d[_0x5df481] = _0x5d1a15;
        // Update owner token index tracking
        _0x1af70a(_0x5d1a15, _0x5df481);
        // Change count tracking
        _0xd0dc6b[_0x5d1a15] += 1;
    }

    /// @dev Function to mint tokens
    ///      Throws if `_to` is zero address.
    ///      Throws if `_tokenId` is owned by someone.
    /// @param _to The address that will receive the minted tokens.
    /// @param _tokenId The token id to mint.
    /// @return A boolean that indicates if the operation was successful.
    function _0x9e0227(address _0x5d1a15, uint _0x5df481) internal returns (bool) {
        // Throws if `_to` is zero address
        assert(_0x5d1a15 != address(0));
        // checkpoint for gov
        VotingDelegationLib._0xbf2e9b(_0x14872c, address(0), _0x7f3cc6(_0x5d1a15), _0x5df481, _0x686137);
        // Add NFT. Throws if `_tokenId` is owned by someone
        _0x581a7c(_0x5d1a15, _0x5df481);
        emit Transfer(address(0), _0x5d1a15, _0x5df481);
        return true;
    }

    /// @dev Remove a NFT from an index mapping to a given address
    /// @param _from address of the sender
    /// @param _tokenId uint ID Of the token to be removed
    function _0xe25b85(address _0x926a34, uint _0x5df481) internal {
        // Delete
        uint _0x81102c = _0xa5ebb8(_0x926a34) - 1;
        uint _0x1a6e77 = _0x0c0286[_0x5df481];

        if (_0x81102c == _0x1a6e77) {
            // update ownerToNFTokenIdList
            _0x97ca44[_0x926a34][_0x81102c] = 0;
            // update tokenToOwnerIndex
            _0x0c0286[_0x5df481] = 0;
        } else {
            uint _0xe33a39 = _0x97ca44[_0x926a34][_0x81102c];

            // Add
            // update ownerToNFTokenIdList
            _0x97ca44[_0x926a34][_0x1a6e77] = _0xe33a39;
            // update tokenToOwnerIndex
            _0x0c0286[_0xe33a39] = _0x1a6e77;

            // Delete
            // update ownerToNFTokenIdList
            _0x97ca44[_0x926a34][_0x81102c] = 0;
            // update tokenToOwnerIndex
            _0x0c0286[_0x5df481] = 0;
        }
    }

    /// @dev Remove a NFT from a given address
    ///      Throws if `_from` is not the current owner.
    function _0xd1a6da(address _0x926a34, uint _0x5df481) internal {
        // Throws if `_from` is not the current owner
        assert(_0xa3b03d[_0x5df481] == _0x926a34);
        // Change the owner
        _0xa3b03d[_0x5df481] = address(0);
        // Update owner token index tracking
        _0xe25b85(_0x926a34, _0x5df481);
        // Change count tracking
        _0xd0dc6b[_0x926a34] -= 1;
    }

    function _0x422597(uint _0x5df481) internal {
        require(_0x090c25(msg.sender, _0x5df481), "NAO");

        address _0xdc2230 = _0x686137(_0x5df481);

        // Clear approval
        delete _0x1d4965[_0x5df481];
        // Remove token
        //_removeTokenFrom(msg.sender, _tokenId);
        _0xd1a6da(_0xdc2230, _0x5df481);
        // checkpoint for gov
        VotingDelegationLib._0xbf2e9b(_0x14872c, _0x7f3cc6(_0xdc2230), address(0), _0x5df481, _0x686137);

        emit Transfer(_0xdc2230, address(0), _0x5df481);
    }

    /*//////////////////////////////////////////////////////////////
                             ESCROW STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint => IVotingEscrow.LockedBalance) public _0xabcf2a;
    uint public _0x01bc68;
    uint public _0x515bb7;
    mapping(uint => int128) public _0x58a767; // time -> signed slope change
    uint public _0x743a0f;
    mapping(address => bool) public _0x5adf69;

    uint internal constant MULTIPLIER = 1 ether;

    /*//////////////////////////////////////////////////////////////
                              ESCROW LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the most recently recorded rate of voting power decrease for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @return Value of the slope
    function _0x395a47(uint _0x5df481) external view returns (int128) {
        uint _0xbe558d = _0x38ef44._0xa2603a[_0x5df481];
        return _0x38ef44._0x9baa66[_0x5df481][_0xbe558d]._0x79c1ee;
    }

    /// @notice Get the timestamp for checkpoint `_idx` for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function _0x9baa66(uint _0x5df481, uint _0x7ed466) external view returns (IVotingEscrow.Point memory) {
        return _0x38ef44._0x9baa66[_0x5df481][_0x7ed466];
    }

    function _0xef96cd(uint _0x515bb7) external view returns (IVotingEscrow.Point memory) {
        return _0x38ef44._0xef96cd[_0x515bb7];
    }

    function _0xa2603a(uint _0xa09499) external view returns (uint) {
        return _0x38ef44._0xa2603a[_0xa09499];
    }

    /// @notice Record global and per-user data to checkpoint
    /// @param _tokenId NFT token ID. No user checkpoint if 0
    /// @param old_locked Pevious locked amount / end lock time for the user
    /// @param new_locked New locked amount / end lock time for the user
    function _0x6b3775(
        uint _0x5df481,
        IVotingEscrow.LockedBalance memory _0x24eb43,
        IVotingEscrow.LockedBalance memory _0xc23948
    ) internal {
        IVotingEscrow.Point memory _0x00e623;
        IVotingEscrow.Point memory _0xa2a3e7;
        int128 _0xeeb9d0 = 0;
        int128 _0xa8de77 = 0;
        uint _0x46457f = _0x515bb7;

        if (_0x5df481 != 0) {
            _0xa2a3e7._0x4b8496 = 0;

            if(_0xc23948._0x060c30){
                _0xa2a3e7._0x4b8496 = uint(int256(_0xc23948._0x4284c8));
            }

            // Calculate slopes and biases
            // Kept at zero when they have to
            if (_0x24eb43._0xcab435 > block.timestamp && _0x24eb43._0x4284c8 > 0) {
                _0x00e623._0x79c1ee = _0x24eb43._0x4284c8 / _0x915f19;
                _0x00e623._0x8aa000 = _0x00e623._0x79c1ee * int128(int256(_0x24eb43._0xcab435 - block.timestamp));
            }
            if (_0xc23948._0xcab435 > block.timestamp && _0xc23948._0x4284c8 > 0) {
                _0xa2a3e7._0x79c1ee = _0xc23948._0x4284c8 / _0x915f19;
                _0xa2a3e7._0x8aa000 = _0xa2a3e7._0x79c1ee * int128(int256(_0xc23948._0xcab435 - block.timestamp));
            }

            // Read values of scheduled changes in the slope
            // old_locked.end can be in the past and in the future
            // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            _0xeeb9d0 = _0x58a767[_0x24eb43._0xcab435];
            if (_0xc23948._0xcab435 != 0) {
                if (_0xc23948._0xcab435 == _0x24eb43._0xcab435) {
                    _0xa8de77 = _0xeeb9d0;
                } else {
                    _0xa8de77 = _0x58a767[_0xc23948._0xcab435];
                }
            }
        }

        IVotingEscrow.Point memory _0x3fd558 = IVotingEscrow.Point({_0x8aa000: 0, _0x79c1ee: 0, _0xcd5a26: block.timestamp, _0x61d546: block.number, _0x4b8496: 0});
        if (_0x46457f > 0) {
            _0x3fd558 = _0x38ef44._0xef96cd[_0x46457f];
        }
        uint _0x703e77 = _0x3fd558._0xcd5a26;
        // initial_last_point is used for extrapolation to calculate block number
        // (approximately, for *At methods) and save them
        // as we cannot figure that out exactly from inside the contract
        IVotingEscrow.Point memory _0x04fa5b = _0x3fd558;
        uint _0x1980c2 = 0; // dblock/dt
        if (block.timestamp > _0x3fd558._0xcd5a26) {
            _0x1980c2 = (MULTIPLIER * (block.number - _0x3fd558._0x61d546)) / (block.timestamp - _0x3fd558._0xcd5a26);
        }
        // If last point is already recorded in this block, slope=0
        // But that's ok b/c we know the block in such case

        // Go over weeks to fill history and calculate what the current point is
        {
            uint _0x211a79 = (_0x703e77 / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {
                // Hopefully it won't happen that this won't get used in 5 years!
                // If it does, users will be able to withdraw but vote weight will be broken
                _0x211a79 += WEEK;
                int128 _0x782741 = 0;
                if (_0x211a79 > block.timestamp) {
                    _0x211a79 = block.timestamp;
                } else {
                    _0x782741 = _0x58a767[_0x211a79];
                }
                _0x3fd558._0x8aa000 -= _0x3fd558._0x79c1ee * int128(int256(_0x211a79 - _0x703e77));
                _0x3fd558._0x79c1ee += _0x782741;
                if (_0x3fd558._0x8aa000 < 0) {
                    // This can happen
                    _0x3fd558._0x8aa000 = 0;
                }
                if (_0x3fd558._0x79c1ee < 0) {
                    // This cannot happen - just in case
                    _0x3fd558._0x79c1ee = 0;
                }
                _0x703e77 = _0x211a79;
                _0x3fd558._0xcd5a26 = _0x211a79;
                _0x3fd558._0x61d546 = _0x04fa5b._0x61d546 + (_0x1980c2 * (_0x211a79 - _0x04fa5b._0xcd5a26)) / MULTIPLIER;
                _0x46457f += 1;
                if (_0x211a79 == block.timestamp) {
                    _0x3fd558._0x61d546 = block.number;
                    break;
                } else {
                    _0x38ef44._0xef96cd[_0x46457f] = _0x3fd558;
                }
            }
        }

        _0x515bb7 = _0x46457f;
        // Now point_history is filled until t=now

        if (_0x5df481 != 0) {
            // If last point was in this block, the slope change has been applied already
            // But in such case we have 0 slope(s)
            _0x3fd558._0x79c1ee += (_0xa2a3e7._0x79c1ee - _0x00e623._0x79c1ee);
            _0x3fd558._0x8aa000 += (_0xa2a3e7._0x8aa000 - _0x00e623._0x8aa000);
            if (_0x3fd558._0x79c1ee < 0) {
                _0x3fd558._0x79c1ee = 0;
            }
            if (_0x3fd558._0x8aa000 < 0) {
                _0x3fd558._0x8aa000 = 0;
            }
            _0x3fd558._0x4b8496 = _0x01bc68;
        }

        // Record the changed point into history
        _0x38ef44._0xef96cd[_0x46457f] = _0x3fd558;

        if (_0x5df481 != 0) {
            // Schedule the slope changes (slope is going down)
            // We subtract new_user_slope from [new_locked.end]
            // and add old_user_slope to [old_locked.end]
            if (_0x24eb43._0xcab435 > block.timestamp) {
                // old_dslope was <something> - u_old.slope, so we cancel that
                _0xeeb9d0 += _0x00e623._0x79c1ee;
                if (_0xc23948._0xcab435 == _0x24eb43._0xcab435) {
                    _0xeeb9d0 -= _0xa2a3e7._0x79c1ee; // It was a new deposit, not extension
                }
                _0x58a767[_0x24eb43._0xcab435] = _0xeeb9d0;
            }

            if (_0xc23948._0xcab435 > block.timestamp) {
                if (_0xc23948._0xcab435 > _0x24eb43._0xcab435) {
                    _0xa8de77 -= _0xa2a3e7._0x79c1ee; // old slope disappeared at this point
                    _0x58a767[_0xc23948._0xcab435] = _0xa8de77;
                }
                // else: we recorded it already in old_dslope
            }
            // Now handle user history
            uint _0x119df3 = _0x38ef44._0xa2603a[_0x5df481] + 1;

            _0x38ef44._0xa2603a[_0x5df481] = _0x119df3;
            _0xa2a3e7._0xcd5a26 = block.timestamp;
            _0xa2a3e7._0x61d546 = block.number;
            _0x38ef44._0x9baa66[_0x5df481][_0x119df3] = _0xa2a3e7;
        }
    }

    /// @notice Deposit and lock tokens for a user
    /// @param _tokenId NFT that holds lock
    /// @param _value Amount to deposit
    /// @param unlock_time New time when to unlock the tokens, or 0 if unchanged
    /// @param locked_balance Previous locked amount / timestamp
    /// @param deposit_type The type of deposit
    function _0xe72d05(
        uint _0x5df481,
        uint _0xd769e9,
        uint _0x76d858,
        IVotingEscrow.LockedBalance memory _0x473217,
        DepositType _0xdf513e
    ) internal {
        IVotingEscrow.LockedBalance memory _0x0a02a8 = _0x473217;
        uint _0x481d9f = _0x743a0f;

        _0x743a0f = _0x481d9f + _0xd769e9;
        IVotingEscrow.LockedBalance memory _0x24eb43;
        (_0x24eb43._0x4284c8, _0x24eb43._0xcab435, _0x24eb43._0x060c30) = (_0x0a02a8._0x4284c8, _0x0a02a8._0xcab435, _0x0a02a8._0x060c30);
        // Adding to existing lock, or if a lock is expired - creating a new one
        _0x0a02a8._0x4284c8 += int128(int256(_0xd769e9));

        if (_0x76d858 != 0) {
            _0x0a02a8._0xcab435 = _0x76d858;
        }
        _0xabcf2a[_0x5df481] = _0x0a02a8;

        // Possibilities:
        // Both old_locked.end could be current or expired (>/< block.timestamp)
        // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // _locked.end > block.timestamp (always)
        _0x6b3775(_0x5df481, _0x24eb43, _0x0a02a8);

        address from = msg.sender;
        if (_0xd769e9 != 0) {
            assert(IERC20(_0x0ca0d4)._0xf8cb4b(from, address(this), _0xd769e9));
        }

        emit Deposit(from, _0x5df481, _0xd769e9, _0x0a02a8._0xcab435, _0xdf513e, block.timestamp);
        emit Supply(_0x481d9f, _0x481d9f + _0xd769e9);
    }

    /// @notice Record global data to checkpoint
    function _0x857a46() external {
        _0x6b3775(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }

    /// @notice Deposit `_value` tokens for `_tokenId` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _tokenId lock NFT
    /// @param _value Amount to add to user's lock
    function _0x3324b6(uint _0x5df481, uint _0xd769e9) external _0x42237d {
        IVotingEscrow.LockedBalance memory _0x0a02a8 = _0xabcf2a[_0x5df481];

        require(_0xd769e9 > 0, "ZV"); // dev: need non-zero value
        require(_0x0a02a8._0x4284c8 > 0, 'ZL');
        require(_0x0a02a8._0xcab435 > block.timestamp || _0x0a02a8._0x060c30, 'EXP');

        if (_0x0a02a8._0x060c30) _0x01bc68 += _0xd769e9;

        _0xe72d05(_0x5df481, _0xd769e9, 0, _0x0a02a8, DepositType.DEPOSIT_FOR_TYPE);

        if(_0x91e191[_0x5df481]) {
            IVoter(_0x3dd917)._0x4571e0(_0x5df481);
        }
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _0x1714a4(uint _0xd769e9, uint _0xf51f7f, address _0x5d1a15) internal returns (uint) {
        uint _0x76d858 = (block.timestamp + _0xf51f7f) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_0xd769e9 > 0, "ZV"); // dev: need non-zero value
        require(_0x76d858 > block.timestamp && (_0x76d858 <= block.timestamp + MAXTIME), 'IUT');

        ++_0xa09499;
        uint _0x5df481 = _0xa09499;
        _0x9e0227(_0x5d1a15, _0x5df481);

        IVotingEscrow.LockedBalance memory _0x0a02a8 = _0xabcf2a[_0x5df481];

        _0xe72d05(_0x5df481, _0xd769e9, _0x76d858, _0x0a02a8, DepositType.CREATE_LOCK_TYPE);
        return _0x5df481;
    }

    /// @notice Deposit `_value` tokens for `msg.sender` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    function _0x3f20d8(uint _0xd769e9, uint _0xf51f7f) external _0x42237d returns (uint) {
        return _0x1714a4(_0xd769e9, _0xf51f7f, msg.sender);
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _0x5232ae(uint _0xd769e9, uint _0xf51f7f, address _0x5d1a15) external _0x42237d returns (uint) {
        return _0x1714a4(_0xd769e9, _0xf51f7f, _0x5d1a15);
    }

    /// @notice Deposit `_value` additional tokens for `_tokenId` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    function _0x458296(uint _0x5df481, uint _0xd769e9) external _0x42237d {
        assert(_0x090c25(msg.sender, _0x5df481));

        IVotingEscrow.LockedBalance memory _0x0a02a8 = _0xabcf2a[_0x5df481];

        assert(_0xd769e9 > 0); // dev: need non-zero value
        require(_0x0a02a8._0x4284c8 > 0, 'ZL');
        require(_0x0a02a8._0xcab435 > block.timestamp || _0x0a02a8._0x060c30, 'EXP');

        if (_0x0a02a8._0x060c30) _0x01bc68 += _0xd769e9;
        _0xe72d05(_0x5df481, _0xd769e9, 0, _0x0a02a8, DepositType.INCREASE_LOCK_AMOUNT);

        // poke for the gained voting power
        if(_0x91e191[_0x5df481]) {
            IVoter(_0x3dd917)._0x4571e0(_0x5df481);
        }
        emit MetadataUpdate(_0x5df481);
    }

    /// @notice Extend the unlock time for `_tokenId`
    /// @param _lock_duration New number of seconds until tokens unlock
    function _0x8b22da(uint _0x5df481, uint _0xf51f7f) external _0x42237d {
        assert(_0x090c25(msg.sender, _0x5df481));

        IVotingEscrow.LockedBalance memory _0x0a02a8 = _0xabcf2a[_0x5df481];
        require(!_0x0a02a8._0x060c30, "!NORM");
        uint _0x76d858 = (block.timestamp + _0xf51f7f) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_0x0a02a8._0xcab435 > block.timestamp && _0x0a02a8._0x4284c8 > 0, 'EXP||ZV');
        require(_0x76d858 > _0x0a02a8._0xcab435 && (_0x76d858 <= block.timestamp + MAXTIME), 'IUT'); // IUT -> invalid unlock time

        _0xe72d05(_0x5df481, 0, _0x76d858, _0x0a02a8, DepositType.INCREASE_UNLOCK_TIME);

        // poke for the gained voting power
        if(_0x91e191[_0x5df481]) {
            IVoter(_0x3dd917)._0x4571e0(_0x5df481);
        }
        emit MetadataUpdate(_0x5df481);
    }

    /// @notice Withdraw all tokens for `_tokenId`
    /// @dev Only possible if the lock has expired
    function _0xcc469b(uint _0x5df481) external _0x42237d {
        assert(_0x090c25(msg.sender, _0x5df481));
        require(_0x45015f[_0x5df481] == 0 && !_0x91e191[_0x5df481], "ATT");

        IVotingEscrow.LockedBalance memory _0x0a02a8 = _0xabcf2a[_0x5df481];
        require(!_0x0a02a8._0x060c30, "!NORM");
        require(block.timestamp >= _0x0a02a8._0xcab435, "!EXP");
        uint value = uint(int256(_0x0a02a8._0x4284c8));

        _0xabcf2a[_0x5df481] = IVotingEscrow.LockedBalance(0, 0, false);
        uint _0x481d9f = _0x743a0f;
        _0x743a0f = _0x481d9f - value;

        // old_locked can have either expired <= timestamp or zero end
        // _locked has only 0 end
        // Both can have >= 0 amount
        _0x6b3775(_0x5df481, _0x0a02a8, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(_0x0ca0d4).transfer(msg.sender, value));

        // Burn the NFT
        _0x422597(_0x5df481);

        emit Withdraw(msg.sender, _0x5df481, value, block.timestamp);
        emit Supply(_0x481d9f, _0x481d9f - value);
    }

    function _0xc5a163(uint _0x5df481) external {
        address sender = msg.sender;
        require(_0x090c25(sender, _0x5df481), "NAO");

        IVotingEscrow.LockedBalance memory _0xff506b = _0xabcf2a[_0x5df481];
        require(!_0xff506b._0x060c30, "!NORM");
        require(_0xff506b._0xcab435 > block.timestamp, "EXP");
        require(_0xff506b._0x4284c8 > 0, "ZV");

        uint _0x65a0f1 = uint(int256(_0xff506b._0x4284c8));
        _0x01bc68 += _0x65a0f1;
        _0xff506b._0xcab435 = 0;
        _0xff506b._0x060c30 = true;
        _0x6b3775(_0x5df481, _0xabcf2a[_0x5df481], _0xff506b);
        _0xabcf2a[_0x5df481] = _0xff506b;
        if(_0x91e191[_0x5df481]) {
            IVoter(_0x3dd917)._0x4571e0(_0x5df481);
        }
        emit LockPermanent(sender, _0x5df481, _0x65a0f1, block.timestamp);
        emit MetadataUpdate(_0x5df481);
    }

    function _0xe5799f(uint _0x5df481) external {
        address sender = msg.sender;
        require(_0x090c25(msg.sender, _0x5df481), "NAO");

        require(_0x45015f[_0x5df481] == 0 && !_0x91e191[_0x5df481], "ATT");
        IVotingEscrow.LockedBalance memory _0xff506b = _0xabcf2a[_0x5df481];
        require(_0xff506b._0x060c30, "!NORM");
        uint _0x65a0f1 = uint(int256(_0xff506b._0x4284c8));
        _0x01bc68 -= _0x65a0f1;
        _0xff506b._0xcab435 = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _0xff506b._0x060c30 = false;

        _0x6b3775(_0x5df481, _0xabcf2a[_0x5df481], _0xff506b);
        _0xabcf2a[_0x5df481] = _0xff506b;

        emit UnlockPermanent(sender, _0x5df481, _0x65a0f1, block.timestamp);
        emit MetadataUpdate(_0x5df481);
    }

    /*///////////////////////////////////////////////////////////////
                           GAUGE VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    // The following ERC20/minime-compatible methods are not real balanceOf and supply!
    // They measure the weights for the purpose of voting, so they don't represent
    // real coins.

    function _0xf768b3(uint _0x5df481) external view returns (uint) {
        if (_0x5bc75c[_0x5df481] == block.number) return 0;
        return VotingBalanceLogic._0xf768b3(_0x5df481, block.timestamp, _0x38ef44);
    }

    function _0xf79973(uint _0x5df481, uint _0x57cc72) external view returns (uint) {
        return VotingBalanceLogic._0xf768b3(_0x5df481, _0x57cc72, _0x38ef44);
    }

    function _0xc8355f(uint _0x5df481, uint _0xc88e3a) external view returns (uint) {
        return VotingBalanceLogic._0xc8355f(_0x5df481, _0xc88e3a, _0x38ef44, _0x515bb7);
    }

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function _0x5dae03(uint _0xc88e3a) external view returns (uint) {
        return VotingBalanceLogic._0x5dae03(_0xc88e3a, _0x515bb7, _0x38ef44, _0x58a767);
    }

    function _0xcae313() external view returns (uint) {
        return _0xdecc07(block.timestamp);
    }

    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    function _0xdecc07(uint t) public view returns (uint) {
        return VotingBalanceLogic._0xdecc07(t, _0x515bb7, _0x58a767,  _0x38ef44);
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE VOTING LOGIC
    //////////////////////////////////////////////////////////////*/

    mapping(uint => uint) public _0x45015f;
    mapping(uint => bool) public _0x91e191;

    function _0x234a6e(address _0x06a452) external {
        require(msg.sender == _0x0b0202);
        _0x3dd917 = _0x06a452;
    }

    function _0xd291c4(uint _0x5df481) external {
        require(msg.sender == _0x3dd917);
        _0x91e191[_0x5df481] = true;
    }

    function _0xe19b1b(uint _0x5df481) external {
        require(msg.sender == _0x3dd917, "NA");
        _0x91e191[_0x5df481] = false;
    }

    function _0x98325b(uint _0x5df481) external {
        require(msg.sender == _0x3dd917, "NA");
        _0x45015f[_0x5df481] = _0x45015f[_0x5df481] + 1;
    }

    function _0xeeff1c(uint _0x5df481) external {
        require(msg.sender == _0x3dd917, "NA");
        _0x45015f[_0x5df481] = _0x45015f[_0x5df481] - 1;
    }

    function _0xdbfc0d(uint _0x926a34, uint _0x5d1a15) external _0x42237d _0x36539f(_0x926a34) {
        require(_0x45015f[_0x926a34] == 0 && !_0x91e191[_0x926a34], "ATT");
        require(_0x926a34 != _0x5d1a15, "SAME");
        require(_0x090c25(msg.sender, _0x926a34) &&
        _0x090c25(msg.sender, _0x5d1a15), "NAO");

        IVotingEscrow.LockedBalance memory _0x113539 = _0xabcf2a[_0x926a34];
        IVotingEscrow.LockedBalance memory _0x7e418b = _0xabcf2a[_0x5d1a15];
        require(_0x7e418b._0xcab435 > block.timestamp ||  _0x7e418b._0x060c30,"EXP||PERM");
        require(_0x113539._0x060c30 ? _0x7e418b._0x060c30 : true, "!MERGE");

        uint _0x01c8f6 = uint(int256(_0x113539._0x4284c8));
        uint _0xcab435 = _0x113539._0xcab435 >= _0x7e418b._0xcab435 ? _0x113539._0xcab435 : _0x7e418b._0xcab435;

        _0xabcf2a[_0x926a34] = IVotingEscrow.LockedBalance(0, 0, false);
        _0x6b3775(_0x926a34, _0x113539, IVotingEscrow.LockedBalance(0, 0, false));
        _0x422597(_0x926a34);

        IVotingEscrow.LockedBalance memory _0x401316;
        _0x401316._0x060c30 = _0x7e418b._0x060c30;

        if (_0x401316._0x060c30){
            _0x401316._0x4284c8 = _0x7e418b._0x4284c8 + _0x113539._0x4284c8;
            if (!_0x113539._0x060c30) {  // Only add if source wasn't already permanent
                _0x01bc68 += _0x01c8f6;
            }
        }else{
            _0x401316._0x4284c8 = _0x7e418b._0x4284c8 + _0x113539._0x4284c8;
            _0x401316._0xcab435 = _0xcab435;
        }

        //_checkpointDelegatee(_delegates[_to], value0, true);
        _0x6b3775(_0x5d1a15, _0x7e418b, _0x401316);
        _0xabcf2a[_0x5d1a15] = _0x401316;

        if(_0x91e191[_0x5d1a15]) {
            IVoter(_0x3dd917)._0x4571e0(_0x5d1a15);
        }
        emit Merge(
            msg.sender,
            _0x926a34,
            _0x5d1a15,
            uint(int256(_0x113539._0x4284c8)),
            uint(int256(_0x7e418b._0x4284c8)),
            uint(int256(_0x401316._0x4284c8)),
            _0x401316._0xcab435,
            block.timestamp
        );
        emit MetadataUpdate(_0x5d1a15);
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
    function _0x27c9ff(
        uint _0x926a34,
        uint[] memory _0x7b8f3b
    ) external _0x42237d _0x94aa52(_0x926a34) _0x36539f(_0x926a34) returns (uint256[] memory _0x5694ff) {
        require(_0x7b8f3b.length >= 2 && _0x7b8f3b.length <= 10, "MIN2MAX10");

        address _0xdc2230 = _0xa3b03d[_0x926a34];

        IVotingEscrow.LockedBalance memory _0xab4047 = _0xabcf2a[_0x926a34];
        require(_0xab4047._0xcab435 > block.timestamp || _0xab4047._0x060c30, "EXP");
        require(_0xab4047._0x4284c8 > 0, "ZV");

        // Calculate total weight
        uint _0x86c5ee = 0;
        for(uint i = 0; i < _0x7b8f3b.length; i++) {
            require(_0x7b8f3b[i] > 0, "ZW"); // Zero weight not allowed
            _0x86c5ee += _0x7b8f3b[i];
        }

        // Burn the original NFT
        _0xabcf2a[_0x926a34] = IVotingEscrow.LockedBalance(0, 0, false);
        _0x6b3775(_0x926a34, _0xab4047, IVotingEscrow.LockedBalance(0, 0, false));
        _0x422597(_0x926a34);

        // Create new NFTs with proportional amounts
        _0x5694ff = new uint256[](_0x7b8f3b.length);
        uint[] memory _0x6f8df3 = new uint[](_0x7b8f3b.length);

        for(uint i = 0; i < _0x7b8f3b.length; i++) {
            IVotingEscrow.LockedBalance memory _0x5b4a13 = IVotingEscrow.LockedBalance({
                _0x4284c8: int128(int256(uint256(int256(_0xab4047._0x4284c8)) * _0x7b8f3b[i] / _0x86c5ee)),
                _0xcab435: _0xab4047._0xcab435,
                _0x060c30: _0xab4047._0x060c30
            });

            _0x5694ff[i] = _0x6623a2(_0xdc2230, _0x5b4a13);
            _0x6f8df3[i] = uint256(int256(_0x5b4a13._0x4284c8));
        }

        emit MultiSplit(
            _0x926a34,
            _0x5694ff,
            msg.sender,
            _0x6f8df3,
            _0xab4047._0xcab435,
            block.timestamp
        );
    }

    function _0x6623a2(address _0x5d1a15, IVotingEscrow.LockedBalance memory _0xff506b) private returns (uint256 _0x5df481) {
        if (1 == 1) { _0x5df481 = ++_0xa09499; }
        _0xabcf2a[_0x5df481] = _0xff506b;
        _0x6b3775(_0x5df481, IVotingEscrow.LockedBalance(0, 0, false), _0xff506b);
        _0x9e0227(_0x5d1a15, _0x5df481);
    }

    function _0xc30a43(address _0x5f04b1, bool _0x807e33) external {
        require(msg.sender == _0x0b0202);
        _0x5adf69[_0x5f04b1] = _0x807e33;
    }

    /*///////////////////////////////////////////////////////////////
                            DAO VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = _0xd45d86("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = _0xd45d86("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of each accounts delegate
    mapping(address => address) private _0xff69d2;

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint) public _0xb81508;

    /**
     * @notice Overrides the standard `Comp.sol` delegates mapping to return
     * the delegator's own address if they haven't delegated.
     * This avoids having to delegate to oneself.
     */
    function _0x7f3cc6(address _0x7a3e7b) public view returns (address) {
        address _0xb4a571 = _0xff69d2[_0x7a3e7b];
        return _0xb4a571 == address(0) ? _0x7a3e7b : _0xb4a571;
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function _0x367052(address _0xe2f196) external view returns (uint) {
        uint32 _0x067d16 = _0x14872c._0x92559b[_0xe2f196];
        if (_0x067d16 == 0) {
            return 0;
        }
        uint[] storage _0x08e968 = _0x14872c._0xcdf694[_0xe2f196][_0x067d16 - 1]._0xac9a2a;
        uint _0xe62107 = 0;
        for (uint i = 0; i < _0x08e968.length; i++) {
            uint _0x208667 = _0x08e968[i];
            _0xe62107 = _0xe62107 + VotingBalanceLogic._0xf768b3(_0x208667, block.timestamp, _0x38ef44);
        }
        return _0xe62107;
    }

    function _0xc4c326(address _0xe2f196, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 _0xb84ca5 = VotingDelegationLib._0x451039(_0x14872c, _0xe2f196, timestamp);
        // Sum votes
        uint[] storage _0x08e968 = _0x14872c._0xcdf694[_0xe2f196][_0xb84ca5]._0xac9a2a;
        uint _0xe62107 = 0;
        for (uint i = 0; i < _0x08e968.length; i++) {
            uint _0x208667 = _0x08e968[i];
            // Use the provided input timestamp here to get the right decay
            _0xe62107 = _0xe62107 + VotingBalanceLogic._0xf768b3(_0x208667, timestamp,  _0x38ef44);
        }

        return _0xe62107;
    }

    function _0x16158b(uint256 timestamp) external view returns (uint) {
        return _0xdecc07(timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                             DAO VOTING LOGIC
    //////////////////////////////////////////////////////////////*/
    function _0x861f3e(address _0x7a3e7b, address _0xf922a7) internal {
        /// @notice differs from `_delegate()` in `Comp.sol` to use `delegates` override method to simulate auto-delegation
        address _0x7f3307 = _0x7f3cc6(_0x7a3e7b);

        _0xff69d2[_0x7a3e7b] = _0xf922a7;

        emit DelegateChanged(_0x7a3e7b, _0x7f3307, _0xf922a7);
        VotingDelegationLib.TokenHelpers memory _0x992379 = VotingDelegationLib.TokenHelpers({
            _0x366c46: _0x686137,
            _0xe9033f: _0xe9033f,
            _0x3a052a:_0x3a052a
        });
        VotingDelegationLib._0xc8c8d7(_0x14872c, _0x7a3e7b, _0x7f3307, _0xf922a7, _0x992379);
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function _0xaefa69(address _0xf922a7) public {
        if (_0xf922a7 == address(0)) _0xf922a7 = msg.sender;
        return _0x861f3e(msg.sender, _0xf922a7);
    }

    function _0xe6cd70(
        address _0xf922a7,
        uint _0xd6f164,
        uint _0xf89259,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(_0xf922a7 != msg.sender, "NA");
        require(_0xf922a7 != address(0), "ZA");

        bytes32 _0xb67841 = _0xd45d86(
            abi._0x6bccba(
                DOMAIN_TYPEHASH,
                _0xd45d86(bytes(_0x3776a6)),
                _0xd45d86(bytes(_0xa28113)),
                block.chainid,
                address(this)
            )
        );
        bytes32 _0x4f780a = _0xd45d86(
            abi._0x6bccba(DELEGATION_TYPEHASH, _0xf922a7, _0xd6f164, _0xf89259)
        );
        bytes32 _0x21ed45 = _0xd45d86(
            abi._0xc36516("\x19\x01", _0xb67841, _0x4f780a)
        );
        address _0x9fe8b6 = _0x5160ed(_0x21ed45, v, r, s);
        require(
            _0x9fe8b6 != address(0),
            "ZA"
        );
        require(
            _0xd6f164 == _0xb81508[_0x9fe8b6]++,
            "!NONCE"
        );
        require(
            block.timestamp <= _0xf89259,
            "EXP"
        );
        return _0x861f3e(_0x9fe8b6, _0xf922a7);
    }

}