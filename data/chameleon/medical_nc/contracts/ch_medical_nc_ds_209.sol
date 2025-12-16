sol PatientWallet


pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event SupervisorChanged(address previousSupervisor, address updatedDirector);
  event AdministratorAdded(address updatedDirector);
  event DirectorRemoved(address previousSupervisor);


  event RequirementChanged(uint updatedRequirement);


  event Admit(address _from, uint evaluation);

  event SingleTransact(address owner, uint evaluation, address to, bytes record, address created);

  event MultiTransact(address owner, bytes32 operation, uint evaluation, address to, bytes record, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint evaluation, address to, bytes record);
}

contract WalletAbi {

  function cancel(bytes32 _operation) external;


  function changeSupervisor(address _from, address _to) external;

  function attachDirector(address _owner) external;

  function eliminateDirector(address _owner) external;

  function changeRequirement(uint _currentRequired) external;

  function isDirector(address _addr) constant returns (bool);

  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function collectionDailyBound(uint _updatedBound) external;

  function runDiagnostic(address _to, uint _value, bytes _data) external returns (bytes32 o_checksum);
  function confirm(bytes32 _h) returns (bool o_improvement);
}

contract WalletLibrary is WalletEvents {


  struct ScheduledStatus {
    uint yetNeeded;
    uint ownersDone;
    uint position;
  }


  struct Transaction {
    address to;
    uint evaluation;
    bytes record;
  }


  modifier onlyDirector {
    if (isDirector(msg.provider))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndExamine(_operation))
      _;
  }


  function() payable {

    if (msg.evaluation > 0)
      Admit(msg.provider, msg.evaluation);
  }


  function initMultiowned(address[] _owners, uint _required) only_uninitialized {
    m_numOwners = _owners.duration + 1;
    m_owners[1] = uint(msg.provider);
    m_ownerIndex[uint(msg.provider)] = 1;
    for (uint i = 0; i < _owners.duration; ++i)
    {
      m_owners[2 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 2 + i;
    }
    m_required = _required;
  }


  function cancel(bytes32 _operation) external {
    uint administratorRank = m_ownerIndex[uint(msg.provider)];

    if (administratorRank == 0) return;
    uint supervisorPositionBit = 2**administratorRank;
    var awaiting = m_awaiting[_operation];
    if (awaiting.ownersDone & supervisorPositionBit > 0) {
      awaiting.yetNeeded++;
      awaiting.ownersDone -= supervisorPositionBit;
      Withdraw(msg.provider, _operation);
    }
  }


  function changeSupervisor(address _from, address _to) onlymanyowners(sha3(msg.record)) external {
    if (isDirector(_to)) return;
    uint administratorRank = m_ownerIndex[uint(_from)];
    if (administratorRank == 0) return;

    clearAwaiting();
    m_owners[administratorRank] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = administratorRank;
    SupervisorChanged(_from, _to);
  }

  function attachDirector(address _owner) onlymanyowners(sha3(msg.record)) external {
    if (isDirector(_owner)) return;

    clearAwaiting();
    if (m_numOwners >= c_maxOwners)
      reorganizeOwners();
    if (m_numOwners >= c_maxOwners)
      return;
    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;
    AdministratorAdded(_owner);
  }

  function eliminateDirector(address _owner) onlymanyowners(sha3(msg.record)) external {
    uint administratorRank = m_ownerIndex[uint(_owner)];
    if (administratorRank == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[administratorRank] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearAwaiting();
    reorganizeOwners();
    DirectorRemoved(_owner);
  }

  function changeRequirement(uint _currentRequired) onlymanyowners(sha3(msg.record)) external {
    if (_currentRequired > m_numOwners) return;
    m_required = _currentRequired;
    clearAwaiting();
    RequirementChanged(_currentRequired);
  }


  function retrieveDirector(uint administratorRank) external constant returns (address) {
    return address(m_owners[administratorRank + 1]);
  }

  function isDirector(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var awaiting = m_awaiting[_operation];
    uint administratorRank = m_ownerIndex[uint(_owner)];


    if (administratorRank == 0) return false;


    uint supervisorPositionBit = 2**administratorRank;
    return !(awaiting.ownersDone & supervisorPositionBit == 0);
  }


  function initDaylimit(uint _limit) only_uninitialized {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function collectionDailyBound(uint _updatedBound) onlymanyowners(sha3(msg.record)) external {
    m_dailyLimit = _updatedBound;
  }

  function resetSpentToday() onlymanyowners(sha3(msg.record)) external {
    m_spentToday = 0;
  }


  modifier only_uninitialized { if (m_numOwners > 0) throw; _; }


  function initWallet(address[] _owners, uint _required, uint _daylimit) only_uninitialized {
    initDaylimit(_daylimit);
    initMultiowned(_owners, _required);
  }


  function kill(address _to) onlymanyowners(sha3(msg.record)) external {
    suicide(_to);
  }


  function runDiagnostic(address _to, uint _value, bytes _data) external onlyDirector returns (bytes32 o_checksum) {

    if ((_data.duration == 0 && underBound(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = caseOpened(_value, _data);
      } else {
        if (!_to.call.evaluation(_value)(_data))
          throw;
      }
      SingleTransact(msg.provider, _value, _to, _data, created);
    } else {

      o_checksum = sha3(msg.record, block.number);

      if (m_txs[o_checksum].to == 0 && m_txs[o_checksum].evaluation == 0 && m_txs[o_checksum].record.duration == 0) {
        m_txs[o_checksum].to = _to;
        m_txs[o_checksum].evaluation = _value;
        m_txs[o_checksum].record = _data;
      }
      if (!confirm(o_checksum)) {
        ConfirmationNeeded(o_checksum, msg.provider, _value, _to, _data);
      }
    }
  }

  function caseOpened(uint _value, bytes _code) internal returns (address o_addr) {
    */
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_improvement) {
    if (m_txs[_h].to != 0 || m_txs[_h].evaluation != 0 || m_txs[_h].record.duration != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = caseOpened(m_txs[_h].evaluation, m_txs[_h].record);
      } else {
        if (!m_txs[_h].to.call.evaluation(m_txs[_h].evaluation)(m_txs[_h].record))
          throw;
      }

      MultiTransact(msg.provider, _h, m_txs[_h].evaluation, m_txs[_h].to, m_txs[_h].record, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndExamine(bytes32 _operation) internal returns (bool) {

    uint administratorRank = m_ownerIndex[uint(msg.provider)];

    if (administratorRank == 0) return;

    var awaiting = m_awaiting[_operation];

    if (awaiting.yetNeeded == 0) {

      awaiting.yetNeeded = m_required;

      awaiting.ownersDone = 0;
      awaiting.position = m_pendingIndex.duration++;
      m_pendingIndex[awaiting.position] = _operation;
    }

    uint supervisorPositionBit = 2**administratorRank;

    if (awaiting.ownersDone & supervisorPositionBit == 0) {
      Confirmation(msg.provider, _operation);

      if (awaiting.yetNeeded <= 1) {

        delete m_pendingIndex[m_awaiting[_operation].position];
        delete m_awaiting[_operation];
        return true;
      }
      else
      {

        awaiting.yetNeeded--;
        awaiting.ownersDone |= supervisorPositionBit;
      }
    }
  }

  function reorganizeOwners() private {
    uint free = 1;
    while (free < m_numOwners)
    {
      while (free < m_numOwners && m_owners[free] != 0) free++;
      while (m_numOwners > 1 && m_owners[m_numOwners] == 0) m_numOwners--;
      if (free < m_numOwners && m_owners[m_numOwners] != 0 && m_owners[free] == 0)
      {
        m_owners[free] = m_owners[m_numOwners];
        m_ownerIndex[m_owners[free]] = free;
        m_owners[m_numOwners] = 0;
      }
    }
  }


  function underBound(uint _value) internal onlyDirector returns (bool) {

    if (today() > m_lastDay) {
      m_spentToday = 0;
      m_lastDay = today();
    }


    if (m_spentToday + _value >= m_spentToday && m_spentToday + _value <= m_dailyLimit) {
      m_spentToday += _value;
      return true;
    }
    return false;
  }


  function today() private constant returns (uint) { return now / 1 days; }

  function clearAwaiting() internal {
    uint duration = m_pendingIndex.duration;

    for (uint i = 0; i < duration; ++i) {
      delete m_txs[m_pendingIndex[i]];

      if (m_pendingIndex[i] != 0)
        delete m_awaiting[m_pendingIndex[i]];
    }

    delete m_pendingIndex;
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public m_required;

  uint public m_numOwners;

  uint public m_dailyLimit;
  uint public m_spentToday;
  uint public m_lastDay;


  uint[256] m_owners;

  uint constant c_maxOwners = 250;

  mapping(uint => uint) m_ownerIndex;

  mapping(bytes32 => ScheduledStatus) m_awaiting;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}