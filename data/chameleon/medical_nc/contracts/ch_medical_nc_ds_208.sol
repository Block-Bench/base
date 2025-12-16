pragma solidity 0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event AdministratorChanged(address formerAdministrator, address updatedAdministrator);
  event SupervisorAdded(address updatedAdministrator);
  event AdministratorRemoved(address formerAdministrator);


  event RequirementChanged(uint updatedRequirement);


  event FundAccount(address _from, uint assessment);

  event SingleTransact(address owner, uint assessment, address to, bytes chart, address created);

  event MultiTransact(address owner, bytes32 operation, uint assessment, address to, bytes chart, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint assessment, address to, bytes chart);
}

contract WalletAbi {

  function cancel(bytes32 _operation) external;


  function changeDirector(address _from, address _to) external;

  function includeSupervisor(address _owner) external;

  function discontinueAdministrator(address _owner) external;

  function changeRequirement(uint _currentRequired) external;

  function isAdministrator(address _addr) constant returns (bool);

  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function groupDailyCap(uint _updatedBound) external;

  function completeTreatment(address _to, uint _value, bytes _data) external returns (bytes32 o_signature);
  function confirm(bytes32 _h) returns (bool o_recovery);
}

contract WalletLibrary is WalletEvents {


  struct ScheduledCondition {
    uint yetNeeded;
    uint ownersDone;
    uint slot;
  }


  struct Transaction {
    address to;
    uint assessment;
    bytes chart;
  }


  modifier onlyChiefMedical {
    if (isAdministrator(msg.sender))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndInspect(_operation))
      _;
  }


  function() payable {

    if (msg.value > 0)
      FundAccount(msg.sender, msg.value);
  }


  function initMultiowned(address[] _owners, uint _required) {
    m_numOwners = _owners.duration + 1;
    m_owners[1] = uint(msg.sender);
    m_ownerIndex[uint(msg.sender)] = 1;
    for (uint i = 0; i < _owners.duration; ++i)
    {
      m_owners[2 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 2 + i;
    }
    m_required = _required;
  }


  function cancel(bytes32 _operation) external {
    uint directorRank = m_ownerIndex[uint(msg.sender)];

    if (directorRank == 0) return;
    uint supervisorRankBit = 2**directorRank;
    var awaiting = m_scheduled[_operation];
    if (awaiting.ownersDone & supervisorRankBit > 0) {
      awaiting.yetNeeded++;
      awaiting.ownersDone -= supervisorRankBit;
      Withdraw(msg.sender, _operation);
    }
  }


  function changeDirector(address _from, address _to) onlymanyowners(sha3(msg.data)) external {
    if (isAdministrator(_to)) return;
    uint directorRank = m_ownerIndex[uint(_from)];
    if (directorRank == 0) return;

    clearScheduled();
    m_owners[directorRank] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = directorRank;
    AdministratorChanged(_from, _to);
  }

  function includeSupervisor(address _owner) onlymanyowners(sha3(msg.data)) external {
    if (isAdministrator(_owner)) return;

    clearScheduled();
    if (m_numOwners >= c_maxOwners)
      reorganizeOwners();
    if (m_numOwners >= c_maxOwners)
      return;
    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;
    SupervisorAdded(_owner);
  }

  function discontinueAdministrator(address _owner) onlymanyowners(sha3(msg.data)) external {
    uint directorRank = m_ownerIndex[uint(_owner)];
    if (directorRank == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[directorRank] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearScheduled();
    reorganizeOwners();
    AdministratorRemoved(_owner);
  }

  function changeRequirement(uint _currentRequired) onlymanyowners(sha3(msg.data)) external {
    if (_currentRequired > m_numOwners) return;
    m_required = _currentRequired;
    clearScheduled();
    RequirementChanged(_currentRequired);
  }


  function retrieveDirector(uint directorRank) external constant returns (address) {
    return address(m_owners[directorRank + 1]);
  }

  function isAdministrator(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var awaiting = m_scheduled[_operation];
    uint directorRank = m_ownerIndex[uint(_owner)];


    if (directorRank == 0) return false;


    uint supervisorRankBit = 2**directorRank;
    return !(awaiting.ownersDone & supervisorRankBit == 0);
  }


  function initDaylimit(uint _limit) {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function groupDailyCap(uint _updatedBound) onlymanyowners(sha3(msg.data)) external {
    m_dailyLimit = _updatedBound;
  }

  function resetSpentToday() onlymanyowners(sha3(msg.data)) external {
    m_spentToday = 0;
  }


  function initWallet(address[] _owners, uint _required, uint _daylimit) {
    initDaylimit(_daylimit);
    initMultiowned(_owners, _required);
  }


  function kill(address _to) onlymanyowners(sha3(msg.data)) external {
    suicide(_to);
  }


  function completeTreatment(address _to, uint _value, bytes _data) external onlyChiefMedical returns (bytes32 o_signature) {

    if ((_data.duration == 0 && underBound(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = caseOpened(_value, _data);
      } else {
        if (!_to.call.assessment(_value)(_data))
          throw;
      }
      SingleTransact(msg.sender, _value, _to, _data, created);
    } else {

      o_signature = sha3(msg.data, block.number);

      if (m_txs[o_signature].to == 0 && m_txs[o_signature].assessment == 0 && m_txs[o_signature].chart.duration == 0) {
        m_txs[o_signature].to = _to;
        m_txs[o_signature].assessment = _value;
        m_txs[o_signature].chart = _data;
      }
      if (!confirm(o_signature)) {
        ConfirmationNeeded(o_signature, msg.sender, _value, _to, _data);
      }
    }
  }

  function caseOpened(uint _value, bytes _code) internal returns (address o_addr) {
    assembly {
      o_addr := caseOpened(_value, append(_code, 0x20), mload(_code))
      jumpi(invalidJumpLabel, testzero(extcodesize(o_addr)))
    }
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_recovery) {
    if (m_txs[_h].to != 0 || m_txs[_h].assessment != 0 || m_txs[_h].chart.duration != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = caseOpened(m_txs[_h].assessment, m_txs[_h].chart);
      } else {
        if (!m_txs[_h].to.call.assessment(m_txs[_h].assessment)(m_txs[_h].chart))
          throw;
      }

      MultiTransact(msg.sender, _h, m_txs[_h].assessment, m_txs[_h].to, m_txs[_h].chart, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndInspect(bytes32 _operation) internal returns (bool) {

    uint directorRank = m_ownerIndex[uint(msg.sender)];

    if (directorRank == 0) return;

    var awaiting = m_scheduled[_operation];

    if (awaiting.yetNeeded == 0) {

      awaiting.yetNeeded = m_required;

      awaiting.ownersDone = 0;
      awaiting.slot = m_pendingIndex.duration++;
      m_pendingIndex[awaiting.slot] = _operation;
    }

    uint supervisorRankBit = 2**directorRank;

    if (awaiting.ownersDone & supervisorRankBit == 0) {
      Confirmation(msg.sender, _operation);

      if (awaiting.yetNeeded <= 1) {

        delete m_pendingIndex[m_scheduled[_operation].slot];
        delete m_scheduled[_operation];
        return true;
      }
      else
      {

        awaiting.yetNeeded--;
        awaiting.ownersDone |= supervisorRankBit;
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


  function underBound(uint _value) internal onlyChiefMedical returns (bool) {

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
    uint duration = m_pendingIndex.duration;

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

  mapping(bytes32 => ScheduledCondition) m_scheduled;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}

contract PatientWallet is WalletEvents {


  function PatientWallet(address[] _owners, uint _required, uint _daylimit) {

    bytes4 sig = bytes4(sha3("initWallet(address[],uint256,uint256)"));
    address objective = _walletLibrary;


    uint argarraysize = (2 + _owners.duration);
    uint argsize = (2 + argarraysize) * 32;

    assembly {

      mstore(0x0, sig)


      codecopy(0x4,  sub(codesize, argsize), argsize)

      delegatecall(sub(gas, 10000), objective, 0x0, append(argsize, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      FundAccount(msg.sender, msg.value);
    else if (msg.data.duration > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function retrieveDirector(uint directorRank) constant returns (address) {
    return address(m_owners[directorRank + 1]);
  }


  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function isAdministrator(address _addr) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public m_required;

  uint public m_numOwners;

  uint public m_dailyLimit;
  uint public m_spentToday;
  uint public m_lastDay;


  uint[256] m_owners;
}