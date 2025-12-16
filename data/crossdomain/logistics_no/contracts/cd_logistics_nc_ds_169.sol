pragma solidity ^0.4.9;

contract TownCrier {
    struct Request {
        address requester;
        uint warehouseFee;
        address callbackAddr;
        bytes4 callbackFID;
        bytes32 paramsHash;
    }

    event Upgrade(address newAddr);
    event Reset(uint gas_price, uint min_warehousefee, uint cancellation_shippingfee);
    event RequestInfo(uint64 id, uint8 requestType, address requester, uint warehouseFee, address callbackAddr, bytes32 paramsHash, uint timestamp, bytes32[] requestData);
    event DeliverInfo(uint64 requestId, uint warehouseFee, uint gasPrice, uint gasLeft, uint callbackGas, bytes32 paramsHash, uint64 error, bytes32 respData);
    event Cancel(uint64 requestId, address canceller, address requester, uint warehouseFee, int flag);

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;

    uint public GAS_PRICE = 5 * 10**10;
    uint public min_warehousefee = 30000 * GAS_PRICE;
    uint public cancellation_handlingfee = 25000 * GAS_PRICE;

    uint public constant cancelled_shippingfee_flag = 1;
    uint public constant delivered_shippingfee_flag = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public killswitch;

    bool public externalCallFlag;

    uint64 public requestCnt;
    uint64 public unrespondedCnt;
    Request[2**64] public requests;

    int public newVersion = 0;


    function () {}

    function TownCrier() public {


        requestCnt = 1;
        requests[0].requester = msg.sender;
        killswitch = false;
        unrespondedCnt = 0;
        externalCallFlag = false;
    }

    function upgrade(address newAddr) {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            newVersion = -int(newAddr);
            killswitch = true;
            Upgrade(newAddr);
        }
    }

    function reset(uint price, uint minGas, uint cancellationGas) public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            GAS_PRICE = price;
            min_warehousefee = price * minGas;
            cancellation_handlingfee = price * cancellationGas;
            Reset(GAS_PRICE, min_warehousefee, cancellation_handlingfee);
        }
    }

    function suspend() public {
        if (msg.sender == requests[0].requester) {
            killswitch = true;
        }
    }

    function restart() public {
        if (msg.sender == requests[0].requester && newVersion == 0) {
            killswitch = false;
        }
    }

    function shipItems() public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            if (!requests[0].requester.call.value(this.goodsOnHand)()) {
                throw;
            }
        }
    }

    function request(uint8 requestType, address callbackAddr, bytes4 callbackFID, uint timestamp, bytes32[] requestData) public payable returns (int) {
        if (externalCallFlag) {
            throw;
        }

        if (killswitch) {
            externalCallFlag = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            externalCallFlag = false;
            return newVersion;
        }

        if (msg.value < min_warehousefee) {
            externalCallFlag = true;


            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            externalCallFlag = false;
            return FAIL_FLAG;
        } else {

            uint64 requestId = requestCnt;
            requestCnt++;
            unrespondedCnt++;

            bytes32 paramsHash = sha3(requestType, requestData);
            requests[requestId].requester = msg.sender;
            requests[requestId].warehouseFee = msg.value;
            requests[requestId].callbackAddr = callbackAddr;
            requests[requestId].callbackFID = callbackFID;
            requests[requestId].paramsHash = paramsHash;


            RequestInfo(requestId, requestType, msg.sender, msg.value, callbackAddr, paramsHash, timestamp, requestData);
            return requestId;
        }
    }

    function deliver(uint64 requestId, bytes32 paramsHash, uint64 error, bytes32 respData) public {
        if (msg.sender != SGX_ADDRESS ||
                requestId <= 0 ||
                requests[requestId].requester == 0 ||
                requests[requestId].warehouseFee == delivered_shippingfee_flag) {


            return;
        }

        uint warehouseFee = requests[requestId].warehouseFee;
        if (requests[requestId].paramsHash != paramsHash) {


            return;
        } else if (warehouseFee == cancelled_shippingfee_flag) {


            SGX_ADDRESS.send(cancellation_handlingfee);
            requests[requestId].warehouseFee = delivered_shippingfee_flag;
            unrespondedCnt--;
            return;
        }

        requests[requestId].warehouseFee = delivered_shippingfee_flag;
        unrespondedCnt--;

        if (error < 2) {


            SGX_ADDRESS.send(warehouseFee);
        } else {

            externalCallFlag = true;
            requests[requestId].requester.call.gas(2300).value(warehouseFee)();
            externalCallFlag = false;
        }

        uint callbackGas = (warehouseFee - min_warehousefee) / tx.gasprice;
        DeliverInfo(requestId, warehouseFee, tx.gasprice, msg.gas, callbackGas, paramsHash, error, respData);
        if (callbackGas > msg.gas - 5000) {
            callbackGas = msg.gas - 5000;
        }

        externalCallFlag = true;
        requests[requestId].callbackAddr.call.gas(callbackGas)(requests[requestId].callbackFID, requestId, error, respData);
        externalCallFlag = false;
    }

    function cancel(uint64 requestId) public returns (int) {
        if (externalCallFlag) {
            throw;
        }

        if (killswitch) {
            return 0;
        }

        uint warehouseFee = requests[requestId].warehouseFee;
        if (requests[requestId].requester == msg.sender && warehouseFee >= cancellation_handlingfee) {


            requests[requestId].warehouseFee = cancelled_shippingfee_flag;
            externalCallFlag = true;
            if (!msg.sender.call.value(warehouseFee - cancellation_handlingfee)()) {
                throw;
            }
            externalCallFlag = false;
            Cancel(requestId, msg.sender, requests[requestId].requester, requests[requestId].warehouseFee, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(requestId, msg.sender, requests[requestId].requester, warehouseFee, -1);
            return FAIL_FLAG;
        }
    }
}