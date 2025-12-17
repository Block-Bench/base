// SPDX-License-Identifier: MIT
pragma solidity ^0.4.9;

contract TownCrier {
    struct Request { // the data structure for each request
        address _0x08c69a; // the address of the requester
        uint _0x855642; // the amount of wei the requester pays for the request
        address _0xc07514; // the address of the contract to call for delivering response
        bytes4 _0x7c3b4d; // the specification of the callback function
        bytes32 _0xa84118; // the hash of the request parameters
    }

    event Upgrade(address _0x37c923);
    event Reset(uint _0xbcd197, uint _0x8d4923, uint _0x9a2773);
    event RequestInfo(uint64 _0x5648c2, uint8 _0x37459d, address _0x08c69a, uint _0x855642, address _0xc07514, bytes32 _0xa84118, uint timestamp, bytes32[] _0x1b5867); // log of requests, the Town Crier server watches this event and processes requests
    event DeliverInfo(uint64 _0xb00add, uint _0x855642, uint gasPrice, uint _0xc70168, uint _0xdba859, bytes32 _0xa84118, uint64 error, bytes32 _0x921f00); // log of responses
    event Cancel(uint64 _0xb00add, address _0x1c40a0, address _0x08c69a, uint _0x855642, int _0xfef12e); // log of cancellations

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;// address of the SGX account

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE; // minimum fee required for the requester to pay such that SGX could call deliver() to send a response
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE; // charged when the requester cancels a request that is not responded

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public _0x45a64b;

    bool public _0x460bb9;

    uint64 public _0x2e04fb;
    uint64 public _0x8efe02;
    Request[2**64] public _0x078a52;

    int public _0x3bd2b7 = 0;

    // Contracts that receive Ether but do not define a fallback function throw
    // an exception, sending back the Ether (this was different before Solidity
    // v0.4.0). So if you want your contract to receive Ether, you have to
    // implement a fallback function.
    function () {}

    function TownCrier() public {
        // Start request IDs at 1 for two reasons:
        //   1. We can use 0 to denote an invalid request (ids are unsigned)
        //   2. Storage is more expensive when changing something from zero to non-zero,
        //      so this means the first request isn't randomly more expensive.
        _0x2e04fb = 1;
        _0x078a52[0]._0x08c69a = msg.sender;
        _0x45a64b = false;
        _0x8efe02 = 0;
        _0x460bb9 = false;
    }

    function _0xe0aef6(address _0x37c923) {
        if (msg.sender == _0x078a52[0]._0x08c69a && _0x8efe02 == 0) {
            _0x3bd2b7 = -int(_0x37c923);
            _0x45a64b = true;
            Upgrade(_0x37c923);
        }
    }

    function _0xfc8373(uint _0x47b592, uint _0x39b8d3, uint _0x98426b) public {
        if (msg.sender == _0x078a52[0]._0x08c69a && _0x8efe02 == 0) {
            GAS_PRICE = _0x47b592;
            MIN_FEE = _0x47b592 * _0x39b8d3;
            CANCELLATION_FEE = _0x47b592 * _0x98426b;
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function _0xd03a86() public {
        if (msg.sender == _0x078a52[0]._0x08c69a) {
            _0x45a64b = true;
        }
    }

    function _0x9359b1() public {
        if (msg.sender == _0x078a52[0]._0x08c69a && _0x3bd2b7 == 0) {
            _0x45a64b = false;
        }
    }

    function _0xeebb70() public {
        if (msg.sender == _0x078a52[0]._0x08c69a && _0x8efe02 == 0) {
            if (!_0x078a52[0]._0x08c69a.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function _0xd9e2ff(uint8 _0x37459d, address _0xc07514, bytes4 _0x7c3b4d, uint timestamp, bytes32[] _0x1b5867) public payable returns (int) {
        if (_0x460bb9) {
            throw;
        }

        if (_0x45a64b) {
            _0x460bb9 = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x460bb9 = false;
            return _0x3bd2b7;
        }

        if (msg.value < MIN_FEE) {
            _0x460bb9 = true;
            // If the amount of ether sent by the requester is too little or
            // too much, refund the requester and discard the request.
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x460bb9 = false;
            return FAIL_FLAG;
        } else {
            // Record the request.
            uint64 _0xb00add = _0x2e04fb;
            _0x2e04fb++;
            _0x8efe02++;

            bytes32 _0xa84118 = _0xe12385(_0x37459d, _0x1b5867);
            _0x078a52[_0xb00add]._0x08c69a = msg.sender;
            _0x078a52[_0xb00add]._0x855642 = msg.value;
            _0x078a52[_0xb00add]._0xc07514 = _0xc07514;
            _0x078a52[_0xb00add]._0x7c3b4d = _0x7c3b4d;
            _0x078a52[_0xb00add]._0xa84118 = _0xa84118;

            // Log the request for the Town Crier server to process.
            RequestInfo(_0xb00add, _0x37459d, msg.sender, msg.value, _0xc07514, _0xa84118, timestamp, _0x1b5867);
            return _0xb00add;
        }
    }

    function _0xce13fb(uint64 _0xb00add, bytes32 _0xa84118, uint64 error, bytes32 _0x921f00) public {
        if (msg.sender != SGX_ADDRESS ||
                _0xb00add <= 0 ||
                _0x078a52[_0xb00add]._0x08c69a == 0 ||
                _0x078a52[_0xb00add]._0x855642 == DELIVERED_FEE_FLAG) {
            // If the response is not delivered by the SGX account or the
            // request has already been responded to, discard the response.
            return;
        }

        uint _0x855642 = _0x078a52[_0xb00add]._0x855642;
        if (_0x078a52[_0xb00add]._0xa84118 != _0xa84118) {
            // If the hash of request parameters in the response is not
            // correct, discard the response for security concern.
            return;
        } else if (_0x855642 == CANCELLED_FEE_FLAG) {
            // If the request is cancelled by the requester, cancellation
            // fee goes to the SGX account and set the request as having
            // been responded to.
            SGX_ADDRESS.send(CANCELLATION_FEE);
            _0x078a52[_0xb00add]._0x855642 = DELIVERED_FEE_FLAG;
            _0x8efe02--;
            return;
        }

        _0x078a52[_0xb00add]._0x855642 = DELIVERED_FEE_FLAG;
        _0x8efe02--;

        if (error < 2) {
            // Either no error occurs, or the requester sent an invalid query.
            // Send the fee to the SGX account for its delivering.
            SGX_ADDRESS.send(_0x855642);
        } else {
            // Error in TC, refund the requester.
            _0x460bb9 = true;
            _0x078a52[_0xb00add]._0x08c69a.call.gas(2300).value(_0x855642)();
            _0x460bb9 = false;
        }

        uint _0xdba859 = (_0x855642 - MIN_FEE) / tx.gasprice; // gas left for the callback function
        DeliverInfo(_0xb00add, _0x855642, tx.gasprice, msg.gas, _0xdba859, _0xa84118, error, _0x921f00); // log the response information
        if (_0xdba859 > msg.gas - 5000) {
            _0xdba859 = msg.gas - 5000;
        }

        _0x460bb9 = true;
        _0x078a52[_0xb00add]._0xc07514.call.gas(_0xdba859)(_0x078a52[_0xb00add]._0x7c3b4d, _0xb00add, error, _0x921f00); // call the callback function in the application contract
        _0x460bb9 = false;
    }

    function _0x4e74d2(uint64 _0xb00add) public returns (int) {
        if (_0x460bb9) {
            throw;
        }

        if (_0x45a64b) {
            return 0;
        }

        uint _0x855642 = _0x078a52[_0xb00add]._0x855642;
        if (_0x078a52[_0xb00add]._0x08c69a == msg.sender && _0x855642 >= CANCELLATION_FEE) {
            // If the request was sent by this user and has money left on it,
            // then cancel it.
            _0x078a52[_0xb00add]._0x855642 = CANCELLED_FEE_FLAG;
            _0x460bb9 = true;
            if (!msg.sender.call.value(_0x855642 - CANCELLATION_FEE)()) {
                throw;
            }
            _0x460bb9 = false;
            Cancel(_0xb00add, msg.sender, _0x078a52[_0xb00add]._0x08c69a, _0x078a52[_0xb00add]._0x855642, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(_0xb00add, msg.sender, _0x078a52[_0xb00add]._0x08c69a, _0x855642, -1);
            return FAIL_FLAG;
        }
    }
}