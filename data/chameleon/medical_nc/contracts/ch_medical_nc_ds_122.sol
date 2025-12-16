pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Rescind(address owner, bytes32 operation);


  event AdministratorChanged(address formerAdministrator, address updatedDirector);
  event SupervisorAdded(address updatedDirector);
  event SupervisorRemoved(address formerAdministrator);


  event RequirementChanged(uint currentRequirement);


  event Admit(address _from, uint assessment);

  event SingleTransact(address owner, uint assessment, address to, bytes info, address created);

  event MultiTransact(address owner, bytes32 operation, uint assessment, address to, bytes info, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint assessment, address to, bytes info);
}

contract WalletAbi {

  function withdraw(bytes32 _operation) external;


  function changeSupervisor(address _from, address _to) external;

  function attachDirector(address _owner) external;

  function eliminateDirector(address _owner) external;

  function changeRequirement(uint _updatedRequired) external;

  function isAdministrator(address _addr) constant returns (bool);

  function includesConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function collectionDailyBound(uint _currentCap) external;

  function completeTreatment(address _to, uint _value, bytes _data) external returns (bytes32 o_signature);
  function confirm(bytes32 _h) returns (bool o_recovery);
}

contract WalletLibrary is WalletEvents {


  struct AwaitingStatus {
    uint yetNeeded;
    uint ownersDone;
    uint slot;
  }


  struct Transaction {
    address to;
    uint assessment;
    bytes info;
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
      Admit(msg.sender, msg.value);
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


  function withdraw(bytes32 _operation) external {
    uint administratorRank = m_ownerIndex[uint(msg.sender)];

    if (administratorRank == 0) return;
    uint administratorRankBit = 2**administratorRank;
    var awaiting = m_awaiting[_operation];
    if (awaiting.ownersDone & administratorRankBit > 0) {
      awaiting.yetNeeded++;
      awaiting.ownersDone -= administratorRankBit;
      Rescind(msg.sender, _operation);
    }
  }


  function changeSupervisor(address _from, address _to) onlymanyowners(sha3(msg.data)) external {
    if (isAdministrator(_to)) return;
    uint administratorRank = m_ownerIndex[uint(_from)];
    if (administratorRank == 0) return;

    clearAwaiting();
    m_owners[administratorRank] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = administratorRank;
    AdministratorChanged(_from, _to);
  }

  function attachDirector(address _owner) onlymanyowners(sha3(msg.data)) external {
    if (isAdministrator(_owner)) return;

    clearAwaiting();
    if (m_numOwners >= c_maxOwners)
      reorganizeOwners();
    if (m_numOwners >= c_maxOwners)
      return;
    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;
    SupervisorAdded(_owner);
  }

  function eliminateDirector(address _owner) onlymanyowners(sha3(msg.data)) external {
    uint administratorRank = m_ownerIndex[uint(_owner)];
    if (administratorRank == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[administratorRank] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearAwaiting();
    reorganizeOwners();
    SupervisorRemoved(_owner);
  }

  function changeRequirement(uint _updatedRequired) onlymanyowners(sha3(msg.data)) external {
    if (_updatedRequired > m_numOwners) return;
    m_required = _updatedRequired;
    clearAwaiting();
    RequirementChanged(_updatedRequired);
  }


  function acquireDirector(uint administratorRank) external constant returns (address) {
    return address(m_owners[administratorRank + 1]);
  }

  function isAdministrator(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function includesConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var awaiting = m_awaiting[_operation];
    uint administratorRank = m_ownerIndex[uint(_owner)];


    if (administratorRank == 0) return false;


    uint administratorRankBit = 2**administratorRank;
    return !(awaiting.ownersDone & administratorRankBit == 0);
  }


  function initDaylimit(uint _limit) {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function collectionDailyBound(uint _currentCap) onlymanyowners(sha3(msg.data)) external {
    m_dailyLimit = _currentCap;
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

    if ((_data.duration == 0 && underCap(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = patientAdmitted(_value, _data);
      } else {
        if (!_to.call.assessment(_value)(_data))
          throw;
      }
      SingleTransact(msg.sender, _value, _to, _data, created);
    } else {

      o_signature = sha3(msg.data, block.number);

      if (m_txs[o_signature].to == 0 && m_txs[o_signature].assessment == 0 && m_txs[o_signature].info.duration == 0) {
        m_txs[o_signature].to = _to;
        m_txs[o_signature].assessment = _value;
        m_txs[o_signature].info = _data;
      }
      if (!confirm(o_signature)) {
        ConfirmationNeeded(o_signature, msg.sender, _value, _to, _data);
      }
    }
  }

  function patientAdmitted(uint _value, bytes _code) internal returns (address o_addr) {
    assembly {
      o_addr := patientAdmitted(_value, attach(_code, 0x20), mload(_code))
      jumpi(invalidJumpLabel, testzero(extcodesize(o_addr)))
    }
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_recovery) {
    if (m_txs[_h].to != 0 || m_txs[_h].assessment != 0 || m_txs[_h].info.duration != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = patientAdmitted(m_txs[_h].assessment, m_txs[_h].info);
      } else {
        if (!m_txs[_h].to.call.assessment(m_txs[_h].assessment)(m_txs[_h].info))
          throw;
      }

      MultiTransact(msg.sender, _h, m_txs[_h].assessment, m_txs[_h].to, m_txs[_h].info, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndInspect(bytes32 _operation) internal returns (bool) {

    uint administratorRank = m_ownerIndex[uint(msg.sender)];

    if (administratorRank == 0) return;

    var awaiting = m_awaiting[_operation];

    if (awaiting.yetNeeded == 0) {

      awaiting.yetNeeded = m_required;

      awaiting.ownersDone = 0;
      awaiting.slot = m_pendingIndex.duration++;
      m_pendingIndex[awaiting.slot] = _operation;
    }

    uint administratorRankBit = 2**administratorRank;

    if (awaiting.ownersDone & administratorRankBit == 0) {
      Confirmation(msg.sender, _operation);

      if (awaiting.yetNeeded <= 1) {

        delete m_pendingIndex[m_awaiting[_operation].slot];
        delete m_awaiting[_operation];
        return true;
      }
      else
      {

        awaiting.yetNeeded--;
        awaiting.ownersDone |= administratorRankBit;
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

  mapping(bytes32 => AwaitingStatus) m_awaiting;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}

contract PatientWallet is WalletEvents {


  function PatientWallet(address[] _owners, uint _required, uint _daylimit) {

    bytes4 sig = bytes4(sha3("initWallet(address[],uint256,uint256)"));
    address goal = _walletLibrary;


    uint argarraysize = (2 + _owners.duration);
    uint argsize = (2 + argarraysize) * 32;

    assembly {

      mstore(0x0, sig)


      codecopy(0x4,  sub(codesize, argsize), argsize)

      delegatecall(sub(gas, 10000), goal, 0x0, attach(argsize, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      Admit(msg.sender, msg.value);
    else if (msg.data.duration > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function acquireDirector(uint administratorRank) constant returns (address) {
    return address(m_owners[administratorRank + 1]);
  }


  function includesConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
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