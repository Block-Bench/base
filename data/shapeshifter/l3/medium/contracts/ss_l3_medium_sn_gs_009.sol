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
        address indexed _0x8f0084,
        uint _0x0f299d,
        uint value,
        uint indexed _0xe22c76,
        DepositType _0x90fcb0,
        uint _0x09fb48
    );

    event Merge(
        address indexed _0x60f853,
        uint256 indexed _0xb0d395,
        uint256 indexed _0x0000eb,
        uint256 _0x21bb72,
        uint256 _0xc38f13,
        uint256 _0xa70796,
        uint256 _0x475692,
        uint256 _0x81b88e
    );
    event Split(
        uint256 indexed _0xb0d395,
        uint256 indexed _0x96b11e,
        uint256 indexed _0x257314,
        address _0x60f853,
        uint256 _0x488f49,
        uint256 _0x817053,
        uint256 _0x475692,
        uint256 _0x81b88e
    );

    event MultiSplit(
        uint256 indexed _0xb0d395,
        uint256[] _0x5d784c,
        address _0x60f853,
        uint256[] _0xcd4095,
        uint256 _0x475692,
        uint256 _0x81b88e
    );

    event MetadataUpdate(uint256 _0x498993);
    event BatchMetadataUpdate(uint256 _0x181914, uint256 _0x1b5391);

    event Withdraw(address indexed _0x8f0084, uint _0x0f299d, uint value, uint _0x09fb48);
    event LockPermanent(address indexed _0x3c791d, uint256 indexed _0x498993, uint256 _0xe6eaf0, uint256 _0x81b88e);
    event UnlockPermanent(address indexed _0x3c791d, uint256 indexed _0x498993, uint256 _0xe6eaf0, uint256 _0x81b88e);
    event Supply(uint _0xcaa74c, uint _0x3742c0);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    address public immutable _0x6f1e41;
    address public _0x2aec38;
    address public _0x3b167b;
    address public _0xc6c142;
    // address public burnTokenAddress=0x000000000000000000000000000000000000dEaD;

    uint public PRECISISON = 10000;

    /// @dev Mapping of interface id to bool about whether or not it's supported
    mapping(bytes4 => bool) internal _0xa8eeef;
    mapping(uint => bool) internal _0xcd3484;

    /// @dev ERC165 interface ID of ERC165
    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    /// @dev ERC165 interface ID of ERC721
    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;

    /// @dev ERC165 interface ID of ERC721Metadata
    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;

    /// @dev Current count of token
    uint internal _0x0f299d;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal _0x5901f1;
    IHybra public _0x75772a;

    // Instance of the library's storage struct
    VotingDelegationLib.Data private _0xa205d3;

    VotingBalanceLogic.Data private _0x5acbfd;

    /// @notice Contract constructor
    /// @param token_addr `BLACK` token address
    constructor(address _0x6fcfcf, address _0xe20598) {
        _0x6f1e41 = _0x6fcfcf;
        _0x2aec38 = msg.sender;
        _0x3b167b = msg.sender;
        if (1 == 1) { _0xc6c142 = _0xe20598; }
        if (msg.sender != address(0) || msg.sender == address(0)) { WEEK = HybraTimeLibrary.WEEK; }
        MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION;
        if (gasleft() > 0) { _0x5901f1 = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION)); }

        _0x5acbfd._0xd3cfc3[0]._0xbb24ac = block.number;
        _0x5acbfd._0xd3cfc3[0]._0x09fb48 = block.timestamp;

        _0xa8eeef[ERC165_INTERFACE_ID] = true;
        _0xa8eeef[ERC721_INTERFACE_ID] = true;
        _0xa8eeef[ERC721_METADATA_INTERFACE_ID] = true;
        if (block.timestamp > 0) { _0x75772a = IHybra(_0x6f1e41); }

        // mint-ish
        emit Transfer(address(0), address(this), _0x0f299d);
        // burn-ish
        emit Transfer(address(this), address(0), _0x0f299d);
    }

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    uint8 internal constant _0x72f78c = 1;
    uint8 internal constant _0xb09902 = 2;
    uint8 internal _0x040b38 = 1;
    modifier _0x498fb1() {
        require(_0x040b38 == _0x72f78c);
        _0x040b38 = _0xb09902;
        _;
        _0x040b38 = _0x72f78c;
    }

    modifier _0xb807d9(uint256 _0x498993) {
        require(!_0xcd3484[_0x498993], "PNFT");
        _;
    }

    modifier _0xe93cee(uint _0xb0d395) {
        require(_0xbfec33[msg.sender] || _0xbfec33[address(0)], "!SPLIT");
        require(_0x696c2b[_0xb0d395] == 0 && !_0x6ae278[_0xb0d395], "ATT");
        require(_0xe853fd(msg.sender, _0xb0d395), "NAO");
        _;
    }

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string constant public _0x00356c = "veHYBR";
    string constant public _0xf77260 = "veHYBR";
    string constant public _0x80eacc = "1.0.0";
    uint8 constant public _0xb0291e = 18;

    function _0x4ca80d(address _0xe0ae01) external {
        require(msg.sender == _0x3b167b);
        _0x3b167b = _0xe0ae01;
    }

    function _0xdbe624(address _0xe4445a) external {
        require(msg.sender == _0x3b167b);
        if (1 == 1) { _0xc6c142 = _0xe4445a; }
        emit BatchMetadataUpdate(0, type(uint256)._0x5c5bb9);
    }

    /// @param _tokenId The token ID to modify
    /// @param _isPartner Whether this should be a partner veNFT
    function _0xc8c7dc(uint _0x498993, bool _0xf052be) external {
        require(msg.sender == _0x3b167b, "NA");
        require(_0x34f9ab[_0x498993] != address(0), "DNE");
        _0xcd3484[_0x498993] = _0xf052be;
    }

    /// @dev Returns current token URI metadata
    /// @param _tokenId Token ID to fetch URI for.
    function _0xa3256f(uint _0x498993) external view returns (string memory) {
        require(_0x34f9ab[_0x498993] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory _0x5ca81a = _0xd9186e[_0x498993];

        return IVeArtProxy(_0xc6c142)._0x927a90(_0x498993,VotingBalanceLogic._0xb01b2c(_0x498993, block.timestamp, _0x5acbfd),_0x5ca81a._0xa44afa,uint(int256(_0x5ca81a._0xe6eaf0)));
    }

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to the address that owns it.
    mapping(uint => address) internal _0x34f9ab;

    /// @dev Mapping from owner address to count of his tokens.
    mapping(address => uint) internal _0x251555;

    /// @dev Returns the address of the owner of the NFT.
    /// @param _tokenId The identifier for an NFT.
    function _0x5aeafb(uint _0x498993) public view returns (address) {
        return _0x34f9ab[_0x498993];
    }

    function _0xbc95c6(address _0x995dbe) public view returns (uint) {

        return _0x251555[_0x995dbe];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned p to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _0x86a98b(address _0x3c791d) internal view returns (uint) {
        return _0x251555[_0x3c791d];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _0x1dc02d(address _0x3c791d) external view returns (uint) {
        return _0x86a98b(_0x3c791d);
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to approved address.
    mapping(uint => address) internal _0xf3302e;

    /// @dev Mapping from owner address to mapping of operator addresses.
    mapping(address => mapping(address => bool)) internal _0xadaab3;

    mapping(uint => uint) public _0x1916a8;

    /// @dev Get the approved address for a single NFT.
    /// @param _tokenId ID of the NFT to query the approval of.
    function _0xc13ec2(uint _0x498993) external view returns (address) {
        return _0xf3302e[_0x498993];
    }

    /// @dev Checks if `_operator` is an approved operator for `_owner`.
    /// @param _owner The address that owns the NFTs.
    /// @param _operator The address that acts on behalf of the owner.
    function _0x0ba419(address _0x3c791d, address _0x140788) external view returns (bool) {
        return (_0xadaab3[_0x3c791d])[_0x140788];
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
    function _0x211e05(address _0x2c1908, uint _0x498993) public {
        address _0x995dbe = _0x34f9ab[_0x498993];
        // Throws if `_tokenId` is not a valid NFT
        require(_0x995dbe != address(0), "ZA");
        // Throws if `_approved` is the current owner
        require(_0x2c1908 != _0x995dbe, "IA");
        // Check requirements
        bool _0x7e729e = (_0x34f9ab[_0x498993] == msg.sender);
        bool _0x44ff7e = (_0xadaab3[_0x995dbe])[msg.sender];
        require(_0x7e729e || _0x44ff7e, "NAO");
        // Set the approval
        _0xf3302e[_0x498993] = _0x2c1908;
        emit Approval(_0x995dbe, _0x2c1908, _0x498993);
    }

    /// @dev Enables or disables approval for a third party ("operator") to manage all of
    ///      `msg.sender`'s assets. It also emits the ApprovalForAll event.
    ///      Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
    /// @notice This works even if sender doesn't own any tokens at the time.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval.
    function _0x4cd64c(address _0x140788, bool _0x2c1908) external {
        // Throws if `_operator` is the `msg.sender`
        assert(_0x140788 != msg.sender);
        _0xadaab3[msg.sender][_0x140788] = _0x2c1908;
        emit ApprovalForAll(msg.sender, _0x140788, _0x2c1908);
    }

    /* TRANSFER FUNCTIONS */
    /// @dev Clear an approval of a given address
    ///      Throws if `_owner` is not the current owner.
    function _0x4bce92(address _0x3c791d, uint _0x498993) internal {
        // Throws if `_owner` is not the current owner
        assert(_0x34f9ab[_0x498993] == _0x3c791d);
        if (_0xf3302e[_0x498993] != address(0)) {
            // Reset approvals
            _0xf3302e[_0x498993] = address(0);
        }
    }

    /// @dev Returns whether the given spender can transfer a given token ID
    /// @param _spender address of the spender to query
    /// @param _tokenId uint ID of the token to be transferred
    /// @return bool whether the msg.sender is approved for the given token ID, is an operator of the owner, or is the owner of the token
    function _0xe853fd(address _0xa5a6ef, uint _0x498993) internal view returns (bool) {
        address _0x995dbe = _0x34f9ab[_0x498993];
        bool _0xe3de39 = _0x995dbe == _0xa5a6ef;
        bool _0x7cb016 = _0xa5a6ef == _0xf3302e[_0x498993];
        bool _0x6fe1fa = (_0xadaab3[_0x995dbe])[_0xa5a6ef];
        return _0xe3de39 || _0x7cb016 || _0x6fe1fa;
    }

    function _0xfe6854(address _0xa5a6ef, uint _0x498993) external view returns (bool) {
        return _0xe853fd(_0xa5a6ef, _0x498993);
    }

    /// @dev Exeute transfer of a NFT.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
    ///      address for this NFT. (NOTE: `msg.sender` not allowed in internal function so pass `_sender`.)
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_tokenId` is not a valid NFT.
    function _0x995d19(
        address _0xb0d395,
        address _0x0000eb,
        uint _0x498993,
        address _0x60f853
    ) internal _0xb807d9(_0x498993) {
        require(_0x696c2b[_0x498993] == 0 && !_0x6ae278[_0x498993], "ATT");
        // Check requirements
        require(_0xe853fd(_0x60f853, _0x498993), "NAO");

        // Clear approval. Throws if `_from` is not the current owner
        _0x4bce92(_0xb0d395, _0x498993);
        // Remove NFT. Throws if `_tokenId` is not a valid NFT
        _0x555f1e(_0xb0d395, _0x498993);
        // auto re-delegate
        VotingDelegationLib._0xbb88d7(_0xa205d3, _0x2e4ce8(_0xb0d395), _0x2e4ce8(_0x0000eb), _0x498993, _0x5aeafb);
        // Add NFT
        _0xf93b88(_0x0000eb, _0x498993);
        // Set the block of ownership transfer (for Flash NFT protection)
        _0x1916a8[_0x498993] = block.number;

        // Log the transfer
        emit Transfer(_0xb0d395, _0x0000eb, _0x498993);
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
    function _0x29018b(
        address _0xb0d395,
        address _0x0000eb,
        uint _0x498993
    ) external {
        _0x995d19(_0xb0d395, _0x0000eb, _0x498993, msg.sender);
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
    function _0x397a9b(
        address _0xb0d395,
        address _0x0000eb,
        uint _0x498993
    ) external {
        _0x397a9b(_0xb0d395, _0x0000eb, _0x498993, "");
    }

    function _0x26d0a6(address _0xa8a6fd) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint _0xa4515e;
        assembly {
            _0xa4515e := extcodesize(_0xa8a6fd)
        }
        return _0xa4515e > 0;
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
    function _0x397a9b(
        address _0xb0d395,
        address _0x0000eb,
        uint _0x498993,
        bytes memory _0xb58f48
    ) public {
        _0x995d19(_0xb0d395, _0x0000eb, _0x498993, msg.sender);

        if (_0x26d0a6(_0x0000eb)) {
            // Throws if transfer destination is a contract which does not implement 'onERC721Received'
            try IERC721Receiver(_0x0000eb)._0x0aa05b(msg.sender, _0xb0d395, _0x498993, _0xb58f48) returns (bytes4 _0xda321f) {
                if (_0xda321f != IERC721Receiver(_0x0000eb)._0x0aa05b.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory _0x9be2e0) {
                if (_0x9be2e0.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, _0x9be2e0), mload(_0x9be2e0))
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
    function _0x3f37c2(bytes4 _0xe95dd7) external view returns (bool) {
        return _0xa8eeef[_0xe95dd7];
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from owner address to mapping of index to tokenIds
    mapping(address => mapping(uint => uint)) internal _0xcbc5ae;

    /// @dev Mapping from NFT ID to index of owner
    mapping(uint => uint) internal _0xd73607;

    /// @dev  Get token by index
    function _0x1cd3bd(address _0x3c791d, uint _0x08c9dd) public view returns (uint) {
        return _0xcbc5ae[_0x3c791d][_0x08c9dd];
    }

    /// @dev Add a NFT to an index mapping to a given addressndashushun
    /// @param _to address of the receiver
    /// @param _tokenId uint ID Of the token to be added
    function _0x270ff8(address _0x0000eb, uint _0x498993) internal {
        uint _0x8a78ad = _0x86a98b(_0x0000eb);

        _0xcbc5ae[_0x0000eb][_0x8a78ad] = _0x498993;
        _0xd73607[_0x498993] = _0x8a78ad;
    }

    /// @dev Add a NFT to a given address
    ///      Throws if `_tokenId` is owned by someone.
    function _0xf93b88(address _0x0000eb, uint _0x498993) internal {
        // Throws if `_tokenId` is owned by someone
        assert(_0x34f9ab[_0x498993] == address(0));
        // Change the owner
        _0x34f9ab[_0x498993] = _0x0000eb;
        // Update owner token index tracking
        _0x270ff8(_0x0000eb, _0x498993);
        // Change count tracking
        _0x251555[_0x0000eb] += 1;
    }

    /// @dev Function to mint tokens
    ///      Throws if `_to` is zero address.
    ///      Throws if `_tokenId` is owned by someone.
    /// @param _to The address that will receive the minted tokens.
    /// @param _tokenId The token id to mint.
    /// @return A boolean that indicates if the operation was successful.
    function _0x56e1a4(address _0x0000eb, uint _0x498993) internal returns (bool) {
        // Throws if `_to` is zero address
        assert(_0x0000eb != address(0));
        // checkpoint for gov
        VotingDelegationLib._0xbb88d7(_0xa205d3, address(0), _0x2e4ce8(_0x0000eb), _0x498993, _0x5aeafb);
        // Add NFT. Throws if `_tokenId` is owned by someone
        _0xf93b88(_0x0000eb, _0x498993);
        emit Transfer(address(0), _0x0000eb, _0x498993);
        return true;
    }

    /// @dev Remove a NFT from an index mapping to a given address
    /// @param _from address of the sender
    /// @param _tokenId uint ID Of the token to be removed
    function _0x2fe3f5(address _0xb0d395, uint _0x498993) internal {
        // Delete
        uint _0x8a78ad = _0x86a98b(_0xb0d395) - 1;
        uint _0x83a68e = _0xd73607[_0x498993];

        if (_0x8a78ad == _0x83a68e) {
            // update ownerToNFTokenIdList
            _0xcbc5ae[_0xb0d395][_0x8a78ad] = 0;
            // update tokenToOwnerIndex
            _0xd73607[_0x498993] = 0;
        } else {
            uint _0x6cce1d = _0xcbc5ae[_0xb0d395][_0x8a78ad];

            // Add
            // update ownerToNFTokenIdList
            _0xcbc5ae[_0xb0d395][_0x83a68e] = _0x6cce1d;
            // update tokenToOwnerIndex
            _0xd73607[_0x6cce1d] = _0x83a68e;

            // Delete
            // update ownerToNFTokenIdList
            _0xcbc5ae[_0xb0d395][_0x8a78ad] = 0;
            // update tokenToOwnerIndex
            _0xd73607[_0x498993] = 0;
        }
    }

    /// @dev Remove a NFT from a given address
    ///      Throws if `_from` is not the current owner.
    function _0x555f1e(address _0xb0d395, uint _0x498993) internal {
        // Throws if `_from` is not the current owner
        assert(_0x34f9ab[_0x498993] == _0xb0d395);
        // Change the owner
        _0x34f9ab[_0x498993] = address(0);
        // Update owner token index tracking
        _0x2fe3f5(_0xb0d395, _0x498993);
        // Change count tracking
        _0x251555[_0xb0d395] -= 1;
    }

    function _0xc21ac8(uint _0x498993) internal {
        require(_0xe853fd(msg.sender, _0x498993), "NAO");

        address _0x995dbe = _0x5aeafb(_0x498993);

        // Clear approval
        delete _0xf3302e[_0x498993];
        // Remove token
        //_removeTokenFrom(msg.sender, _tokenId);
        _0x555f1e(_0x995dbe, _0x498993);
        // checkpoint for gov
        VotingDelegationLib._0xbb88d7(_0xa205d3, _0x2e4ce8(_0x995dbe), address(0), _0x498993, _0x5aeafb);

        emit Transfer(_0x995dbe, address(0), _0x498993);
    }

    /*//////////////////////////////////////////////////////////////
                             ESCROW STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint => IVotingEscrow.LockedBalance) public _0xd9186e;
    uint public _0x1596d8;
    uint public _0xb1e36a;
    mapping(uint => int128) public _0xfabc37; // time -> signed slope change
    uint public _0x3742c0;
    mapping(address => bool) public _0xbfec33;

    uint internal constant MULTIPLIER = 1 ether;

    /*//////////////////////////////////////////////////////////////
                              ESCROW LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the most recently recorded rate of voting power decrease for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @return Value of the slope
    function _0x4511b7(uint _0x498993) external view returns (int128) {
        uint _0x39be88 = _0x5acbfd._0xaed215[_0x498993];
        return _0x5acbfd._0xc8f6a5[_0x498993][_0x39be88]._0x1edeb5;
    }

    /// @notice Get the timestamp for checkpoint `_idx` for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function _0xc8f6a5(uint _0x498993, uint _0x8d9f7a) external view returns (IVotingEscrow.Point memory) {
        return _0x5acbfd._0xc8f6a5[_0x498993][_0x8d9f7a];
    }

    function _0xd3cfc3(uint _0xb1e36a) external view returns (IVotingEscrow.Point memory) {
        return _0x5acbfd._0xd3cfc3[_0xb1e36a];
    }

    function _0xaed215(uint _0x0f299d) external view returns (uint) {
        return _0x5acbfd._0xaed215[_0x0f299d];
    }

    /// @notice Record global and per-user data to checkpoint
    /// @param _tokenId NFT token ID. No user checkpoint if 0
    /// @param old_locked Pevious locked amount / end lock time for the user
    /// @param new_locked New locked amount / end lock time for the user
    function _0x0abb95(
        uint _0x498993,
        IVotingEscrow.LockedBalance memory _0xe032ee,
        IVotingEscrow.LockedBalance memory _0xf89fd3
    ) internal {
        IVotingEscrow.Point memory _0x18295f;
        IVotingEscrow.Point memory _0xce60e7;
        int128 _0xb65376 = 0;
        int128 _0x54ccd5 = 0;
        uint _0xbf7d2a = _0xb1e36a;

        if (_0x498993 != 0) {
            _0xce60e7._0x530b74 = 0;

            if(_0xf89fd3._0x3a7e69){
                _0xce60e7._0x530b74 = uint(int256(_0xf89fd3._0xe6eaf0));
            }

            // Calculate slopes and biases
            // Kept at zero when they have to
            if (_0xe032ee._0xa44afa > block.timestamp && _0xe032ee._0xe6eaf0 > 0) {
                _0x18295f._0x1edeb5 = _0xe032ee._0xe6eaf0 / _0x5901f1;
                _0x18295f._0xe344d1 = _0x18295f._0x1edeb5 * int128(int256(_0xe032ee._0xa44afa - block.timestamp));
            }
            if (_0xf89fd3._0xa44afa > block.timestamp && _0xf89fd3._0xe6eaf0 > 0) {
                _0xce60e7._0x1edeb5 = _0xf89fd3._0xe6eaf0 / _0x5901f1;
                _0xce60e7._0xe344d1 = _0xce60e7._0x1edeb5 * int128(int256(_0xf89fd3._0xa44afa - block.timestamp));
            }

            // Read values of scheduled changes in the slope
            // old_locked.end can be in the past and in the future
            // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            _0xb65376 = _0xfabc37[_0xe032ee._0xa44afa];
            if (_0xf89fd3._0xa44afa != 0) {
                if (_0xf89fd3._0xa44afa == _0xe032ee._0xa44afa) {
                    _0x54ccd5 = _0xb65376;
                } else {
                    _0x54ccd5 = _0xfabc37[_0xf89fd3._0xa44afa];
                }
            }
        }

        IVotingEscrow.Point memory _0x6e7489 = IVotingEscrow.Point({_0xe344d1: 0, _0x1edeb5: 0, _0x09fb48: block.timestamp, _0xbb24ac: block.number, _0x530b74: 0});
        if (_0xbf7d2a > 0) {
            _0x6e7489 = _0x5acbfd._0xd3cfc3[_0xbf7d2a];
        }
        uint _0xe1b0d8 = _0x6e7489._0x09fb48;
        // initial_last_point is used for extrapolation to calculate block number
        // (approximately, for *At methods) and save them
        // as we cannot figure that out exactly from inside the contract
        IVotingEscrow.Point memory _0x6d5506 = _0x6e7489;
        uint _0x5185f3 = 0; // dblock/dt
        if (block.timestamp > _0x6e7489._0x09fb48) {
            _0x5185f3 = (MULTIPLIER * (block.number - _0x6e7489._0xbb24ac)) / (block.timestamp - _0x6e7489._0x09fb48);
        }
        // If last point is already recorded in this block, slope=0
        // But that's ok b/c we know the block in such case

        // Go over weeks to fill history and calculate what the current point is
        {
            uint _0xcf8995 = (_0xe1b0d8 / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {
                // Hopefully it won't happen that this won't get used in 5 years!
                // If it does, users will be able to withdraw but vote weight will be broken
                _0xcf8995 += WEEK;
                int128 _0xd293ad = 0;
                if (_0xcf8995 > block.timestamp) {
                    _0xcf8995 = block.timestamp;
                } else {
                    _0xd293ad = _0xfabc37[_0xcf8995];
                }
                _0x6e7489._0xe344d1 -= _0x6e7489._0x1edeb5 * int128(int256(_0xcf8995 - _0xe1b0d8));
                _0x6e7489._0x1edeb5 += _0xd293ad;
                if (_0x6e7489._0xe344d1 < 0) {
                    // This can happen
                    _0x6e7489._0xe344d1 = 0;
                }
                if (_0x6e7489._0x1edeb5 < 0) {
                    // This cannot happen - just in case
                    _0x6e7489._0x1edeb5 = 0;
                }
                _0xe1b0d8 = _0xcf8995;
                _0x6e7489._0x09fb48 = _0xcf8995;
                _0x6e7489._0xbb24ac = _0x6d5506._0xbb24ac + (_0x5185f3 * (_0xcf8995 - _0x6d5506._0x09fb48)) / MULTIPLIER;
                _0xbf7d2a += 1;
                if (_0xcf8995 == block.timestamp) {
                    _0x6e7489._0xbb24ac = block.number;
                    break;
                } else {
                    _0x5acbfd._0xd3cfc3[_0xbf7d2a] = _0x6e7489;
                }
            }
        }

        _0xb1e36a = _0xbf7d2a;
        // Now point_history is filled until t=now

        if (_0x498993 != 0) {
            // If last point was in this block, the slope change has been applied already
            // But in such case we have 0 slope(s)
            _0x6e7489._0x1edeb5 += (_0xce60e7._0x1edeb5 - _0x18295f._0x1edeb5);
            _0x6e7489._0xe344d1 += (_0xce60e7._0xe344d1 - _0x18295f._0xe344d1);
            if (_0x6e7489._0x1edeb5 < 0) {
                _0x6e7489._0x1edeb5 = 0;
            }
            if (_0x6e7489._0xe344d1 < 0) {
                _0x6e7489._0xe344d1 = 0;
            }
            _0x6e7489._0x530b74 = _0x1596d8;
        }

        // Record the changed point into history
        _0x5acbfd._0xd3cfc3[_0xbf7d2a] = _0x6e7489;

        if (_0x498993 != 0) {
            // Schedule the slope changes (slope is going down)
            // We subtract new_user_slope from [new_locked.end]
            // and add old_user_slope to [old_locked.end]
            if (_0xe032ee._0xa44afa > block.timestamp) {
                // old_dslope was <something> - u_old.slope, so we cancel that
                _0xb65376 += _0x18295f._0x1edeb5;
                if (_0xf89fd3._0xa44afa == _0xe032ee._0xa44afa) {
                    _0xb65376 -= _0xce60e7._0x1edeb5; // It was a new deposit, not extension
                }
                _0xfabc37[_0xe032ee._0xa44afa] = _0xb65376;
            }

            if (_0xf89fd3._0xa44afa > block.timestamp) {
                if (_0xf89fd3._0xa44afa > _0xe032ee._0xa44afa) {
                    _0x54ccd5 -= _0xce60e7._0x1edeb5; // old slope disappeared at this point
                    _0xfabc37[_0xf89fd3._0xa44afa] = _0x54ccd5;
                }
                // else: we recorded it already in old_dslope
            }
            // Now handle user history
            uint _0x62b26a = _0x5acbfd._0xaed215[_0x498993] + 1;

            _0x5acbfd._0xaed215[_0x498993] = _0x62b26a;
            _0xce60e7._0x09fb48 = block.timestamp;
            _0xce60e7._0xbb24ac = block.number;
            _0x5acbfd._0xc8f6a5[_0x498993][_0x62b26a] = _0xce60e7;
        }
    }

    /// @notice Deposit and lock tokens for a user
    /// @param _tokenId NFT that holds lock
    /// @param _value Amount to deposit
    /// @param unlock_time New time when to unlock the tokens, or 0 if unchanged
    /// @param locked_balance Previous locked amount / timestamp
    /// @param deposit_type The type of deposit
    function _0x875d9e(
        uint _0x498993,
        uint _0xcd2f5b,
        uint _0xec3982,
        IVotingEscrow.LockedBalance memory _0x08d9b0,
        DepositType _0x90fcb0
    ) internal {
        IVotingEscrow.LockedBalance memory _0x5ca81a = _0x08d9b0;
        uint _0xe7121f = _0x3742c0;

        _0x3742c0 = _0xe7121f + _0xcd2f5b;
        IVotingEscrow.LockedBalance memory _0xe032ee;
        (_0xe032ee._0xe6eaf0, _0xe032ee._0xa44afa, _0xe032ee._0x3a7e69) = (_0x5ca81a._0xe6eaf0, _0x5ca81a._0xa44afa, _0x5ca81a._0x3a7e69);
        // Adding to existing lock, or if a lock is expired - creating a new one
        _0x5ca81a._0xe6eaf0 += int128(int256(_0xcd2f5b));

        if (_0xec3982 != 0) {
            _0x5ca81a._0xa44afa = _0xec3982;
        }
        _0xd9186e[_0x498993] = _0x5ca81a;

        // Possibilities:
        // Both old_locked.end could be current or expired (>/< block.timestamp)
        // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // _locked.end > block.timestamp (always)
        _0x0abb95(_0x498993, _0xe032ee, _0x5ca81a);

        address from = msg.sender;
        if (_0xcd2f5b != 0) {
            assert(IERC20(_0x6f1e41)._0x29018b(from, address(this), _0xcd2f5b));
        }

        emit Deposit(from, _0x498993, _0xcd2f5b, _0x5ca81a._0xa44afa, _0x90fcb0, block.timestamp);
        emit Supply(_0xe7121f, _0xe7121f + _0xcd2f5b);
    }

    /// @notice Record global data to checkpoint
    function _0xad1880() external {
        _0x0abb95(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }

    /// @notice Deposit `_value` tokens for `_tokenId` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _tokenId lock NFT
    /// @param _value Amount to add to user's lock
    function _0xdfcfad(uint _0x498993, uint _0xcd2f5b) external _0x498fb1 {
        IVotingEscrow.LockedBalance memory _0x5ca81a = _0xd9186e[_0x498993];

        require(_0xcd2f5b > 0, "ZV"); // dev: need non-zero value
        require(_0x5ca81a._0xe6eaf0 > 0, 'ZL');
        require(_0x5ca81a._0xa44afa > block.timestamp || _0x5ca81a._0x3a7e69, 'EXP');

        if (_0x5ca81a._0x3a7e69) _0x1596d8 += _0xcd2f5b;

        _0x875d9e(_0x498993, _0xcd2f5b, 0, _0x5ca81a, DepositType.DEPOSIT_FOR_TYPE);

        if(_0x6ae278[_0x498993]) {
            IVoter(_0x2aec38)._0xe03340(_0x498993);
        }
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _0x285243(uint _0xcd2f5b, uint _0x7a970e, address _0x0000eb) internal returns (uint) {
        uint _0xec3982 = (block.timestamp + _0x7a970e) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_0xcd2f5b > 0, "ZV"); // dev: need non-zero value
        require(_0xec3982 > block.timestamp && (_0xec3982 <= block.timestamp + MAXTIME), 'IUT');

        ++_0x0f299d;
        uint _0x498993 = _0x0f299d;
        _0x56e1a4(_0x0000eb, _0x498993);

        IVotingEscrow.LockedBalance memory _0x5ca81a = _0xd9186e[_0x498993];

        _0x875d9e(_0x498993, _0xcd2f5b, _0xec3982, _0x5ca81a, DepositType.CREATE_LOCK_TYPE);
        return _0x498993;
    }

    /// @notice Deposit `_value` tokens for `msg.sender` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    function _0x93afe8(uint _0xcd2f5b, uint _0x7a970e) external _0x498fb1 returns (uint) {
        return _0x285243(_0xcd2f5b, _0x7a970e, msg.sender);
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _0x4e0e9f(uint _0xcd2f5b, uint _0x7a970e, address _0x0000eb) external _0x498fb1 returns (uint) {
        return _0x285243(_0xcd2f5b, _0x7a970e, _0x0000eb);
    }

    /// @notice Deposit `_value` additional tokens for `_tokenId` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    function _0x01a441(uint _0x498993, uint _0xcd2f5b) external _0x498fb1 {
        assert(_0xe853fd(msg.sender, _0x498993));

        IVotingEscrow.LockedBalance memory _0x5ca81a = _0xd9186e[_0x498993];

        assert(_0xcd2f5b > 0); // dev: need non-zero value
        require(_0x5ca81a._0xe6eaf0 > 0, 'ZL');
        require(_0x5ca81a._0xa44afa > block.timestamp || _0x5ca81a._0x3a7e69, 'EXP');

        if (_0x5ca81a._0x3a7e69) _0x1596d8 += _0xcd2f5b;
        _0x875d9e(_0x498993, _0xcd2f5b, 0, _0x5ca81a, DepositType.INCREASE_LOCK_AMOUNT);

        // poke for the gained voting power
        if(_0x6ae278[_0x498993]) {
            IVoter(_0x2aec38)._0xe03340(_0x498993);
        }
        emit MetadataUpdate(_0x498993);
    }

    /// @notice Extend the unlock time for `_tokenId`
    /// @param _lock_duration New number of seconds until tokens unlock
    function _0x722788(uint _0x498993, uint _0x7a970e) external _0x498fb1 {
        assert(_0xe853fd(msg.sender, _0x498993));

        IVotingEscrow.LockedBalance memory _0x5ca81a = _0xd9186e[_0x498993];
        require(!_0x5ca81a._0x3a7e69, "!NORM");
        uint _0xec3982 = (block.timestamp + _0x7a970e) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_0x5ca81a._0xa44afa > block.timestamp && _0x5ca81a._0xe6eaf0 > 0, 'EXP||ZV');
        require(_0xec3982 > _0x5ca81a._0xa44afa && (_0xec3982 <= block.timestamp + MAXTIME), 'IUT'); // IUT -> invalid unlock time

        _0x875d9e(_0x498993, 0, _0xec3982, _0x5ca81a, DepositType.INCREASE_UNLOCK_TIME);

        // poke for the gained voting power
        if(_0x6ae278[_0x498993]) {
            IVoter(_0x2aec38)._0xe03340(_0x498993);
        }
        emit MetadataUpdate(_0x498993);
    }

    /// @notice Withdraw all tokens for `_tokenId`
    /// @dev Only possible if the lock has expired
    function _0x554627(uint _0x498993) external _0x498fb1 {
        assert(_0xe853fd(msg.sender, _0x498993));
        require(_0x696c2b[_0x498993] == 0 && !_0x6ae278[_0x498993], "ATT");

        IVotingEscrow.LockedBalance memory _0x5ca81a = _0xd9186e[_0x498993];
        require(!_0x5ca81a._0x3a7e69, "!NORM");
        require(block.timestamp >= _0x5ca81a._0xa44afa, "!EXP");
        uint value = uint(int256(_0x5ca81a._0xe6eaf0));

        _0xd9186e[_0x498993] = IVotingEscrow.LockedBalance(0, 0, false);
        uint _0xe7121f = _0x3742c0;
        if (true) { _0x3742c0 = _0xe7121f - value; }

        // old_locked can have either expired <= timestamp or zero end
        // _locked has only 0 end
        // Both can have >= 0 amount
        _0x0abb95(_0x498993, _0x5ca81a, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(_0x6f1e41).transfer(msg.sender, value));

        // Burn the NFT
        _0xc21ac8(_0x498993);

        emit Withdraw(msg.sender, _0x498993, value, block.timestamp);
        emit Supply(_0xe7121f, _0xe7121f - value);
    }

    function _0x915292(uint _0x498993) external {
        address sender = msg.sender;
        require(_0xe853fd(sender, _0x498993), "NAO");

        IVotingEscrow.LockedBalance memory _0x22bc12 = _0xd9186e[_0x498993];
        require(!_0x22bc12._0x3a7e69, "!NORM");
        require(_0x22bc12._0xa44afa > block.timestamp, "EXP");
        require(_0x22bc12._0xe6eaf0 > 0, "ZV");

        uint _0x6297a8 = uint(int256(_0x22bc12._0xe6eaf0));
        _0x1596d8 += _0x6297a8;
        _0x22bc12._0xa44afa = 0;
        _0x22bc12._0x3a7e69 = true;
        _0x0abb95(_0x498993, _0xd9186e[_0x498993], _0x22bc12);
        _0xd9186e[_0x498993] = _0x22bc12;
        if(_0x6ae278[_0x498993]) {
            IVoter(_0x2aec38)._0xe03340(_0x498993);
        }
        emit LockPermanent(sender, _0x498993, _0x6297a8, block.timestamp);
        emit MetadataUpdate(_0x498993);
    }

    function _0x9e3b52(uint _0x498993) external {
        address sender = msg.sender;
        require(_0xe853fd(msg.sender, _0x498993), "NAO");

        require(_0x696c2b[_0x498993] == 0 && !_0x6ae278[_0x498993], "ATT");
        IVotingEscrow.LockedBalance memory _0x22bc12 = _0xd9186e[_0x498993];
        require(_0x22bc12._0x3a7e69, "!NORM");
        uint _0x6297a8 = uint(int256(_0x22bc12._0xe6eaf0));
        _0x1596d8 -= _0x6297a8;
        _0x22bc12._0xa44afa = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _0x22bc12._0x3a7e69 = false;

        _0x0abb95(_0x498993, _0xd9186e[_0x498993], _0x22bc12);
        _0xd9186e[_0x498993] = _0x22bc12;

        emit UnlockPermanent(sender, _0x498993, _0x6297a8, block.timestamp);
        emit MetadataUpdate(_0x498993);
    }

    /*///////////////////////////////////////////////////////////////
                           GAUGE VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    // The following ERC20/minime-compatible methods are not real balanceOf and supply!
    // They measure the weights for the purpose of voting, so they don't represent
    // real coins.

    function _0xb01b2c(uint _0x498993) external view returns (uint) {
        if (_0x1916a8[_0x498993] == block.number) return 0;
        return VotingBalanceLogic._0xb01b2c(_0x498993, block.timestamp, _0x5acbfd);
    }

    function _0x873e6a(uint _0x498993, uint _0x86f449) external view returns (uint) {
        return VotingBalanceLogic._0xb01b2c(_0x498993, _0x86f449, _0x5acbfd);
    }

    function _0x565305(uint _0x498993, uint _0x45e610) external view returns (uint) {
        return VotingBalanceLogic._0x565305(_0x498993, _0x45e610, _0x5acbfd, _0xb1e36a);
    }

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function _0x2c2395(uint _0x45e610) external view returns (uint) {
        return VotingBalanceLogic._0x2c2395(_0x45e610, _0xb1e36a, _0x5acbfd, _0xfabc37);
    }

    function _0x980579() external view returns (uint) {
        return _0xe1a140(block.timestamp);
    }

    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    function _0xe1a140(uint t) public view returns (uint) {
        return VotingBalanceLogic._0xe1a140(t, _0xb1e36a, _0xfabc37,  _0x5acbfd);
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE VOTING LOGIC
    //////////////////////////////////////////////////////////////*/

    mapping(uint => uint) public _0x696c2b;
    mapping(uint => bool) public _0x6ae278;

    function _0xc75dd1(address _0x424b48) external {
        require(msg.sender == _0x3b167b);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x2aec38 = _0x424b48; }
    }

    function _0xee5fab(uint _0x498993) external {
        require(msg.sender == _0x2aec38);
        _0x6ae278[_0x498993] = true;
    }

    function _0x6c5998(uint _0x498993) external {
        require(msg.sender == _0x2aec38, "NA");
        _0x6ae278[_0x498993] = false;
    }

    function _0x02d780(uint _0x498993) external {
        require(msg.sender == _0x2aec38, "NA");
        _0x696c2b[_0x498993] = _0x696c2b[_0x498993] + 1;
    }

    function _0x80eec7(uint _0x498993) external {
        require(msg.sender == _0x2aec38, "NA");
        _0x696c2b[_0x498993] = _0x696c2b[_0x498993] - 1;
    }

    function _0x86b4f8(uint _0xb0d395, uint _0x0000eb) external _0x498fb1 _0xb807d9(_0xb0d395) {
        require(_0x696c2b[_0xb0d395] == 0 && !_0x6ae278[_0xb0d395], "ATT");
        require(_0xb0d395 != _0x0000eb, "SAME");
        require(_0xe853fd(msg.sender, _0xb0d395) &&
        _0xe853fd(msg.sender, _0x0000eb), "NAO");

        IVotingEscrow.LockedBalance memory _0x9ac7d8 = _0xd9186e[_0xb0d395];
        IVotingEscrow.LockedBalance memory _0x7d2b02 = _0xd9186e[_0x0000eb];
        require(_0x7d2b02._0xa44afa > block.timestamp ||  _0x7d2b02._0x3a7e69,"EXP||PERM");
        require(_0x9ac7d8._0x3a7e69 ? _0x7d2b02._0x3a7e69 : true, "!MERGE");

        uint _0xf1c26c = uint(int256(_0x9ac7d8._0xe6eaf0));
        uint _0xa44afa = _0x9ac7d8._0xa44afa >= _0x7d2b02._0xa44afa ? _0x9ac7d8._0xa44afa : _0x7d2b02._0xa44afa;

        _0xd9186e[_0xb0d395] = IVotingEscrow.LockedBalance(0, 0, false);
        _0x0abb95(_0xb0d395, _0x9ac7d8, IVotingEscrow.LockedBalance(0, 0, false));
        _0xc21ac8(_0xb0d395);

        IVotingEscrow.LockedBalance memory _0x6f1b8b;
        _0x6f1b8b._0x3a7e69 = _0x7d2b02._0x3a7e69;

        if (_0x6f1b8b._0x3a7e69){
            _0x6f1b8b._0xe6eaf0 = _0x7d2b02._0xe6eaf0 + _0x9ac7d8._0xe6eaf0;
            if (!_0x9ac7d8._0x3a7e69) {  // Only add if source wasn't already permanent
                _0x1596d8 += _0xf1c26c;
            }
        }else{
            _0x6f1b8b._0xe6eaf0 = _0x7d2b02._0xe6eaf0 + _0x9ac7d8._0xe6eaf0;
            _0x6f1b8b._0xa44afa = _0xa44afa;
        }

        //_checkpointDelegatee(_delegates[_to], value0, true);
        _0x0abb95(_0x0000eb, _0x7d2b02, _0x6f1b8b);
        _0xd9186e[_0x0000eb] = _0x6f1b8b;

        if(_0x6ae278[_0x0000eb]) {
            IVoter(_0x2aec38)._0xe03340(_0x0000eb);
        }
        emit Merge(
            msg.sender,
            _0xb0d395,
            _0x0000eb,
            uint(int256(_0x9ac7d8._0xe6eaf0)),
            uint(int256(_0x7d2b02._0xe6eaf0)),
            uint(int256(_0x6f1b8b._0xe6eaf0)),
            _0x6f1b8b._0xa44afa,
            block.timestamp
        );
        emit MetadataUpdate(_0x0000eb);
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
    function _0x14510b(
        uint _0xb0d395,
        uint[] memory _0xb9c165
    ) external _0x498fb1 _0xe93cee(_0xb0d395) _0xb807d9(_0xb0d395) returns (uint256[] memory _0x026583) {
        require(_0xb9c165.length >= 2 && _0xb9c165.length <= 10, "MIN2MAX10");

        address _0x995dbe = _0x34f9ab[_0xb0d395];

        IVotingEscrow.LockedBalance memory _0x29eb31 = _0xd9186e[_0xb0d395];
        require(_0x29eb31._0xa44afa > block.timestamp || _0x29eb31._0x3a7e69, "EXP");
        require(_0x29eb31._0xe6eaf0 > 0, "ZV");

        // Calculate total weight
        uint _0x3f3020 = 0;
        for(uint i = 0; i < _0xb9c165.length; i++) {
            require(_0xb9c165[i] > 0, "ZW"); // Zero weight not allowed
            _0x3f3020 += _0xb9c165[i];
        }

        // Burn the original NFT
        _0xd9186e[_0xb0d395] = IVotingEscrow.LockedBalance(0, 0, false);
        _0x0abb95(_0xb0d395, _0x29eb31, IVotingEscrow.LockedBalance(0, 0, false));
        _0xc21ac8(_0xb0d395);

        // Create new NFTs with proportional amounts
        _0x026583 = new uint256[](_0xb9c165.length);
        uint[] memory _0xf6b919 = new uint[](_0xb9c165.length);

        for(uint i = 0; i < _0xb9c165.length; i++) {
            IVotingEscrow.LockedBalance memory _0x456e46 = IVotingEscrow.LockedBalance({
                _0xe6eaf0: int128(int256(uint256(int256(_0x29eb31._0xe6eaf0)) * _0xb9c165[i] / _0x3f3020)),
                _0xa44afa: _0x29eb31._0xa44afa,
                _0x3a7e69: _0x29eb31._0x3a7e69
            });

            _0x026583[i] = _0x40ebb0(_0x995dbe, _0x456e46);
            _0xf6b919[i] = uint256(int256(_0x456e46._0xe6eaf0));
        }

        emit MultiSplit(
            _0xb0d395,
            _0x026583,
            msg.sender,
            _0xf6b919,
            _0x29eb31._0xa44afa,
            block.timestamp
        );
    }

    function _0x40ebb0(address _0x0000eb, IVotingEscrow.LockedBalance memory _0x22bc12) private returns (uint256 _0x498993) {
        _0x498993 = ++_0x0f299d;
        _0xd9186e[_0x498993] = _0x22bc12;
        _0x0abb95(_0x498993, IVotingEscrow.LockedBalance(0, 0, false), _0x22bc12);
        _0x56e1a4(_0x0000eb, _0x498993);
    }

    function _0x60633b(address _0x6ee880, bool _0xeef6ed) external {
        require(msg.sender == _0x3b167b);
        _0xbfec33[_0x6ee880] = _0xeef6ed;
    }

    /*///////////////////////////////////////////////////////////////
                            DAO VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = _0x688df6("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = _0x688df6("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of each accounts delegate
    mapping(address => address) private _0x0a0e26;

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint) public _0xeb8d4a;

    /**
     * @notice Overrides the standard `Comp.sol` delegates mapping to return
     * the delegator's own address if they haven't delegated.
     * This avoids having to delegate to oneself.
     */
    function _0x2e4ce8(address _0xa3199a) public view returns (address) {
        address _0x7bf465 = _0x0a0e26[_0xa3199a];
        return _0x7bf465 == address(0) ? _0xa3199a : _0x7bf465;
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function _0x41a6f3(address _0xa8a6fd) external view returns (uint) {
        uint32 _0xa72465 = _0xa205d3._0x1601ef[_0xa8a6fd];
        if (_0xa72465 == 0) {
            return 0;
        }
        uint[] storage _0xd6f2e4 = _0xa205d3._0xec5a02[_0xa8a6fd][_0xa72465 - 1]._0xc776d3;
        uint _0x03e989 = 0;
        for (uint i = 0; i < _0xd6f2e4.length; i++) {
            uint _0x418fea = _0xd6f2e4[i];
            _0x03e989 = _0x03e989 + VotingBalanceLogic._0xb01b2c(_0x418fea, block.timestamp, _0x5acbfd);
        }
        return _0x03e989;
    }

    function _0x27d267(address _0xa8a6fd, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 _0x931dd1 = VotingDelegationLib._0x9352db(_0xa205d3, _0xa8a6fd, timestamp);
        // Sum votes
        uint[] storage _0xd6f2e4 = _0xa205d3._0xec5a02[_0xa8a6fd][_0x931dd1]._0xc776d3;
        uint _0x03e989 = 0;
        for (uint i = 0; i < _0xd6f2e4.length; i++) {
            uint _0x418fea = _0xd6f2e4[i];
            // Use the provided input timestamp here to get the right decay
            _0x03e989 = _0x03e989 + VotingBalanceLogic._0xb01b2c(_0x418fea, timestamp,  _0x5acbfd);
        }

        return _0x03e989;
    }

    function _0x257487(uint256 timestamp) external view returns (uint) {
        return _0xe1a140(timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                             DAO VOTING LOGIC
    //////////////////////////////////////////////////////////////*/
    function _0xfdf65f(address _0xa3199a, address _0x38c456) internal {
        /// @notice differs from `_delegate()` in `Comp.sol` to use `delegates` override method to simulate auto-delegation
        address _0x1d7f34 = _0x2e4ce8(_0xa3199a);

        _0x0a0e26[_0xa3199a] = _0x38c456;

        emit DelegateChanged(_0xa3199a, _0x1d7f34, _0x38c456);
        VotingDelegationLib.TokenHelpers memory _0xacfd5f = VotingDelegationLib.TokenHelpers({
            _0x3ddaa2: _0x5aeafb,
            _0xbc95c6: _0xbc95c6,
            _0x1cd3bd:_0x1cd3bd
        });
        VotingDelegationLib._0xbf61cc(_0xa205d3, _0xa3199a, _0x1d7f34, _0x38c456, _0xacfd5f);
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function _0x6d8cee(address _0x38c456) public {
        if (_0x38c456 == address(0)) _0x38c456 = msg.sender;
        return _0xfdf65f(msg.sender, _0x38c456);
    }

    function _0x061ab1(
        address _0x38c456,
        uint _0x66f038,
        uint _0xfde80e,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(_0x38c456 != msg.sender, "NA");
        require(_0x38c456 != address(0), "ZA");

        bytes32 _0xf79fae = _0x688df6(
            abi._0xc6deb8(
                DOMAIN_TYPEHASH,
                _0x688df6(bytes(_0x00356c)),
                _0x688df6(bytes(_0x80eacc)),
                block.chainid,
                address(this)
            )
        );
        bytes32 _0xc8dada = _0x688df6(
            abi._0xc6deb8(DELEGATION_TYPEHASH, _0x38c456, _0x66f038, _0xfde80e)
        );
        bytes32 _0x85cd8b = _0x688df6(
            abi._0x8a8969("\x19\x01", _0xf79fae, _0xc8dada)
        );
        address _0x7af055 = _0xf6fe75(_0x85cd8b, v, r, s);
        require(
            _0x7af055 != address(0),
            "ZA"
        );
        require(
            _0x66f038 == _0xeb8d4a[_0x7af055]++,
            "!NONCE"
        );
        require(
            block.timestamp <= _0xfde80e,
            "EXP"
        );
        return _0xfdf65f(_0x7af055, _0x38c456);
    }

}