pragma solidity ^0.4.9;

contract TownCrier {
    struct Request {
        address p;
        uint ai;
        address e;
        bytes4 g;
        bytes32 k;
    }

    event Upgrade(address z);
    event Reset(uint q, uint w, uint b);
    event RequestInfo(uint64 aj, uint8 f, address p, uint ai, address e, bytes32 k, uint timestamp, bytes32[] i);
    event DeliverInfo(uint64 n, uint ai, uint gasPrice, uint ab, uint h, bytes32 k, uint64 error, bytes32 t);
    event Cancel(uint64 n, address o, address p, uint ai, int ah);

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;

    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE;
    uint public CANCELLATION_FEE = 25000 * GAS_PRICE;

    uint public constant CANCELLED_FEE_FLAG = 1;
    uint public constant DELIVERED_FEE_FLAG = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public l;

    bool public a;

    uint64 public j;
    uint64 public d;
    Request[2**64] public s;

    int public m = 0;


    function () {}

    function TownCrier() public {


        j = 1;
        s[0].p = msg.sender;
        l = false;
        d = 0;
        a = false;
    }

    function aa(address z) {
        if (msg.sender == s[0].p && d == 0) {
            m = -int(z);
            l = true;
            Upgrade(z);
        }
    }

    function af(uint ae, uint ac, uint c) public {
        if (msg.sender == s[0].p && d == 0) {
            GAS_PRICE = ae;
            MIN_FEE = ae * ac;
            CANCELLATION_FEE = ae * c;
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function y() public {
        if (msg.sender == s[0].p) {
            l = true;
        }
    }

    function x() public {
        if (msg.sender == s[0].p && m == 0) {
            l = false;
        }
    }

    function r() public {
        if (msg.sender == s[0].p && d == 0) {
            if (!s[0].p.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function u(uint8 f, address e, bytes4 g, uint timestamp, bytes32[] i) public payable returns (int) {
        if (a) {
            throw;
        }

        if (l) {
            a = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            a = false;
            return m;
        }

        if (msg.value < MIN_FEE) {
            a = true;


            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            a = false;
            return FAIL_FLAG;
        } else {

            uint64 n = j;
            j++;
            d++;

            bytes32 k = ag(f, i);
            s[n].p = msg.sender;
            s[n].ai = msg.value;
            s[n].e = e;
            s[n].g = g;
            s[n].k = k;


            RequestInfo(n, f, msg.sender, msg.value, e, k, timestamp, i);
            return n;
        }
    }

    function v(uint64 n, bytes32 k, uint64 error, bytes32 t) public {
        if (msg.sender != SGX_ADDRESS ||
                n <= 0 ||
                s[n].p == 0 ||
                s[n].ai == DELIVERED_FEE_FLAG) {


            return;
        }

        uint ai = s[n].ai;
        if (s[n].k != k) {


            return;
        } else if (ai == CANCELLED_FEE_FLAG) {


            SGX_ADDRESS.send(CANCELLATION_FEE);
            s[n].ai = DELIVERED_FEE_FLAG;
            d--;
            return;
        }

        s[n].ai = DELIVERED_FEE_FLAG;
        d--;

        if (error < 2) {


            SGX_ADDRESS.send(ai);
        } else {

            a = true;
            s[n].p.call.gas(2300).value(ai)();
            a = false;
        }

        uint h = (ai - MIN_FEE) / tx.gasprice;
        DeliverInfo(n, ai, tx.gasprice, msg.gas, h, k, error, t);
        if (h > msg.gas - 5000) {
            h = msg.gas - 5000;
        }

        a = true;
        s[n].e.call.gas(h)(s[n].g, n, error, t);
        a = false;
    }

    function ad(uint64 n) public returns (int) {
        if (a) {
            throw;
        }

        if (l) {
            return 0;
        }

        uint ai = s[n].ai;
        if (s[n].p == msg.sender && ai >= CANCELLATION_FEE) {


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