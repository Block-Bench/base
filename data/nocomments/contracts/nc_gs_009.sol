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


contract VotingEscrow is IERC721, IERC721Metadata, IHybraVotes {
    enum DepositType {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME
    }


    event Deposit(
        address indexed provider,
        uint tokenId,
        uint value,
        uint indexed locktime,
        DepositType deposit_type,
        uint ts
    );

    event Merge(
        address indexed _sender,
        uint256 indexed _from,
        uint256 indexed _to,
        uint256 _amountFrom,
        uint256 _amountTo,
        uint256 _amountFinal,
        uint256 _locktime,
        uint256 _ts
    );
    event Split(
        uint256 indexed _from,
        uint256 indexed _tokenId1,
        uint256 indexed _tokenId2,
        address _sender,
        uint256 _splitAmount1,
        uint256 _splitAmount2,
        uint256 _locktime,
        uint256 _ts
    );

    event MultiSplit(
        uint256 indexed _from,
        uint256[] _newTokenIds,
        address _sender,
        uint256[] _amounts,
        uint256 _locktime,
        uint256 _ts
    );

    event MetadataUpdate(uint256 _tokenId);
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    event Withdraw(address indexed provider, uint tokenId, uint value, uint ts);
    event LockPermanent(address indexed _owner, uint256 indexed _tokenId, uint256 amount, uint256 _ts);
    event UnlockPermanent(address indexed _owner, uint256 indexed _tokenId, uint256 amount, uint256 _ts);
    event Supply(uint prevSupply, uint supply);


    address public immutable token;
    address public voter;
    address public team;
    address public artProxy;


    uint public PRECISISON = 10000;


    mapping(bytes4 => bool) internal supportedInterfaces;
    mapping(uint => bool) internal isPartnerVeNFT;


    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;


    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;


    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;


    uint internal tokenId;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal iMAXTIME;
    IHybra public _hybr;


    VotingDelegationLib.Data private cpData;

    VotingBalanceLogic.Data private votingBalanceLogicData;


    constructor(address token_addr, address art_proxy) {
        token = token_addr;
        voter = msg.sender;
        team = msg.sender;
        artProxy = art_proxy;
        WEEK = HybraTimeLibrary.WEEK;
        MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION;
        iMAXTIME = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION));

        votingBalanceLogicData.point_history[0].blk = block.number;
        votingBalanceLogicData.point_history[0].ts = block.timestamp;

        supportedInterfaces[ERC165_INTERFACE_ID] = true;
        supportedInterfaces[ERC721_INTERFACE_ID] = true;
        supportedInterfaces[ERC721_METADATA_INTERFACE_ID] = true;
        _hybr = IHybra(token);


        emit Transfer(address(0), address(this), tokenId);

        emit Transfer(address(this), address(0), tokenId);
    }


    uint8 internal constant _not_entered = 1;
    uint8 internal constant _entered = 2;
    uint8 internal _entered_state = 1;
    modifier nonreentrant() {
        require(_entered_state == _not_entered);
        _entered_state = _entered;
        _;
        _entered_state = _not_entered;
    }

    modifier notPartnerNFT(uint256 _tokenId) {
        require(!isPartnerVeNFT[_tokenId], "PNFT");
        _;
    }

    modifier splitAllowed(uint _from) {
        require(canSplit[msg.sender] || canSplit[address(0)], "!SPLIT");
        require(attachments[_from] == 0 && !voted[_from], "ATT");
        require(_isApprovedOrOwner(msg.sender, _from), "NAO");
        _;
    }


    string constant public name = "veHYBR";
    string constant public symbol = "veHYBR";
    string constant public version = "1.0.0";
    uint8 constant public decimals = 18;

    function setTeam(address _team) external {
        require(msg.sender == team);
        team = _team;
    }

    function setArtProxy(address _proxy) external {
        require(msg.sender == team);
        artProxy = _proxy;
        emit BatchMetadataUpdate(0, type(uint256).max);
    }


    function setPartnerVeNFT(uint _tokenId, bool _isPartner) external {
        require(msg.sender == team, "NA");
        require(idToOwner[_tokenId] != address(0), "DNE");
        isPartnerVeNFT[_tokenId] = _isPartner;
    }


    function tokenURI(uint _tokenId) external view returns (string memory) {
        require(idToOwner[_tokenId] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory _locked = locked[_tokenId];

        return IVeArtProxy(artProxy)._tokenURI(_tokenId,VotingBalanceLogic.balanceOfNFT(_tokenId, block.timestamp, votingBalanceLogicData),_locked.end,uint(int256(_locked.amount)));
    }


    mapping(uint => address) internal idToOwner;


    mapping(address => uint) internal ownerToNFTokenCount;


    function ownerOf(uint _tokenId) public view returns (address) {
        return idToOwner[_tokenId];
    }

    function ownerToNFTokenCountFn(address owner) public view returns (uint) {

        return ownerToNFTokenCount[owner];
    }


    function _balance(address _owner) internal view returns (uint) {
        return ownerToNFTokenCount[_owner];
    }


    function balanceOf(address _owner) external view returns (uint) {
        return _balance(_owner);
    }


    mapping(uint => address) internal idToApprovals;


    mapping(address => mapping(address => bool)) internal ownerToOperators;

    mapping(uint => uint) public ownership_change;


    function getApproved(uint _tokenId) external view returns (address) {
        return idToApprovals[_tokenId];
    }


    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return (ownerToOperators[_owner])[_operator];
    }


    function approve(address _approved, uint _tokenId) public {
        address owner = idToOwner[_tokenId];

        require(owner != address(0), "ZA");

        require(_approved != owner, "IA");

        bool senderIsOwner = (idToOwner[_tokenId] == msg.sender);
        bool senderIsApprovedForAll = (ownerToOperators[owner])[msg.sender];
        require(senderIsOwner || senderIsApprovedForAll, "NAO");

        idToApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }


    function setApprovalForAll(address _operator, bool _approved) external {

        assert(_operator != msg.sender);
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }


    function _clearApproval(address _owner, uint _tokenId) internal {

        assert(idToOwner[_tokenId] == _owner);
        if (idToApprovals[_tokenId] != address(0)) {

            idToApprovals[_tokenId] = address(0);
        }
    }


    function _isApprovedOrOwner(address _spender, uint _tokenId) internal view returns (bool) {
        address owner = idToOwner[_tokenId];
        bool spenderIsOwner = owner == _spender;
        bool spenderIsApproved = _spender == idToApprovals[_tokenId];
        bool spenderIsApprovedForAll = (ownerToOperators[owner])[_spender];
        return spenderIsOwner || spenderIsApproved || spenderIsApprovedForAll;
    }

    function isApprovedOrOwner(address _spender, uint _tokenId) external view returns (bool) {
        return _isApprovedOrOwner(_spender, _tokenId);
    }


    function _transferFrom(
        address _from,
        address _to,
        uint _tokenId,
        address _sender
    ) internal notPartnerNFT(_tokenId) {
        require(attachments[_tokenId] == 0 && !voted[_tokenId], "ATT");

        require(_isApprovedOrOwner(_sender, _tokenId), "NAO");


        _clearApproval(_from, _tokenId);

        _removeTokenFrom(_from, _tokenId);

        VotingDelegationLib.moveTokenDelegates(cpData, delegates(_from), delegates(_to), _tokenId, ownerOf);

        _addTokenTo(_to, _tokenId);

        ownership_change[_tokenId] = block.number;


        emit Transfer(_from, _to, _tokenId);
    }


    function transferFrom(
        address _from,
        address _to,
        uint _tokenId
    ) external {
        _transferFrom(_from, _to, _tokenId, msg.sender);
    }


    function safeTransferFrom(
        address _from,
        address _to,
        uint _tokenId
    ) external {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function _isContract(address account) internal view returns (bool) {


        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }


    function safeTransferFrom(
        address _from,
        address _to,
        uint _tokenId,
        bytes memory _data
    ) public {
        _transferFrom(_from, _to, _tokenId, msg.sender);

        if (_isContract(_to)) {

            try IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) returns (bytes4 response) {
                if (response != IERC721Receiver(_to).onERC721Received.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }


    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        return supportedInterfaces[_interfaceID];
    }


    mapping(address => mapping(uint => uint)) internal ownerToNFTokenIdList;


    mapping(uint => uint) internal tokenToOwnerIndex;


    function tokenOfOwnerByIndex(address _owner, uint _tokenIndex) public view returns (uint) {
        return ownerToNFTokenIdList[_owner][_tokenIndex];
    }


    function _addTokenToOwnerList(address _to, uint _tokenId) internal {
        uint current_count = _balance(_to);

        ownerToNFTokenIdList[_to][current_count] = _tokenId;
        tokenToOwnerIndex[_tokenId] = current_count;
    }


    function _addTokenTo(address _to, uint _tokenId) internal {

        assert(idToOwner[_tokenId] == address(0));

        idToOwner[_tokenId] = _to;

        _addTokenToOwnerList(_to, _tokenId);

        ownerToNFTokenCount[_to] += 1;
    }


    function _mint(address _to, uint _tokenId) internal returns (bool) {

        assert(_to != address(0));

        VotingDelegationLib.moveTokenDelegates(cpData, address(0), delegates(_to), _tokenId, ownerOf);

        _addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
        return true;
    }


    function _removeTokenFromOwnerList(address _from, uint _tokenId) internal {

        uint current_count = _balance(_from) - 1;
        uint current_index = tokenToOwnerIndex[_tokenId];

        if (current_count == current_index) {

            ownerToNFTokenIdList[_from][current_count] = 0;

            tokenToOwnerIndex[_tokenId] = 0;
        } else {
            uint lastTokenId = ownerToNFTokenIdList[_from][current_count];


            ownerToNFTokenIdList[_from][current_index] = lastTokenId;

            tokenToOwnerIndex[lastTokenId] = current_index;


            ownerToNFTokenIdList[_from][current_count] = 0;

            tokenToOwnerIndex[_tokenId] = 0;
        }
    }


    function _removeTokenFrom(address _from, uint _tokenId) internal {

        assert(idToOwner[_tokenId] == _from);

        idToOwner[_tokenId] = address(0);

        _removeTokenFromOwnerList(_from, _tokenId);

        ownerToNFTokenCount[_from] -= 1;
    }

    function _burn(uint _tokenId) internal {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "NAO");

        address owner = ownerOf(_tokenId);


        delete idToApprovals[_tokenId];


        _removeTokenFrom(owner, _tokenId);

        VotingDelegationLib.moveTokenDelegates(cpData, delegates(owner), address(0), _tokenId, ownerOf);

        emit Transfer(owner, address(0), _tokenId);
    }


    mapping(uint => IVotingEscrow.LockedBalance) public locked;
    uint public permanentLockBalance;
    uint public epoch;
    mapping(uint => int128) public slope_changes;
    uint public supply;
    mapping(address => bool) public canSplit;

    uint internal constant MULTIPLIER = 1 ether;


    function get_last_user_slope(uint _tokenId) external view returns (int128) {
        uint uepoch = votingBalanceLogicData.user_point_epoch[_tokenId];
        return votingBalanceLogicData.user_point_history[_tokenId][uepoch].slope;
    }


    function user_point_history(uint _tokenId, uint _idx) external view returns (IVotingEscrow.Point memory) {
        return votingBalanceLogicData.user_point_history[_tokenId][_idx];
    }

    function point_history(uint epoch) external view returns (IVotingEscrow.Point memory) {
        return votingBalanceLogicData.point_history[epoch];
    }

    function user_point_epoch(uint tokenId) external view returns (uint) {
        return votingBalanceLogicData.user_point_epoch[tokenId];
    }


    function _checkpoint(
        uint _tokenId,
        IVotingEscrow.LockedBalance memory old_locked,
        IVotingEscrow.LockedBalance memory new_locked
    ) internal {
        IVotingEscrow.Point memory u_old;
        IVotingEscrow.Point memory u_new;
        int128 old_dslope = 0;
        int128 new_dslope = 0;
        uint _epoch = epoch;

        if (_tokenId != 0) {
            u_new.permanent = 0;

            if(new_locked.isPermanent){
                u_new.permanent = uint(int256(new_locked.amount));
            }


            if (old_locked.end > block.timestamp && old_locked.amount > 0) {
                u_old.slope = old_locked.amount / iMAXTIME;
                u_old.bias = u_old.slope * int128(int256(old_locked.end - block.timestamp));
            }
            if (new_locked.end > block.timestamp && new_locked.amount > 0) {
                u_new.slope = new_locked.amount / iMAXTIME;
                u_new.bias = u_new.slope * int128(int256(new_locked.end - block.timestamp));
            }


            old_dslope = slope_changes[old_locked.end];
            if (new_locked.end != 0) {
                if (new_locked.end == old_locked.end) {
                    new_dslope = old_dslope;
                } else {
                    new_dslope = slope_changes[new_locked.end];
                }
            }
        }

        IVotingEscrow.Point memory last_point = IVotingEscrow.Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number, permanent: 0});
        if (_epoch > 0) {
            last_point = votingBalanceLogicData.point_history[_epoch];
        }
        uint last_checkpoint = last_point.ts;


        IVotingEscrow.Point memory initial_last_point = last_point;
        uint block_slope = 0;
        if (block.timestamp > last_point.ts) {
            block_slope = (MULTIPLIER * (block.number - last_point.blk)) / (block.timestamp - last_point.ts);
        }


        {
            uint t_i = (last_checkpoint / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {


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

                    last_point.bias = 0;
                }
                if (last_point.slope < 0) {

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


        if (_tokenId != 0) {


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


        votingBalanceLogicData.point_history[_epoch] = last_point;

        if (_tokenId != 0) {


            if (old_locked.end > block.timestamp) {

                old_dslope += u_old.slope;
                if (new_locked.end == old_locked.end) {
                    old_dslope -= u_new.slope;
                }
                slope_changes[old_locked.end] = old_dslope;
            }

            if (new_locked.end > block.timestamp) {
                if (new_locked.end > old_locked.end) {
                    new_dslope -= u_new.slope;
                    slope_changes[new_locked.end] = new_dslope;
                }

            }

            uint user_epoch = votingBalanceLogicData.user_point_epoch[_tokenId] + 1;

            votingBalanceLogicData.user_point_epoch[_tokenId] = user_epoch;
            u_new.ts = block.timestamp;
            u_new.blk = block.number;
            votingBalanceLogicData.user_point_history[_tokenId][user_epoch] = u_new;
        }
    }


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

        _locked.amount += int128(int256(_value));

        if (unlock_time != 0) {
            _locked.end = unlock_time;
        }
        locked[_tokenId] = _locked;


        _checkpoint(_tokenId, old_locked, _locked);

        address from = msg.sender;
        if (_value != 0) {
            assert(IERC20(token).transferFrom(from, address(this), _value));
        }

        emit Deposit(from, _tokenId, _value, _locked.end, deposit_type, block.timestamp);
        emit Supply(supply_before, supply_before + _value);
    }


    function checkpoint() external {
        _checkpoint(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }


    function deposit_for(uint _tokenId, uint _value) external nonreentrant {
        IVotingEscrow.LockedBalance memory _locked = locked[_tokenId];

        require(_value > 0, "ZV");
        require(_locked.amount > 0, 'ZL');
        require(_locked.end > block.timestamp || _locked.isPermanent, 'EXP');

        if (_locked.isPermanent) permanentLockBalance += _value;

        _deposit_for(_tokenId, _value, 0, _locked, DepositType.DEPOSIT_FOR_TYPE);

        if(voted[_tokenId]) {
            IVoter(voter).poke(_tokenId);
        }
    }


    function _create_lock(uint _value, uint _lock_duration, address _to) internal returns (uint) {
        uint unlock_time = (block.timestamp + _lock_duration) / WEEK * WEEK;

        require(_value > 0, "ZV");
        require(unlock_time > block.timestamp && (unlock_time <= block.timestamp + MAXTIME), 'IUT');

        ++tokenId;
        uint _tokenId = tokenId;
        _mint(_to, _tokenId);

        IVotingEscrow.LockedBalance memory _locked = locked[_tokenId];

        _deposit_for(_tokenId, _value, unlock_time, _locked, DepositType.CREATE_LOCK_TYPE);
        return _tokenId;
    }


    function create_lock(uint _value, uint _lock_duration) external nonreentrant returns (uint) {
        return _create_lock(_value, _lock_duration, msg.sender);
    }


    function create_lock_for(uint _value, uint _lock_duration, address _to) external nonreentrant returns (uint) {
        return _create_lock(_value, _lock_duration, _to);
    }


    function increase_amount(uint _tokenId, uint _value) external nonreentrant {
        assert(_isApprovedOrOwner(msg.sender, _tokenId));

        IVotingEscrow.LockedBalance memory _locked = locked[_tokenId];

        assert(_value > 0);
        require(_locked.amount > 0, 'ZL');
        require(_locked.end > block.timestamp || _locked.isPermanent, 'EXP');

        if (_locked.isPermanent) permanentLockBalance += _value;
        _deposit_for(_tokenId, _value, 0, _locked, DepositType.INCREASE_LOCK_AMOUNT);


        if(voted[_tokenId]) {
            IVoter(voter).poke(_tokenId);
        }
        emit MetadataUpdate(_tokenId);
    }


    function increase_unlock_time(uint _tokenId, uint _lock_duration) external nonreentrant {
        assert(_isApprovedOrOwner(msg.sender, _tokenId));

        IVotingEscrow.LockedBalance memory _locked = locked[_tokenId];
        require(!_locked.isPermanent, "!NORM");
        uint unlock_time = (block.timestamp + _lock_duration) / WEEK * WEEK;

        require(_locked.end > block.timestamp && _locked.amount > 0, 'EXP||ZV');
        require(unlock_time > _locked.end && (unlock_time <= block.timestamp + MAXTIME), 'IUT');

        _deposit_for(_tokenId, 0, unlock_time, _locked, DepositType.INCREASE_UNLOCK_TIME);


        if(voted[_tokenId]) {
            IVoter(voter).poke(_tokenId);
        }
        emit MetadataUpdate(_tokenId);
    }


    function withdraw(uint _tokenId) external nonreentrant {
        assert(_isApprovedOrOwner(msg.sender, _tokenId));
        require(attachments[_tokenId] == 0 && !voted[_tokenId], "ATT");

        IVotingEscrow.LockedBalance memory _locked = locked[_tokenId];
        require(!_locked.isPermanent, "!NORM");
        require(block.timestamp >= _locked.end, "!EXP");
        uint value = uint(int256(_locked.amount));

        locked[_tokenId] = IVotingEscrow.LockedBalance(0, 0, false);
        uint supply_before = supply;
        supply = supply_before - value;


        _checkpoint(_tokenId, _locked, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(token).transfer(msg.sender, value));


        _burn(_tokenId);

        emit Withdraw(msg.sender, _tokenId, value, block.timestamp);
        emit Supply(supply_before, supply_before - value);
    }

    function lockPermanent(uint _tokenId) external {
        address sender = msg.sender;
        require(_isApprovedOrOwner(sender, _tokenId), "NAO");

        IVotingEscrow.LockedBalance memory _newLocked = locked[_tokenId];
        require(!_newLocked.isPermanent, "!NORM");
        require(_newLocked.end > block.timestamp, "EXP");
        require(_newLocked.amount > 0, "ZV");

        uint _amount = uint(int256(_newLocked.amount));
        permanentLockBalance += _amount;
        _newLocked.end = 0;
        _newLocked.isPermanent = true;
        _checkpoint(_tokenId, locked[_tokenId], _newLocked);
        locked[_tokenId] = _newLocked;
        if(voted[_tokenId]) {
            IVoter(voter).poke(_tokenId);
        }
        emit LockPermanent(sender, _tokenId, _amount, block.timestamp);
        emit MetadataUpdate(_tokenId);
    }

    function unlockPermanent(uint _tokenId) external {
        address sender = msg.sender;
        require(_isApprovedOrOwner(msg.sender, _tokenId), "NAO");

        require(attachments[_tokenId] == 0 && !voted[_tokenId], "ATT");
        IVotingEscrow.LockedBalance memory _newLocked = locked[_tokenId];
        require(_newLocked.isPermanent, "!NORM");
        uint _amount = uint(int256(_newLocked.amount));
        permanentLockBalance -= _amount;
        _newLocked.end = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _newLocked.isPermanent = false;

        _checkpoint(_tokenId, locked[_tokenId], _newLocked);
        locked[_tokenId] = _newLocked;

        emit UnlockPermanent(sender, _tokenId, _amount, block.timestamp);
        emit MetadataUpdate(_tokenId);
    }


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


    function totalSupplyAt(uint _block) external view returns (uint) {
        return VotingBalanceLogic.totalSupplyAt(_block, epoch, votingBalanceLogicData, slope_changes);
    }

    function totalSupply() external view returns (uint) {
        return totalSupplyAtT(block.timestamp);
    }


    function totalSupplyAtT(uint t) public view returns (uint) {
        return VotingBalanceLogic.totalSupplyAtT(t, epoch, slope_changes,  votingBalanceLogicData);
    }


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
            if (!_locked0.isPermanent) {
                permanentLockBalance += value0;
            }
        }else{
            newLockedTo.amount = _locked1.amount + _locked0.amount;
            newLockedTo.end = end;
        }


        _checkpoint(_to, _locked1, newLockedTo);
        locked[_to] = newLockedTo;

        if(voted[_to]) {
            IVoter(voter).poke(_to);
        }
        emit Merge(
            msg.sender,
            _from,
            _to,
            uint(int256(_locked0.amount)),
            uint(int256(_locked1.amount)),
            uint(int256(newLockedTo.amount)),
            newLockedTo.end,
            block.timestamp
        );
        emit MetadataUpdate(_to);
    }


    function multiSplit(
        uint _from,
        uint[] memory amounts
    ) external nonreentrant splitAllowed(_from) notPartnerNFT(_from) returns (uint256[] memory newTokenIds) {
        require(amounts.length >= 2 && amounts.length <= 10, "MIN2MAX10");

        address owner = idToOwner[_from];

        IVotingEscrow.LockedBalance memory originalLocked = locked[_from];
        require(originalLocked.end > block.timestamp || originalLocked.isPermanent, "EXP");
        require(originalLocked.amount > 0, "ZV");


        uint totalWeight = 0;
        for(uint i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "ZW");
            totalWeight += amounts[i];
        }


        locked[_from] = IVotingEscrow.LockedBalance(0, 0, false);
        _checkpoint(_from, originalLocked, IVotingEscrow.LockedBalance(0, 0, false));
        _burn(_from);


        newTokenIds = new uint256[](amounts.length);
        uint[] memory actualAmounts = new uint[](amounts.length);

        for(uint i = 0; i < amounts.length; i++) {
            IVotingEscrow.LockedBalance memory newLocked = IVotingEscrow.LockedBalance({
                amount: int128(int256(uint256(int256(originalLocked.amount)) * amounts[i] / totalWeight)),
                end: originalLocked.end,
                isPermanent: originalLocked.isPermanent
            });

            newTokenIds[i] = _createSplitNFT(owner, newLocked);
            actualAmounts[i] = uint256(int256(newLocked.amount));
        }

        emit MultiSplit(
            _from,
            newTokenIds,
            msg.sender,
            actualAmounts,
            originalLocked.end,
            block.timestamp
        );
    }

    function _createSplitNFT(address _to, IVotingEscrow.LockedBalance memory _newLocked) private returns (uint256 _tokenId) {
        _tokenId = ++tokenId;
        locked[_tokenId] = _newLocked;
        _checkpoint(_tokenId, IVotingEscrow.LockedBalance(0, 0, false), _newLocked);
        _mint(_to, _tokenId);
    }

    function toggleSplit(address _account, bool _bool) external {
        require(msg.sender == team);
        canSplit[_account] = _bool;
    }


    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");


    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");


    mapping(address => address) private _delegates;


    mapping(address => uint) public nonces;


    function delegates(address delegator) public view returns (address) {
        address current = _delegates[delegator];
        return current == address(0) ? delegator : current;
    }


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

        uint[] storage _tokenIds = cpData.checkpoints[account][_checkIndex].tokenIds;
        uint votes = 0;
        for (uint i = 0; i < _tokenIds.length; i++) {
            uint tId = _tokenIds[i];

            votes = votes + VotingBalanceLogic.balanceOfNFT(tId, timestamp,  votingBalanceLogicData);
        }

        return votes;
    }

    function getPastTotalSupply(uint256 timestamp) external view returns (uint) {
        return totalSupplyAtT(timestamp);
    }


    function _delegate(address delegator, address delegatee) internal {

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