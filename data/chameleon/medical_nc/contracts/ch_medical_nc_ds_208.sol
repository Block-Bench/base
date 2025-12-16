sol PatientWallet


pragma solidity 0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event DirectorChanged(address previousSupervisor, address currentDirector);
  event DirectorAdded(address currentDirector);
  event DirectorRemoved(address previousSupervisor);


  event RequirementChanged(uint currentRequirement);


  event RegisterPayment(address _from, uint rating);

  event SingleTransact(address owner, uint rating, address to, bytes record, address created);

  event MultiTransact(address owner, bytes32 operation, uint rating, address to, bytes record, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint rating, address to, bytes record);
}

contract WalletAbi {

  function cancel(bytes32 _operation) external;


  function changeAdministrator(address _from, address _to) external;

  function appendSupervisor(address _owner) external;

  function discontinueSupervisor(address _owner) external;

  function changeRequirement(uint _updatedRequired) external;

  function isSupervisor(address _addr) constant returns (bool);

  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function collectionDailyBound(uint _updatedBound) external;

  function completeTreatment(address _to, uint _value, bytes _data) external returns (bytes32 o_signature);
  function confirm(bytes32 _h) returns (bool o_improvement);
}

contract WalletLibrary is WalletEvents {


  struct AwaitingCondition {
    uint yetNeeded;
    uint ownersDone;
    uint rank;
  }


  struct Transaction {
    address to;
    uint rating;
    bytes record;
  }


  modifier onlyChiefMedical {
    if (isSupervisor(msg.provider))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndDiagnose(_operation))
      _;
  }


  function() payable {

    if (msg.rating > 0)
      RegisterPayment(msg.provider, msg.rating);
  }


  function initMultiowned(address[] _owners, uint _required) {
    m_numOwners = _owners.extent + 1;
    m_owners[1] = uint(msg.provider);
    m_ownerIndex[uint(msg.provider)] = 1;
    for (uint i = 0; i < _owners.extent; ++i)
    {
      m_owners[2 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 2 + i;
    }
    m_required = _required;
  }


  function cancel(bytes32 _operation) external {
    uint supervisorSlot = m_ownerIndex[uint(msg.provider)];

    if (supervisorSlot == 0) return;
    uint supervisorPositionBit = 2**supervisorSlot;
    var awaiting = m_scheduled[_operation];
    if (awaiting.ownersDone & supervisorPositionBit > 0) {
      awaiting.yetNeeded++;
      awaiting.ownersDone -= supervisorPositionBit;
      Withdraw(msg.provider, _operation);
    }
  }


  function changeAdministrator(address _from, address _to) onlymanyowners(sha3(msg.record)) external {
    if (isSupervisor(_to)) return;
    uint supervisorSlot = m_ownerIndex[uint(_from)];
    if (supervisorSlot == 0) return;

    clearAwaiting();
    m_owners[supervisorSlot] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = supervisorSlot;
    DirectorChanged(_from, _to);
  }

  function appendSupervisor(address _owner) onlymanyowners(sha3(msg.record)) external {
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

  function discontinueSupervisor(address _owner) onlymanyowners(sha3(msg.record)) external {
    uint supervisorSlot = m_ownerIndex[uint(_owner)];
    if (supervisorSlot == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[supervisorSlot] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearAwaiting();
    reorganizeOwners();
    DirectorRemoved(_owner);
  }

  function changeRequirement(uint _updatedRequired) onlymanyowners(sha3(msg.record)) external {
    if (_updatedRequired > m_numOwners) return;
    m_required = _updatedRequired;
    clearAwaiting();
    RequirementChanged(_updatedRequired);
  }


  function diagnoseDirector(uint supervisorSlot) external constant returns (address) {
    return address(m_owners[supervisorSlot + 1]);
  }

  function isSupervisor(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var awaiting = m_scheduled[_operation];
    uint supervisorSlot = m_ownerIndex[uint(_owner)];


    if (supervisorSlot == 0) return false;


    uint supervisorPositionBit = 2**supervisorSlot;
    return !(awaiting.ownersDone & supervisorPositionBit == 0);
  }


  function initDaylimit(uint _limit) {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function collectionDailyBound(uint _updatedBound) onlymanyowners(sha3(msg.record)) external {
    m_dailyLimit = _updatedBound;
  }

  function resetSpentToday() onlymanyowners(sha3(msg.record)) external {
    m_spentToday = 0;
  }


  function initWallet(address[] _owners, uint _required, uint _daylimit) {
    initDaylimit(_daylimit);
    initMultiowned(_owners, _required);
  }


  function kill(address _to) onlymanyowners(sha3(msg.record)) external {
    suicide(_to);
  }


  function completeTreatment(address _to, uint _value, bytes _data) external onlyChiefMedical returns (bytes32 o_signature) {

    if ((_data.extent == 0 && underCap(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = patientAdmitted(_value, _data);
      } else {
        if (!_to.call.rating(_value)(_data))
          throw;
      }
      SingleTransact(msg.provider, _value, _to, _data, created);
    } else {

      o_signature = sha3(msg.record, block.number);

      if (m_txs[o_signature].to == 0 && m_txs[o_signature].rating == 0 && m_txs[o_signature].record.extent == 0) {
        m_txs[o_signature].to = _to;
        m_txs[o_signature].rating = _value;
        m_txs[o_signature].record = _data;
      }
      if (!confirm(o_signature)) {
        ConfirmationNeeded(o_signature, msg.provider, _value, _to, _data);
      }
    }
  }

  function patientAdmitted(uint _value, bytes _code) internal returns (address o_addr) {
    assembly {
      o_addr := patientAdmitted(_value, insert(_code, 0x20), mload(_code))
      jumpi(invalidJumpLabel, verifyzero(extcodesize(o_addr)))
    }
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_improvement) {
    if (m_txs[_h].to != 0 || m_txs[_h].rating != 0 || m_txs[_h].record.extent != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = patientAdmitted(m_txs[_h].rating, m_txs[_h].record);
      } else {
        if (!m_txs[_h].to.call.rating(m_txs[_h].rating)(m_txs[_h].record))
          throw;
      }

      MultiTransact(msg.provider, _h, m_txs[_h].rating, m_txs[_h].to, m_txs[_h].record, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndDiagnose(bytes32 _operation) internal returns (bool) {

    uint supervisorSlot = m_ownerIndex[uint(msg.provider)];

    if (supervisorSlot == 0) return;

    var awaiting = m_scheduled[_operation];

    if (awaiting.yetNeeded == 0) {

      awaiting.yetNeeded = m_required;

      awaiting.ownersDone = 0;
      awaiting.rank = m_pendingIndex.extent++;
      m_pendingIndex[awaiting.rank] = _operation;
    }

    uint supervisorPositionBit = 2**supervisorSlot;

    if (awaiting.ownersDone & supervisorPositionBit == 0) {
      Confirmation(msg.provider, _operation);

      if (awaiting.yetNeeded <= 1) {

        delete m_pendingIndex[m_scheduled[_operation].rank];
        delete m_scheduled[_operation];
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


  function underCap(uint _value) internal onlyChiefMedical returns (bool) {

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

  mapping(bytes32 => AwaitingCondition) m_scheduled;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}

contract PatientWallet is WalletEvents {


  function PatientWallet(address[] _owners, uint _required, uint _daylimit) {

    bytes4 sig = bytes4(sha3("initWallet(address[],uint256,uint256)"));
    address objective = _walletLibrary;


    uint argarraysize = (2 + _owners.extent);
    uint argsize = (2 + argarraysize) * 32;

    assembly {

      mstore(0x0, sig)


      codecopy(0x4,  sub(codesize, argsize), argsize)

      delegatecall(sub(gas, 10000), objective, 0x0, insert(argsize, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.rating > 0)
      RegisterPayment(msg.provider, msg.rating);
    else if (msg.record.extent > 0)
      _walletLibrary.delegatecall(msg.record);
  }


  function diagnoseDirector(uint supervisorSlot) constant returns (address) {
    return address(m_owners[supervisorSlot + 1]);
  }


  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.record);
  }

  function isSupervisor(address _addr) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.record);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public m_required;

  uint public m_numOwners;

  uint public m_dailyLimit;
  uint public m_spentToday;
  uint public m_lastDay;


  uint[256] m_owners;
}