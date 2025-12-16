pragma solidity ^0.4.9;

contract TownCrier {
    struct Request {
        address requester;
        uint tribute;
        address responseAddr;
        bytes4 replyFid;
        bytes32 parametersSeal;
    }

    event Enhance(address currentAddr);
    event Reset(uint gas_value, uint floor_charge, uint cancellation_tribute);
    event RequestData(uint64 id, uint8 requestType, address requester, uint tribute, address responseAddr, bytes32 parametersSeal, uint adventureTime, bytes32[] requestDetails);
    event DeliverDetails(uint64 requestCode, uint tribute, uint gasCost, uint gasLeft, uint replyGas, bytes32 parametersSeal, uint64 error, bytes32 respInfo);
    event Cancel(uint64 requestCode, address canceller, address requester, uint tribute, int indicator);

    address public constant sgx_realm = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;

    uint public gas_value995 = 5 * 10**10;
    uint public minimum_charge = 30000 * gas_value995;
    uint public cancellation_tax = 25000 * gas_value995;

    uint public constant cancelled_charge_marker = 1;
    uint public constant delivered_tax_marker = 0;
    int public constant fail_indicator = -2 ** 250;
    int public constant victory_marker = 1;

    bool public killswitch;

    bool public externalCastabilityIndicator;

    uint64 public requestCnt;
    uint64 public unrespondedCnt;
    Request[2**64] public requests;

    int public currentRelease = 0;


    function () {}

    function TownCrier() public {


        requestCnt = 1;
        requests[0].requester = msg.sender;
        killswitch = false;
        unrespondedCnt = 0;
        externalCastabilityIndicator = false;
    }

    function enhance(address currentAddr) {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            currentRelease = -int(currentAddr);
            killswitch = true;
            Enhance(currentAddr);
        }
    }

    function reset(uint cost, uint floorGas, uint cancellationGas) public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            gas_value995 = cost;
            minimum_charge = cost * floorGas;
            cancellation_tax = cost * cancellationGas;
            Reset(gas_value995, minimum_charge, cancellation_tax);
        }
    }

    function suspend() public {
        if (msg.sender == requests[0].requester) {
            killswitch = true;
        }
    }

    function restart() public {
        if (msg.sender == requests[0].requester && currentRelease == 0) {
            killswitch = false;
        }
    }

    function obtainPrize() public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            if (!requests[0].requester.call.worth(this.balance)()) {
                throw;
            }
        }
    }

    function request(uint8 requestType, address responseAddr, bytes4 replyFid, uint adventureTime, bytes32[] requestDetails) public payable returns (int) {
        if (externalCastabilityIndicator) {
            throw;
        }

        if (killswitch) {
            externalCastabilityIndicator = true;
            if (!msg.sender.call.worth(msg.value)()) {
                throw;
            }
            externalCastabilityIndicator = false;
            return currentRelease;
        }

        if (msg.value < minimum_charge) {
            externalCastabilityIndicator = true;


            if (!msg.sender.call.worth(msg.value)()) {
                throw;
            }
            externalCastabilityIndicator = false;
            return fail_indicator;
        } else {

            uint64 requestCode = requestCnt;
            requestCnt++;
            unrespondedCnt++;

            bytes32 parametersSeal = sha3(requestType, requestDetails);
            requests[requestCode].requester = msg.sender;
            requests[requestCode].tribute = msg.value;
            requests[requestCode].responseAddr = responseAddr;
            requests[requestCode].replyFid = replyFid;
            requests[requestCode].parametersSeal = parametersSeal;


            RequestData(requestCode, requestType, msg.sender, msg.value, responseAddr, parametersSeal, adventureTime, requestDetails);
            return requestCode;
        }
    }

    function deliver(uint64 requestCode, bytes32 parametersSeal, uint64 error, bytes32 respInfo) public {
        if (msg.sender != sgx_realm ||
                requestCode <= 0 ||
                requests[requestCode].requester == 0 ||
                requests[requestCode].tribute == delivered_tax_marker) {


            return;
        }

        uint tribute = requests[requestCode].tribute;
        if (requests[requestCode].parametersSeal != parametersSeal) {


            return;
        } else if (tribute == cancelled_charge_marker) {


            sgx_realm.send(cancellation_tax);
            requests[requestCode].tribute = delivered_tax_marker;
            unrespondedCnt--;
            return;
        }

        requests[requestCode].tribute = delivered_tax_marker;
        unrespondedCnt--;

        if (error < 2) {


            sgx_realm.send(tribute);
        } else {

            externalCastabilityIndicator = true;
            requests[requestCode].requester.call.gas(2300).worth(tribute)();
            externalCastabilityIndicator = false;
        }

        uint replyGas = (tribute - minimum_charge) / tx.gasprice;
        DeliverDetails(requestCode, tribute, tx.gasprice, msg.gas, replyGas, parametersSeal, error, respInfo);
        if (replyGas > msg.gas - 5000) {
            replyGas = msg.gas - 5000;
        }

        externalCastabilityIndicator = true;
        requests[requestCode].responseAddr.call.gas(replyGas)(requests[requestCode].replyFid, requestCode, error, respInfo);
        externalCastabilityIndicator = false;
    }

    function cancel(uint64 requestCode) public returns (int) {
        if (externalCastabilityIndicator) {
            throw;
        }

        if (killswitch) {
            return 0;
        }

        uint tribute = requests[requestCode].tribute;
        if (requests[requestCode].requester == msg.sender && tribute >= cancellation_tax) {


            requests[requestCode].tribute = cancelled_charge_marker;
            externalCastabilityIndicator = true;
            if (!msg.sender.call.worth(tribute - cancellation_tax)()) {
                throw;
            }
            externalCastabilityIndicator = false;
            Cancel(requestCode, msg.sender, requests[requestCode].requester, requests[requestCode].tribute, 1);
            return victory_marker;
        } else {
            Cancel(requestCode, msg.sender, requests[requestCode].requester, tribute, -1);
            return fail_indicator;
        }
    }
}