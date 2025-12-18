pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event CustodianChanged(address formerCustodian, address updatedCustodian);
  event CustodianAdded(address updatedCustodian);
  event CustodianRemoved(address formerCustodian);


  event RequirementChanged(uint currentRequirement);


  event SubmitPayment(address _from, uint measurement);

  event SingleTransact(address owner, uint measurement, address to, bytes chart, address created);

  event MultiTransact(address owner, bytes32 operation, uint measurement, address to, bytes chart, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint measurement, address to, bytes chart);
}

contract WalletAbi {

  function cancel(bytes32 _operation) external;


  function transferCustody(address _from, address _to) external;

  function addCustodian(address _owner) external;

  function removeCustodian(address _owner) external;

  function changeRequirement(uint _updatedRequired) external;

  function isCustodian(address _addr) constant returns (bool);

  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function groupDailyBound(uint _currentCap) external;

  function implementDecision(address _to, uint _value, bytes _data) external returns (bytes32 o_checksum);
  function confirm(bytes32 _h) returns (bool o_recovery);
}

contract WalletLibrary is WalletEvents {


  struct ScheduledStatus {
    uint yetNeeded;
    uint ownersDone;
    uint position;
  }


  struct MedicalTransaction {
    address to;
    uint measurement;
    bytes chart;
  }


  modifier onlyCustodian {
    if (isCustodian(msg.sender))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndInspectstatus(_operation))
      _;
  }


  function() payable {

    if (msg.value > 0)
      SubmitPayment(msg.sender, msg.value);
  }


  function initializesystemMultiowned(address[] _owners, uint _required) only_uninitialized {
    m_numOwners = _owners.length + 1;
    m_owners[1] = uint(msg.sender);
    m_ownerIndex[uint(msg.sender)] = 1;
    for (uint i = 0; i < _owners.length; ++i)
    {
      m_owners[2 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 2 + i;
    }
    m_required = _required;
  }


  function cancel(bytes32 _operation) external {
    uint custodianSlot = m_ownerIndex[uint(msg.sender)];

    if (custodianSlot == 0) return;
    uint custodianPositionBit = 2**custodianSlot;
    var awaiting = m_scheduled[_operation];
    if (awaiting.ownersDone & custodianPositionBit > 0) {
      awaiting.yetNeeded++;
      awaiting.ownersDone -= custodianPositionBit;
      Withdraw(msg.sender, _operation);
    }
  }


  function transferCustody(address _from, address _to) onlymanyowners(sha3(msg.data)) external {
    if (isCustodian(_to)) return;
    uint custodianSlot = m_ownerIndex[uint(_from)];
    if (custodianSlot == 0) return;

    clearScheduled();
    m_owners[custodianSlot] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = custodianSlot;
    CustodianChanged(_from, _to);
  }

  function addCustodian(address _owner) onlymanyowners(sha3(msg.data)) external {
    if (isCustodian(_owner)) return;

    clearScheduled();
    if (m_numOwners >= c_maxOwners)
      reorganizeOwners();
    if (m_numOwners >= c_maxOwners)
      return;
    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;
    CustodianAdded(_owner);
  }

  function removeCustodian(address _owner) onlymanyowners(sha3(msg.data)) external {
    uint custodianSlot = m_ownerIndex[uint(_owner)];
    if (custodianSlot == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[custodianSlot] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearScheduled();
    reorganizeOwners();
    CustodianRemoved(_owner);
  }

  function changeRequirement(uint _updatedRequired) onlymanyowners(sha3(msg.data)) external {
    if (_updatedRequired > m_numOwners) return;
    m_required = _updatedRequired;
    clearScheduled();
    RequirementChanged(_updatedRequired);
  }


  function retrieveCustodian(uint custodianSlot) external constant returns (address) {
    return address(m_owners[custodianSlot + 1]);
  }

  function isCustodian(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var awaiting = m_scheduled[_operation];
    uint custodianSlot = m_ownerIndex[uint(_owner)];


    if (custodianSlot == 0) return false;


    uint custodianPositionBit = 2**custodianSlot;
    return !(awaiting.ownersDone & custodianPositionBit == 0);
  }


  function initializesystemDaylimit(uint _limit) only_uninitialized {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function groupDailyBound(uint _currentCap) onlymanyowners(sha3(msg.data)) external {
    m_dailyLimit = _currentCap;
  }

  function resetSpentToday() onlymanyowners(sha3(msg.data)) external {
    m_spentToday = 0;
  }


  modifier only_uninitialized { if (m_numOwners > 0) throw; _; }


  function initializesystemWallet(address[] _owners, uint _required, uint _daylimit) only_uninitialized {
    initializesystemDaylimit(_daylimit);
    initializesystemMultiowned(_owners, _required);
  }


  function deactivateSystem(address _to) onlymanyowners(sha3(msg.data)) external {
    suicide(_to);
  }


  function implementDecision(address _to, uint _value, bytes _data) external onlyCustodian returns (bytes32 o_checksum) {

    if ((_data.length == 0 && underCap(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = patientAdmitted(_value, _data);
      } else {
        if (!_to.call.value(_value)(_data))
          throw;
      }
      SingleTransact(msg.sender, _value, _to, _data, created);
    } else {

      o_checksum = sha3(msg.data, block.number);

      if (m_txs[o_checksum].to == 0 && m_txs[o_checksum].measurement == 0 && m_txs[o_checksum].chart.length == 0) {
        m_txs[o_checksum].to = _to;
        m_txs[o_checksum].measurement = _value;
        m_txs[o_checksum].chart = _data;
      }
      if (!confirm(o_checksum)) {
        ConfirmationNeeded(o_checksum, msg.sender, _value, _to, _data);
      }
    }
  }

  function patientAdmitted(uint _value, bytes _code) internal returns (address o_addr) {
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_recovery) {
    if (m_txs[_h].to != 0 || m_txs[_h].measurement != 0 || m_txs[_h].chart.length != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = patientAdmitted(m_txs[_h].measurement, m_txs[_h].chart);
      } else {
        if (!m_txs[_h].to.call.value(m_txs[_h].measurement)(m_txs[_h].chart))
          throw;
      }

      MultiTransact(msg.sender, _h, m_txs[_h].measurement, m_txs[_h].to, m_txs[_h].chart, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndInspectstatus(bytes32 _operation) internal returns (bool) {

    uint custodianSlot = m_ownerIndex[uint(msg.sender)];

    if (custodianSlot == 0) return;

    var awaiting = m_scheduled[_operation];

    if (awaiting.yetNeeded == 0) {

      awaiting.yetNeeded = m_required;

      awaiting.ownersDone = 0;
      awaiting.position = m_pendingIndex.length++;
      m_pendingIndex[awaiting.position] = _operation;
    }

    uint custodianPositionBit = 2**custodianSlot;

    if (awaiting.ownersDone & custodianPositionBit == 0) {
      Confirmation(msg.sender, _operation);

      if (awaiting.yetNeeded <= 1) {

        delete m_pendingIndex[m_scheduled[_operation].position];
        delete m_scheduled[_operation];
        return true;
      }
      else
      {

        awaiting.yetNeeded--;
        awaiting.ownersDone |= custodianPositionBit;
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


  function underCap(uint _value) internal onlyCustodian returns (bool) {

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

  function clearScheduled() internal {
    uint duration = m_pendingIndex.length;

    for (uint i = 0; i < duration; ++i) {
      delete m_txs[m_pendingIndex[i]];

      if (m_pendingIndex[i] != 0)
        delete m_scheduled[m_pendingIndex[i]];
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

  mapping(bytes32 => ScheduledStatus) m_scheduled;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => MedicalTransaction) m_txs;
}