// SPDX-License-Identifier: MIT
pragma solidity ^0.4.9;

contract TownCrier {
    struct Request { // the data structure for each request
        address p; // the address of the requester
        uint ai; // the amount of wei the requester pays for the request
        address e; // the address of the contract to call for delivering response
        bytes4 h; // the specification of the callback function
        bytes32 j; // the hash of the request parameters
    }

    event Upgrade(address v);
    event Reset(uint q, uint ab, uint b);
    event RequestInfo(uint64 aj, uint8 g, address p, uint ai, address e, bytes32 j, uint timestamp, bytes32[] i); // log of requests, the Town Crier server watches this event and processes requests
    event DeliverInfo(uint64 n, uint ai, uint gasPrice, uint u, uint f, bytes32 j, uint64 error, bytes32 r); // log of responses
    event Cancel(uint64 n, address o, address p, uint ai, int ag); // log of cancellations

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;// address of the SGX account

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE; // minimum fee required for the requester to pay such that SGX could call deliver() to send a response
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE; // charged when the requester cancels a request that is not responded

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public k;

    bool public a;

    uint64 public l;
    uint64 public d;
    Request[2**64] public s;

    int public m = 0;

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
        l = 1;
        s[0].p = msg.sender;
        k = false;
        d = 0;
        a = false;
    }

    function y(address v) {
        if (msg.sender == s[0].p && d == 0) {
            m = -int(v);
            k = true;
            Upgrade(v);
        }
    }

    function ae(uint af, uint ad, uint c) public {
        if (msg.sender == s[0].p && d == 0) {
            GAS_PRICE = af;
            MIN_FEE = af * ad;
            CANCELLATION_FEE = af * c;
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function aa() public {
        if (msg.sender == s[0].p) {
            k = true;
        }
    }

    function w() public {
        if (msg.sender == s[0].p && m == 0) {
            k = false;
        }
    }

    function t() public {
        if (msg.sender == s[0].p && d == 0) {
            if (!s[0].p.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function x(uint8 g, address e, bytes4 h, uint timestamp, bytes32[] i) public payable returns (int) {
        if (a) {
            throw;
        }

        if (k) {
            a = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            a = false;
            return m;
        }

        if (msg.value < MIN_FEE) {
            a = true;
            // If the amount of ether sent by the requester is too little or
            // too much, refund the requester and discard the request.
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            a = false;
            return FAIL_FLAG;
        } else {
            // Record the request.
            uint64 n = l;
            l++;
            d++;

            bytes32 j = ah(g, i);
            s[n].p = msg.sender;
            s[n].ai = msg.value;
            s[n].e = e;
            s[n].h = h;
            s[n].j = j;

            // Log the request for the Town Crier server to process.
            RequestInfo(n, g, msg.sender, msg.value, e, j, timestamp, i);
            return n;
        }
    }

    function z(uint64 n, bytes32 j, uint64 error, bytes32 r) public {
        if (msg.sender != SGX_ADDRESS ||
                n <= 0 ||
                s[n].p == 0 ||
                s[n].ai == DELIVERED_FEE_FLAG) {
            // If the response is not delivered by the SGX account or the
            // request has already been responded to, discard the response.
            return;
        }

        uint ai = s[n].ai;
        if (s[n].j != j) {
            // If the hash of request parameters in the response is not
            // correct, discard the response for security concern.
            return;
        } else if (ai == CANCELLED_FEE_FLAG) {
            // If the request is cancelled by the requester, cancellation
            // fee goes to the SGX account and set the request as having
            // been responded to.
            SGX_ADDRESS.send(CANCELLATION_FEE);
            s[n].ai = DELIVERED_FEE_FLAG;
            d--;
            return;
        }

        s[n].ai = DELIVERED_FEE_FLAG;
        d--;

        if (error < 2) {
            // Either no error occurs, or the requester sent an invalid query.
            // Send the fee to the SGX account for its delivering.
            SGX_ADDRESS.send(ai);
        } else {
            // Error in TC, refund the requester.
            a = true;
            s[n].p.call.gas(2300).value(ai)();
            a = false;
        }

        uint f = (ai - MIN_FEE) / tx.gasprice; // gas left for the callback function
        DeliverInfo(n, ai, tx.gasprice, msg.gas, f, j, error, r); // log the response information
        if (f > msg.gas - 5000) {
            f = msg.gas - 5000;
        }

        a = true;
        s[n].e.call.gas(f)(s[n].h, n, error, r); // call the callback function in the application contract
        a = false;
    }

    function ac(uint64 n) public returns (int) {
        if (a) {
            throw;
        }

        if (k) {
            return 0;
        }

        uint ai = s[n].ai;
        if (s[n].p == msg.sender && ai >= CANCELLATION_FEE) {
            // If the request was sent by this user and has money left on it,
            // then cancel it.
            s[n].ai = CANCELLED_FEE_FLAG;
            a = true;
            if (!msg.sender.call.value(ai - CANCELLATION_FEE)()) {
                throw;
            }
            a = false;
            Cancel(n, msg.sender, s[n].p, s[n].ai, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(n, msg.sender, s[n].p, ai, -1);
            return FAIL_FLAG;
        }
    }
}