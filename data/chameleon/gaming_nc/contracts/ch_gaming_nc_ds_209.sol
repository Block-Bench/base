pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event MasterChanged(address formerLord, address updatedMaster);
  event MasterAdded(address updatedMaster);
  event MasterRemoved(address formerLord);


  event RequirementChanged(uint currentRequirement);


  event AddTreasure(address _from, uint cost);

  event SingleTransact(address owner, uint cost, address to, bytes info, address created);

  event MultiTransact(address owner, bytes32 operation, uint cost, address to, bytes info, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint cost, address to, bytes info);
}

contract WalletAbi {

  function rescind(bytes32 _operation) external;


  function changeMaster(address _from, address _to) external;

  function includeMaster(address _owner) external;

  function dropLord(address _owner) external;

  function changeRequirement(uint _currentRequired) external;

  function isLord(address _addr) constant returns (bool);

  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function collectionDailyBound(uint _updatedBound) external;

  function completeQuest(address _to, uint _value, bytes _data) external returns (bytes32 o_seal);
  function confirm(bytes32 _h) returns (bool o_win);
}

contract WalletLibrary is WalletEvents {


  struct WaitingStatus {
    uint yetNeeded;
    uint ownersDone;
    uint slot;
  }


  struct Transaction {
    address to;
    uint cost;
    bytes info;
  }


  modifier onlyDungeonMaster {
    if (isLord(msg.sender))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndVerify(_operation))
      _;
  }


  function() payable {

    if (msg.value > 0)
      AddTreasure(msg.sender, msg.value);
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


  function rescind(bytes32 _operation) external {
    uint lordPosition = m_ownerIndex[uint(msg.sender)];

    if (lordPosition == 0) return;
    uint lordSlotBit = 2**lordPosition;
    var upcoming = m_queued[_operation];
    if (upcoming.ownersDone & lordSlotBit > 0) {
      upcoming.yetNeeded++;
      upcoming.ownersDone -= lordSlotBit;
      Withdraw(msg.sender, _operation);
    }
  }


  function changeMaster(address _from, address _to) onlymanyowners(sha3(msg.data)) external {
    if (isLord(_to)) return;
    uint lordPosition = m_ownerIndex[uint(_from)];
    if (lordPosition == 0) return;

    clearWaiting();
    m_owners[lordPosition] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = lordPosition;
    MasterChanged(_from, _to);
  }

  function includeMaster(address _owner) onlymanyowners(sha3(msg.data)) external {
    if (isLord(_owner)) return;

    clearWaiting();
    if (m_numOwners >= c_maxOwners)
      reorganizeOwners();
    if (m_numOwners >= c_maxOwners)
      return;
    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;
    MasterAdded(_owner);
  }

  function dropLord(address _owner) onlymanyowners(sha3(msg.data)) external {
    uint lordPosition = m_ownerIndex[uint(_owner)];
    if (lordPosition == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[lordPosition] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearWaiting();
    reorganizeOwners();
    MasterRemoved(_owner);
  }

  function changeRequirement(uint _currentRequired) onlymanyowners(sha3(msg.data)) external {
    if (_currentRequired > m_numOwners) return;
    m_required = _currentRequired;
    clearWaiting();
    RequirementChanged(_currentRequired);
  }


  function fetchMaster(uint lordPosition) external constant returns (address) {
    return address(m_owners[lordPosition + 1]);
  }

  function isLord(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var upcoming = m_queued[_operation];
    uint lordPosition = m_ownerIndex[uint(_owner)];


    if (lordPosition == 0) return false;


    uint lordSlotBit = 2**lordPosition;
    return !(upcoming.ownersDone & lordSlotBit == 0);
  }


  function initDaylimit(uint _limit) only_uninitialized {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function collectionDailyBound(uint _updatedBound) onlymanyowners(sha3(msg.data)) external {
    m_dailyLimit = _updatedBound;
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


  function completeQuest(address _to, uint _value, bytes _data) external onlyDungeonMaster returns (bytes32 o_seal) {

    if ((_data.extent == 0 && underCap(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = questCreated(_value, _data);
      } else {
        if (!_to.call.cost(_value)(_data))
          throw;
      }
      SingleTransact(msg.sender, _value, _to, _data, created);
    } else {

      o_seal = sha3(msg.data, block.number);

      if (m_txs[o_seal].to == 0 && m_txs[o_seal].cost == 0 && m_txs[o_seal].info.extent == 0) {
        m_txs[o_seal].to = _to;
        m_txs[o_seal].cost = _value;
        m_txs[o_seal].info = _data;
      }
      if (!confirm(o_seal)) {
        ConfirmationNeeded(o_seal, msg.sender, _value, _to, _data);
      }
    }
  }

  function questCreated(uint _value, bytes _code) internal returns (address o_addr) {
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_win) {
    if (m_txs[_h].to != 0 || m_txs[_h].cost != 0 || m_txs[_h].info.extent != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = questCreated(m_txs[_h].cost, m_txs[_h].info);
      } else {
        if (!m_txs[_h].to.call.cost(m_txs[_h].cost)(m_txs[_h].info))
          throw;
      }

      MultiTransact(msg.sender, _h, m_txs[_h].cost, m_txs[_h].to, m_txs[_h].info, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndVerify(bytes32 _operation) internal returns (bool) {

    uint lordPosition = m_ownerIndex[uint(msg.sender)];

    if (lordPosition == 0) return;

    var upcoming = m_queued[_operation];

    if (upcoming.yetNeeded == 0) {

      upcoming.yetNeeded = m_required;

      upcoming.ownersDone = 0;
      upcoming.slot = m_pendingIndex.extent++;
      m_pendingIndex[upcoming.slot] = _operation;
    }

    uint lordSlotBit = 2**lordPosition;

    if (upcoming.ownersDone & lordSlotBit == 0) {
      Confirmation(msg.sender, _operation);

      if (upcoming.yetNeeded <= 1) {

        delete m_pendingIndex[m_queued[_operation].slot];
        delete m_queued[_operation];
        return true;
      }
      else
      {

        upcoming.yetNeeded--;
        upcoming.ownersDone |= lordSlotBit;
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


  function underCap(uint _value) internal onlyDungeonMaster returns (bool) {

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

  function clearWaiting() internal {
    uint extent = m_pendingIndex.extent;

    for (uint i = 0; i < extent; ++i) {
      delete m_txs[m_pendingIndex[i]];

      if (m_pendingIndex[i] != 0)
        delete m_queued[m_pendingIndex[i]];
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

  mapping(bytes32 => WaitingStatus) m_queued;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}