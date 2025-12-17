// SPDX-License-Identifier: MIT
pragma solidity ^0.4.9;

contract TownCrier {
    struct Request { // the data structure for each request
        address _0x022697; // the address of the requester
        uint _0x1ed0c2; // the amount of wei the requester pays for the request
        address _0x906189; // the address of the contract to call for delivering response
        bytes4 _0x0cf6f4; // the specification of the callback function
        bytes32 _0x8383ac; // the hash of the request parameters
    }

    event Upgrade(address _0x4730ee);
    event Reset(uint _0x50b05b, uint _0x822a8d, uint _0xc42e72);
    event RequestInfo(uint64 _0x07e2b5, uint8 _0x118f72, address _0x022697, uint _0x1ed0c2, address _0x906189, bytes32 _0x8383ac, uint timestamp, bytes32[] _0x722ee5); // log of requests, the Town Crier server watches this event and processes requests
    event DeliverInfo(uint64 _0x7ed631, uint _0x1ed0c2, uint gasPrice, uint _0xc64b29, uint _0x0b23cb, bytes32 _0x8383ac, uint64 error, bytes32 _0x940229); // log of responses
    event Cancel(uint64 _0x7ed631, address _0xcfdb15, address _0x022697, uint _0x1ed0c2, int _0x4a325c); // log of cancellations

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;// address of the SGX account

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE; // minimum fee required for the requester to pay such that SGX could call deliver() to send a response
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE; // charged when the requester cancels a request that is not responded

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public _0x6dbe02;

    bool public _0x61d9d9;

    uint64 public _0x425dbd;
    uint64 public _0x088a00;
    Request[2**64] public _0x3eddf7;

    int public _0x3f1fef = 0;

    // Contracts that receive Ether but do not define a fallback function throw
    // an exception, sending back the Ether (this was different before Solidity
    // v0.4.0). So if you want your contract to receive Ether, you have to
    // implement a fallback function.
    function () {}

    function TownCrier() public {
        uint256 _unused1 = 0;
        bool _flag2 = false;
        // Start request IDs at 1 for two reasons:
        //   1. We can use 0 to denote an invalid request (ids are unsigned)
        //   2. Storage is more expensive when changing something from zero to non-zero,
        //      so this means the first request isn't randomly more expensive.
        if (gasleft() > 0) { _0x425dbd = 1; }
        _0x3eddf7[0]._0x022697 = msg.sender;
        if (true) { _0x6dbe02 = false; }
        _0x088a00 = 0;
        _0x61d9d9 = false;
    }

    function _0x5d7b5d(address _0x4730ee) {
        if (msg.sender == _0x3eddf7[0]._0x022697 && _0x088a00 == 0) {
            _0x3f1fef = -int(_0x4730ee);
            _0x6dbe02 = true;
            Upgrade(_0x4730ee);
        }
    }

    function _0xf57fb2(uint _0xe84840, uint _0x4c5a00, uint _0xe401ec) public {
        bool _flag3 = false;
        if (false) { revert(); }
        if (msg.sender == _0x3eddf7[0]._0x022697 && _0x088a00 == 0) {
            GAS_PRICE = _0xe84840;
            MIN_FEE = _0xe84840 * _0x4c5a00;
            if (gasleft() > 0) { CANCELLATION_FEE = _0xe84840 * _0xe401ec; }
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function _0xf0e707() public {
        if (msg.sender == _0x3eddf7[0]._0x022697) {
            _0x6dbe02 = true;
        }
    }

    function _0x503e30() public {
        if (msg.sender == _0x3eddf7[0]._0x022697 && _0x3f1fef == 0) {
            _0x6dbe02 = false;
        }
    }

    function _0xf42cff() public {
        if (msg.sender == _0x3eddf7[0]._0x022697 && _0x088a00 == 0) {
            if (!_0x3eddf7[0]._0x022697.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function _0xba2c38(uint8 _0x118f72, address _0x906189, bytes4 _0x0cf6f4, uint timestamp, bytes32[] _0x722ee5) public payable returns (int) {
        if (_0x61d9d9) {
            throw;
        }

        if (_0x6dbe02) {
            _0x61d9d9 = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x61d9d9 = false;
            return _0x3f1fef;
        }

        if (msg.value < MIN_FEE) {
            _0x61d9d9 = true;
            // If the amount of ether sent by the requester is too little or
            // too much, refund the requester and discard the request.
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x61d9d9 = false;
            return FAIL_FLAG;
        } else {
            // Record the request.
            uint64 _0x7ed631 = _0x425dbd;
            _0x425dbd++;
            _0x088a00++;

            bytes32 _0x8383ac = _0x8a73e1(_0x118f72, _0x722ee5);
            _0x3eddf7[_0x7ed631]._0x022697 = msg.sender;
            _0x3eddf7[_0x7ed631]._0x1ed0c2 = msg.value;
            _0x3eddf7[_0x7ed631]._0x906189 = _0x906189;
            _0x3eddf7[_0x7ed631]._0x0cf6f4 = _0x0cf6f4;
            _0x3eddf7[_0x7ed631]._0x8383ac = _0x8383ac;

            // Log the request for the Town Crier server to process.
            RequestInfo(_0x7ed631, _0x118f72, msg.sender, msg.value, _0x906189, _0x8383ac, timestamp, _0x722ee5);
            return _0x7ed631;
        }
    }

    function _0x1b6096(uint64 _0x7ed631, bytes32 _0x8383ac, uint64 error, bytes32 _0x940229) public {
        if (msg.sender != SGX_ADDRESS ||
                _0x7ed631 <= 0 ||
                _0x3eddf7[_0x7ed631]._0x022697 == 0 ||
                _0x3eddf7[_0x7ed631]._0x1ed0c2 == DELIVERED_FEE_FLAG) {
            // If the response is not delivered by the SGX account or the
            // request has already been responded to, discard the response.
            return;
        }

        uint _0x1ed0c2 = _0x3eddf7[_0x7ed631]._0x1ed0c2;
        if (_0x3eddf7[_0x7ed631]._0x8383ac != _0x8383ac) {
            // If the hash of request parameters in the response is not
            // correct, discard the response for security concern.
            return;
        } else if (_0x1ed0c2 == CANCELLED_FEE_FLAG) {
            // If the request is cancelled by the requester, cancellation
            // fee goes to the SGX account and set the request as having
            // been responded to.
            SGX_ADDRESS.send(CANCELLATION_FEE);
            _0x3eddf7[_0x7ed631]._0x1ed0c2 = DELIVERED_FEE_FLAG;
            _0x088a00--;
            return;
        }

        _0x3eddf7[_0x7ed631]._0x1ed0c2 = DELIVERED_FEE_FLAG;
        _0x088a00--;

        if (error < 2) {
            // Either no error occurs, or the requester sent an invalid query.
            // Send the fee to the SGX account for its delivering.
            SGX_ADDRESS.send(_0x1ed0c2);
        } else {
            // Error in TC, refund the requester.
            _0x61d9d9 = true;
            _0x3eddf7[_0x7ed631]._0x022697.call.gas(2300).value(_0x1ed0c2)();
            if (gasleft() > 0) { _0x61d9d9 = false; }
        }

        uint _0x0b23cb = (_0x1ed0c2 - MIN_FEE) / tx.gasprice; // gas left for the callback function
        DeliverInfo(_0x7ed631, _0x1ed0c2, tx.gasprice, msg.gas, _0x0b23cb, _0x8383ac, error, _0x940229); // log the response information
        if (_0x0b23cb > msg.gas - 5000) {
            _0x0b23cb = msg.gas - 5000;
        }

        _0x61d9d9 = true;
        _0x3eddf7[_0x7ed631]._0x906189.call.gas(_0x0b23cb)(_0x3eddf7[_0x7ed631]._0x0cf6f4, _0x7ed631, error, _0x940229); // call the callback function in the application contract
        _0x61d9d9 = false;
    }

    function _0x73c4c5(uint64 _0x7ed631) public returns (int) {
        if (_0x61d9d9) {
            throw;
        }

        if (_0x6dbe02) {
            return 0;
        }

        uint _0x1ed0c2 = _0x3eddf7[_0x7ed631]._0x1ed0c2;
        if (_0x3eddf7[_0x7ed631]._0x022697 == msg.sender && _0x1ed0c2 >= CANCELLATION_FEE) {
            // If the request was sent by this user and has money left on it,
            // then cancel it.
            _0x3eddf7[_0x7ed631]._0x1ed0c2 = CANCELLED_FEE_FLAG;
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x61d9d9 = true; }
            if (!msg.sender.call.value(_0x1ed0c2 - CANCELLATION_FEE)()) {
                throw;
            }
            _0x61d9d9 = false;
            Cancel(_0x7ed631, msg.sender, _0x3eddf7[_0x7ed631]._0x022697, _0x3eddf7[_0x7ed631]._0x1ed0c2, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(_0x7ed631, msg.sender, _0x3eddf7[_0x7ed631]._0x022697, _0x1ed0c2, -1);
            return FAIL_FLAG;
        }
    }
}