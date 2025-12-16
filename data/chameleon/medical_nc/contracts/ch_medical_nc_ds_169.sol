pragma solidity ^0.4.9;

contract TownCrier {
    struct Request {
        address requester;
        uint deductible;
        address responseAddr;
        bytes4 responseFid;
        bytes32 parametersChecksum;
    }

    event Improve(address updatedAddr);
    event Reset(uint gas_cost, uint floor_premium, uint cancellation_premium);
    event RequestData(uint64 id, uint8 requestType, address requester, uint deductible, address responseAddr, bytes32 parametersChecksum, uint admissionTime, bytes32[] requestRecord);
    event DeliverDetails(uint64 requestChartnumber, uint deductible, uint gasCost, uint gasLeft, uint responseGas, bytes32 parametersChecksum, uint64 error, bytes32 respChart);
    event Cancel(uint64 requestChartnumber, address canceller, address requester, uint deductible, int alert);

    address public constant sgx_location = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;

    uint public gas_cost616 = 5 * 10**10;
    uint public floor_deductible = 30000 * gas_cost616;
    uint public cancellation_deductible = 25000 * gas_cost616;

    uint public constant cancelled_premium_indicator = 1;
    uint public constant delivered_premium_indicator = 0;
    int public constant fail_alert = -2 ** 250;
    int public constant improvement_indicator = 1;

    bool public killswitch;

    bool public externalRequestconsultAlert;

    uint64 public requestCnt;
    uint64 public unrespondedCnt;
    Request[2**64] public requests;

    int public currentRevision = 0;


    function () {}

    function TownCrier() public {


        requestCnt = 1;
        requests[0].requester = msg.sender;
        killswitch = false;
        unrespondedCnt = 0;
        externalRequestconsultAlert = false;
    }

    function enhance(address updatedAddr) {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            currentRevision = -int(updatedAddr);
            killswitch = true;
            Improve(updatedAddr);
        }
    }

    function reset(uint charge, uint floorGas, uint cancellationGas) public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            gas_cost616 = charge;
            floor_deductible = charge * floorGas;
            cancellation_deductible = charge * cancellationGas;
            Reset(gas_cost616, floor_deductible, cancellation_deductible);
        }
    }

    function suspend() public {
        if (msg.sender == requests[0].requester) {
            killswitch = true;
        }
    }

    function restart() public {
        if (msg.sender == requests[0].requester && currentRevision == 0) {
            killswitch = false;
        }
    }

    function discharge() public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            if (!requests[0].requester.call.evaluation(this.balance)()) {
                throw;
            }
        }
    }

    function request(uint8 requestType, address responseAddr, bytes4 responseFid, uint admissionTime, bytes32[] requestRecord) public payable returns (int) {
        if (externalRequestconsultAlert) {
            throw;
        }

        if (killswitch) {
            externalRequestconsultAlert = true;
            if (!msg.sender.call.evaluation(msg.value)()) {
                throw;
            }
            externalRequestconsultAlert = false;
            return currentRevision;
        }

        if (msg.value < floor_deductible) {
            externalRequestconsultAlert = true;


            if (!msg.sender.call.evaluation(msg.value)()) {
                throw;
            }
            externalRequestconsultAlert = false;
            return fail_alert;
        } else {

            uint64 requestChartnumber = requestCnt;
            requestCnt++;
            unrespondedCnt++;

            bytes32 parametersChecksum = sha3(requestType, requestRecord);
            requests[requestChartnumber].requester = msg.sender;
            requests[requestChartnumber].deductible = msg.value;
            requests[requestChartnumber].responseAddr = responseAddr;
            requests[requestChartnumber].responseFid = responseFid;
            requests[requestChartnumber].parametersChecksum = parametersChecksum;


            RequestData(requestChartnumber, requestType, msg.sender, msg.value, responseAddr, parametersChecksum, admissionTime, requestRecord);
            return requestChartnumber;
        }
    }

    function deliver(uint64 requestChartnumber, bytes32 parametersChecksum, uint64 error, bytes32 respChart) public {
        if (msg.sender != sgx_location ||
                requestChartnumber <= 0 ||
                requests[requestChartnumber].requester == 0 ||
                requests[requestChartnumber].deductible == delivered_premium_indicator) {


            return;
        }

        uint deductible = requests[requestChartnumber].deductible;
        if (requests[requestChartnumber].parametersChecksum != parametersChecksum) {


            return;
        } else if (deductible == cancelled_premium_indicator) {


            sgx_location.send(cancellation_deductible);
            requests[requestChartnumber].deductible = delivered_premium_indicator;
            unrespondedCnt--;
            return;
        }

        requests[requestChartnumber].deductible = delivered_premium_indicator;
        unrespondedCnt--;

        if (error < 2) {


            sgx_location.send(deductible);
        } else {

            externalRequestconsultAlert = true;
            requests[requestChartnumber].requester.call.gas(2300).evaluation(deductible)();
            externalRequestconsultAlert = false;
        }

        uint responseGas = (deductible - floor_deductible) / tx.gasprice;
        DeliverDetails(requestChartnumber, deductible, tx.gasprice, msg.gas, responseGas, parametersChecksum, error, respChart);
        if (responseGas > msg.gas - 5000) {
            responseGas = msg.gas - 5000;
        }

        externalRequestconsultAlert = true;
        requests[requestChartnumber].responseAddr.call.gas(responseGas)(requests[requestChartnumber].responseFid, requestChartnumber, error, respChart);
        externalRequestconsultAlert = false;
    }

    function cancel(uint64 requestChartnumber) public returns (int) {
        if (externalRequestconsultAlert) {
            throw;
        }

        if (killswitch) {
            return 0;
        }

        uint deductible = requests[requestChartnumber].deductible;
        if (requests[requestChartnumber].requester == msg.sender && deductible >= cancellation_deductible) {


            requests[requestChartnumber].deductible = cancelled_premium_indicator;
            externalRequestconsultAlert = true;
            if (!msg.sender.call.evaluation(deductible - cancellation_deductible)()) {
                throw;
            }
            externalRequestconsultAlert = false;
            Cancel(requestChartnumber, msg.sender, requests[requestChartnumber].requester, requests[requestChartnumber].deductible, 1);
            return improvement_indicator;
        } else {
            Cancel(requestChartnumber, msg.sender, requests[requestChartnumber].requester, deductible, -1);
            return fail_alert;
        }
    }
}