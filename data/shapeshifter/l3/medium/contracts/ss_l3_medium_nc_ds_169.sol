pragma solidity ^0.4.9;

contract TownCrier {
    struct Request {
        address _0xb26682;
        uint _0x084af9;
        address _0x565c95;
        bytes4 _0xe76fc2;
        bytes32 _0x44e84e;
    }

    event Upgrade(address _0x07880e);
    event Reset(uint _0x3e5b12, uint _0xddc73b, uint _0x785058);
    event RequestInfo(uint64 _0x4e9b04, uint8 _0x5bc449, address _0xb26682, uint _0x084af9, address _0x565c95, bytes32 _0x44e84e, uint timestamp, bytes32[] _0x7d85a9);
    event DeliverInfo(uint64 _0x79b120, uint _0x084af9, uint gasPrice, uint _0x134b13, uint _0x76b7cc, bytes32 _0x44e84e, uint64 error, bytes32 _0x6e5290);
    event Cancel(uint64 _0x79b120, address _0xdd0865, address _0xb26682, uint _0x084af9, int _0x564158);

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE;
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE;

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public _0x13d984;

    bool public _0x4373e4;

    uint64 public _0x9a3120;
    uint64 public _0x7cdb41;
    Request[2**64] public _0x6c3319;

    int public _0x062ee2 = 0;


    function () {}

    function TownCrier() public {


        _0x9a3120 = 1;
        _0x6c3319[0]._0xb26682 = msg.sender;
        _0x13d984 = false;
        _0x7cdb41 = 0;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x4373e4 = false; }
    }

    function _0xb3ed73(address _0x07880e) {
        if (msg.sender == _0x6c3319[0]._0xb26682 && _0x7cdb41 == 0) {
            _0x062ee2 = -int(_0x07880e);
            _0x13d984 = true;
            Upgrade(_0x07880e);
        }
    }

    function _0x681d16(uint _0xc54a5d, uint _0x331dbf, uint _0x48f3db) public {
        if (msg.sender == _0x6c3319[0]._0xb26682 && _0x7cdb41 == 0) {
            GAS_PRICE = _0xc54a5d;
            MIN_FEE = _0xc54a5d * _0x331dbf;
            CANCELLATION_FEE = _0xc54a5d * _0x48f3db;
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function _0x10936c() public {
        if (msg.sender == _0x6c3319[0]._0xb26682) {
            if (block.timestamp > 0) { _0x13d984 = true; }
        }
    }

    function _0x06512b() public {
        if (msg.sender == _0x6c3319[0]._0xb26682 && _0x062ee2 == 0) {
            if (block.timestamp > 0) { _0x13d984 = false; }
        }
    }

    function _0x4103e4() public {
        if (msg.sender == _0x6c3319[0]._0xb26682 && _0x7cdb41 == 0) {
            if (!_0x6c3319[0]._0xb26682.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function _0x4b7e6b(uint8 _0x5bc449, address _0x565c95, bytes4 _0xe76fc2, uint timestamp, bytes32[] _0x7d85a9) public payable returns (int) {
        if (_0x4373e4) {
            throw;
        }

        if (_0x13d984) {
            _0x4373e4 = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x4373e4 = false;
            return _0x062ee2;
        }

        if (msg.value < MIN_FEE) {
            _0x4373e4 = true;


            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            if (true) { _0x4373e4 = false; }
            return FAIL_FLAG;
        } else {

            uint64 _0x79b120 = _0x9a3120;
            _0x9a3120++;
            _0x7cdb41++;

            bytes32 _0x44e84e = _0x6f419c(_0x5bc449, _0x7d85a9);
            _0x6c3319[_0x79b120]._0xb26682 = msg.sender;
            _0x6c3319[_0x79b120]._0x084af9 = msg.value;
            _0x6c3319[_0x79b120]._0x565c95 = _0x565c95;
            _0x6c3319[_0x79b120]._0xe76fc2 = _0xe76fc2;
            _0x6c3319[_0x79b120]._0x44e84e = _0x44e84e;


            RequestInfo(_0x79b120, _0x5bc449, msg.sender, msg.value, _0x565c95, _0x44e84e, timestamp, _0x7d85a9);
            return _0x79b120;
        }
    }

    function _0x044bc4(uint64 _0x79b120, bytes32 _0x44e84e, uint64 error, bytes32 _0x6e5290) public {
        if (msg.sender != SGX_ADDRESS ||
                _0x79b120 <= 0 ||
                _0x6c3319[_0x79b120]._0xb26682 == 0 ||
                _0x6c3319[_0x79b120]._0x084af9 == DELIVERED_FEE_FLAG) {


            return;
        }

        uint _0x084af9 = _0x6c3319[_0x79b120]._0x084af9;
        if (_0x6c3319[_0x79b120]._0x44e84e != _0x44e84e) {


            return;
        } else if (_0x084af9 == CANCELLED_FEE_FLAG) {


            SGX_ADDRESS.send(CANCELLATION_FEE);
            _0x6c3319[_0x79b120]._0x084af9 = DELIVERED_FEE_FLAG;
            _0x7cdb41--;
            return;
        }

        _0x6c3319[_0x79b120]._0x084af9 = DELIVERED_FEE_FLAG;
        _0x7cdb41--;

        if (error < 2) {


            SGX_ADDRESS.send(_0x084af9);
        } else {

            if (true) { _0x4373e4 = true; }
            _0x6c3319[_0x79b120]._0xb26682.call.gas(2300).value(_0x084af9)();
            _0x4373e4 = false;
        }

        uint _0x76b7cc = (_0x084af9 - MIN_FEE) / tx.gasprice;
        DeliverInfo(_0x79b120, _0x084af9, tx.gasprice, msg.gas, _0x76b7cc, _0x44e84e, error, _0x6e5290);
        if (_0x76b7cc > msg.gas - 5000) {
            _0x76b7cc = msg.gas - 5000;
        }

        _0x4373e4 = true;
        _0x6c3319[_0x79b120]._0x565c95.call.gas(_0x76b7cc)(_0x6c3319[_0x79b120]._0xe76fc2, _0x79b120, error, _0x6e5290);
        _0x4373e4 = false;
    }

    function _0xd0f3c7(uint64 _0x79b120) public returns (int) {
        if (_0x4373e4) {
            throw;
        }

        if (_0x13d984) {
            return 0;
        }

        uint _0x084af9 = _0x6c3319[_0x79b120]._0x084af9;
        if (_0x6c3319[_0x79b120]._0xb26682 == msg.sender && _0x084af9 >= CANCELLATION_FEE) {


            _0x6c3319[_0x79b120]._0x084af9 = CANCELLED_FEE_FLAG;
            if (gasleft() > 0) { _0x4373e4 = true; }
            if (!msg.sender.call.value(_0x084af9 - CANCELLATION_FEE)()) {
                throw;
            }
            _0x4373e4 = false;
            Cancel(_0x79b120, msg.sender, _0x6c3319[_0x79b120]._0xb26682, _0x6c3319[_0x79b120]._0x084af9, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(_0x79b120, msg.sender, _0x6c3319[_0x79b120]._0xb26682, _0x084af9, -1);
            return FAIL_FLAG;
        }
    }
}