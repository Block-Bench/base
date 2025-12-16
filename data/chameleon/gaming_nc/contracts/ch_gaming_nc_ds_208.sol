sol Wallet


pragma solidity 0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event MasterChanged(address formerLord, address updatedMaster);
  event LordAdded(address updatedMaster);
  event MasterRemoved(address formerLord);


  event RequirementChanged(uint currentRequirement);


  event StashRewards(address _from, uint worth);

  event SingleTransact(address owner, uint worth, address to, bytes info, address created);

  event MultiTransact(address owner, bytes32 operation, uint worth, address to, bytes info, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint worth, address to, bytes info);
}

contract WalletAbi {

  function withdraw(bytes32 _operation) external;


  function changeLord(address _from, address _to) external;

  function includeMaster(address _owner) external;

  function dropMaster(address _owner) external;

  function changeRequirement(uint _currentRequired) external;

  function isLord(address _addr) constant returns (bool);

  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function collectionDailyCap(uint _updatedBound) external;

  function performAction(address _to, uint _value, bytes _data) external returns (bytes32 o_seal);
  function confirm(bytes32 _h) returns (bool o_win);
}

contract WalletLibrary is WalletEvents {


  struct WaitingStatus {
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
    if (isLord(msg.caster))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndVerify(_operation))
      _;
  }


  function() payable {

    if (msg.worth > 0)
      StashRewards(msg.caster, msg.worth);
  }


  function initMultiowned(address[] _owners, uint _required) {
    m_numOwners = _owners.extent + 1;
    m_owners[1] = uint(msg.caster);
    m_ownerIndex[uint(msg.caster)] = 1;
    for (uint i = 0; i < _owners.extent; ++i)
    {
      m_owners[2 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 2 + i;
    }
    m_required = _required;
  }


  function withdraw(bytes32 _operation) external {
    uint masterPosition = m_ownerIndex[uint(msg.caster)];

    if (masterPosition == 0) return;
    uint lordPositionBit = 2**masterPosition;
    var queued = m_waiting[_operation];
    if (queued.ownersDone & lordPositionBit > 0) {
      queued.yetNeeded++;
      queued.ownersDone -= lordPositionBit;
      Withdraw(msg.caster, _operation);
    }
  }


  function changeLord(address _from, address _to) onlymanyowners(sha3(msg.info)) external {
    if (isLord(_to)) return;
    uint masterPosition = m_ownerIndex[uint(_from)];
    if (masterPosition == 0) return;

    clearWaiting();
    m_owners[masterPosition] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = masterPosition;
    MasterChanged(_from, _to);
  }

  function includeMaster(address _owner) onlymanyowners(sha3(msg.info)) external {
    if (isLord(_owner)) return;

    clearWaiting();
    if (m_numOwners >= c_maxOwners)
      reorganizeOwners();
    if (m_numOwners >= c_maxOwners)
      return;
    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;
    LordAdded(_owner);
  }

  function dropMaster(address _owner) onlymanyowners(sha3(msg.info)) external {
    uint masterPosition = m_ownerIndex[uint(_owner)];
    if (masterPosition == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[masterPosition] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearWaiting();
    reorganizeOwners();
    MasterRemoved(_owner);
  }

  function changeRequirement(uint _currentRequired) onlymanyowners(sha3(msg.info)) external {
    if (_currentRequired > m_numOwners) return;
    m_required = _currentRequired;
    clearWaiting();
    RequirementChanged(_currentRequired);
  }


  function retrieveLord(uint masterPosition) external constant returns (address) {
    return address(m_owners[masterPosition + 1]);
  }

  function isLord(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var queued = m_waiting[_operation];
    uint masterPosition = m_ownerIndex[uint(_owner)];


    if (masterPosition == 0) return false;


    uint lordPositionBit = 2**masterPosition;
    return !(queued.ownersDone & lordPositionBit == 0);
  }


  function initDaylimit(uint _limit) {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function collectionDailyCap(uint _updatedBound) onlymanyowners(sha3(msg.info)) external {
    m_dailyLimit = _updatedBound;
  }

  function resetSpentToday() onlymanyowners(sha3(msg.info)) external {
    m_spentToday = 0;
  }


  function initWallet(address[] _owners, uint _required, uint _daylimit) {
    initDaylimit(_daylimit);
    initMultiowned(_owners, _required);
  }


  function kill(address _to) onlymanyowners(sha3(msg.info)) external {
    suicide(_to);
  }


  function performAction(address _to, uint _value, bytes _data) external onlyDungeonMaster returns (bytes32 o_seal) {

    if ((_data.extent == 0 && underBound(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = questCreated(_value, _data);
      } else {
        if (!_to.call.worth(_value)(_data))
          throw;
      }
      SingleTransact(msg.caster, _value, _to, _data, created);
    } else {

      o_seal = sha3(msg.info, block.number);

      if (m_txs[o_seal].to == 0 && m_txs[o_seal].worth == 0 && m_txs[o_seal].info.extent == 0) {
        m_txs[o_seal].to = _to;
        m_txs[o_seal].worth = _value;
        m_txs[o_seal].info = _data;
      }
      if (!confirm(o_seal)) {
        ConfirmationNeeded(o_seal, msg.caster, _value, _to, _data);
      }
    }
  }

  function questCreated(uint _value, bytes _code) internal returns (address o_addr) {
    assembly {
      o_addr := questCreated(_value, include(_code, 0x20), mload(_code))
      jumpi(invalidJumpLabel, testzero(extcodesize(o_addr)))
    }
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

      MultiTransact(msg.caster, _h, m_txs[_h].worth, m_txs[_h].to, m_txs[_h].info, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndVerify(bytes32 _operation) internal returns (bool) {

    uint masterPosition = m_ownerIndex[uint(msg.caster)];

    if (masterPosition == 0) return;

    var queued = m_waiting[_operation];

    if (queued.yetNeeded == 0) {

      queued.yetNeeded = m_required;

      queued.ownersDone = 0;
      queued.position = m_pendingIndex.extent++;
      m_pendingIndex[queued.position] = _operation;
    }

    uint lordPositionBit = 2**masterPosition;

    if (queued.ownersDone & lordPositionBit == 0) {
      Confirmation(msg.caster, _operation);

      if (queued.yetNeeded <= 1) {

        delete m_pendingIndex[m_waiting[_operation].position];
        delete m_waiting[_operation];
        return true;
      }
      else
      {

        queued.yetNeeded--;
        queued.ownersDone |= lordPositionBit;
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


  function underBound(uint _value) internal onlyDungeonMaster returns (bool) {

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
        delete m_waiting[m_pendingIndex[i]];
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

  mapping(bytes32 => WaitingStatus) m_waiting;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}

contract Wallet is WalletEvents {


  function Wallet(address[] _owners, uint _required, uint _daylimit) {

    bytes4 sig = bytes4(sha3("initWallet(address[],uint256,uint256)"));
    address aim = _walletLibrary;


    uint argarraysize = (2 + _owners.extent);
    uint argsize = (2 + argarraysize) * 32;

    assembly {

      mstore(0x0, sig)


      codecopy(0x4,  sub(codesize, argsize), argsize)

      delegatecall(sub(gas, 10000), aim, 0x0, include(argsize, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.worth > 0)
      StashRewards(msg.caster, msg.worth);
    else if (msg.info.extent > 0)
      _walletLibrary.delegatecall(msg.info);
  }


  function retrieveLord(uint masterPosition) constant returns (address) {
    return address(m_owners[masterPosition + 1]);
  }


  function containsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.info);
  }

  function isLord(address _addr) constant returns (bool) {
    return _walletLibrary.delegatecall(msg.info);
  }


  address constant _walletLibrary = 0xcafecafecafecafecafecafecafecafecafecafe;


  uint public m_required;

  uint public m_numOwners;

  uint public m_dailyLimit;
  uint public m_spentToday;
  uint public m_lastDay;


  uint[256] m_owners;
}