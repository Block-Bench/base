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
        address indexed _0x283758,
        uint _0x323a04,
        uint value,
        uint indexed _0x9295e3,
        DepositType _0x5165e0,
        uint _0xfcf605
    );

    event Merge(
        address indexed _0xa489de,
        uint256 indexed _0x7ea499,
        uint256 indexed _0x280b05,
        uint256 _0x51f6a7,
        uint256 _0x1ffcde,
        uint256 _0xbb9b94,
        uint256 _0x563344,
        uint256 _0x5c4114
    );
    event Split(
        uint256 indexed _0x7ea499,
        uint256 indexed _0x366e99,
        uint256 indexed _0x679a17,
        address _0xa489de,
        uint256 _0x65aeec,
        uint256 _0x0f765f,
        uint256 _0x563344,
        uint256 _0x5c4114
    );

    event MultiSplit(
        uint256 indexed _0x7ea499,
        uint256[] _0x365eb7,
        address _0xa489de,
        uint256[] _0x6f295c,
        uint256 _0x563344,
        uint256 _0x5c4114
    );

    event MetadataUpdate(uint256 _0x5c718d);
    event BatchMetadataUpdate(uint256 _0xb4621f, uint256 _0x5b890e);

    event Withdraw(address indexed _0x283758, uint _0x323a04, uint value, uint _0xfcf605);
    event LockPermanent(address indexed _0xbeb817, uint256 indexed _0x5c718d, uint256 _0xacca5b, uint256 _0x5c4114);
    event UnlockPermanent(address indexed _0xbeb817, uint256 indexed _0x5c718d, uint256 _0xacca5b, uint256 _0x5c4114);
    event Supply(uint _0xe084dc, uint _0x09dce4);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    address public immutable _0x07f5fa;
    address public _0x875b36;
    address public _0x133a65;
    address public _0x90bbe6;
    // address public burnTokenAddress=0x000000000000000000000000000000000000dEaD;

    uint public PRECISISON = 10000;

    /// @dev Mapping of interface id to bool about whether or not it's supported
    mapping(bytes4 => bool) internal _0x502bcb;
    mapping(uint => bool) internal _0x5e9e0a;

    /// @dev ERC165 interface ID of ERC165
    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    /// @dev ERC165 interface ID of ERC721
    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;

    /// @dev ERC165 interface ID of ERC721Metadata
    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;

    /// @dev Current count of token
    uint internal _0x323a04;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal _0x0408eb;
    IHybra public _0xcfd878;

    // Instance of the library's storage struct
    VotingDelegationLib.Data private _0x0efb6c;

    VotingBalanceLogic.Data private _0x01a4b1;

    /// @notice Contract constructor
    /// @param token_addr `BLACK` token address
    constructor(address _0x9d6920, address _0x82ddc0) {
        _0x07f5fa = _0x9d6920;
        _0x875b36 = msg.sender;
        _0x133a65 = msg.sender;
        _0x90bbe6 = _0x82ddc0;
        WEEK = HybraTimeLibrary.WEEK;
        MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION;
        _0x0408eb = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION));

        _0x01a4b1._0xa7b12c[0]._0xecd795 = block.number;
        _0x01a4b1._0xa7b12c[0]._0xfcf605 = block.timestamp;

        _0x502bcb[ERC165_INTERFACE_ID] = true;
        _0x502bcb[ERC721_INTERFACE_ID] = true;
        _0x502bcb[ERC721_METADATA_INTERFACE_ID] = true;
        _0xcfd878 = IHybra(_0x07f5fa);

        // mint-ish
        emit Transfer(address(0), address(this), _0x323a04);
        // burn-ish
        emit Transfer(address(this), address(0), _0x323a04);
    }

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    uint8 internal constant _0x554801 = 1;
    uint8 internal constant _0xc1c854 = 2;
    uint8 internal _0x43e8e9 = 1;
    modifier _0x101c7a() {
        require(_0x43e8e9 == _0x554801);
        _0x43e8e9 = _0xc1c854;
        _;
        _0x43e8e9 = _0x554801;
    }

    modifier _0xb9abb6(uint256 _0x5c718d) {
        require(!_0x5e9e0a[_0x5c718d], "PNFT");
        _;
    }

    modifier _0x888d5f(uint _0x7ea499) {
        require(_0xa08f42[msg.sender] || _0xa08f42[address(0)], "!SPLIT");
        require(_0x50cfd0[_0x7ea499] == 0 && !_0xb1ddd2[_0x7ea499], "ATT");
        require(_0xe32dab(msg.sender, _0x7ea499), "NAO");
        _;
    }

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string constant public _0x0c52df = "veHYBR";
    string constant public _0x7b30a5 = "veHYBR";
    string constant public _0xc17187 = "1.0.0";
    uint8 constant public _0xea5320 = 18;

    function _0x11868b(address _0xf12e7c) external {
        require(msg.sender == _0x133a65);
        _0x133a65 = _0xf12e7c;
    }

    function _0xa181a7(address _0x01f486) external {
        require(msg.sender == _0x133a65);
        _0x90bbe6 = _0x01f486;
        emit BatchMetadataUpdate(0, type(uint256)._0x68b771);
    }

    /// @param _tokenId The token ID to modify
    /// @param _isPartner Whether this should be a partner veNFT
    function _0xe7f4dd(uint _0x5c718d, bool _0x81d8d1) external {
        require(msg.sender == _0x133a65, "NA");
        require(_0xcaa4db[_0x5c718d] != address(0), "DNE");
        _0x5e9e0a[_0x5c718d] = _0x81d8d1;
    }

    /// @dev Returns current token URI metadata
    /// @param _tokenId Token ID to fetch URI for.
    function _0xf3f81b(uint _0x5c718d) external view returns (string memory) {
        require(_0xcaa4db[_0x5c718d] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory _0x68ad16 = _0xec3fe4[_0x5c718d];

        return IVeArtProxy(_0x90bbe6)._0x1f71cc(_0x5c718d,VotingBalanceLogic._0x7d100c(_0x5c718d, block.timestamp, _0x01a4b1),_0x68ad16._0x1219ef,uint(int256(_0x68ad16._0xacca5b)));
    }

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to the address that owns it.
    mapping(uint => address) internal _0xcaa4db;

    /// @dev Mapping from owner address to count of his tokens.
    mapping(address => uint) internal _0x5169b4;

    /// @dev Returns the address of the owner of the NFT.
    /// @param _tokenId The identifier for an NFT.
    function _0xbd3ac2(uint _0x5c718d) public view returns (address) {
        return _0xcaa4db[_0x5c718d];
    }

    function _0x767ebe(address _0x8c1f77) public view returns (uint) {

        return _0x5169b4[_0x8c1f77];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned p to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _0x4ee9c3(address _0xbeb817) internal view returns (uint) {
        return _0x5169b4[_0xbeb817];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _0xcfd0e1(address _0xbeb817) external view returns (uint) {
        return _0x4ee9c3(_0xbeb817);
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to approved address.
    mapping(uint => address) internal _0xdc1ea6;

    /// @dev Mapping from owner address to mapping of operator addresses.
    mapping(address => mapping(address => bool)) internal _0x507f95;

    mapping(uint => uint) public _0x6427c5;

    /// @dev Get the approved address for a single NFT.
    /// @param _tokenId ID of the NFT to query the approval of.
    function _0x235f60(uint _0x5c718d) external view returns (address) {
        return _0xdc1ea6[_0x5c718d];
    }

    /// @dev Checks if `_operator` is an approved operator for `_owner`.
    /// @param _owner The address that owns the NFTs.
    /// @param _operator The address that acts on behalf of the owner.
    function _0xf83d44(address _0xbeb817, address _0x9d6144) external view returns (bool) {
        return (_0x507f95[_0xbeb817])[_0x9d6144];
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
    function _0xe05975(address _0x89763a, uint _0x5c718d) public {
        address _0x8c1f77 = _0xcaa4db[_0x5c718d];
        // Throws if `_tokenId` is not a valid NFT
        require(_0x8c1f77 != address(0), "ZA");
        // Throws if `_approved` is the current owner
        require(_0x89763a != _0x8c1f77, "IA");
        // Check requirements
        bool _0x2710f2 = (_0xcaa4db[_0x5c718d] == msg.sender);
        bool _0xf90aa8 = (_0x507f95[_0x8c1f77])[msg.sender];
        require(_0x2710f2 || _0xf90aa8, "NAO");
        // Set the approval
        _0xdc1ea6[_0x5c718d] = _0x89763a;
        emit Approval(_0x8c1f77, _0x89763a, _0x5c718d);
    }

    /// @dev Enables or disables approval for a third party ("operator") to manage all of
    ///      `msg.sender`'s assets. It also emits the ApprovalForAll event.
    ///      Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
    /// @notice This works even if sender doesn't own any tokens at the time.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval.
    function _0x393327(address _0x9d6144, bool _0x89763a) external {
        // Throws if `_operator` is the `msg.sender`
        assert(_0x9d6144 != msg.sender);
        _0x507f95[msg.sender][_0x9d6144] = _0x89763a;
        emit ApprovalForAll(msg.sender, _0x9d6144, _0x89763a);
    }

    /* TRANSFER FUNCTIONS */
    /// @dev Clear an approval of a given address
    ///      Throws if `_owner` is not the current owner.
    function _0x66b41c(address _0xbeb817, uint _0x5c718d) internal {
        // Throws if `_owner` is not the current owner
        assert(_0xcaa4db[_0x5c718d] == _0xbeb817);
        if (_0xdc1ea6[_0x5c718d] != address(0)) {
            // Reset approvals
            _0xdc1ea6[_0x5c718d] = address(0);
        }
    }

    /// @dev Returns whether the given spender can transfer a given token ID
    /// @param _spender address of the spender to query
    /// @param _tokenId uint ID of the token to be transferred
    /// @return bool whether the msg.sender is approved for the given token ID, is an operator of the owner, or is the owner of the token
    function _0xe32dab(address _0xd4d405, uint _0x5c718d) internal view returns (bool) {
        address _0x8c1f77 = _0xcaa4db[_0x5c718d];
        bool _0xad189c = _0x8c1f77 == _0xd4d405;
        bool _0x3f1ab4 = _0xd4d405 == _0xdc1ea6[_0x5c718d];
        bool _0x1f3441 = (_0x507f95[_0x8c1f77])[_0xd4d405];
        return _0xad189c || _0x3f1ab4 || _0x1f3441;
    }

    function _0x00423e(address _0xd4d405, uint _0x5c718d) external view returns (bool) {
        return _0xe32dab(_0xd4d405, _0x5c718d);
    }

    /// @dev Exeute transfer of a NFT.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
    ///      address for this NFT. (NOTE: `msg.sender` not allowed in internal function so pass `_sender`.)
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_tokenId` is not a valid NFT.
    function _0xdb66bf(
        address _0x7ea499,
        address _0x280b05,
        uint _0x5c718d,
        address _0xa489de
    ) internal _0xb9abb6(_0x5c718d) {
        require(_0x50cfd0[_0x5c718d] == 0 && !_0xb1ddd2[_0x5c718d], "ATT");
        // Check requirements
        require(_0xe32dab(_0xa489de, _0x5c718d), "NAO");

        // Clear approval. Throws if `_from` is not the current owner
        _0x66b41c(_0x7ea499, _0x5c718d);
        // Remove NFT. Throws if `_tokenId` is not a valid NFT
        _0x81edbb(_0x7ea499, _0x5c718d);
        // auto re-delegate
        VotingDelegationLib._0xc0d0cb(_0x0efb6c, _0x59a1c3(_0x7ea499), _0x59a1c3(_0x280b05), _0x5c718d, _0xbd3ac2);
        // Add NFT
        _0x30714f(_0x280b05, _0x5c718d);
        // Set the block of ownership transfer (for Flash NFT protection)
        _0x6427c5[_0x5c718d] = block.number;

        // Log the transfer
        emit Transfer(_0x7ea499, _0x280b05, _0x5c718d);
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
    function _0x4d6f20(
        address _0x7ea499,
        address _0x280b05,
        uint _0x5c718d
    ) external {
        _0xdb66bf(_0x7ea499, _0x280b05, _0x5c718d, msg.sender);
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
    function _0xac2537(
        address _0x7ea499,
        address _0x280b05,
        uint _0x5c718d
    ) external {
        _0xac2537(_0x7ea499, _0x280b05, _0x5c718d, "");
    }

    function _0x056e45(address _0xadc115) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint _0xe7b240;
        assembly {
            _0xe7b240 := extcodesize(_0xadc115)
        }
        return _0xe7b240 > 0;
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
    function _0xac2537(
        address _0x7ea499,
        address _0x280b05,
        uint _0x5c718d,
        bytes memory _0x7f6141
    ) public {
        _0xdb66bf(_0x7ea499, _0x280b05, _0x5c718d, msg.sender);

        if (_0x056e45(_0x280b05)) {
            // Throws if transfer destination is a contract which does not implement 'onERC721Received'
            try IERC721Receiver(_0x280b05)._0xb1b697(msg.sender, _0x7ea499, _0x5c718d, _0x7f6141) returns (bytes4 _0xacbd79) {
                if (_0xacbd79 != IERC721Receiver(_0x280b05)._0xb1b697.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory _0x7fe275) {
                if (_0x7fe275.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, _0x7fe275), mload(_0x7fe275))
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
    function _0x53c785(bytes4 _0x020529) external view returns (bool) {
        return _0x502bcb[_0x020529];
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from owner address to mapping of index to tokenIds
    mapping(address => mapping(uint => uint)) internal _0xcf0e8a;

    /// @dev Mapping from NFT ID to index of owner
    mapping(uint => uint) internal _0x510e05;

    /// @dev  Get token by index
    function _0x4ae926(address _0xbeb817, uint _0x835f8e) public view returns (uint) {
        return _0xcf0e8a[_0xbeb817][_0x835f8e];
    }

    /// @dev Add a NFT to an index mapping to a given addressndashushun
    /// @param _to address of the receiver
    /// @param _tokenId uint ID Of the token to be added
    function _0x28c49d(address _0x280b05, uint _0x5c718d) internal {
        uint _0x2865e6 = _0x4ee9c3(_0x280b05);

        _0xcf0e8a[_0x280b05][_0x2865e6] = _0x5c718d;
        _0x510e05[_0x5c718d] = _0x2865e6;
    }

    /// @dev Add a NFT to a given address
    ///      Throws if `_tokenId` is owned by someone.
    function _0x30714f(address _0x280b05, uint _0x5c718d) internal {
        // Throws if `_tokenId` is owned by someone
        assert(_0xcaa4db[_0x5c718d] == address(0));
        // Change the owner
        _0xcaa4db[_0x5c718d] = _0x280b05;
        // Update owner token index tracking
        _0x28c49d(_0x280b05, _0x5c718d);
        // Change count tracking
        _0x5169b4[_0x280b05] += 1;
    }

    /// @dev Function to mint tokens
    ///      Throws if `_to` is zero address.
    ///      Throws if `_tokenId` is owned by someone.
    /// @param _to The address that will receive the minted tokens.
    /// @param _tokenId The token id to mint.
    /// @return A boolean that indicates if the operation was successful.
    function _0xf6677c(address _0x280b05, uint _0x5c718d) internal returns (bool) {
        // Throws if `_to` is zero address
        assert(_0x280b05 != address(0));
        // checkpoint for gov
        VotingDelegationLib._0xc0d0cb(_0x0efb6c, address(0), _0x59a1c3(_0x280b05), _0x5c718d, _0xbd3ac2);
        // Add NFT. Throws if `_tokenId` is owned by someone
        _0x30714f(_0x280b05, _0x5c718d);
        emit Transfer(address(0), _0x280b05, _0x5c718d);
        return true;
    }

    /// @dev Remove a NFT from an index mapping to a given address
    /// @param _from address of the sender
    /// @param _tokenId uint ID Of the token to be removed
    function _0x1957dd(address _0x7ea499, uint _0x5c718d) internal {
        // Delete
        uint _0x2865e6 = _0x4ee9c3(_0x7ea499) - 1;
        uint _0xa3c213 = _0x510e05[_0x5c718d];

        if (_0x2865e6 == _0xa3c213) {
            // update ownerToNFTokenIdList
            _0xcf0e8a[_0x7ea499][_0x2865e6] = 0;
            // update tokenToOwnerIndex
            _0x510e05[_0x5c718d] = 0;
        } else {
            uint _0xccfc79 = _0xcf0e8a[_0x7ea499][_0x2865e6];

            // Add
            // update ownerToNFTokenIdList
            _0xcf0e8a[_0x7ea499][_0xa3c213] = _0xccfc79;
            // update tokenToOwnerIndex
            _0x510e05[_0xccfc79] = _0xa3c213;

            // Delete
            // update ownerToNFTokenIdList
            _0xcf0e8a[_0x7ea499][_0x2865e6] = 0;
            // update tokenToOwnerIndex
            _0x510e05[_0x5c718d] = 0;
        }
    }

    /// @dev Remove a NFT from a given address
    ///      Throws if `_from` is not the current owner.
    function _0x81edbb(address _0x7ea499, uint _0x5c718d) internal {
        // Throws if `_from` is not the current owner
        assert(_0xcaa4db[_0x5c718d] == _0x7ea499);
        // Change the owner
        _0xcaa4db[_0x5c718d] = address(0);
        // Update owner token index tracking
        _0x1957dd(_0x7ea499, _0x5c718d);
        // Change count tracking
        _0x5169b4[_0x7ea499] -= 1;
    }

    function _0x340c31(uint _0x5c718d) internal {
        require(_0xe32dab(msg.sender, _0x5c718d), "NAO");

        address _0x8c1f77 = _0xbd3ac2(_0x5c718d);

        // Clear approval
        delete _0xdc1ea6[_0x5c718d];
        // Remove token
        //_removeTokenFrom(msg.sender, _tokenId);
        _0x81edbb(_0x8c1f77, _0x5c718d);
        // checkpoint for gov
        VotingDelegationLib._0xc0d0cb(_0x0efb6c, _0x59a1c3(_0x8c1f77), address(0), _0x5c718d, _0xbd3ac2);

        emit Transfer(_0x8c1f77, address(0), _0x5c718d);
    }

    /*//////////////////////////////////////////////////////////////
                             ESCROW STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint => IVotingEscrow.LockedBalance) public _0xec3fe4;
    uint public _0x667fbc;
    uint public _0x6f3259;
    mapping(uint => int128) public _0x57b569; // time -> signed slope change
    uint public _0x09dce4;
    mapping(address => bool) public _0xa08f42;

    uint internal constant MULTIPLIER = 1 ether;

    /*//////////////////////////////////////////////////////////////
                              ESCROW LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the most recently recorded rate of voting power decrease for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @return Value of the slope
    function _0x81dfe6(uint _0x5c718d) external view returns (int128) {
        uint _0x18d6e4 = _0x01a4b1._0xc6020f[_0x5c718d];
        return _0x01a4b1._0xd49cbc[_0x5c718d][_0x18d6e4]._0x628fb9;
    }

    /// @notice Get the timestamp for checkpoint `_idx` for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function _0xd49cbc(uint _0x5c718d, uint _0xd6bf6b) external view returns (IVotingEscrow.Point memory) {
        return _0x01a4b1._0xd49cbc[_0x5c718d][_0xd6bf6b];
    }

    function _0xa7b12c(uint _0x6f3259) external view returns (IVotingEscrow.Point memory) {
        return _0x01a4b1._0xa7b12c[_0x6f3259];
    }

    function _0xc6020f(uint _0x323a04) external view returns (uint) {
        return _0x01a4b1._0xc6020f[_0x323a04];
    }

    /// @notice Record global and per-user data to checkpoint
    /// @param _tokenId NFT token ID. No user checkpoint if 0
    /// @param old_locked Pevious locked amount / end lock time for the user
    /// @param new_locked New locked amount / end lock time for the user
    function _0x2d3736(
        uint _0x5c718d,
        IVotingEscrow.LockedBalance memory _0x5f1a4c,
        IVotingEscrow.LockedBalance memory _0x27e2af
    ) internal {
        IVotingEscrow.Point memory _0xb98fc9;
        IVotingEscrow.Point memory _0x4bd237;
        int128 _0xa3e01b = 0;
        int128 _0xedb24f = 0;
        uint _0x3c9b20 = _0x6f3259;

        if (_0x5c718d != 0) {
            _0x4bd237._0x2da774 = 0;

            if(_0x27e2af._0x4076e8){
                _0x4bd237._0x2da774 = uint(int256(_0x27e2af._0xacca5b));
            }

            // Calculate slopes and biases
            // Kept at zero when they have to
            if (_0x5f1a4c._0x1219ef > block.timestamp && _0x5f1a4c._0xacca5b > 0) {
                _0xb98fc9._0x628fb9 = _0x5f1a4c._0xacca5b / _0x0408eb;
                _0xb98fc9._0x8b8dd4 = _0xb98fc9._0x628fb9 * int128(int256(_0x5f1a4c._0x1219ef - block.timestamp));
            }
            if (_0x27e2af._0x1219ef > block.timestamp && _0x27e2af._0xacca5b > 0) {
                _0x4bd237._0x628fb9 = _0x27e2af._0xacca5b / _0x0408eb;
                _0x4bd237._0x8b8dd4 = _0x4bd237._0x628fb9 * int128(int256(_0x27e2af._0x1219ef - block.timestamp));
            }

            // Read values of scheduled changes in the slope
            // old_locked.end can be in the past and in the future
            // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            _0xa3e01b = _0x57b569[_0x5f1a4c._0x1219ef];
            if (_0x27e2af._0x1219ef != 0) {
                if (_0x27e2af._0x1219ef == _0x5f1a4c._0x1219ef) {
                    _0xedb24f = _0xa3e01b;
                } else {
                    _0xedb24f = _0x57b569[_0x27e2af._0x1219ef];
                }
            }
        }

        IVotingEscrow.Point memory _0xf01da1 = IVotingEscrow.Point({_0x8b8dd4: 0, _0x628fb9: 0, _0xfcf605: block.timestamp, _0xecd795: block.number, _0x2da774: 0});
        if (_0x3c9b20 > 0) {
            _0xf01da1 = _0x01a4b1._0xa7b12c[_0x3c9b20];
        }
        uint _0xe78c0b = _0xf01da1._0xfcf605;
        // initial_last_point is used for extrapolation to calculate block number
        // (approximately, for *At methods) and save them
        // as we cannot figure that out exactly from inside the contract
        IVotingEscrow.Point memory _0x498f31 = _0xf01da1;
        uint _0xce36c8 = 0; // dblock/dt
        if (block.timestamp > _0xf01da1._0xfcf605) {
            _0xce36c8 = (MULTIPLIER * (block.number - _0xf01da1._0xecd795)) / (block.timestamp - _0xf01da1._0xfcf605);
        }
        // If last point is already recorded in this block, slope=0
        // But that's ok b/c we know the block in such case

        // Go over weeks to fill history and calculate what the current point is
        {
            uint _0xca395b = (_0xe78c0b / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {
                // Hopefully it won't happen that this won't get used in 5 years!
                // If it does, users will be able to withdraw but vote weight will be broken
                _0xca395b += WEEK;
                int128 _0xebe73d = 0;
                if (_0xca395b > block.timestamp) {
                    _0xca395b = block.timestamp;
                } else {
                    _0xebe73d = _0x57b569[_0xca395b];
                }
                _0xf01da1._0x8b8dd4 -= _0xf01da1._0x628fb9 * int128(int256(_0xca395b - _0xe78c0b));
                _0xf01da1._0x628fb9 += _0xebe73d;
                if (_0xf01da1._0x8b8dd4 < 0) {
                    // This can happen
                    _0xf01da1._0x8b8dd4 = 0;
                }
                if (_0xf01da1._0x628fb9 < 0) {
                    // This cannot happen - just in case
                    _0xf01da1._0x628fb9 = 0;
                }
                _0xe78c0b = _0xca395b;
                _0xf01da1._0xfcf605 = _0xca395b;
                _0xf01da1._0xecd795 = _0x498f31._0xecd795 + (_0xce36c8 * (_0xca395b - _0x498f31._0xfcf605)) / MULTIPLIER;
                _0x3c9b20 += 1;
                if (_0xca395b == block.timestamp) {
                    _0xf01da1._0xecd795 = block.number;
                    break;
                } else {
                    _0x01a4b1._0xa7b12c[_0x3c9b20] = _0xf01da1;
                }
            }
        }

        _0x6f3259 = _0x3c9b20;
        // Now point_history is filled until t=now

        if (_0x5c718d != 0) {
            // If last point was in this block, the slope change has been applied already
            // But in such case we have 0 slope(s)
            _0xf01da1._0x628fb9 += (_0x4bd237._0x628fb9 - _0xb98fc9._0x628fb9);
            _0xf01da1._0x8b8dd4 += (_0x4bd237._0x8b8dd4 - _0xb98fc9._0x8b8dd4);
            if (_0xf01da1._0x628fb9 < 0) {
                _0xf01da1._0x628fb9 = 0;
            }
            if (_0xf01da1._0x8b8dd4 < 0) {
                _0xf01da1._0x8b8dd4 = 0;
            }
            _0xf01da1._0x2da774 = _0x667fbc;
        }

        // Record the changed point into history
        _0x01a4b1._0xa7b12c[_0x3c9b20] = _0xf01da1;

        if (_0x5c718d != 0) {
            // Schedule the slope changes (slope is going down)
            // We subtract new_user_slope from [new_locked.end]
            // and add old_user_slope to [old_locked.end]
            if (_0x5f1a4c._0x1219ef > block.timestamp) {
                // old_dslope was <something> - u_old.slope, so we cancel that
                _0xa3e01b += _0xb98fc9._0x628fb9;
                if (_0x27e2af._0x1219ef == _0x5f1a4c._0x1219ef) {
                    _0xa3e01b -= _0x4bd237._0x628fb9; // It was a new deposit, not extension
                }
                _0x57b569[_0x5f1a4c._0x1219ef] = _0xa3e01b;
            }

            if (_0x27e2af._0x1219ef > block.timestamp) {
                if (_0x27e2af._0x1219ef > _0x5f1a4c._0x1219ef) {
                    _0xedb24f -= _0x4bd237._0x628fb9; // old slope disappeared at this point
                    _0x57b569[_0x27e2af._0x1219ef] = _0xedb24f;
                }
                // else: we recorded it already in old_dslope
            }
            // Now handle user history
            uint _0xa581e8 = _0x01a4b1._0xc6020f[_0x5c718d] + 1;

            _0x01a4b1._0xc6020f[_0x5c718d] = _0xa581e8;
            _0x4bd237._0xfcf605 = block.timestamp;
            _0x4bd237._0xecd795 = block.number;
            _0x01a4b1._0xd49cbc[_0x5c718d][_0xa581e8] = _0x4bd237;
        }
    }

    /// @notice Deposit and lock tokens for a user
    /// @param _tokenId NFT that holds lock
    /// @param _value Amount to deposit
    /// @param unlock_time New time when to unlock the tokens, or 0 if unchanged
    /// @param locked_balance Previous locked amount / timestamp
    /// @param deposit_type The type of deposit
    function _0x18439d(
        uint _0x5c718d,
        uint _0x3a6577,
        uint _0xea8d23,
        IVotingEscrow.LockedBalance memory _0xb7b011,
        DepositType _0x5165e0
    ) internal {
        IVotingEscrow.LockedBalance memory _0x68ad16 = _0xb7b011;
        uint _0x593a7a = _0x09dce4;

        _0x09dce4 = _0x593a7a + _0x3a6577;
        IVotingEscrow.LockedBalance memory _0x5f1a4c;
        (_0x5f1a4c._0xacca5b, _0x5f1a4c._0x1219ef, _0x5f1a4c._0x4076e8) = (_0x68ad16._0xacca5b, _0x68ad16._0x1219ef, _0x68ad16._0x4076e8);
        // Adding to existing lock, or if a lock is expired - creating a new one
        _0x68ad16._0xacca5b += int128(int256(_0x3a6577));

        if (_0xea8d23 != 0) {
            _0x68ad16._0x1219ef = _0xea8d23;
        }
        _0xec3fe4[_0x5c718d] = _0x68ad16;

        // Possibilities:
        // Both old_locked.end could be current or expired (>/< block.timestamp)
        // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // _locked.end > block.timestamp (always)
        _0x2d3736(_0x5c718d, _0x5f1a4c, _0x68ad16);

        address from = msg.sender;
        if (_0x3a6577 != 0) {
            assert(IERC20(_0x07f5fa)._0x4d6f20(from, address(this), _0x3a6577));
        }

        emit Deposit(from, _0x5c718d, _0x3a6577, _0x68ad16._0x1219ef, _0x5165e0, block.timestamp);
        emit Supply(_0x593a7a, _0x593a7a + _0x3a6577);
    }

    /// @notice Record global data to checkpoint
    function _0xd76fff() external {
        _0x2d3736(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }

    /// @notice Deposit `_value` tokens for `_tokenId` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _tokenId lock NFT
    /// @param _value Amount to add to user's lock
    function _0x79086f(uint _0x5c718d, uint _0x3a6577) external _0x101c7a {
        IVotingEscrow.LockedBalance memory _0x68ad16 = _0xec3fe4[_0x5c718d];

        require(_0x3a6577 > 0, "ZV"); // dev: need non-zero value
        require(_0x68ad16._0xacca5b > 0, 'ZL');
        require(_0x68ad16._0x1219ef > block.timestamp || _0x68ad16._0x4076e8, 'EXP');

        if (_0x68ad16._0x4076e8) _0x667fbc += _0x3a6577;

        _0x18439d(_0x5c718d, _0x3a6577, 0, _0x68ad16, DepositType.DEPOSIT_FOR_TYPE);

        if(_0xb1ddd2[_0x5c718d]) {
            IVoter(_0x875b36)._0x305b0a(_0x5c718d);
        }
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _0xeabdbd(uint _0x3a6577, uint _0x0690ab, address _0x280b05) internal returns (uint) {
        uint _0xea8d23 = (block.timestamp + _0x0690ab) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_0x3a6577 > 0, "ZV"); // dev: need non-zero value
        require(_0xea8d23 > block.timestamp && (_0xea8d23 <= block.timestamp + MAXTIME), 'IUT');

        ++_0x323a04;
        uint _0x5c718d = _0x323a04;
        _0xf6677c(_0x280b05, _0x5c718d);

        IVotingEscrow.LockedBalance memory _0x68ad16 = _0xec3fe4[_0x5c718d];

        _0x18439d(_0x5c718d, _0x3a6577, _0xea8d23, _0x68ad16, DepositType.CREATE_LOCK_TYPE);
        return _0x5c718d;
    }

    /// @notice Deposit `_value` tokens for `msg.sender` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    function _0x0e6736(uint _0x3a6577, uint _0x0690ab) external _0x101c7a returns (uint) {
        return _0xeabdbd(_0x3a6577, _0x0690ab, msg.sender);
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _0xac9569(uint _0x3a6577, uint _0x0690ab, address _0x280b05) external _0x101c7a returns (uint) {
        return _0xeabdbd(_0x3a6577, _0x0690ab, _0x280b05);
    }

    /// @notice Deposit `_value` additional tokens for `_tokenId` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    function _0xa60d84(uint _0x5c718d, uint _0x3a6577) external _0x101c7a {
        assert(_0xe32dab(msg.sender, _0x5c718d));

        IVotingEscrow.LockedBalance memory _0x68ad16 = _0xec3fe4[_0x5c718d];

        assert(_0x3a6577 > 0); // dev: need non-zero value
        require(_0x68ad16._0xacca5b > 0, 'ZL');
        require(_0x68ad16._0x1219ef > block.timestamp || _0x68ad16._0x4076e8, 'EXP');

        if (_0x68ad16._0x4076e8) _0x667fbc += _0x3a6577;
        _0x18439d(_0x5c718d, _0x3a6577, 0, _0x68ad16, DepositType.INCREASE_LOCK_AMOUNT);

        // poke for the gained voting power
        if(_0xb1ddd2[_0x5c718d]) {
            IVoter(_0x875b36)._0x305b0a(_0x5c718d);
        }
        emit MetadataUpdate(_0x5c718d);
    }

    /// @notice Extend the unlock time for `_tokenId`
    /// @param _lock_duration New number of seconds until tokens unlock
    function _0xf46fee(uint _0x5c718d, uint _0x0690ab) external _0x101c7a {
        assert(_0xe32dab(msg.sender, _0x5c718d));

        IVotingEscrow.LockedBalance memory _0x68ad16 = _0xec3fe4[_0x5c718d];
        require(!_0x68ad16._0x4076e8, "!NORM");
        uint _0xea8d23 = (block.timestamp + _0x0690ab) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_0x68ad16._0x1219ef > block.timestamp && _0x68ad16._0xacca5b > 0, 'EXP||ZV');
        require(_0xea8d23 > _0x68ad16._0x1219ef && (_0xea8d23 <= block.timestamp + MAXTIME), 'IUT'); // IUT -> invalid unlock time

        _0x18439d(_0x5c718d, 0, _0xea8d23, _0x68ad16, DepositType.INCREASE_UNLOCK_TIME);

        // poke for the gained voting power
        if(_0xb1ddd2[_0x5c718d]) {
            IVoter(_0x875b36)._0x305b0a(_0x5c718d);
        }
        emit MetadataUpdate(_0x5c718d);
    }

    /// @notice Withdraw all tokens for `_tokenId`
    /// @dev Only possible if the lock has expired
    function _0xc6362d(uint _0x5c718d) external _0x101c7a {
        assert(_0xe32dab(msg.sender, _0x5c718d));
        require(_0x50cfd0[_0x5c718d] == 0 && !_0xb1ddd2[_0x5c718d], "ATT");

        IVotingEscrow.LockedBalance memory _0x68ad16 = _0xec3fe4[_0x5c718d];
        require(!_0x68ad16._0x4076e8, "!NORM");
        require(block.timestamp >= _0x68ad16._0x1219ef, "!EXP");
        uint value = uint(int256(_0x68ad16._0xacca5b));

        _0xec3fe4[_0x5c718d] = IVotingEscrow.LockedBalance(0, 0, false);
        uint _0x593a7a = _0x09dce4;
        _0x09dce4 = _0x593a7a - value;

        // old_locked can have either expired <= timestamp or zero end
        // _locked has only 0 end
        // Both can have >= 0 amount
        _0x2d3736(_0x5c718d, _0x68ad16, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(_0x07f5fa).transfer(msg.sender, value));

        // Burn the NFT
        _0x340c31(_0x5c718d);

        emit Withdraw(msg.sender, _0x5c718d, value, block.timestamp);
        emit Supply(_0x593a7a, _0x593a7a - value);
    }

    function _0x0fe5b7(uint _0x5c718d) external {
        address sender = msg.sender;
        require(_0xe32dab(sender, _0x5c718d), "NAO");

        IVotingEscrow.LockedBalance memory _0xa823b5 = _0xec3fe4[_0x5c718d];
        require(!_0xa823b5._0x4076e8, "!NORM");
        require(_0xa823b5._0x1219ef > block.timestamp, "EXP");
        require(_0xa823b5._0xacca5b > 0, "ZV");

        uint _0x26990e = uint(int256(_0xa823b5._0xacca5b));
        _0x667fbc += _0x26990e;
        _0xa823b5._0x1219ef = 0;
        _0xa823b5._0x4076e8 = true;
        _0x2d3736(_0x5c718d, _0xec3fe4[_0x5c718d], _0xa823b5);
        _0xec3fe4[_0x5c718d] = _0xa823b5;
        if(_0xb1ddd2[_0x5c718d]) {
            IVoter(_0x875b36)._0x305b0a(_0x5c718d);
        }
        emit LockPermanent(sender, _0x5c718d, _0x26990e, block.timestamp);
        emit MetadataUpdate(_0x5c718d);
    }

    function _0xda9eac(uint _0x5c718d) external {
        address sender = msg.sender;
        require(_0xe32dab(msg.sender, _0x5c718d), "NAO");

        require(_0x50cfd0[_0x5c718d] == 0 && !_0xb1ddd2[_0x5c718d], "ATT");
        IVotingEscrow.LockedBalance memory _0xa823b5 = _0xec3fe4[_0x5c718d];
        require(_0xa823b5._0x4076e8, "!NORM");
        uint _0x26990e = uint(int256(_0xa823b5._0xacca5b));
        _0x667fbc -= _0x26990e;
        _0xa823b5._0x1219ef = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _0xa823b5._0x4076e8 = false;

        _0x2d3736(_0x5c718d, _0xec3fe4[_0x5c718d], _0xa823b5);
        _0xec3fe4[_0x5c718d] = _0xa823b5;

        emit UnlockPermanent(sender, _0x5c718d, _0x26990e, block.timestamp);
        emit MetadataUpdate(_0x5c718d);
    }

    /*///////////////////////////////////////////////////////////////
                           GAUGE VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    // The following ERC20/minime-compatible methods are not real balanceOf and supply!
    // They measure the weights for the purpose of voting, so they don't represent
    // real coins.

    function _0x7d100c(uint _0x5c718d) external view returns (uint) {
        if (_0x6427c5[_0x5c718d] == block.number) return 0;
        return VotingBalanceLogic._0x7d100c(_0x5c718d, block.timestamp, _0x01a4b1);
    }

    function _0x0a3bdf(uint _0x5c718d, uint _0xd4876a) external view returns (uint) {
        return VotingBalanceLogic._0x7d100c(_0x5c718d, _0xd4876a, _0x01a4b1);
    }

    function _0x15ba17(uint _0x5c718d, uint _0x60f5d0) external view returns (uint) {
        return VotingBalanceLogic._0x15ba17(_0x5c718d, _0x60f5d0, _0x01a4b1, _0x6f3259);
    }

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function _0xb7a179(uint _0x60f5d0) external view returns (uint) {
        return VotingBalanceLogic._0xb7a179(_0x60f5d0, _0x6f3259, _0x01a4b1, _0x57b569);
    }

    function _0xf98c2f() external view returns (uint) {
        return _0x36710d(block.timestamp);
    }

    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    function _0x36710d(uint t) public view returns (uint) {
        return VotingBalanceLogic._0x36710d(t, _0x6f3259, _0x57b569,  _0x01a4b1);
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE VOTING LOGIC
    //////////////////////////////////////////////////////////////*/

    mapping(uint => uint) public _0x50cfd0;
    mapping(uint => bool) public _0xb1ddd2;

    function _0x71a491(address _0x32306e) external {
        require(msg.sender == _0x133a65);
        _0x875b36 = _0x32306e;
    }

    function _0x92e3bf(uint _0x5c718d) external {
        require(msg.sender == _0x875b36);
        _0xb1ddd2[_0x5c718d] = true;
    }

    function _0xa6a694(uint _0x5c718d) external {
        require(msg.sender == _0x875b36, "NA");
        _0xb1ddd2[_0x5c718d] = false;
    }

    function _0x2a25a2(uint _0x5c718d) external {
        require(msg.sender == _0x875b36, "NA");
        _0x50cfd0[_0x5c718d] = _0x50cfd0[_0x5c718d] + 1;
    }

    function _0xd5646e(uint _0x5c718d) external {
        require(msg.sender == _0x875b36, "NA");
        _0x50cfd0[_0x5c718d] = _0x50cfd0[_0x5c718d] - 1;
    }

    function _0x12cae5(uint _0x7ea499, uint _0x280b05) external _0x101c7a _0xb9abb6(_0x7ea499) {
        require(_0x50cfd0[_0x7ea499] == 0 && !_0xb1ddd2[_0x7ea499], "ATT");
        require(_0x7ea499 != _0x280b05, "SAME");
        require(_0xe32dab(msg.sender, _0x7ea499) &&
        _0xe32dab(msg.sender, _0x280b05), "NAO");

        IVotingEscrow.LockedBalance memory _0xbf7e15 = _0xec3fe4[_0x7ea499];
        IVotingEscrow.LockedBalance memory _0xcd27b2 = _0xec3fe4[_0x280b05];
        require(_0xcd27b2._0x1219ef > block.timestamp ||  _0xcd27b2._0x4076e8,"EXP||PERM");
        require(_0xbf7e15._0x4076e8 ? _0xcd27b2._0x4076e8 : true, "!MERGE");

        uint _0x222c25 = uint(int256(_0xbf7e15._0xacca5b));
        uint _0x1219ef = _0xbf7e15._0x1219ef >= _0xcd27b2._0x1219ef ? _0xbf7e15._0x1219ef : _0xcd27b2._0x1219ef;

        _0xec3fe4[_0x7ea499] = IVotingEscrow.LockedBalance(0, 0, false);
        _0x2d3736(_0x7ea499, _0xbf7e15, IVotingEscrow.LockedBalance(0, 0, false));
        _0x340c31(_0x7ea499);

        IVotingEscrow.LockedBalance memory _0x43d0a8;
        _0x43d0a8._0x4076e8 = _0xcd27b2._0x4076e8;

        if (_0x43d0a8._0x4076e8){
            _0x43d0a8._0xacca5b = _0xcd27b2._0xacca5b + _0xbf7e15._0xacca5b;
            if (!_0xbf7e15._0x4076e8) {  // Only add if source wasn't already permanent
                _0x667fbc += _0x222c25;
            }
        }else{
            _0x43d0a8._0xacca5b = _0xcd27b2._0xacca5b + _0xbf7e15._0xacca5b;
            _0x43d0a8._0x1219ef = _0x1219ef;
        }

        //_checkpointDelegatee(_delegates[_to], value0, true);
        _0x2d3736(_0x280b05, _0xcd27b2, _0x43d0a8);
        _0xec3fe4[_0x280b05] = _0x43d0a8;

        if(_0xb1ddd2[_0x280b05]) {
            IVoter(_0x875b36)._0x305b0a(_0x280b05);
        }
        emit Merge(
            msg.sender,
            _0x7ea499,
            _0x280b05,
            uint(int256(_0xbf7e15._0xacca5b)),
            uint(int256(_0xcd27b2._0xacca5b)),
            uint(int256(_0x43d0a8._0xacca5b)),
            _0x43d0a8._0x1219ef,
            block.timestamp
        );
        emit MetadataUpdate(_0x280b05);
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
    function _0x8fc511(
        uint _0x7ea499,
        uint[] memory _0xed1556
    ) external _0x101c7a _0x888d5f(_0x7ea499) _0xb9abb6(_0x7ea499) returns (uint256[] memory _0x223c45) {
        require(_0xed1556.length >= 2 && _0xed1556.length <= 10, "MIN2MAX10");

        address _0x8c1f77 = _0xcaa4db[_0x7ea499];

        IVotingEscrow.LockedBalance memory _0x142735 = _0xec3fe4[_0x7ea499];
        require(_0x142735._0x1219ef > block.timestamp || _0x142735._0x4076e8, "EXP");
        require(_0x142735._0xacca5b > 0, "ZV");

        // Calculate total weight
        uint _0x0b1b3b = 0;
        for(uint i = 0; i < _0xed1556.length; i++) {
            require(_0xed1556[i] > 0, "ZW"); // Zero weight not allowed
            _0x0b1b3b += _0xed1556[i];
        }

        // Burn the original NFT
        _0xec3fe4[_0x7ea499] = IVotingEscrow.LockedBalance(0, 0, false);
        _0x2d3736(_0x7ea499, _0x142735, IVotingEscrow.LockedBalance(0, 0, false));
        _0x340c31(_0x7ea499);

        // Create new NFTs with proportional amounts
        _0x223c45 = new uint256[](_0xed1556.length);
        uint[] memory _0x9b3ae7 = new uint[](_0xed1556.length);

        for(uint i = 0; i < _0xed1556.length; i++) {
            IVotingEscrow.LockedBalance memory _0x68830b = IVotingEscrow.LockedBalance({
                _0xacca5b: int128(int256(uint256(int256(_0x142735._0xacca5b)) * _0xed1556[i] / _0x0b1b3b)),
                _0x1219ef: _0x142735._0x1219ef,
                _0x4076e8: _0x142735._0x4076e8
            });

            _0x223c45[i] = _0xad03b6(_0x8c1f77, _0x68830b);
            _0x9b3ae7[i] = uint256(int256(_0x68830b._0xacca5b));
        }

        emit MultiSplit(
            _0x7ea499,
            _0x223c45,
            msg.sender,
            _0x9b3ae7,
            _0x142735._0x1219ef,
            block.timestamp
        );
    }

    function _0xad03b6(address _0x280b05, IVotingEscrow.LockedBalance memory _0xa823b5) private returns (uint256 _0x5c718d) {
        _0x5c718d = ++_0x323a04;
        _0xec3fe4[_0x5c718d] = _0xa823b5;
        _0x2d3736(_0x5c718d, IVotingEscrow.LockedBalance(0, 0, false), _0xa823b5);
        _0xf6677c(_0x280b05, _0x5c718d);
    }

    function _0x57dc34(address _0x53b119, bool _0x07e6be) external {
        require(msg.sender == _0x133a65);
        _0xa08f42[_0x53b119] = _0x07e6be;
    }

    /*///////////////////////////////////////////////////////////////
                            DAO VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = _0xcea475("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = _0xcea475("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of each accounts delegate
    mapping(address => address) private _0x1b186a;

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint) public _0xa7263c;

    /**
     * @notice Overrides the standard `Comp.sol` delegates mapping to return
     * the delegator's own address if they haven't delegated.
     * This avoids having to delegate to oneself.
     */
    function _0x59a1c3(address _0x8f4d5d) public view returns (address) {
        address _0xd8ba14 = _0x1b186a[_0x8f4d5d];
        return _0xd8ba14 == address(0) ? _0x8f4d5d : _0xd8ba14;
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function _0xbac301(address _0xadc115) external view returns (uint) {
        uint32 _0xb3762b = _0x0efb6c._0xebbab0[_0xadc115];
        if (_0xb3762b == 0) {
            return 0;
        }
        uint[] storage _0x468538 = _0x0efb6c._0x3f8424[_0xadc115][_0xb3762b - 1]._0x919f90;
        uint _0xc928d9 = 0;
        for (uint i = 0; i < _0x468538.length; i++) {
            uint _0xbf6b0a = _0x468538[i];
            _0xc928d9 = _0xc928d9 + VotingBalanceLogic._0x7d100c(_0xbf6b0a, block.timestamp, _0x01a4b1);
        }
        return _0xc928d9;
    }

    function _0xdb3486(address _0xadc115, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 _0x989765 = VotingDelegationLib._0x31559c(_0x0efb6c, _0xadc115, timestamp);
        // Sum votes
        uint[] storage _0x468538 = _0x0efb6c._0x3f8424[_0xadc115][_0x989765]._0x919f90;
        uint _0xc928d9 = 0;
        for (uint i = 0; i < _0x468538.length; i++) {
            uint _0xbf6b0a = _0x468538[i];
            // Use the provided input timestamp here to get the right decay
            _0xc928d9 = _0xc928d9 + VotingBalanceLogic._0x7d100c(_0xbf6b0a, timestamp,  _0x01a4b1);
        }

        return _0xc928d9;
    }

    function _0x7385b8(uint256 timestamp) external view returns (uint) {
        return _0x36710d(timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                             DAO VOTING LOGIC
    //////////////////////////////////////////////////////////////*/
    function _0x53df84(address _0x8f4d5d, address _0x71cebe) internal {
        /// @notice differs from `_delegate()` in `Comp.sol` to use `delegates` override method to simulate auto-delegation
        address _0x3b3d71 = _0x59a1c3(_0x8f4d5d);

        _0x1b186a[_0x8f4d5d] = _0x71cebe;

        emit DelegateChanged(_0x8f4d5d, _0x3b3d71, _0x71cebe);
        VotingDelegationLib.TokenHelpers memory _0x37972f = VotingDelegationLib.TokenHelpers({
            _0x117274: _0xbd3ac2,
            _0x767ebe: _0x767ebe,
            _0x4ae926:_0x4ae926
        });
        VotingDelegationLib._0x3399ea(_0x0efb6c, _0x8f4d5d, _0x3b3d71, _0x71cebe, _0x37972f);
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function _0x836f06(address _0x71cebe) public {
        if (_0x71cebe == address(0)) _0x71cebe = msg.sender;
        return _0x53df84(msg.sender, _0x71cebe);
    }

    function _0x294603(
        address _0x71cebe,
        uint _0x064aa0,
        uint _0x1919e9,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(_0x71cebe != msg.sender, "NA");
        require(_0x71cebe != address(0), "ZA");

        bytes32 _0x9c3ee2 = _0xcea475(
            abi._0x42813e(
                DOMAIN_TYPEHASH,
                _0xcea475(bytes(_0x0c52df)),
                _0xcea475(bytes(_0xc17187)),
                block.chainid,
                address(this)
            )
        );
        bytes32 _0x4feb69 = _0xcea475(
            abi._0x42813e(DELEGATION_TYPEHASH, _0x71cebe, _0x064aa0, _0x1919e9)
        );
        bytes32 _0x47b8c3 = _0xcea475(
            abi._0x353d22("\x19\x01", _0x9c3ee2, _0x4feb69)
        );
        address _0xf8ed8c = _0xd22cd9(_0x47b8c3, v, r, s);
        require(
            _0xf8ed8c != address(0),
            "ZA"
        );
        require(
            _0x064aa0 == _0xa7263c[_0xf8ed8c]++,
            "!NONCE"
        );
        require(
            block.timestamp <= _0x1919e9,
            "EXP"
        );
        return _0x53df84(_0xf8ed8c, _0x71cebe);
    }

}