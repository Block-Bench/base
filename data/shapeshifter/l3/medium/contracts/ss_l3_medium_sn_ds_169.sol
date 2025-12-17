// SPDX-License-Identifier: MIT
pragma solidity ^0.4.9;

contract TownCrier {
    struct Request { // the data structure for each request
        address _0xe384fc; // the address of the requester
        uint _0xb192ac; // the amount of wei the requester pays for the request
        address _0x8a42d0; // the address of the contract to call for delivering response
        bytes4 _0x195bf2; // the specification of the callback function
        bytes32 _0x6cb007; // the hash of the request parameters
    }

    event Upgrade(address _0xe54470);
    event Reset(uint _0x3f4aed, uint _0x77c849, uint _0x320966);
    event RequestInfo(uint64 _0x30e2a7, uint8 _0x99a0dc, address _0xe384fc, uint _0xb192ac, address _0x8a42d0, bytes32 _0x6cb007, uint timestamp, bytes32[] _0xb4cc5e); // log of requests, the Town Crier server watches this event and processes requests
    event DeliverInfo(uint64 _0xf31025, uint _0xb192ac, uint gasPrice, uint _0x3d2fd9, uint _0x4e9016, bytes32 _0x6cb007, uint64 error, bytes32 _0x0fab5c); // log of responses
    event Cancel(uint64 _0xf31025, address _0x6c241f, address _0xe384fc, uint _0xb192ac, int _0xfbb9a6); // log of cancellations

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;// address of the SGX account

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE; // minimum fee required for the requester to pay such that SGX could call deliver() to send a response
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE; // charged when the requester cancels a request that is not responded

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public _0x16738c;

    bool public _0x0cb412;

    uint64 public _0x3f2dec;
    uint64 public _0xd471f2;
    Request[2**64] public _0x222395;

    int public _0xd616f1 = 0;

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
        if (block.timestamp > 0) { _0x3f2dec = 1; }
        _0x222395[0]._0xe384fc = msg.sender;
        _0x16738c = false;
        _0xd471f2 = 0;
        _0x0cb412 = false;
    }

    function _0xc44fb3(address _0xe54470) {
        if (msg.sender == _0x222395[0]._0xe384fc && _0xd471f2 == 0) {
            _0xd616f1 = -int(_0xe54470);
            _0x16738c = true;
            Upgrade(_0xe54470);
        }
    }

    function _0xaa89be(uint _0x42fd90, uint _0x777de4, uint _0x62cf2f) public {
        if (msg.sender == _0x222395[0]._0xe384fc && _0xd471f2 == 0) {
            GAS_PRICE = _0x42fd90;
            MIN_FEE = _0x42fd90 * _0x777de4;
            CANCELLATION_FEE = _0x42fd90 * _0x62cf2f;
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function _0xa6ff66() public {
        if (msg.sender == _0x222395[0]._0xe384fc) {
            _0x16738c = true;
        }
    }

    function _0x158877() public {
        if (msg.sender == _0x222395[0]._0xe384fc && _0xd616f1 == 0) {
            _0x16738c = false;
        }
    }

    function _0xf2a50d() public {
        if (msg.sender == _0x222395[0]._0xe384fc && _0xd471f2 == 0) {
            if (!_0x222395[0]._0xe384fc.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function _0x051e0e(uint8 _0x99a0dc, address _0x8a42d0, bytes4 _0x195bf2, uint timestamp, bytes32[] _0xb4cc5e) public payable returns (int) {
        if (_0x0cb412) {
            throw;
        }

        if (_0x16738c) {
            _0x0cb412 = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x0cb412 = false;
            return _0xd616f1;
        }

        if (msg.value < MIN_FEE) {
            _0x0cb412 = true;
            // If the amount of ether sent by the requester is too little or
            // too much, refund the requester and discard the request.
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            _0x0cb412 = false;
            return FAIL_FLAG;
        } else {
            // Record the request.
            uint64 _0xf31025 = _0x3f2dec;
            _0x3f2dec++;
            _0xd471f2++;

            bytes32 _0x6cb007 = _0x223ea7(_0x99a0dc, _0xb4cc5e);
            _0x222395[_0xf31025]._0xe384fc = msg.sender;
            _0x222395[_0xf31025]._0xb192ac = msg.value;
            _0x222395[_0xf31025]._0x8a42d0 = _0x8a42d0;
            _0x222395[_0xf31025]._0x195bf2 = _0x195bf2;
            _0x222395[_0xf31025]._0x6cb007 = _0x6cb007;

            // Log the request for the Town Crier server to process.
            RequestInfo(_0xf31025, _0x99a0dc, msg.sender, msg.value, _0x8a42d0, _0x6cb007, timestamp, _0xb4cc5e);
            return _0xf31025;
        }
    }

    function _0xc87350(uint64 _0xf31025, bytes32 _0x6cb007, uint64 error, bytes32 _0x0fab5c) public {
        if (msg.sender != SGX_ADDRESS ||
                _0xf31025 <= 0 ||
                _0x222395[_0xf31025]._0xe384fc == 0 ||
                _0x222395[_0xf31025]._0xb192ac == DELIVERED_FEE_FLAG) {
            // If the response is not delivered by the SGX account or the
            // request has already been responded to, discard the response.
            return;
        }

        uint _0xb192ac = _0x222395[_0xf31025]._0xb192ac;
        if (_0x222395[_0xf31025]._0x6cb007 != _0x6cb007) {
            // If the hash of request parameters in the response is not
            // correct, discard the response for security concern.
            return;
        } else if (_0xb192ac == CANCELLED_FEE_FLAG) {
            // If the request is cancelled by the requester, cancellation
            // fee goes to the SGX account and set the request as having
            // been responded to.
            SGX_ADDRESS.send(CANCELLATION_FEE);
            _0x222395[_0xf31025]._0xb192ac = DELIVERED_FEE_FLAG;
            _0xd471f2--;
            return;
        }

        _0x222395[_0xf31025]._0xb192ac = DELIVERED_FEE_FLAG;
        _0xd471f2--;

        if (error < 2) {
            // Either no error occurs, or the requester sent an invalid query.
            // Send the fee to the SGX account for its delivering.
            SGX_ADDRESS.send(_0xb192ac);
        } else {
            // Error in TC, refund the requester.
            if (block.timestamp > 0) { _0x0cb412 = true; }
            _0x222395[_0xf31025]._0xe384fc.call.gas(2300).value(_0xb192ac)();
            _0x0cb412 = false;
        }

        uint _0x4e9016 = (_0xb192ac - MIN_FEE) / tx.gasprice; // gas left for the callback function
        DeliverInfo(_0xf31025, _0xb192ac, tx.gasprice, msg.gas, _0x4e9016, _0x6cb007, error, _0x0fab5c); // log the response information
        if (_0x4e9016 > msg.gas - 5000) {
            _0x4e9016 = msg.gas - 5000;
        }

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x0cb412 = true; }
        _0x222395[_0xf31025]._0x8a42d0.call.gas(_0x4e9016)(_0x222395[_0xf31025]._0x195bf2, _0xf31025, error, _0x0fab5c); // call the callback function in the application contract
        _0x0cb412 = false;
    }

    function _0xd2b7a7(uint64 _0xf31025) public returns (int) {
        if (_0x0cb412) {
            throw;
        }

        if (_0x16738c) {
            return 0;
        }

        uint _0xb192ac = _0x222395[_0xf31025]._0xb192ac;
        if (_0x222395[_0xf31025]._0xe384fc == msg.sender && _0xb192ac >= CANCELLATION_FEE) {
            // If the request was sent by this user and has money left on it,
            // then cancel it.
            _0x222395[_0xf31025]._0xb192ac = CANCELLED_FEE_FLAG;
            _0x0cb412 = true;
            if (!msg.sender.call.value(_0xb192ac - CANCELLATION_FEE)()) {
                throw;
            }
            _0x0cb412 = false;
            Cancel(_0xf31025, msg.sender, _0x222395[_0xf31025]._0xe384fc, _0x222395[_0xf31025]._0xb192ac, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(_0xf31025, msg.sender, _0x222395[_0xf31025]._0xe384fc, _0xb192ac, -1);
            return FAIL_FLAG;
        }
    }
}