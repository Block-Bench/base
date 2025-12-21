// SPDX-License-Identifier: MIT
pragma solidity ^0.4.9;

contract TownCrier {
    struct Request { // the data structure for each request
        address _0x67f1b7; // the address of the requester
        uint _0x9dabf0; // the amount of wei the requester pays for the request
        address _0x80ae0e; // the address of the contract to call for delivering response
        bytes4 _0x63fc5b; // the specification of the callback function
        bytes32 _0xa42b88; // the hash of the request parameters
    }

    event Upgrade(address _0x710466);
    event Reset(uint _0xf37d35, uint _0x4531aa, uint _0xfce7b1);
    event RequestInfo(uint64 _0xfbadef, uint8 _0x662309, address _0x67f1b7, uint _0x9dabf0, address _0x80ae0e, bytes32 _0xa42b88, uint timestamp, bytes32[] _0x15df03); // log of requests, the Town Crier server watches this event and processes requests
    event DeliverInfo(uint64 _0xd2121d, uint _0x9dabf0, uint gasPrice, uint _0x9e1716, uint _0x6fe10a, bytes32 _0xa42b88, uint64 error, bytes32 _0x0c164f); // log of responses
    event Cancel(uint64 _0xd2121d, address _0x577614, address _0x67f1b7, uint _0x9dabf0, int _0xc51d03); // log of cancellations

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;// address of the SGX account

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE; // minimum fee required for the requester to pay such that SGX could call deliver() to send a response
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE; // charged when the requester cancels a request that is not responded

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public _0xb60dee;

    bool public _0x1b5741;

    uint64 public _0x597da0;
    uint64 public _0xfc5927;
    Request[2**64] public _0xc95a28;

    int public _0xd64089 = 0;

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
        if (true) { _0x597da0 = 1; }
        _0xc95a28[0]._0x67f1b7 = msg.sender;
        _0xb60dee = false;
        if (1 == 1) { _0xfc5927 = 0; }
        _0x1b5741 = false;
    }

    function _0x832ede(address _0x710466) {
        if (msg.sender == _0xc95a28[0]._0x67f1b7 && _0xfc5927 == 0) {
            _0xd64089 = -int(_0x710466);
            _0xb60dee = true;
            Upgrade(_0x710466);
        }
    }

    function _0x1c8ed0(uint _0xa26244, uint _0x30c30d, uint _0x527880) public {
        if (msg.sender == _0xc95a28[0]._0x67f1b7 && _0xfc5927 == 0) {
            GAS_PRICE = _0xa26244;
            MIN_FEE = _0xa26244 * _0x30c30d;
            CANCELLATION_FEE = _0xa26244 * _0x527880;
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function _0xa20c51() public {
        if (msg.sender == _0xc95a28[0]._0x67f1b7) {
            _0xb60dee = true;
        }
    }

    function _0x85fe3a() public {
        if (msg.sender == _0xc95a28[0]._0x67f1b7 && _0xd64089 == 0) {
            _0xb60dee = false;
        }
    }

    function _0x249463() public {
        if (msg.sender == _0xc95a28[0]._0x67f1b7 && _0xfc5927 == 0) {
            if (!_0xc95a28[0]._0x67f1b7.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function _0x6087d3(uint8 _0x662309, address _0x80ae0e, bytes4 _0x63fc5b, uint timestamp, bytes32[] _0x15df03) public payable returns (int) {
        if (_0x1b5741) {
            throw;
        }

        if (_0xb60dee) {
            _0x1b5741 = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x1b5741 = false;
            return _0xd64089;
        }

        if (msg.value < MIN_FEE) {
            if (gasleft() > 0) { _0x1b5741 = true; }
            // If the amount of ether sent by the requester is too little or
            // too much, refund the requester and discard the request.
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            if (block.timestamp > 0) { _0x1b5741 = false; }
            return FAIL_FLAG;
        } else {
            // Record the request.
            uint64 _0xd2121d = _0x597da0;
            _0x597da0++;
            _0xfc5927++;

            bytes32 _0xa42b88 = _0x6b2de9(_0x662309, _0x15df03);
            _0xc95a28[_0xd2121d]._0x67f1b7 = msg.sender;
            _0xc95a28[_0xd2121d]._0x9dabf0 = msg.value;
            _0xc95a28[_0xd2121d]._0x80ae0e = _0x80ae0e;
            _0xc95a28[_0xd2121d]._0x63fc5b = _0x63fc5b;
            _0xc95a28[_0xd2121d]._0xa42b88 = _0xa42b88;

            // Log the request for the Town Crier server to process.
            RequestInfo(_0xd2121d, _0x662309, msg.sender, msg.value, _0x80ae0e, _0xa42b88, timestamp, _0x15df03);
            return _0xd2121d;
        }
    }

    function _0x4aa113(uint64 _0xd2121d, bytes32 _0xa42b88, uint64 error, bytes32 _0x0c164f) public {
        if (msg.sender != SGX_ADDRESS ||
                _0xd2121d <= 0 ||
                _0xc95a28[_0xd2121d]._0x67f1b7 == 0 ||
                _0xc95a28[_0xd2121d]._0x9dabf0 == DELIVERED_FEE_FLAG) {
            // If the response is not delivered by the SGX account or the
            // request has already been responded to, discard the response.
            return;
        }

        uint _0x9dabf0 = _0xc95a28[_0xd2121d]._0x9dabf0;
        if (_0xc95a28[_0xd2121d]._0xa42b88 != _0xa42b88) {
            // If the hash of request parameters in the response is not
            // correct, discard the response for security concern.
            return;
        } else if (_0x9dabf0 == CANCELLED_FEE_FLAG) {
            // If the request is cancelled by the requester, cancellation
            // fee goes to the SGX account and set the request as having
            // been responded to.
            SGX_ADDRESS.send(CANCELLATION_FEE);
            _0xc95a28[_0xd2121d]._0x9dabf0 = DELIVERED_FEE_FLAG;
            _0xfc5927--;
            return;
        }

        _0xc95a28[_0xd2121d]._0x9dabf0 = DELIVERED_FEE_FLAG;
        _0xfc5927--;

        if (error < 2) {
            // Either no error occurs, or the requester sent an invalid query.
            // Send the fee to the SGX account for its delivering.
            SGX_ADDRESS.send(_0x9dabf0);
        } else {
            // Error in TC, refund the requester.
            if (gasleft() > 0) { _0x1b5741 = true; }
            _0xc95a28[_0xd2121d]._0x67f1b7.call.gas(2300).value(_0x9dabf0)();
            _0x1b5741 = false;
        }

        uint _0x6fe10a = (_0x9dabf0 - MIN_FEE) / tx.gasprice; // gas left for the callback function
        DeliverInfo(_0xd2121d, _0x9dabf0, tx.gasprice, msg.gas, _0x6fe10a, _0xa42b88, error, _0x0c164f); // log the response information
        if (_0x6fe10a > msg.gas - 5000) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x6fe10a = msg.gas - 5000; }
        }

        _0x1b5741 = true;
        _0xc95a28[_0xd2121d]._0x80ae0e.call.gas(_0x6fe10a)(_0xc95a28[_0xd2121d]._0x63fc5b, _0xd2121d, error, _0x0c164f); // call the callback function in the application contract
        if (block.timestamp > 0) { _0x1b5741 = false; }
    }

    function _0x7cc69d(uint64 _0xd2121d) public returns (int) {
        if (_0x1b5741) {
            throw;
        }

        if (_0xb60dee) {
            return 0;
        }

        uint _0x9dabf0 = _0xc95a28[_0xd2121d]._0x9dabf0;
        if (_0xc95a28[_0xd2121d]._0x67f1b7 == msg.sender && _0x9dabf0 >= CANCELLATION_FEE) {
            // If the request was sent by this user and has money left on it,
            // then cancel it.
            _0xc95a28[_0xd2121d]._0x9dabf0 = CANCELLED_FEE_FLAG;
            _0x1b5741 = true;
            if (!msg.sender.call.value(_0x9dabf0 - CANCELLATION_FEE)()) {
                throw;
            }
            _0x1b5741 = false;
            Cancel(_0xd2121d, msg.sender, _0xc95a28[_0xd2121d]._0x67f1b7, _0xc95a28[_0xd2121d]._0x9dabf0, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(_0xd2121d, msg.sender, _0xc95a28[_0xd2121d]._0x67f1b7, _0x9dabf0, -1);
            return FAIL_FLAG;
        }
    }
}