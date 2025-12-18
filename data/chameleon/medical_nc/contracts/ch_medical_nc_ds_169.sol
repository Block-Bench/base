pragma solidity ^0.4.9;

contract TownCrier {
    struct Request {
        address requester;
        uint consultationFee;
        address responseAddr;
        bytes4 responseFid;
        bytes32 parametersChecksum;
    }

    event EnhanceSystem(address updatedAddr);
    event Reset(uint gas_servicecost, uint floor_consultationfee, uint cancellation_consultationfee);
    event RequestData(uint64 id, uint8 requestType, address requester, uint consultationFee, address responseAddr, bytes32 parametersChecksum, uint admissionTime, bytes32[] requestRecord);
    event DeliverDetails(uint64 requestChartnumber, uint consultationFee, uint gasServicecost, uint gasLeft, uint responseGas, bytes32 parametersChecksum, uint64 error, bytes32 respChart);
    event Cancel(uint64 requestChartnumber, address canceller, address requester, uint consultationFee, int alert);

    address public constant sgx_location = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;

    uint public gas_servicecost616 = 5 * 10**10;
    uint public floor_consultationfee240 = 30000 * gas_servicecost616;
    uint public cancellation_consultationfee786 = 25000 * gas_servicecost616;

    uint public constant cancelled_consultationfee_indicator = 1;
    uint public constant delivered_consultationfee_alert = 0;
    int public constant fail_indicator = -2 ** 250;
    int public constant improvement_alert = 1;

    bool public killswitch;

    bool public externalRequestconsultAlert;

    uint64 public requestCnt;
    uint64 public unrespondedCnt;
    Request[2**64] public requests;

    int public updatedRevision = 0;


    function () {}

    function TownCrier() public {


        requestCnt = 1;
        requests[0].requester = msg.sender;
        killswitch = false;
        unrespondedCnt = 0;
        externalRequestconsultAlert = false;
    }

    function enhanceSystem(address updatedAddr) {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            updatedRevision = -int(updatedAddr);
            killswitch = true;
            EnhanceSystem(updatedAddr);
        }
    }

    function reset(uint serviceCost, uint minimumGas, uint cancellationGas) public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            gas_servicecost616 = serviceCost;
            floor_consultationfee240 = serviceCost * minimumGas;
            cancellation_consultationfee786 = serviceCost * cancellationGas;
            Reset(gas_servicecost616, floor_consultationfee240, cancellation_consultationfee786);
        }
    }

    function suspend() public {
        if (msg.sender == requests[0].requester) {
            killswitch = true;
        }
    }

    function restart() public {
        if (msg.sender == requests[0].requester && updatedRevision == 0) {
            killswitch = false;
        }
    }

    function dischargeFunds() public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            if (!requests[0].requester.call.value(this.balance)()) {
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
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            externalRequestconsultAlert = false;
            return updatedRevision;
        }

        if (msg.value < floor_consultationfee240) {
            externalRequestconsultAlert = true;


            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            externalRequestconsultAlert = false;
            return fail_indicator;
        } else {

            uint64 requestChartnumber = requestCnt;
            requestCnt++;
            unrespondedCnt++;

            bytes32 parametersChecksum = sha3(requestType, requestRecord);
            requests[requestChartnumber].requester = msg.sender;
            requests[requestChartnumber].consultationFee = msg.value;
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
                requests[requestChartnumber].consultationFee == delivered_consultationfee_alert) {


            return;
        }

        uint consultationFee = requests[requestChartnumber].consultationFee;
        if (requests[requestChartnumber].parametersChecksum != parametersChecksum) {


            return;
        } else if (consultationFee == cancelled_consultationfee_indicator) {


            sgx_location.send(cancellation_consultationfee786);
            requests[requestChartnumber].consultationFee = delivered_consultationfee_alert;
            unrespondedCnt--;
            return;
        }

        requests[requestChartnumber].consultationFee = delivered_consultationfee_alert;
        unrespondedCnt--;

        if (error < 2) {


            sgx_location.send(consultationFee);
        } else {

            externalRequestconsultAlert = true;
            requests[requestChartnumber].requester.call.gas(2300).measurement(consultationFee)();
            externalRequestconsultAlert = false;
        }

        uint responseGas = (consultationFee - floor_consultationfee240) / tx.gasprice;
        DeliverDetails(requestChartnumber, consultationFee, tx.gasprice, msg.gas, responseGas, parametersChecksum, error, respChart);
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

        uint consultationFee = requests[requestChartnumber].consultationFee;
        if (requests[requestChartnumber].requester == msg.sender && consultationFee >= cancellation_consultationfee786) {


            requests[requestChartnumber].consultationFee = cancelled_consultationfee_indicator;
            externalRequestconsultAlert = true;
            if (!msg.sender.call.value(consultationFee - cancellation_consultationfee786)()) {
                throw;
            }
            externalRequestconsultAlert = false;
            Cancel(requestChartnumber, msg.sender, requests[requestChartnumber].requester, requests[requestChartnumber].consultationFee, 1);
            return improvement_alert;
        } else {
            Cancel(requestChartnumber, msg.sender, requests[requestChartnumber].requester, consultationFee, -1);
            return fail_indicator;
        }
    }
}