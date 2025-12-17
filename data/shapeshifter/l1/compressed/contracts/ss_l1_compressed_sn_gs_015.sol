pragma solidity ^0.8.13;
import {ILockManager, LockManagerSettings, PluginMode} from "../interfaces/ILockManager.sol";
import {ILockToGovernBase} from "../interfaces/ILockToGovernBase.sol";
import {ILockToVote} from "../interfaces/ILockToVote.sol";
import {IMajorityVoting} from "../interfaces/IMajorityVoting.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
abstract contract LockManagerBase is ILockManager {
using EnumerableSet for EnumerableSet.UintSet;
LockManagerSettings public settings;
ILockToGovernBase public plugin;
mapping(address => uint256) private lockedBalances;
EnumerableSet.UintSet internal knownProposalIds;
event BalanceLocked(address voter, uint256 amount);
event BalanceUnlocked(address voter, uint256 amount);
event ProposalEnded(uint256 proposalId);
error InvalidPluginAddress();
error NoBalance();
error LocksStillActive();
error InvalidPlugin();
error InvalidPluginMode();
error SetPluginAddressForbidden();
constructor(LockManagerSettings memory _settings) {
settings.pluginMode = _settings.pluginMode;
}
function knownProposalIdAt(uint256 _index) public view virtual returns (uint256) {
return knownProposalIds.at(_index);
}
function knownProposalIdsLength() public view virtual returns (uint256) {
return knownProposalIds.length();
}
function lock() public virtual {
_lock(_incomingTokenBalance());
}
function lock(uint256 _amount) public virtual {
_lock(_amount);
}
function lockAndVote(uint256 _proposalId, IMajorityVoting.VoteOption _voteOption) public virtual {
if (settings.pluginMode != PluginMode.Voting) {
revert InvalidPluginMode();
}
_lock(_incomingTokenBalance());
_vote(_proposalId, _voteOption);
}
function lockAndVote(uint256 _proposalId, IMajorityVoting.VoteOption _voteOption, uint256 _amount) public virtual {
if (settings.pluginMode != PluginMode.Voting) {
revert InvalidPluginMode();
}
_lock(_amount);
_vote(_proposalId, _voteOption);
}
function vote(uint256 _proposalId, IMajorityVoting.VoteOption _voteOption) public virtual {
if (settings.pluginMode != PluginMode.Voting) {
revert InvalidPluginMode();
}
_vote(_proposalId, _voteOption);
}
function getLockedBalance(address _account) public view virtual returns (uint256) {
return lockedBalances[_account];
}
function canVote(uint256 _proposalId, address _voter, IMajorityVoting.VoteOption _voteOption)
external
view
virtual
returns (bool) {
return ILockToVote(address(plugin)).canVote(_proposalId, _voter, _voteOption);
}
function unlock() public virtual {
uint256 _refundableBalance = getLockedBalance(msg.sender);
if (_refundableBalance == 0) {
revert NoBalance();
}
_withdrawActiveVotingPower();
lockedBalances[msg.sender] = 0;
_doUnlockTransfer(msg.sender, _refundableBalance);
emit BalanceUnlocked(msg.sender, _refundableBalance);
}
function proposalCreated(uint256 _proposalId) public virtual {
if (msg.sender != address(plugin)) {
revert InvalidPluginAddress();
}
knownProposalIds.add(_proposalId);
}
function proposalEnded(uint256 _proposalId) public virtual {
if (msg.sender != address(plugin)) {
revert InvalidPluginAddress();
}
emit ProposalEnded(_proposalId);
knownProposalIds.remove(_proposalId);
}
function setPluginAddress(ILockToGovernBase _newPluginAddress) public virtual {
if (address(plugin) != address(0)) {
revert SetPluginAddressForbidden();
} else if (!IERC165(address(_newPluginAddress)).supportsInterface(type(ILockToGovernBase).interfaceId)) {
revert InvalidPlugin();
}
else if (
settings.pluginMode == PluginMode.Voting
&& !IERC165(address(_newPluginAddress)).supportsInterface(type(ILockToVote).interfaceId)
) {
revert InvalidPlugin();
}
plugin = _newPluginAddress;
}
function _incomingTokenBalance() internal view virtual returns (uint256);
function _lock(uint256 _amount) internal virtual {
if (_amount == 0) {
revert NoBalance();
}
_doLockTransfer(_amount);
lockedBalances[msg.sender] += _amount;
emit BalanceLocked(msg.sender, _amount);
}
function _doLockTransfer(uint256 _amount) internal virtual;
function _doUnlockTransfer(address _recipient, uint256 _amount) internal virtual;
function _vote(uint256 _proposalId, IMajorityVoting.VoteOption _voteOption) internal virtual {
uint256 _currentVotingPower = getLockedBalance(msg.sender);
ILockToVote(address(plugin)).vote(_proposalId, msg.sender, _voteOption, _currentVotingPower);
}
function _withdrawActiveVotingPower() internal virtual {
uint256 _proposalCount = knownProposalIds.length();
for (uint256 _i; _i < _proposalCount;) {
uint256 _proposalId = knownProposalIds.at(_i);
if (!plugin.isProposalOpen(_proposalId)) {
knownProposalIds.remove(_proposalId);
_proposalCount = knownProposalIds.length();
if (_i == _proposalCount) {
return;
}
continue;
}
if (plugin.usedVotingPower(_proposalId, msg.sender) > 0) {
ILockToVote(address(plugin)).clearVote(_proposalId, msg.sender);
}
unchecked {
_i++;
}
}
}
}