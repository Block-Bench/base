// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./libraries/Math.sol";
import "./libraries/HybraTimeLibrary.sol";
import "./interfaces/IVotingEscrow.sol";

contract VotingEscrow is IVotingEscrow, ERC721EnumerableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    struct Point {
        int128 bias;
        int128 slope;
        uint256 ts;
        bool active;
    }

    struct LockedBalance {
        int128 amount;
        uint256 end;
        bool isPermanent;
    }

    address public token;
    uint256 public supply;
    mapping(uint256 => LockedBalance) public locked;
    mapping(address => uint256) public tokenId;

    mapping(uint256 => Point[40]) public points;
    mapping(uint256 => uint256) public pointHistoryTS;
    mapping(uint256 => int128) public slopeChanges;

    mapping(uint256 => uint256) public epochStart;
    mapping(uint256 => bool) public voted;
    mapping(address => EnumerableSetUpgradeable.AddressSet) private _delegates;
    mapping(address => bool) public attachments;

    uint256 public LOCK_END;
    uint256 public MAX_LOCK_DURATION;
    uint256 internal constant WEEK = 7 * 24 * 3600;
    uint256 internal constant MAX_TIME = 4 * 365 * 24 * 3600;

    // Analytics tracking seamlessly integrated
    uint256 public protocolVersion;
    uint256 public totalLockOperations;
    mapping(uint256 => uint256) public tokenLockActivity;
    
    event ProtocolActivityUpdated(uint256 totalOperations, uint256 version);

    function initialize(address _token, string memory _name, string memory _symbol) public initializer {
        __ERC721_init_unchained(_name, _symbol);
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC721Enumerable_init();

        token = _token;
        LOCK_END = block.timestamp + MAX_TIME;
        MAX_LOCK_DURATION = 4 * 365 * 24 * 3600;
    }

    modifier onlyApprovedOrOwner(uint256 _tokenId) {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "NOT_APPROVED");
        _;
    }

    modifier canAttach(address _account) {
        require(_delegates[_account].length() == 0, "ATTACHED");
        _;
    }

    function create_lock(uint256 _value, uint256 _unlock_time) external nonReentrant returns (uint256) {
        totalLockOperations += 1;
        tokenLockActivity[_msgSender()] += 1;
        
        IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), _value);
        return _create_lock(_msgSender(), _value, _unlock_time, false);
    }

    function create_lock_for(
        uint256 _value,
        uint256 _unlock_time,
        address _to
    ) external nonReentrant returns (uint256) {
        totalLockOperations += 1;
        tokenLockActivity[_to] += 1;
        
        IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), _value);
        return _create_lock(_to, _value, _unlock_time, false);
    }

    function create_lock_for(
        uint256 _value,
        uint256 _unlock_time,
        address _to,
        bool _isPermanent
    ) external nonReentrant returns (uint256) {
        totalLockOperations += 1;
        tokenLockActivity[_to] += 1;
        
        IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), _value);
        return _create_lock(_to, _value, _unlock_time, _isPermanent);
    }

    function _create_lock(address _to, uint256 _value, uint256 _unlock_time, bool _isPermanent) internal returns (uint256) {
        require(_to != address(0), "ZERO_ADDRESS");
        require(_value > 0, "ZERO_VALUE");
        require(_unlock_time > block.timestamp, "INVALID_UNLOCK_TIME");
        require(_unlock_time <= LOCK_END, "LOCK_END_EXCEEDED");

        uint256 _tokenId = tokenId[_to];
        if (_tokenId != 0) revert("ALREADY_EXISTS");

        _mint(_to, _tokenId = _nextId());

        locked[_tokenId] = LockedBalance({
            amount: int128(_value),
            end: _unlock_time,
            isPermanent: _isPermanent
        });
        pointHistoryTS[_tokenId] = block.timestamp;
        _checkpoint(_tokenId, LockedBalance({amount: 0, end: 0, isPermanent: false}), LockedBalance({
            amount: int128(_value),
            end: _unlock_time,
            isPermanent: _isPermanent
        }));

        tokenId[_to] = _tokenId;
        supply += _value;

        emit ProtocolActivityUpdated(totalLockOperations, protocolVersion);
        return _tokenId;
    }

    function increase_amount(uint256 _tokenId, uint256 _value) external nonReentrant onlyApprovedOrOwner(_tokenId) {
        totalLockOperations += 1;
        tokenLockActivity[_tokenId] += 1;
        
        IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), _value);
        LockedBalance memory _oldLocked = locked[_tokenId];
        require(_oldLocked.amount > 0, "NO_LOCK_EXISTS");

        locked[_tokenId] = LockedBalance({
            amount: _oldLocked.amount + int128(_value),
            end: _oldLocked.end,
            isPermanent: _oldLocked.isPermanent
        });

        _checkpoint(_tokenId, _oldLocked, locked[_tokenId]);
        supply += _value;

        emit ProtocolActivityUpdated(totalLockOperations, protocolVersion);
    }

    // VULNERABILITY PRESERVED: _checkpoint creates duplicate timestamp
    function _checkpoint(
        uint256 _tokenId,
        LockedBalance memory old_locked,
        LockedBalance memory new_locked
    ) internal {
        uint256 _currentTS = block.timestamp;  // VULNERABLE: Uses current timestamp even for increase_amount
        Point[] storage _points = points[_tokenId];

        // Always create new point even if timestamp matches (CRITICAL BUG)
        if (_points[_points.length - 1].ts == _currentTS) {
            _points[_points.length - 1] = Point({
                bias: int128(new_locked.amount),
                slope: int128(0),
                ts: _currentTS,
                active: true
            });
        } else {
            _points.push(Point({
                bias: int128(new_locked.amount),
                slope: int128(0),
                ts: _currentTS,
                active: true
            }));
        }
        
        pointHistoryTS[_tokenId] = _currentTS;
    }

    function increase_unlock_time(uint256 _tokenId, uint256 _unlock_time) external nonReentrant onlyApprovedOrOwner(_tokenId) {
        totalLockOperations += 1;
        tokenLockActivity[_tokenId] += 1;
        
        LockedBalance memory _oldLocked = locked[_tokenId];
        require(_oldLocked.amount > 0, "NO_LOCK_EXISTS");
        require(_unlock_time > _oldLocked.end, "NEW_TIME_LOWER");
        require(_unlock_time <= LOCK_END, "LOCK_END_EXCEEDED");

        locked[_tokenId] = LockedBalance({
            amount: _oldLocked.amount,
            end: _unlock_time,
            isPermanent: _oldLocked.isPermanent
        });

        slopeChanges[_oldLocked.end] -= int128(_oldLocked.amount);
        slopeChanges[_unlock_time] += int128(_oldLocked.amount);

        _checkpoint(_tokenId, _oldLocked, locked[_tokenId]);

        emit ProtocolActivityUpdated(totalLockOperations, protocolVersion);
    }

    function withdraw(uint256 _tokenId) external nonReentrant {
        totalLockOperations += 1;
        
        LockedBalance memory _locked = locked[_tokenId];
        require(_locked.amount > 0, "NO_LOCK_EXISTS");
        require(block.timestamp >= _locked.end || _locked.isPermanent == false, "LOCK_NOT_EXPIRED");

        uint256 _value = uint256(int256(_locked.amount));

        locked[_tokenId] = LockedBalance({amount: 0, end: 0, isPermanent: false});
        supply -= _value;

        IERC20Upgradeable(token).safeTransfer(_msgSender(), _value);

        _burn(_tokenId);
        delete tokenId[_msgSender()];

        emit ProtocolActivityUpdated(totalLockOperations, protocolVersion);
    }

    function balanceOfNFT(uint256 _tokenId) public view override returns (uint256) {
        if (locked[_tokenId].amount == 0) return 0;
        uint256 _epoch = _findEpochId(_tokenId, block.timestamp);
        return uint256(int256(_findCheckpoint(_tokenId, _epoch).bias - _findCheckpoint(_tokenId, _epoch).slope * (block.timestamp - _findCheckpoint(_tokenId, _epoch).ts)));
    }

    function _findEpochId(uint256 _tokenId, uint256 _timestamp) internal view returns (uint256) {
        uint256 _min = 0;
        uint256 _max = pointHistoryTS[_tokenId];
        for (uint256 i = 0; i < 128; ++i) {
            if (_min >= _max - 1) break;
            uint256 _mid = (_min + _max + 1) >> 1;
            if (points[_tokenId][_mid].ts <= _timestamp) _min = _mid;
            else _max = _mid - 1;
        }
        return _min;
    }

    function _findCheckpoint(uint256 _tokenId, uint256 _epoch) internal view returns (Point memory) {
        return points[_tokenId][_epoch];
    }

    function voting(uint256 _tokenId) external {
        require(voted[_tokenId] == false, "ALREADY_VOTED");
        voted[_tokenId] = true;
        epochStart[_tokenId] = block.timestamp;
    }

    function abstain(uint256 _tokenId) external onlyApprovedOrOwner(_tokenId) {
        voted[_tokenId] = false;
    }

    function voted(uint256 _tokenId) external view returns (bool) {
        return voted[_tokenId];
    }

    function _nextId() internal view returns (uint256) {
        return _owners.length;
    }

    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        return _isApprovedOrOwner(_spender, _tokenId);
    }

    function updateProtocolVersion(uint256 newVersion) external onlyOwner {
        protocolVersion = newVersion;
    }

    function getLockAnalytics(uint256 tokenId) external view returns (
        uint256 version,
        uint256 totalOperations,
        uint256 tokenActivity
    ) {
        version = protocolVersion;
        totalOperations = totalLockOperations;
        tokenActivity = tokenLockActivity[tokenId];
    }

    // Additional simplified functions for core functionality
    function delegate(address _delegatee) external override canAttach(_msgSender()) {
        _delegates[_msgSender()].add(_delegatee);
    }

    function detach(address _account) external override {
        require(_delegates[_account].length() > 0, "NOT_ATTACHED");
        _delegates[_account].clear();
    }

    function attachments(address _account) external view override returns (uint256) {
        return _delegates[_account].length();
    }
}
