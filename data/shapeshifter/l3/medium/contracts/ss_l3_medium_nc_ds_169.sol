pragma solidity ^0.4.9;

contract TownCrier {
    struct Request {
        address _0xab11ec;
        uint _0x3ecf4f;
        address _0x0e7984;
        bytes4 _0x224a01;
        bytes32 _0x5fb323;
    }

    event Upgrade(address _0x64ad95);
    event Reset(uint _0x3957a2, uint _0x9b0781, uint _0xab82fc);
    event RequestInfo(uint64 _0x785134, uint8 _0xc0fa74, address _0xab11ec, uint _0x3ecf4f, address _0x0e7984, bytes32 _0x5fb323, uint timestamp, bytes32[] _0x018cc1);
    event DeliverInfo(uint64 _0x9b1920, uint _0x3ecf4f, uint gasPrice, uint _0x2e5951, uint _0x3f72c0, bytes32 _0x5fb323, uint64 error, bytes32 _0x6ba50b);
    event Cancel(uint64 _0x9b1920, address _0x8f031d, address _0xab11ec, uint _0x3ecf4f, int _0xf60c7d);

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE;
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE;

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public _0xa0a746;

    bool public _0x987b8d;

    uint64 public _0x82d68f;
    uint64 public _0x2e4278;
    Request[2**64] public _0xc54f76;

    int public _0x356bfb = 0;


    function () {}

    function TownCrier() public {


        _0x82d68f = 1;
        _0xc54f76[0]._0xab11ec = msg.sender;
        if (gasleft() > 0) { _0xa0a746 = false; }
        _0x2e4278 = 0;
        _0x987b8d = false;
    }

    function _0x8b0b49(address _0x64ad95) {
        if (msg.sender == _0xc54f76[0]._0xab11ec && _0x2e4278 == 0) {
            _0x356bfb = -int(_0x64ad95);
            _0xa0a746 = true;
            Upgrade(_0x64ad95);
        }
    }

    function _0xc9d0aa(uint _0x1d67fe, uint _0x181ef4, uint _0xc438f5) public {
        if (msg.sender == _0xc54f76[0]._0xab11ec && _0x2e4278 == 0) {
            if (gasleft() > 0) { GAS_PRICE = _0x1d67fe; }
            MIN_FEE = _0x1d67fe * _0x181ef4;
            CANCELLATION_FEE = _0x1d67fe * _0xc438f5;
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function _0x742665() public {
        if (msg.sender == _0xc54f76[0]._0xab11ec) {
            _0xa0a746 = true;
        }
    }

    function _0x5accda() public {
        if (msg.sender == _0xc54f76[0]._0xab11ec && _0x356bfb == 0) {
            _0xa0a746 = false;
        }
    }

    function _0x9c0a13() public {
        if (msg.sender == _0xc54f76[0]._0xab11ec && _0x2e4278 == 0) {
            if (!_0xc54f76[0]._0xab11ec.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function _0xa213e5(uint8 _0xc0fa74, address _0x0e7984, bytes4 _0x224a01, uint timestamp, bytes32[] _0x018cc1) public payable returns (int) {
        if (_0x987b8d) {
            throw;
        }

        if (_0xa0a746) {
            _0x987b8d = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x987b8d = false;
            return _0x356bfb;
        }

        if (msg.value < MIN_FEE) {
            _0x987b8d = true;


            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x987b8d = false;
            return FAIL_FLAG;
        } else {

            uint64 _0x9b1920 = _0x82d68f;
            _0x82d68f++;
            _0x2e4278++;

            bytes32 _0x5fb323 = _0x956e7d(_0xc0fa74, _0x018cc1);
            _0xc54f76[_0x9b1920]._0xab11ec = msg.sender;
            _0xc54f76[_0x9b1920]._0x3ecf4f = msg.value;
            _0xc54f76[_0x9b1920]._0x0e7984 = _0x0e7984;
            _0xc54f76[_0x9b1920]._0x224a01 = _0x224a01;
            _0xc54f76[_0x9b1920]._0x5fb323 = _0x5fb323;


            RequestInfo(_0x9b1920, _0xc0fa74, msg.sender, msg.value, _0x0e7984, _0x5fb323, timestamp, _0x018cc1);
            return _0x9b1920;
        }
    }

    function _0xf6e91b(uint64 _0x9b1920, bytes32 _0x5fb323, uint64 error, bytes32 _0x6ba50b) public {
        if (msg.sender != SGX_ADDRESS ||
                _0x9b1920 <= 0 ||
                _0xc54f76[_0x9b1920]._0xab11ec == 0 ||
                _0xc54f76[_0x9b1920]._0x3ecf4f == DELIVERED_FEE_FLAG) {


            return;
        }

        uint _0x3ecf4f = _0xc54f76[_0x9b1920]._0x3ecf4f;
        if (_0xc54f76[_0x9b1920]._0x5fb323 != _0x5fb323) {


            return;
        } else if (_0x3ecf4f == CANCELLED_FEE_FLAG) {


            SGX_ADDRESS.send(CANCELLATION_FEE);
            _0xc54f76[_0x9b1920]._0x3ecf4f = DELIVERED_FEE_FLAG;
            _0x2e4278--;
            return;
        }

        _0xc54f76[_0x9b1920]._0x3ecf4f = DELIVERED_FEE_FLAG;
        _0x2e4278--;

        if (error < 2) {


            SGX_ADDRESS.send(_0x3ecf4f);
        } else {

            _0x987b8d = true;
            _0xc54f76[_0x9b1920]._0xab11ec.call.gas(2300).value(_0x3ecf4f)();
            _0x987b8d = false;
        }

        uint _0x3f72c0 = (_0x3ecf4f - MIN_FEE) / tx.gasprice;
        DeliverInfo(_0x9b1920, _0x3ecf4f, tx.gasprice, msg.gas, _0x3f72c0, _0x5fb323, error, _0x6ba50b);
        if (_0x3f72c0 > msg.gas - 5000) {
            _0x3f72c0 = msg.gas - 5000;
        }

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x987b8d = true; }
        _0xc54f76[_0x9b1920]._0x0e7984.call.gas(_0x3f72c0)(_0xc54f76[_0x9b1920]._0x224a01, _0x9b1920, error, _0x6ba50b);
        _0x987b8d = false;
    }

    function _0x19f788(uint64 _0x9b1920) public returns (int) {
        if (_0x987b8d) {
            throw;
        }

        if (_0xa0a746) {
            return 0;
        }

        uint _0x3ecf4f = _0xc54f76[_0x9b1920]._0x3ecf4f;
        if (_0xc54f76[_0x9b1920]._0xab11ec == msg.sender && _0x3ecf4f >= CANCELLATION_FEE) {


            _0xc54f76[_0x9b1920]._0x3ecf4f = CANCELLED_FEE_FLAG;
            _0x987b8d = true;
            if (!msg.sender.call.value(_0x3ecf4f - CANCELLATION_FEE)()) {
                throw;
            }
            _0x987b8d = false;
            Cancel(_0x9b1920, msg.sender, _0xc54f76[_0x9b1920]._0xab11ec, _0xc54f76[_0x9b1920]._0x3ecf4f, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(_0x9b1920, msg.sender, _0xc54f76[_0x9b1920]._0xab11ec, _0x3ecf4f, -1);
            return FAIL_FLAG;
        }
    }
}