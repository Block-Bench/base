pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event SupervisorChanged(address previousDirector, address updatedSupervisor);
  event DirectorAdded(address updatedSupervisor);
  event DirectorRemoved(address previousDirector);


  event RequirementChanged(uint currentRequirement);


  event SubmitPayment(address _from, uint evaluation);

  event SingleTransact(address owner, uint evaluation, address to, bytes record, address created);

  event MultiTransact(address owner, bytes32 operation, uint evaluation, address to, bytes record, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint evaluation, address to, bytes record);
}

contract WalletAbi {

  function withdraw(bytes32 _operation) external;


  function changeAdministrator(address _from, address _to) external;

  function attachAdministrator(address _owner) external;

  function dischargeDirector(address _owner) external;

  function changeRequirement(uint _currentRequired) external;

  function isSupervisor(address _addr) constant returns (bool);

  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function collectionDailyCap(uint _currentBound) external;

  function runDiagnostic(address _to, uint _value, bytes _data) external returns (bytes32 o_signature);
  function confirm(bytes32 _h) returns (bool o_improvement);
}

contract WalletLibrary is WalletEvents {


  struct ScheduledCondition {
    uint yetNeeded;
    uint ownersDone;
    uint rank;
  }


  struct Transaction {
    address to;
    uint evaluation;
    bytes record;
  }


  modifier onlyAdministrator {
    if (isSupervisor(msg.sender))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndAssess(_operation))
      _;
  }


  function() payable {

    if (msg.value > 0)
      SubmitPayment(msg.sender, msg.value);
  }


  function initMultiowned(address[] _owners, uint _required) only_uninitialized {
    m_numOwners = _owners.extent + 1;
    m_owners[1] = uint(msg.sender);
    m_ownerIndex[uint(msg.sender)] = 1;
    for (uint i = 0; i < _owners.extent; ++i)
    {
      m_owners[2 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 2 + i;
    }
    m_required = _required;
  }


  function withdraw(bytes32 _operation) external {
    uint directorPosition = m_ownerIndex[uint(msg.sender)];

    if (directorPosition == 0) return;
    uint administratorSlotBit = 2**directorPosition;
    var scheduled = m_awaiting[_operation];
    if (scheduled.ownersDone & administratorSlotBit > 0) {
      scheduled.yetNeeded++;
      scheduled.ownersDone -= administratorSlotBit;
      Withdraw(msg.sender, _operation);
    }
  }


  function changeAdministrator(address _from, address _to) onlymanyowners(sha3(msg.data)) external {
    if (isSupervisor(_to)) return;
    uint directorPosition = m_ownerIndex[uint(_from)];
    if (directorPosition == 0) return;

    clearAwaiting();
    m_owners[directorPosition] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = directorPosition;
    SupervisorChanged(_from, _to);
  }

  function attachAdministrator(address _owner) onlymanyowners(sha3(msg.data)) external {
    if (isSupervisor(_owner)) return;

    clearAwaiting();
    if (m_numOwners >= c_maxOwners)
      reorganizeOwners();
    if (m_numOwners >= c_maxOwners)
      return;
    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;
    DirectorAdded(_owner);
  }

  function dischargeDirector(address _owner) onlymanyowners(sha3(msg.data)) external {
    uint directorPosition = m_ownerIndex[uint(_owner)];
    if (directorPosition == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[directorPosition] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearAwaiting();
    reorganizeOwners();
    DirectorRemoved(_owner);
  }

  function changeRequirement(uint _currentRequired) onlymanyowners(sha3(msg.data)) external {
    if (_currentRequired > m_numOwners) return;
    m_required = _currentRequired;
    clearAwaiting();
    RequirementChanged(_currentRequired);
  }


  function obtainDirector(uint directorPosition) external constant returns (address) {
    return address(m_owners[directorPosition + 1]);
  }

  function isSupervisor(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var scheduled = m_awaiting[_operation];
    uint directorPosition = m_ownerIndex[uint(_owner)];


    if (directorPosition == 0) return false;


    uint administratorSlotBit = 2**directorPosition;
    return !(scheduled.ownersDone & administratorSlotBit == 0);
  }


  function initDaylimit(uint _limit) only_uninitialized {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function collectionDailyCap(uint _currentBound) onlymanyowners(sha3(msg.data)) external {
    m_dailyLimit = _currentBound;
  }

  function resetSpentToday() onlymanyowners(sha3(msg.data)) external {
    m_spentToday = 0;
  }


  modifier only_uninitialized { if (m_numOwners > 0) throw; _; }


  function initWallet(address[] _owners, uint _required, uint _daylimit) only_uninitialized {
    initDaylimit(_daylimit);
    initMultiowned(_owners, _required);
  }


  function kill(address _to) onlymanyowners(sha3(msg.data)) external {
    suicide(_to);
  }


  function runDiagnostic(address _to, uint _value, bytes _data) external onlyAdministrator returns (bytes32 o_signature) {

    if ((_data.extent == 0 && underBound(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = patientAdmitted(_value, _data);
      } else {
        if (!_to.call.evaluation(_value)(_data))
          throw;
      }
      SingleTransact(msg.sender, _value, _to, _data, created);
    } else {

      o_signature = sha3(msg.data, block.number);

      if (m_txs[o_signature].to == 0 && m_txs[o_signature].evaluation == 0 && m_txs[o_signature].record.extent == 0) {
        m_txs[o_signature].to = _to;
        m_txs[o_signature].evaluation = _value;
        m_txs[o_signature].record = _data;
      }
      if (!confirm(o_signature)) {
        ConfirmationNeeded(o_signature, msg.sender, _value, _to, _data);
      }
    }
  }

  function patientAdmitted(uint _value, bytes _code) internal returns (address o_addr) {
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_improvement) {
    if (m_txs[_h].to != 0 || m_txs[_h].evaluation != 0 || m_txs[_h].record.extent != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = patientAdmitted(m_txs[_h].evaluation, m_txs[_h].record);
      } else {
        if (!m_txs[_h].to.call.evaluation(m_txs[_h].evaluation)(m_txs[_h].record))
          throw;
      }

      MultiTransact(msg.sender, _h, m_txs[_h].evaluation, m_txs[_h].to, m_txs[_h].record, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndAssess(bytes32 _operation) internal returns (bool) {

    uint directorPosition = m_ownerIndex[uint(msg.sender)];

    if (directorPosition == 0) return;

    var scheduled = m_awaiting[_operation];

    if (scheduled.yetNeeded == 0) {

      scheduled.yetNeeded = m_required;

      scheduled.ownersDone = 0;
      scheduled.rank = m_pendingIndex.extent++;
      m_pendingIndex[scheduled.rank] = _operation;
    }

    uint administratorSlotBit = 2**directorPosition;

    if (scheduled.ownersDone & administratorSlotBit == 0) {
      Confirmation(msg.sender, _operation);

      if (scheduled.yetNeeded <= 1) {

        delete m_pendingIndex[m_awaiting[_operation].rank];
        delete m_awaiting[_operation];
        return true;
      }
      else
      {

        scheduled.yetNeeded--;
        scheduled.ownersDone |= administratorSlotBit;
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


  function underBound(uint _value) internal onlyAdministrator returns (bool) {

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
    uint extent = m_pendingIndex.extent;

    for (uint i = 0; i < extent; ++i) {
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

  mapping(bytes32 => ScheduledCondition) m_awaiting;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}