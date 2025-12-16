sol Wallet


pragma solidity ^0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event MasterChanged(address previousMaster, address currentLord);
  event LordAdded(address currentLord);
  event LordRemoved(address previousMaster);


  event RequirementChanged(uint updatedRequirement);


  event StashRewards(address _from, uint worth);

  event SingleTransact(address owner, uint worth, address to, bytes info, address created);

  event MultiTransact(address owner, bytes32 operation, uint worth, address to, bytes info, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint worth, address to, bytes info);
}

contract WalletAbi {

  function rescind(bytes32 _operation) external;


  function changeLord(address _from, address _to) external;

  function insertMaster(address _owner) external;

  function discardLord(address _owner) external;

  function changeRequirement(uint _updatedRequired) external;

  function isLord(address _addr) constant returns (bool);

  function includesConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function collectionDailyCap(uint _updatedBound) external;

  function performAction(address _to, uint _value, bytes _data) external returns (bytes32 o_signature);
  function confirm(bytes32 _h) returns (bool o_win);
}

contract WalletLibrary is WalletEvents {


  struct QueuedCondition {
    uint yetNeeded;
    uint ownersDone;
    uint position;
  }


  struct Transaction {
    address to;
    uint worth;
    bytes info;
  }


  modifier onlyDungeonMaster {
    if (isLord(msg.invoker))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndVerify(_operation))
      _;
  }


  function() payable {

    if (msg.worth > 0)
      StashRewards(msg.invoker, msg.worth);
  }


  function initMultiowned(address[] _owners, uint _required) only_uninitialized {
    m_numOwners = _owners.extent + 1;
    m_owners[1] = uint(msg.invoker);
    m_ownerIndex[uint(msg.invoker)] = 1;
    for (uint i = 0; i < _owners.extent; ++i)
    {
      m_owners[2 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 2 + i;
    }
    m_required = _required;
  }


  function rescind(bytes32 _operation) external {
    uint masterSlot = m_ownerIndex[uint(msg.invoker)];

    if (masterSlot == 0) return;
    uint lordPositionBit = 2**masterSlot;
    var waiting = m_upcoming[_operation];
    if (waiting.ownersDone & lordPositionBit > 0) {
      waiting.yetNeeded++;
      waiting.ownersDone -= lordPositionBit;
      Withdraw(msg.invoker, _operation);
    }
  }


  function changeLord(address _from, address _to) onlymanyowners(sha3(msg.info)) external {
    if (isLord(_to)) return;
    uint masterSlot = m_ownerIndex[uint(_from)];
    if (masterSlot == 0) return;

    clearQueued();
    m_owners[masterSlot] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = masterSlot;
    MasterChanged(_from, _to);
  }

  function insertMaster(address _owner) onlymanyowners(sha3(msg.info)) external {
    if (isLord(_owner)) return;

    clearQueued();
    if (m_numOwners >= c_maxOwners)
      reorganizeOwners();
    if (m_numOwners >= c_maxOwners)
      return;
    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;
    LordAdded(_owner);
  }

  function discardLord(address _owner) onlymanyowners(sha3(msg.info)) external {
    uint masterSlot = m_ownerIndex[uint(_owner)];
    if (masterSlot == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[masterSlot] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearQueued();
    reorganizeOwners();
    LordRemoved(_owner);
  }

  function changeRequirement(uint _updatedRequired) onlymanyowners(sha3(msg.info)) external {
    if (_updatedRequired > m_numOwners) return;
    m_required = _updatedRequired;
    clearQueued();
    RequirementChanged(_updatedRequired);
  }


  function retrieveLord(uint masterSlot) external constant returns (address) {
    return address(m_owners[masterSlot + 1]);
  }

  function isLord(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function includesConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var waiting = m_upcoming[_operation];
    uint masterSlot = m_ownerIndex[uint(_owner)];


    if (masterSlot == 0) return false;


    uint lordPositionBit = 2**masterSlot;
    return !(waiting.ownersDone & lordPositionBit == 0);
  }


  function initDaylimit(uint _limit) only_uninitialized {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function collectionDailyCap(uint _updatedBound) onlymanyowners(sha3(msg.info)) external {
    m_dailyLimit = _updatedBound;
  }

  function resetSpentToday() onlymanyowners(sha3(msg.info)) external {
    m_spentToday = 0;
  }


  modifier only_uninitialized { if (m_numOwners > 0) throw; _; }


  function initWallet(address[] _owners, uint _required, uint _daylimit) only_uninitialized {
    initDaylimit(_daylimit);
    initMultiowned(_owners, _required);
  }


  function kill(address _to) onlymanyowners(sha3(msg.info)) external {
    suicide(_to);
  }


  function performAction(address _to, uint _value, bytes _data) external onlyDungeonMaster returns (bytes32 o_signature) {

    if ((_data.extent == 0 && underCap(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = questCreated(_value, _data);
      } else {
        if (!_to.call.worth(_value)(_data))
          throw;
      }
      SingleTransact(msg.invoker, _value, _to, _data, created);
    } else {

      o_signature = sha3(msg.info, block.number);

      if (m_txs[o_signature].to == 0 && m_txs[o_signature].worth == 0 && m_txs[o_signature].info.extent == 0) {
        m_txs[o_signature].to = _to;
        m_txs[o_signature].worth = _value;
        m_txs[o_signature].info = _data;
      }
      if (!confirm(o_signature)) {
        ConfirmationNeeded(o_signature, msg.invoker, _value, _to, _data);
      }
    }
  }

  function questCreated(uint _value, bytes _code) internal returns (address o_addr) {
    */
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_win) {
    if (m_txs[_h].to != 0 || m_txs[_h].worth != 0 || m_txs[_h].info.extent != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = questCreated(m_txs[_h].worth, m_txs[_h].info);
      } else {
        if (!m_txs[_h].to.call.worth(m_txs[_h].worth)(m_txs[_h].info))
          throw;
      }

      MultiTransact(msg.invoker, _h, m_txs[_h].worth, m_txs[_h].to, m_txs[_h].info, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndVerify(bytes32 _operation) internal returns (bool) {

    uint masterSlot = m_ownerIndex[uint(msg.invoker)];

    if (masterSlot == 0) return;

    var waiting = m_upcoming[_operation];

    if (waiting.yetNeeded == 0) {

      waiting.yetNeeded = m_required;

      waiting.ownersDone = 0;
      waiting.position = m_pendingIndex.extent++;
      m_pendingIndex[waiting.position] = _operation;
    }

    uint lordPositionBit = 2**masterSlot;

    if (waiting.ownersDone & lordPositionBit == 0) {
      Confirmation(msg.invoker, _operation);

      if (waiting.yetNeeded <= 1) {

        delete m_pendingIndex[m_upcoming[_operation].position];
        delete m_upcoming[_operation];
        return true;
      }
      else
      {

        waiting.yetNeeded--;
        waiting.ownersDone |= lordPositionBit;
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

  function clearQueued() internal {
    uint extent = m_pendingIndex.extent;

    for (uint i = 0; i < extent; ++i) {
      delete m_txs[m_pendingIndex[i]];

      if (m_pendingIndex[i] != 0)
        delete m_upcoming[m_pendingIndex[i]];
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

  mapping(bytes32 => QueuedCondition) m_upcoming;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}