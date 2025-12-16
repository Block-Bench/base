pragma solidity 0.4.9;

contract WalletEvents {


  event Confirmation(address owner, bytes32 operation);
  event Withdraw(address owner, bytes32 operation);


  event LordChanged(address previousLord, address currentMaster);
  event LordAdded(address currentMaster);
  event LordRemoved(address previousLord);


  event RequirementChanged(uint currentRequirement);


  event StoreLoot(address _from, uint price);

  event SingleTransact(address owner, uint price, address to, bytes info, address created);

  event MultiTransact(address owner, bytes32 operation, uint price, address to, bytes info, address created);

  event ConfirmationNeeded(bytes32 operation, address initiator, uint price, address to, bytes info);
}

contract WalletAbi {

  function rescind(bytes32 _operation) external;


  function changeLord(address _from, address _to) external;

  function attachLord(address _owner) external;

  function deleteLord(address _owner) external;

  function changeRequirement(uint _currentRequired) external;

  function isLord(address _addr) constant returns (bool);

  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool);


  function collectionDailyBound(uint _updatedCap) external;

  function performAction(address _to, uint _value, bytes _data) external returns (bytes32 o_seal);
  function confirm(bytes32 _h) returns (bool o_win);
}

contract WalletLibrary is WalletEvents {


  struct WaitingCondition {
    uint yetNeeded;
    uint ownersDone;
    uint slot;
  }


  struct Transaction {
    address to;
    uint price;
    bytes info;
  }


  modifier onlyGameAdmin {
    if (isLord(msg.sender))
      _;
  }


  modifier onlymanyowners(bytes32 _operation) {
    if (confirmAndValidate(_operation))
      _;
  }


  function() payable {

    if (msg.value > 0)
      StoreLoot(msg.sender, msg.value);
  }


  function initMultiowned(address[] _owners, uint _required) {
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
    uint masterSlot = m_ownerIndex[uint(msg.sender)];

    if (masterSlot == 0) return;
    uint masterSlotBit = 2**masterSlot;
    var queued = m_queued[_operation];
    if (queued.ownersDone & masterSlotBit > 0) {
      queued.yetNeeded++;
      queued.ownersDone -= masterSlotBit;
      Withdraw(msg.sender, _operation);
    }
  }


  function changeLord(address _from, address _to) onlymanyowners(sha3(msg.data)) external {
    if (isLord(_to)) return;
    uint masterSlot = m_ownerIndex[uint(_from)];
    if (masterSlot == 0) return;

    clearWaiting();
    m_owners[masterSlot] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = masterSlot;
    LordChanged(_from, _to);
  }

  function attachLord(address _owner) onlymanyowners(sha3(msg.data)) external {
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

  function deleteLord(address _owner) onlymanyowners(sha3(msg.data)) external {
    uint masterSlot = m_ownerIndex[uint(_owner)];
    if (masterSlot == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[masterSlot] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearWaiting();
    reorganizeOwners();
    LordRemoved(_owner);
  }

  function changeRequirement(uint _currentRequired) onlymanyowners(sha3(msg.data)) external {
    if (_currentRequired > m_numOwners) return;
    m_required = _currentRequired;
    clearWaiting();
    RequirementChanged(_currentRequired);
  }


  function fetchMaster(uint masterSlot) external constant returns (address) {
    return address(m_owners[masterSlot + 1]);
  }

  function isLord(address _addr) constant returns (bool) {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    var queued = m_queued[_operation];
    uint masterSlot = m_ownerIndex[uint(_owner)];


    if (masterSlot == 0) return false;


    uint masterSlotBit = 2**masterSlot;
    return !(queued.ownersDone & masterSlotBit == 0);
  }


  function initDaylimit(uint _limit) {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  function collectionDailyBound(uint _updatedCap) onlymanyowners(sha3(msg.data)) external {
    m_dailyLimit = _updatedCap;
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


  function performAction(address _to, uint _value, bytes _data) external onlyGameAdmin returns (bytes32 o_seal) {

    if ((_data.extent == 0 && underBound(_value)) || m_required == 1) {

      address created;
      if (_to == 0) {
        created = missionStarted(_value, _data);
      } else {
        if (!_to.call.price(_value)(_data))
          throw;
      }
      SingleTransact(msg.sender, _value, _to, _data, created);
    } else {

      o_seal = sha3(msg.data, block.number);

      if (m_txs[o_seal].to == 0 && m_txs[o_seal].price == 0 && m_txs[o_seal].info.extent == 0) {
        m_txs[o_seal].to = _to;
        m_txs[o_seal].price = _value;
        m_txs[o_seal].info = _data;
      }
      if (!confirm(o_seal)) {
        ConfirmationNeeded(o_seal, msg.sender, _value, _to, _data);
      }
    }
  }

  function missionStarted(uint _value, bytes _code) internal returns (address o_addr) {
    assembly {
      o_addr := missionStarted(_value, include(_code, 0x20), mload(_code))
      jumpi(invalidJumpLabel, verifyzero(extcodesize(o_addr)))
    }
  }


  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_win) {
    if (m_txs[_h].to != 0 || m_txs[_h].price != 0 || m_txs[_h].info.extent != 0) {
      address created;
      if (m_txs[_h].to == 0) {
        created = missionStarted(m_txs[_h].price, m_txs[_h].info);
      } else {
        if (!m_txs[_h].to.call.price(m_txs[_h].price)(m_txs[_h].info))
          throw;
      }

      MultiTransact(msg.sender, _h, m_txs[_h].price, m_txs[_h].to, m_txs[_h].info, created);
      delete m_txs[_h];
      return true;
    }
  }


  function confirmAndValidate(bytes32 _operation) internal returns (bool) {

    uint masterSlot = m_ownerIndex[uint(msg.sender)];

    if (masterSlot == 0) return;

    var queued = m_queued[_operation];

    if (queued.yetNeeded == 0) {

      queued.yetNeeded = m_required;

      queued.ownersDone = 0;
      queued.slot = m_pendingIndex.extent++;
      m_pendingIndex[queued.slot] = _operation;
    }

    uint masterSlotBit = 2**masterSlot;

    if (queued.ownersDone & masterSlotBit == 0) {
      Confirmation(msg.sender, _operation);

      if (queued.yetNeeded <= 1) {

        delete m_pendingIndex[m_queued[_operation].slot];
        delete m_queued[_operation];
        return true;
      }
      else
      {

        queued.yetNeeded--;
        queued.ownersDone |= masterSlotBit;
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


  function underBound(uint _value) internal onlyGameAdmin returns (bool) {

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

  mapping(bytes32 => WaitingCondition) m_queued;
  bytes32[] m_pendingIndex;


  mapping (bytes32 => Transaction) m_txs;
}

contract Wallet is WalletEvents {


  function Wallet(address[] _owners, uint _required, uint _daylimit) {

    bytes4 sig = bytes4(sha3("initWallet(address[],uint256,uint256)"));
    address goal = _walletLibrary;


    uint argarraysize = (2 + _owners.extent);
    uint argsize = (2 + argarraysize) * 32;

    assembly {

      mstore(0x0, sig)


      codecopy(0x4,  sub(codesize, argsize), argsize)

      delegatecall(sub(gas, 10000), goal, 0x0, include(argsize, 0x4), 0x0, 0x0)
    }
  }


  function() payable {

    if (msg.value > 0)
      StoreLoot(msg.sender, msg.value);
    else if (msg.data.extent > 0)
      _walletLibrary.delegatecall(msg.data);
  }


  function fetchMaster(uint masterSlot) constant returns (address) {
    return address(m_owners[masterSlot + 1]);
  }


  function holdsConfirmed(bytes32 _operation, address _owner) external constant returns (bool) {
    return _walletLibrary.delegatecall(msg.data);
  }

  function isLord(address _addr) constant returns (bool) {
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