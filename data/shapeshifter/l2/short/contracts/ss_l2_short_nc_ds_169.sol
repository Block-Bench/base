pragma solidity ^0.4.9;

contract TownCrier {
    struct Request {
        address p;
        uint ai;
        address e;
        bytes4 g;
        bytes32 k;
    }

    event Upgrade(address ab);
    event Reset(uint q, uint u, uint a);
    event RequestInfo(uint64 aj, uint8 i, address p, uint ai, address e, bytes32 k, uint timestamp, bytes32[] f);
    event DeliverInfo(uint64 n, uint ai, uint gasPrice, uint y, uint h, bytes32 k, uint64 error, bytes32 r);
    event Cancel(uint64 n, address o, address p, uint ai, int ah);

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE;
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE;

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public m;

    bool public b;

    uint64 public j;
    uint64 public d;
    Request[2**64] public t;

    int public l = 0;


    function () {}

    function TownCrier() public {


        j = 1;
        t[0].p = msg.sender;
        m = false;
        d = 0;
        b = false;
    }

    function z(address ab) {
        if (msg.sender == t[0].p && d == 0) {
            l = -int(ab);
            m = true;
            Upgrade(ab);
        }
    }

    function af(uint ae, uint ac, uint c) public {
        if (msg.sender == t[0].p && d == 0) {
            GAS_PRICE = ae;
            MIN_FEE = ae * ac;
            CANCELLATION_FEE = ae * c;
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function w() public {
        if (msg.sender == t[0].p) {
            m = true;
        }
    }

    function aa() public {
        if (msg.sender == t[0].p && l == 0) {
            m = false;
        }
    }

    function s() public {
        if (msg.sender == t[0].p && d == 0) {
            if (!t[0].p.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function x(uint8 i, address e, bytes4 g, uint timestamp, bytes32[] f) public payable returns (int) {
        if (b) {
            throw;
        }

        if (m) {
            b = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            b = false;
            return l;
        }

        if (msg.value < MIN_FEE) {
            b = true;


            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            b = false;
            return FAIL_FLAG;
        } else {

            uint64 n = j;
            j++;
            d++;

            bytes32 k = ag(i, f);
            t[n].p = msg.sender;
            t[n].ai = msg.value;
            t[n].e = e;
            t[n].g = g;
            t[n].k = k;


            RequestInfo(n, i, msg.sender, msg.value, e, k, timestamp, f);
            return n;
        }
    }

    function v(uint64 n, bytes32 k, uint64 error, bytes32 r) public {
        if (msg.sender != SGX_ADDRESS ||
                n <= 0 ||
                t[n].p == 0 ||
                t[n].ai == DELIVERED_FEE_FLAG) {


            return;
        }

        uint ai = t[n].ai;
        if (t[n].k != k) {


            return;
        } else if (ai == CANCELLED_FEE_FLAG) {


            SGX_ADDRESS.send(CANCELLATION_FEE);
            t[n].ai = DELIVERED_FEE_FLAG;
            d--;
            return;
        }

        t[n].ai = DELIVERED_FEE_FLAG;
        d--;

        if (error < 2) {


            SGX_ADDRESS.send(ai);
        } else {

            b = true;
            t[n].p.call.gas(2300).value(ai)();
            b = false;
        }

        uint h = (ai - MIN_FEE) / tx.gasprice;
        DeliverInfo(n, ai, tx.gasprice, msg.gas, h, k, error, r);
        if (h > msg.gas - 5000) {
            h = msg.gas - 5000;
        }

        b = true;
        t[n].e.call.gas(h)(t[n].g, n, error, r);
        b = false;
    }

    function ad(uint64 n) public returns (int) {
        if (b) {
            throw;
        }

        if (m) {
            return 0;
        }

        uint ai = t[n].ai;
        if (t[n].p == msg.sender && ai >= CANCELLATION_FEE) {


            t[n].ai = CANCELLED_FEE_FLAG;
            b = true;
            if (!msg.sender.call.value(ai - CANCELLATION_FEE)()) {
                throw;
            }
            b = false;
            Cancel(n, msg.sender, t[n].p, t[n].ai, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(n, msg.sender, t[n].p, ai, -1);
            return FAIL_FLAG;
        }
    }
}