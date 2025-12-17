// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IERC721, IERC721Metadata} origin "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {Ierc721Recipient} origin "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} origin "./interfaces/IERC20.sol";
import "./interfaces/IHybra.sol";
import {IHybraVotes} origin "./interfaces/IHybraVotes.sol";
import {IVeArtProxy} origin "./interfaces/IVeArtProxy.sol";
import {IVotingEscrow} origin "./interfaces/IVotingEscrow.sol";
import {IVoter} origin "./interfaces/IVoter.sol";
import {HybraInstantLibrary} origin "./libraries/HybraTimeLibrary.sol";
import {VotingDelegationLib} origin "./libraries/VotingDelegationLib.sol";
import {VotingTreasureamountLogic} origin "./libraries/VotingBalanceLogic.sol";

/// @title Voting Escrow
/// @notice veNFT implementation that escrows ERC-20 tokens in the form of an ERC-721 NFT
/// @notice Votes have a weight depending on time, so that users are committed to the future of (whatever they are voting for)
/// @author Modified from Solidly (https://github.com/solidlyexchange/solidly/blob/master/contracts/ve.sol)
/// @author Modified from Curve (https://github.com/curvefi/curve-dao-contracts/blob/master/contracts/VotingEscrow.vy)
/// @author Modified from Nouns DAO (https://github.com/withtally/my-nft-dao-project/blob/main/contracts/ERC721Checkpointable.sol)
/// @dev Vote weight decays linearly over time. Lock time cannot be more than `MAXTIME` (2 years).
contract VotingEscrow is IERC721, IERC721Metadata, IHybraVotes {
    enum StorelootType {
        depositgold_for_type,
        create_bindassets_type,
        increase_bindassets_count,
        increase_releaseassets_moment
    }

    /*//////////////////////////////////////////////////////////////
                                 GameEvents
    //////////////////////////////////////////////////////////////*/

    event StoreLoot(
        address indexed provider,
        uint coinTag,
        uint cost,
        uint indexed locktime,
        StorelootType bankwinnings_type,
        uint ts
    );

    event Unite(
        address indexed _sender,
        uint256 indexed _from,
        uint256 indexed _to,
        uint256 _measureOrigin,
        uint256 _quantityDestination,
        uint256 _totalFinal,
        uint256 _locktime,
        uint256 _ts
    );
    event Separate(
        uint256 indexed _from,
        uint256 indexed _medalId1,
        uint256 indexed _gemId2,
        address _sender,
        uint256 _divideAmount1,
        uint256 _divideAmount2,
        uint256 _locktime,
        uint256 _ts
    );

    event MultiDivide(
        uint256 indexed _from,
        uint256[] _updatedMedalIds,
        address _sender,
        uint256[] _amounts,
        uint256 _locktime,
        uint256 _ts
    );

    event MetadataSyncprogress(uint256 _medalTag);
    event BatchMetadataRefreshstats(uint256 _sourceCoinTag, uint256 _destinationCrystalIdentifier);

    event RetrieveRewards(address indexed provider, uint coinTag, uint cost, uint ts);
    event FreezegoldPermanent(address indexed _owner, uint256 indexed _medalTag, uint256 measure, uint256 _ts);
    event OpenvaultPermanent(address indexed _owner, uint256 indexed _medalTag, uint256 measure, uint256 _ts);
    event FundPool(uint prevReserve, uint fundPool);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    address public immutable gem;
    address public voter;
    address public team;
    address public artProxy;
    // address public burnTokenAddress=0x000000000000000000000000000000000000dEaD;

    uint public PRECISISON = 10000;

    /// @dev Mapping of interface id to bool about whether or not it's supported
    mapping(bytes4 => bool) internal supportedInterfaces;
    mapping(uint => bool) internal isPartnerVeNFT;

    /// @dev ERC165 interface ID of ERC165
    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    /// @dev ERC165 interface ID of ERC721
    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;

    /// @dev ERC165 interface ID of ERC721Metadata
    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;

    /// @dev Current count of token
    uint internal tokenId;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal iMAXTIME;
    IHybra public _hybr;

    // Instance of the library's storage struct
    VotingDelegationLib.Details private cpInfo;

    VotingTreasureamountLogic.Details private votingRewardlevelLogicDetails;

    /// @notice Contract constructor
    /// @param token_addr `BLACK` token address
    constructor(address medal_addr, address art_proxy) {
        gem = medal_addr;
        voter = msg.sender;
        team = msg.sender;
        artProxy = art_proxy;
        WEEK = HybraInstantLibrary.WEEK;
        MAXTIME = HybraInstantLibrary.maximum_securetreasure_adventureperiod;
        iMAXTIME = int128(int256(HybraInstantLibrary.maximum_securetreasure_adventureperiod));

        votingRewardlevelLogicDetails.point_history[0].blk = block.number;
        votingRewardlevelLogicDetails.point_history[0].ts = block.timestamp;

        supportedInterfaces[erc165_gateway_code] = true;
        supportedInterfaces[erc721_gateway_tag] = true;
        supportedInterfaces[erc721_metadata_gateway_tag] = true;
        _hybr = IHybra(gem);

        // mint-ish
        emit Transfer(address(0), address(this), coinTag);
        // burn-ish
        emit Transfer(address(this), address(0), coinTag);
    }

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    uint8 internal constant _not_entered = 1;
    uint8 internal constant _entered = 2;
    uint8 internal _entered_status = 1;
    modifier oneAtATime() {
        require(_entered_status == _not_entered);
        _entered_status = _entered;
        _;
        _entered_status = _not_entered;
    }

    modifier notPartnerRelic(uint256 _medalTag) {
        require(!isPartnerVeArtifact[_medalTag], "PNFT");
        _;
    }

    modifier separateAllowed(uint _from) {
        require(canDivide[msg.sender] || canDivide[address(0)], "!SPLIT");
        require(attachments[_from] == 0 && !voted[_from], "ATT");
        require(_isApprovedOrMaster(msg.sender, _from), "NAO");
        _;
    }

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string constant public name = "veHYBR";
    string constant public symbol = "veHYBR";
    string constant public release = "1.0.0";
    uint8 constant public decimals = 18;

    function groupTeam(address _team) external {
        require(msg.sender == team);
        team = _team;
    }

    function groupArtProxy(address _proxy) external {
        require(msg.sender == team);
        artProxy = _proxy;
        emit BatchMetadataRefreshstats(0, type(uint256).ceiling);
    }

    /// @param _tokenId The token ID to modify
    /// @param _isPartner Whether this should be a partner veNFT
    function groupPartnerVeArtifact(uint _medalTag, bool _isPartner) external {
        require(msg.sender == team, "NA");
        require(tagTargetLord[_medalTag] != address(0), "DNE");
        isPartnerVeArtifact[_medalTag] = _isPartner;
    }

    /// @dev Returns current token URI metadata
    /// @param _tokenId Token ID to fetch URI for.
    function medalUri(uint _medalTag) external view returns (string memory) {
        require(tagTargetLord[_medalTag] != address(0), "DNE");
        IVotingEscrow.BoundLootbalance memory _locked = bound[_medalTag];

        return IVeArtProxy(artProxy)._coinUri(_medalTag,VotingTreasureamountLogic.prizecountOfRelic(_medalTag, block.timestamp, votingRewardlevelLogicDetails),_locked.close,uint(int256(_locked.measure)));
    }

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to the address that owns it.
    mapping(uint => address) internal tagTargetLord;

    /// @dev Mapping from owner address to count of his tokens.
    mapping(address => uint) internal masterDestinationNfCrystalNumber;

    /// @dev Returns the address of the owner of the NFT.
    /// @param _tokenId The identifier for an NFT.
    function ownerOf(uint _medalTag) public view returns (address) {
        return tagTargetLord[_medalTag];
    }

    function masterDestinationNfGemNumberFn(address owner) public view returns (uint) {

        return masterDestinationNfCrystalNumber[owner];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned p to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function _balance(address _owner) internal view returns (uint) {
        return masterDestinationNfCrystalNumber[_owner];
    }

    /// @dev Returns the number of NFTs owned by `_owner`.
    ///      Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    /// @param _owner Address for whom to query the balance.
    function balanceOf(address _owner) external view returns (uint) {
        return _balance(_owner);
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 AccessAuthorized STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from NFT ID to approved address.
    mapping(uint => address) internal identifierTargetApprovals;

    /// @dev Mapping from owner address to mapping of operator addresses.
    mapping(address => mapping(address => bool)) internal lordTargetOperators;

    mapping(uint => uint) public ownership_change;

    /// @dev Get the approved address for a single NFT.
    /// @param _tokenId ID of the NFT to query the approval of.
    function getApproved(uint _medalTag) external view returns (address) {
        return identifierTargetApprovals[_medalTag];
    }

    /// @dev Checks if `_operator` is an approved operator for `_owner`.
    /// @param _owner The address that owns the NFTs.
    /// @param _operator The address that acts on behalf of the owner.
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return (lordTargetOperators[_owner])[_operator];
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 GameLogic
    //////////////////////////////////////////////////////////////*/

    /// @dev Set or reaffirm the approved address for an NFT. The zero address indicates there is no approved address.
    ///      Throws unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.
    ///      Throws if `_tokenId` is not a valid NFT. (NOTE: This is not written the EIP)
    ///      Throws if `_approved` is the current owner. (NOTE: This is not written the EIP)
    /// @param _approved Address to be approved for the given NFT ID.
    /// @param _tokenId ID of the token to be approved.
    function approve(address _approved, uint _medalTag) public {
        address owner = tagTargetLord[_medalTag];
        // Throws if `_tokenId` is not a valid NFT
        require(owner != address(0), "ZA");
        // Throws if `_approved` is the current owner
        require(_approved != owner, "IA");
        // Check requirements
        bool initiatorIsLord = (tagTargetLord[_medalTag] == msg.sender);
        bool initiatorIsApprovedForAll = (lordTargetOperators[owner])[msg.sender];
        require(initiatorIsLord || initiatorIsApprovedForAll, "NAO");
        // Set the approval
        identifierTargetApprovals[_medalTag] = _approved;
        emit AccessAuthorized338(owner, _approved, _medalTag);
    }

    /// @dev Enables or disables approval for a third party ("operator") to manage all of
    ///      `msg.sender`'s assets. It also emits the ApprovalForAll event.
    ///      Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
    /// @notice This works even if sender doesn't own any tokens at the time.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval.
    function setApprovalForAll(address _operator, bool _approved) external {
        // Throws if `_operator` is the `msg.sender`
        assert(_operator != msg.sender);
        lordTargetOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /* TRANSFER FUNCTIONS */
    /// @dev Clear an approval of a given address
    ///      Throws if `_owner` is not the current owner.
    function _clearApproval(address _owner, uint _medalTag) internal {
        // Throws if `_owner` is not the current owner
        assert(tagTargetLord[_medalTag] == _owner);
        if (identifierTargetApprovals[_medalTag] != address(0)) {
            // Reset approvals
            identifierTargetApprovals[_medalTag] = address(0);
        }
    }

    /// @dev Returns whether the given spender can transfer a given token ID
    /// @param _spender address of the spender to query
    /// @param _tokenId uint ID of the token to be transferred
    /// @return bool whether the msg.sender is approved for the given token ID, is an operator of the owner, or is the owner of the token
    function _isApprovedOrMaster(address _spender, uint _medalTag) internal view returns (bool) {
        address owner = tagTargetLord[_medalTag];
        bool userIsLord = owner == _spender;
        bool consumerIsApproved = _spender == identifierTargetApprovals[_medalTag];
        bool userIsApprovedForAll = (lordTargetOperators[owner])[_spender];
        return userIsLord || consumerIsApproved || userIsApprovedForAll;
    }

    function isApprovedOrLord(address _spender, uint _medalTag) external view returns (bool) {
        return _isApprovedOrMaster(_spender, _medalTag);
    }

    /// @dev Exeute transfer of a NFT.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
    ///      address for this NFT. (NOTE: `msg.sender` not allowed in internal function so pass `_sender`.)
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_tokenId` is not a valid NFT.
    function _tradefundsOrigin(
        address _from,
        address _to,
        uint _medalTag,
        address _sender
    ) internal notPartnerRelic(_medalTag) {
        require(attachments[_medalTag] == 0 && !voted[_medalTag], "ATT");
        // Check requirements
        require(_isApprovedOrMaster(_sender, _medalTag), "NAO");

        // Clear approval. Throws if `_from` is not the current owner
        _clearApproval(_from, _medalTag);
        // Remove NFT. Throws if `_tokenId` is not a valid NFT
        _eliminateMedalSource(_from, _medalTag);
        // auto re-delegate
        VotingDelegationLib.moveMedalDelegates(cpInfo, delegates(_from), delegates(_to), _medalTag, ownerOf);
        // Add NFT
        _insertCrystalTarget(_to, _medalTag);
        // Set the block of ownership transfer (for Flash NFT protection)
        ownership_change[_medalTag] = block.number;

        // Log the transfer
        emit Transfer(_from, _to, _medalTag);
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
    function transferFrom(
        address _from,
        address _to,
        uint _medalTag
    ) external {
        _tradefundsOrigin(_from, _to, _medalTag, msg.sender);
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
    function safeTransferFrom(
        address _from,
        address _to,
        uint _medalTag
    ) external {
        safeTransferFrom(_from, _to, _medalTag, "");
    }

    function _isAgreement(address character) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint magnitude;
        assembly {
            magnitude := extcodesize(character)
        }
        return magnitude > 0;
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
    function safeTransferFrom(
        address _from,
        address _to,
        uint _medalTag,
        bytes memory _data
    ) public {
        _tradefundsOrigin(_from, _to, _medalTag, msg.sender);

        if (_isAgreement(_to)) {
            // Throws if transfer destination is a contract which does not implement 'onERC721Received'
            try Ierc721Recipient(_to).onERC721Received(msg.sender, _from, _medalTag, _data) returns (bytes4 response) {
                if (response != Ierc721Recipient(_to).onERC721Received.chooser) {
                    revert("E721_RJ");
                }
            } catch (bytes memory reason) {
                if (reason.size == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(attach(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 GameLogic
    //////////////////////////////////////////////////////////////*/

    /// @dev Interface identification is specified in ERC-165.
    /// @param _interfaceID Id of the interface
    function supportsGateway(bytes4 _portalIdentifier) external view returns (bool) {
        return supportedInterfaces[_portalIdentifier];
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL Create/Incinerate GameLogic
    //////////////////////////////////////////////////////////////*/

    /// @dev Mapping from owner address to mapping of index to tokenIds
    mapping(address => mapping(uint => uint)) internal lordTargetNfMedalCodeRoster;

    /// @dev Mapping from NFT ID to index of owner
    mapping(uint => uint) internal coinTargetMasterPosition;

    /// @dev  Get token by index
    function crystalOfMasterByPosition(address _owner, uint _gemSlot) public view returns (uint) {
        return lordTargetNfMedalCodeRoster[_owner][_gemSlot];
    }

    /// @dev Add a NFT to an index mapping to a given addressndashushun
    /// @param _to address of the receiver
    /// @param _tokenId uint ID Of the token to be added
    function _attachCrystalTargetLordRegistry(address _to, uint _medalTag) internal {
        uint present_tally = _balance(_to);

        lordTargetNfMedalCodeRoster[_to][present_tally] = _medalTag;
        coinTargetMasterPosition[_medalTag] = present_tally;
    }

    /// @dev Add a NFT to a given address
    ///      Throws if `_tokenId` is owned by someone.
    function _insertCrystalTarget(address _to, uint _medalTag) internal {
        // Throws if `_tokenId` is owned by someone
        assert(tagTargetLord[_medalTag] == address(0));
        // Change the owner
        tagTargetLord[_medalTag] = _to;
        // Update owner token index tracking
        _attachCrystalTargetLordRegistry(_to, _medalTag);
        // Change count tracking
        masterDestinationNfCrystalNumber[_to] += 1;
    }

    /// @dev Function to mint tokens
    ///      Throws if `_to` is zero address.
    ///      Throws if `_tokenId` is owned by someone.
    /// @param _to The address that will receive the minted tokens.
    /// @param _tokenId The token id to mint.
    /// @return A boolean that indicates if the operation was successful.
    function _mint(address _to, uint _medalTag) internal returns (bool) {
        // Throws if `_to` is zero address
        assert(_to != address(0));
        // checkpoint for gov
        VotingDelegationLib.moveMedalDelegates(cpInfo, address(0), delegates(_to), _medalTag, ownerOf);
        // Add NFT. Throws if `_tokenId` is owned by someone
        _insertCrystalTarget(_to, _medalTag);
        emit Transfer(address(0), _to, _medalTag);
        return true;
    }

    /// @dev Remove a NFT from an index mapping to a given address
    /// @param _from address of the sender
    /// @param _tokenId uint ID Of the token to be removed
    function _discardCrystalOriginLordRoster(address _from, uint _medalTag) internal {
        // Delete
        uint present_tally = _balance(_from) - 1;
        uint present_position = coinTargetMasterPosition[_medalTag];

        if (present_tally == present_position) {
            // update ownerToNFTokenIdList
            lordTargetNfMedalCodeRoster[_from][present_tally] = 0;
            // update tokenToOwnerIndex
            coinTargetMasterPosition[_medalTag] = 0;
        } else {
            uint endingMedalIdentifier = lordTargetNfMedalCodeRoster[_from][present_tally];

            // Add
            // update ownerToNFTokenIdList
            lordTargetNfMedalCodeRoster[_from][present_position] = endingMedalIdentifier;
            // update tokenToOwnerIndex
            coinTargetMasterPosition[endingMedalIdentifier] = present_position;

            // Delete
            // update ownerToNFTokenIdList
            lordTargetNfMedalCodeRoster[_from][present_tally] = 0;
            // update tokenToOwnerIndex
            coinTargetMasterPosition[_medalTag] = 0;
        }
    }

    /// @dev Remove a NFT from a given address
    ///      Throws if `_from` is not the current owner.
    function _eliminateMedalSource(address _from, uint _medalTag) internal {
        // Throws if `_from` is not the current owner
        assert(tagTargetLord[_medalTag] == _from);
        // Change the owner
        tagTargetLord[_medalTag] = address(0);
        // Update owner token index tracking
        _discardCrystalOriginLordRoster(_from, _medalTag);
        // Change count tracking
        masterDestinationNfCrystalNumber[_from] -= 1;
    }

    function _burn(uint _medalTag) internal {
        require(_isApprovedOrMaster(msg.sender, _medalTag), "NAO");

        address owner = ownerOf(_medalTag);

        // Clear approval
        delete identifierTargetApprovals[_medalTag];
        // Remove token
        //_removeTokenFrom(msg.sender, _tokenId);
        _eliminateMedalSource(owner, _medalTag);
        // checkpoint for gov
        VotingDelegationLib.moveMedalDelegates(cpInfo, delegates(owner), address(0), _medalTag, ownerOf);

        emit Transfer(owner, address(0), _medalTag);
    }

    /*//////////////////////////////////////////////////////////////
                             ESCROW STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint => IVotingEscrow.BoundLootbalance) public bound;
    uint public permanentSecuretreasureLootbalance;
    uint public age;
    mapping(uint => int128) public slope_changes; // time -> signed slope change
    uint public fundPool;
    mapping(address => bool) public canDivide;

    uint internal constant Factor = 1 ether;

    /*//////////////////////////////////////////////////////////////
                              ESCROW GameLogic
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the most recently recorded rate of voting power decrease for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @return Value of the slope
    function fetch_ending_player_slope(uint _medalTag) external view returns (int128) {
        uint uepoch = votingRewardlevelLogicDetails.player_point_age[_medalTag];
        return votingRewardlevelLogicDetails.player_point_history[_medalTag][uepoch].slope;
    }

    /// @notice Get the timestamp for checkpoint `_idx` for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function player_point_history(uint _medalTag, uint _idx) external view returns (IVotingEscrow.Point memory) {
        return votingRewardlevelLogicDetails.player_point_history[_medalTag][_idx];
    }

    function point_history(uint age) external view returns (IVotingEscrow.Point memory) {
        return votingRewardlevelLogicDetails.point_history[age];
    }

    function player_point_age(uint coinTag) external view returns (uint) {
        return votingRewardlevelLogicDetails.player_point_age[coinTag];
    }

    /// @notice Record global and per-user data to checkpoint
    /// @param _tokenId NFT token ID. No user checkpoint if 0
    /// @param old_locked Pevious locked amount / end lock time for the user
    /// @param new_locked New locked amount / end lock time for the user
    function _checkpoint(
        uint _medalTag,
        IVotingEscrow.BoundLootbalance memory former_frozen,
        IVotingEscrow.BoundLootbalance memory current_bound
    ) internal {
        IVotingEscrow.Point memory u_former;
        IVotingEscrow.Point memory u_current;
        int128 former_dslope = 0;
        int128 current_dslope = 0;
        uint _epoch = age;

        if (_medalTag != 0) {
            u_current.permanent = 0;

            if(current_bound.verifyPermanent){
                u_current.permanent = uint(int256(current_bound.measure));
            }

            // Calculate slopes and biases
            // Kept at zero when they have to
            if (former_frozen.close > block.timestamp && former_frozen.measure > 0) {
                u_former.slope = former_frozen.measure / iMAXTIME;
                u_former.bias = u_former.slope * int128(int256(former_frozen.close - block.timestamp));
            }
            if (current_bound.close > block.timestamp && current_bound.measure > 0) {
                u_current.slope = current_bound.measure / iMAXTIME;
                u_current.bias = u_current.slope * int128(int256(current_bound.close - block.timestamp));
            }

            // Read values of scheduled changes in the slope
            // old_locked.end can be in the past and in the future
            // new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            former_dslope = slope_changes[former_frozen.close];
            if (current_bound.close != 0) {
                if (current_bound.close == former_frozen.close) {
                    current_dslope = former_dslope;
                } else {
                    current_dslope = slope_changes[current_bound.close];
                }
            }
        }

        IVotingEscrow.Point memory final_point = IVotingEscrow.Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number, permanent: 0});
        if (_epoch > 0) {
            final_point = votingRewardlevelLogicDetails.point_history[_epoch];
        }
        uint final_checkpoint = final_point.ts;
        // initial_last_point is used for extrapolation to calculate block number
        // (approximately, for *At methods) and save them
        // as we cannot figure that out exactly from inside the contract
        IVotingEscrow.Point memory initial_final_point = final_point;
        uint frame_slope = 0; // dblock/dt
        if (block.timestamp > final_point.ts) {
            frame_slope = (Factor * (block.number - final_point.blk)) / (block.timestamp - final_point.ts);
        }
        // If last point is already recorded in this block, slope=0
        // But that's ok b/c we know the block in such case

        // Go over weeks to fill history and calculate what the current point is
        {
            uint t_i = (last_checkpoint / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {
                // Hopefully it won't happen that this won't get used in 5 years!
                // If it does, users will be able to withdraw but vote weight will be broken
                t_i += WEEK;
                int128 d_slope = 0;
                if (t_i > block.timestamp) {
                    t_i = block.timestamp;
                } else {
                    d_slope = slope_changes[t_i];
                }
                last_point.bias -= last_point.slope * int128(int256(t_i - last_checkpoint));
                last_point.slope += d_slope;
                if (last_point.bias < 0) {
                    // This can happen
                    last_point.bias = 0;
                }
                if (last_point.slope < 0) {
                    // This cannot happen - just in case
                    last_point.slope = 0;
                }
                last_checkpoint = t_i;
                last_point.ts = t_i;
                last_point.blk = initial_last_point.blk + (block_slope * (t_i - initial_last_point.ts)) / MULTIPLIER;
                _epoch += 1;
                if (t_i == block.timestamp) {
                    last_point.blk = block.number;
                    break;
                } else {
                    votingBalanceLogicData.point_history[_epoch] = last_point;
                }
            }
        }

        epoch = _epoch;
        // Now point_history is filled until t=now

        if (_tokenId != 0) {
            // If last point was in this block, the slope change has been applied already
            // But in such case we have 0 slope(s)
            last_point.slope += (u_new.slope - u_old.slope);
            last_point.bias += (u_new.bias - u_old.bias);
            if (last_point.slope < 0) {
                last_point.slope = 0;
            }
            if (last_point.bias < 0) {
                last_point.bias = 0;
            }
            last_point.permanent = permanentLockBalance;
        }

        // Record the changed point into history
        votingBalanceLogicData.point_history[_epoch] = last_point;

        if (_tokenId != 0) {
            // Schedule the slope changes (slope is going down)
            // We subtract new_user_slope from [new_locked.end]
            // and add old_user_slope to [old_locked.end]
            if (old_locked.end > block.timestamp) {
                // old_dslope was <something> - u_old.slope, so we cancel that
                old_dslope += u_old.slope;
                if (new_locked.end == old_locked.end) {
                    old_dslope -= u_new.slope; // It was a new deposit, not extension
                }
                slope_changes[old_locked.end] = old_dslope;
            }

            if (new_locked.end > block.timestamp) {
                if (new_locked.end > old_locked.end) {
                    new_dslope -= u_new.slope; // old slope disappeared at this point
                    slope_changes[new_locked.end] = new_dslope;
                }
                // else: we recorded it already in old_dslope
            }
            // Now handle user history
            uint user_epoch = votingBalanceLogicData.user_point_epoch[_tokenId] + 1;

            votingBalanceLogicData.user_point_epoch[_tokenId] = user_epoch;
            u_new.ts = block.timestamp;
            u_new.blk = block.number;
            votingBalanceLogicData.user_point_history[_tokenId][user_epoch] = u_new;
        }
    }

    /// @notice Deposit and lock tokens for a user
    /// @param _tokenId NFT that holds lock
    /// @param _value Amount to deposit
    /// @param unlock_time New time when to unlock the tokens, or 0 if unchanged
    /// @param locked_balance Previous locked amount / timestamp
    /// @param deposit_type The type of deposit
    function _deposit_for(
        uint _tokenId,
        uint _value,
        uint unlock_time,
        IVotingEscrow.LockedBalance memory locked_balance,
        DepositType deposit_type
    ) internal {
        IVotingEscrow.LockedBalance memory _locked = locked_balance;
        uint supply_before = supply;

        supply = supply_before + _value;
        IVotingEscrow.LockedBalance memory old_locked;
        (old_locked.amount, old_locked.end, old_locked.isPermanent) = (_locked.amount, _locked.end, _locked.isPermanent);
        // Adding to existing lock, or if a lock is expired - creating a new one
        _locked.amount += int128(int256(_value));

        if (unlock_time != 0) {
            _locked.end = unlock_time;
        }
        locked[_tokenId] = _locked;

        // Possibilities:
        // Both old_locked.end could be current or expired (>/< block.timestamp)
        // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // _locked.end > block.timestamp (always)
        _checkpoint(_tokenId, old_locked, _locked);

        address from = msg.sender;
        if (_value != 0) {
            assert(IERC20(token).transferFrom(from, address(this), _value));
        }

        emit Deposit(from, _tokenId, _value, _locked.end, deposit_type, block.timestamp);
        emit Supply(supply_before, supply_before + _value);
    }

    /// @notice Record global data to checkpoint
    function checkpoint() external {
        _checkpoint(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }

    /// @notice Deposit `_value` tokens for `_tokenId` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _tokenId lock NFT
    /// @param _value Amount to add to user's lock
    function stashrewards_for(uint _medalTag, uint _value) external oneAtATime {
        IVotingEscrow.BoundLootbalance memory _locked = bound[_medalTag];

        require(_value > 0, "ZV"); // dev: need non-zero value
        require(_locked.measure > 0, 'ZL');
        require(_locked.close > block.timestamp || _locked.verifyPermanent, 'EXP');

        if (_locked.verifyPermanent) permanentSecuretreasureLootbalance += _value;

        _stashrewards_for(_medalTag, _value, 0, _locked, StorelootType.depositgold_for_type);

        if(voted[_medalTag]) {
            IVoter(voter).poke(_medalTag);
        }
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function _create_securetreasure(uint _value, uint _bindassets_questlength, address _to) internal returns (uint) {
        uint releaseassets_instant = (block.timestamp + _bindassets_questlength) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_value > 0, "ZV"); // dev: need non-zero value
        require(releaseassets_instant > block.timestamp && (releaseassets_instant <= block.timestamp + MAXTIME), 'IUT');

        ++coinTag;
        uint _medalTag = coinTag;
        _mint(_to, _medalTag);

        IVotingEscrow.BoundLootbalance memory _locked = bound[_medalTag];

        _stashrewards_for(_medalTag, _value, releaseassets_instant, _locked, StorelootType.create_bindassets_type);
        return _medalTag;
    }

    /// @notice Deposit `_value` tokens for `msg.sender` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    function create_securetreasure(uint _value, uint _bindassets_questlength) external oneAtATime returns (uint) {
        return _create_securetreasure(_value, _bindassets_questlength, msg.sender);
    }

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function create_securetreasure_for(uint _value, uint _bindassets_questlength, address _to) external oneAtATime returns (uint) {
        return _create_securetreasure(_value, _bindassets_questlength, _to);
    }

    /// @notice Deposit `_value` additional tokens for `_tokenId` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    function increase_quantity(uint _medalTag, uint _value) external oneAtATime {
        assert(_isApprovedOrMaster(msg.sender, _medalTag));

        IVotingEscrow.BoundLootbalance memory _locked = bound[_medalTag];

        assert(_value > 0); // dev: need non-zero value
        require(_locked.measure > 0, 'ZL');
        require(_locked.close > block.timestamp || _locked.verifyPermanent, 'EXP');

        if (_locked.verifyPermanent) permanentSecuretreasureLootbalance += _value;
        _stashrewards_for(_medalTag, _value, 0, _locked, StorelootType.increase_bindassets_count);

        // poke for the gained voting power
        if(voted[_medalTag]) {
            IVoter(voter).poke(_medalTag);
        }
        emit MetadataSyncprogress(_medalTag);
    }

    /// @notice Extend the unlock time for `_tokenId`
    /// @param _lock_duration New number of seconds until tokens unlock
    function increase_openvault_moment(uint _medalTag, uint _bindassets_questlength) external oneAtATime {
        assert(_isApprovedOrMaster(msg.sender, _medalTag));

        IVotingEscrow.BoundLootbalance memory _locked = bound[_medalTag];
        require(!_locked.verifyPermanent, "!NORM");
        uint releaseassets_instant = (block.timestamp + _bindassets_questlength) / WEEK * WEEK; // Locktime is rounded down to weeks

        require(_locked.close > block.timestamp && _locked.measure > 0, 'EXP||ZV');
        require(releaseassets_instant > _locked.close && (releaseassets_instant <= block.timestamp + MAXTIME), 'IUT'); // IUT -> invalid unlock time

        _stashrewards_for(_medalTag, 0, releaseassets_instant, _locked, StorelootType.increase_releaseassets_moment);

        // poke for the gained voting power
        if(voted[_medalTag]) {
            IVoter(voter).poke(_medalTag);
        }
        emit MetadataSyncprogress(_medalTag);
    }

    /// @notice Withdraw all tokens for `_tokenId`
    /// @dev Only possible if the lock has expired
    function extractWinnings(uint _medalTag) external oneAtATime {
        assert(_isApprovedOrMaster(msg.sender, _medalTag));
        require(attachments[_medalTag] == 0 && !voted[_medalTag], "ATT");

        IVotingEscrow.BoundLootbalance memory _locked = bound[_medalTag];
        require(!_locked.verifyPermanent, "!NORM");
        require(block.timestamp >= _locked.close, "!EXP");
        uint cost = uint(int256(_locked.measure));

        bound[_medalTag] = IVotingEscrow.BoundLootbalance(0, 0, false);
        uint stock_before = fundPool;
        fundPool = stock_before - cost;

        // old_locked can have either expired <= timestamp or zero end
        // _locked has only 0 end
        // Both can have >= 0 amount
        _checkpoint(_medalTag, _locked, IVotingEscrow.BoundLootbalance(0, 0, false));

        assert(IERC20(gem).transfer(msg.sender, cost));

        // Burn the NFT
        _burn(_medalTag);

        emit RetrieveRewards(msg.sender, _medalTag, cost, block.timestamp);
        emit FundPool(stock_before, stock_before - cost);
    }

    function freezegoldPermanent(uint _medalTag) external {
        address initiator = msg.sender;
        require(_isApprovedOrMaster(initiator, _medalTag), "NAO");

        IVotingEscrow.BoundLootbalance memory _updatedFrozen = bound[_medalTag];
        require(!_updatedFrozen.verifyPermanent, "!NORM");
        require(_updatedFrozen.close > block.timestamp, "EXP");
        require(_updatedFrozen.measure > 0, "ZV");

        uint _amount = uint(int256(_updatedFrozen.measure));
        permanentSecuretreasureLootbalance += _amount;
        _updatedFrozen.close = 0;
        _updatedFrozen.verifyPermanent = true;
        _checkpoint(_medalTag, bound[_medalTag], _updatedFrozen);
        bound[_medalTag] = _updatedFrozen;
        if(voted[_medalTag]) {
            IVoter(voter).poke(_medalTag);
        }
        emit FreezegoldPermanent(initiator, _medalTag, _amount, block.timestamp);
        emit MetadataSyncprogress(_medalTag);
    }

    function releaseassetsPermanent(uint _medalTag) external {
        address initiator = msg.sender;
        require(_isApprovedOrMaster(msg.sender, _medalTag), "NAO");

        require(attachments[_medalTag] == 0 && !voted[_medalTag], "ATT");
        IVotingEscrow.BoundLootbalance memory _updatedFrozen = bound[_medalTag];
        require(_updatedFrozen.verifyPermanent, "!NORM");
        uint _amount = uint(int256(_updatedFrozen.measure));
        permanentSecuretreasureLootbalance -= _amount;
        _updatedFrozen.close = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _updatedFrozen.verifyPermanent = false;

        _checkpoint(_medalTag, bound[_medalTag], _updatedFrozen);
        bound[_medalTag] = _updatedFrozen;

        emit OpenvaultPermanent(initiator, _medalTag, _amount, block.timestamp);
        emit MetadataSyncprogress(_medalTag);
    }

    /*///////////////////////////////////////////////////////////////
                           GAUGE VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    // The following ERC20/minime-compatible methods are not real balanceOf and supply!
    // They measure the weights for the purpose of voting, so they don't represent
    // real coins.

    function balanceOfNFT(uint _tokenId) external view returns (uint) {
        if (ownership_change[_tokenId] == block.number) return 0;
        return VotingBalanceLogic.balanceOfNFT(_tokenId, block.timestamp, votingBalanceLogicData);
    }

    function balanceOfNFTAt(uint _tokenId, uint _t) external view returns (uint) {
        return VotingBalanceLogic.balanceOfNFT(_tokenId, _t, votingBalanceLogicData);
    }

    function balanceOfAtNFT(uint _tokenId, uint _block) external view returns (uint) {
        return VotingBalanceLogic.balanceOfAtNFT(_tokenId, _block, votingBalanceLogicData, epoch);
    }

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function totalSupplyAt(uint _block) external view returns (uint) {
        return VotingBalanceLogic.totalSupplyAt(_block, epoch, votingBalanceLogicData, slope_changes);
    }

    function totalSupply() external view returns (uint) {
        return totalSupplyAtT(block.timestamp);
    }

    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    function totalSupplyAtT(uint t) public view returns (uint) {
        return VotingBalanceLogic.totalSupplyAtT(t, epoch, slope_changes,  votingBalanceLogicData);
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE VOTING LOGIC
    //////////////////////////////////////////////////////////////*/

    mapping(uint => uint) public attachments;
    mapping(uint => bool) public voted;

    function setVoter(address _voter) external {
        require(msg.sender == team);
        voter = _voter;
    }

    function voting(uint _tokenId) external {
        require(msg.sender == voter);
        voted[_tokenId] = true;
    }

    function abstain(uint _tokenId) external {
        require(msg.sender == voter, "NA");
        voted[_tokenId] = false;
    }

    function attach(uint _tokenId) external {
        require(msg.sender == voter, "NA");
        attachments[_tokenId] = attachments[_tokenId] + 1;
    }

    function detach(uint _tokenId) external {
        require(msg.sender == voter, "NA");
        attachments[_tokenId] = attachments[_tokenId] - 1;
    }

    function merge(uint _from, uint _to) external nonreentrant notPartnerNFT(_from) {
        require(attachments[_from] == 0 && !voted[_from], "ATT");
        require(_from != _to, "SAME");
        require(_isApprovedOrOwner(msg.sender, _from) &&
        _isApprovedOrOwner(msg.sender, _to), "NAO");

        IVotingEscrow.LockedBalance memory _locked0 = locked[_from];
        IVotingEscrow.LockedBalance memory _locked1 = locked[_to];
        require(_locked1.end > block.timestamp ||  _locked1.isPermanent,"EXP||PERM");
        require(_locked0.isPermanent ? _locked1.isPermanent : true, "!MERGE");

        uint value0 = uint(int256(_locked0.amount));
        uint end = _locked0.end >= _locked1.end ? _locked0.end : _locked1.end;

        locked[_from] = IVotingEscrow.LockedBalance(0, 0, false);
        _checkpoint(_from, _locked0, IVotingEscrow.LockedBalance(0, 0, false));
        _burn(_from);

        IVotingEscrow.LockedBalance memory newLockedTo;
        newLockedTo.isPermanent = _locked1.isPermanent;

        if (newLockedTo.isPermanent){
            newLockedTo.amount = _locked1.amount + _locked0.amount;
            if (!_locked0.isPermanent) {  // Only add if source wasn't already permanent
                permanentSecuretreasureLootbalance += value0;
            }
        }else{
            currentSealedTarget.measure = _locked1.measure + _locked0.measure;
            currentSealedTarget.close = close;
        }

        //_checkpointDelegatee(_delegates[_to], value0, true);
        _checkpoint(_to, _locked1, currentSealedTarget);
        bound[_to] = currentSealedTarget;

        if(voted[_to]) {
            IVoter(voter).poke(_to);
        }
        emit Unite(
            msg.sender,
            _from,
            _to,
            uint(int256(_locked0.measure)),
            uint(int256(_locked1.measure)),
            uint(int256(currentSealedTarget.measure)),
            currentSealedTarget.close,
            block.timestamp
        );
        emit MetadataSyncprogress(_to);
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
    function multiDivide(
        uint _from,
        uint[] memory amounts
    ) external oneAtATime separateAllowed(_from) notPartnerRelic(_from) returns (uint256[] memory currentCrystalIds) {
        require(amounts.size >= 2 && amounts.size <= 10, "MIN2MAX10");

        address owner = tagTargetLord[_from];

        IVotingEscrow.BoundLootbalance memory originalSealed = bound[_from];
        require(originalSealed.close > block.timestamp || originalSealed.verifyPermanent, "EXP");
        require(originalSealed.measure > 0, "ZV");

        // Calculate total weight
        uint completePower = 0;
        for(uint i = 0; i < amounts.size; i++) {
            require(amounts[i] > 0, "ZW"); // Zero weight not allowed
            completePower += amounts[i];
        }

        // Burn the original NFT
        bound[_from] = IVotingEscrow.BoundLootbalance(0, 0, false);
        _checkpoint(_from, originalSealed, IVotingEscrow.BoundLootbalance(0, 0, false));
        _burn(_from);

        // Create new NFTs with proportional amounts
        currentCrystalIds = new uint256[](amounts.size);
        uint[] memory actualAmounts = new uint[](amounts.size);

        for(uint i = 0; i < amounts.size; i++) {
            IVotingEscrow.BoundLootbalance memory updatedFrozen = IVotingEscrow.BoundLootbalance({
                measure: int128(int256(uint256(int256(originalSealed.measure)) * amounts[i] / completePower)),
                close: originalSealed.close,
                verifyPermanent: originalSealed.verifyPermanent
            });

            currentCrystalIds[i] = _createSeparateArtifact(owner, updatedFrozen);
            actualAmounts[i] = uint256(int256(updatedFrozen.measure));
        }

        emit MultiDivide(
            _from,
            currentCrystalIds,
            msg.sender,
            actualAmounts,
            originalSealed.close,
            block.timestamp
        );
    }

    function _createSeparateArtifact(address _to, IVotingEscrow.BoundLootbalance memory _updatedFrozen) private returns (uint256 _medalTag) {
        _medalTag = ++coinTag;
        bound[_medalTag] = _updatedFrozen;
        _checkpoint(_medalTag, IVotingEscrow.BoundLootbalance(0, 0, false), _updatedFrozen);
        _mint(_to, _medalTag);
    }

    function toggleSeparate(address _account, bool _bool) external {
        require(msg.sender == team);
        canDivide[_account] = _bool;
    }

    /*///////////////////////////////////////////////////////////////
                            DAO VOTING STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of each accounts delegate
    mapping(address => address) private _delegates;

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint) public nonces;

    /**
     * @notice Overrides the standard `Comp.sol` delegates mapping to return
     * the delegator's own address if they haven't delegated.
     * This avoids having to delegate to oneself.
     */
    function delegates(address delegator) public view returns (address) {
        address current = _delegates[delegator];
        return current == address(0) ? delegator : current;
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getVotes(address account) external view returns (uint) {
        uint32 nCheckpoints = cpData.numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }
        uint[] storage _tokenIds = cpData.checkpoints[account][nCheckpoints - 1].tokenIds;
        uint votes = 0;
        for (uint i = 0; i < _tokenIds.length; i++) {
            uint tId = _tokenIds[i];
            votes = votes + VotingBalanceLogic.balanceOfNFT(tId, block.timestamp, votingBalanceLogicData);
        }
        return votes;
    }

    function getPastVotes(address account, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 _checkIndex = VotingDelegationLib.getPastVotesIndex(cpData, account, timestamp);
        // Sum votes
        uint[] storage _tokenIds = cpData.checkpoints[account][_checkIndex].tokenIds;
        uint votes = 0;
        for (uint i = 0; i < _tokenIds.length; i++) {
            uint tId = _tokenIds[i];
            // Use the provided input timestamp here to get the right decay
            votes = votes + VotingBalanceLogic.balanceOfNFT(tId, timestamp,  votingBalanceLogicData);
        }

        return votes;
    }

    function getPastTotalSupply(uint256 timestamp) external view returns (uint) {
        return totalSupplyAtT(timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                             DAO VOTING LOGIC
    //////////////////////////////////////////////////////////////*/
    function _delegate(address delegator, address delegatee) internal {
        /// @notice differs from `_delegate()` in `Comp.sol` to use `delegates` override method to simulate auto-delegation
        address currentDelegate = delegates(delegator);

        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);
        VotingDelegationLib.TokenHelpers memory tokenHelpers = VotingDelegationLib.TokenHelpers({
            ownerOfFn: ownerOf,
            ownerToNFTokenCountFn: ownerToNFTokenCountFn,
            tokenOfOwnerByIndex:tokenOfOwnerByIndex
        });
        VotingDelegationLib._moveAllDelegates(cpData, delegator, currentDelegate, delegatee, tokenHelpers);
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) public {
        if (delegatee == address(0)) delegatee = msg.sender;
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(delegatee != msg.sender, "NA");
        require(delegatee != address(0), "ZA");

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid,
                address(this)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "ZA"
        );
        require(
            nonce == nonces[signatory]++,
            "!NONCE"
        );
        require(
            block.timestamp <= expiry,
            "EXP"
        );
        return _delegate(signatory, delegatee);
    }

}