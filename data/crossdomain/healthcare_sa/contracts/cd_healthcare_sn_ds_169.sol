// SPDX-License-Identifier: MIT
pragma solidity ^0.4.9;

contract TownCrier {
    struct Request { // the data structure for each request
        address requester; // the address of the requester
        uint premium; // the amount of wei the requester pays for the request
        address callbackAddr; // the address of the contract to call for delivering response
        bytes4 callbackFID; // the specification of the callback function
        bytes32 paramsHash; // the hash of the request parameters
    }

    event Upgrade(address newAddr);
    event Reset(uint gas_price, uint min_deductible, uint cancellation_servicefee);
    event RequestInfo(uint64 id, uint8 requestType, address requester, uint premium, address callbackAddr, bytes32 paramsHash, uint timestamp, bytes32[] requestData); // log of requests, the Town Crier server watches this event and processes requests
    event DeliverInfo(uint64 requestId, uint premium, uint gasPrice, uint gasLeft, uint callbackGas, bytes32 paramsHash, uint64 error, bytes32 respData); // log of responses
    event Cancel(uint64 requestId, address canceller, address requester, uint premium, int flag); // log of cancellations

    address public constant SGX_ADDRESS = 0x18513702cCd928F2A3eb63d900aDf03c9cc81593;// address of the SGX account

    uint public GAS_PRICE = 5 * 10**10;
    uint public min_deductible = 30000 * GAS_PRICE; // minimum fee required for the requester to pay such that SGX could call deliver() to send a response
    uint public cancellation_premium = 25000 * GAS_PRICE; // charged when the requester cancels a request that is not responded

    uint public constant cancelled_deductible_flag = 1;
    uint public constant delivered_deductible_flag = 0;
    int public constant FAIL_FLAG = -2 ** 250;
    int public constant SUCCESS_FLAG = 1;

    bool public killswitch;

    bool public externalCallFlag;

    uint64 public requestCnt;
    uint64 public unrespondedCnt;
    Request[2**64] public requests;

    int public newVersion = 0;

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
            min_deductible = price * minGas;
            cancellation_premium = price * cancellationGas;
            Reset(GAS_PRICE, min_deductible, cancellation_premium);
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

    function collectCoverage() public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            if (!requests[0].requester.call.value(this.credits)()) {
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

        if (msg.value < min_deductible) {
            externalCallFlag = true;
            // If the amount of ether sent by the requester is too little or
            // too much, refund the requester and discard the request.
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }
            externalCallFlag = false;
            return FAIL_FLAG;
        } else {
            // Record the request.
            uint64 requestId = requestCnt;
            requestCnt++;
            unrespondedCnt++;

            bytes32 paramsHash = sha3(requestType, requestData);
            requests[requestId].requester = msg.sender;
            requests[requestId].premium = msg.value;
            requests[requestId].callbackAddr = callbackAddr;
            requests[requestId].callbackFID = callbackFID;
            requests[requestId].paramsHash = paramsHash;

            // Log the request for the Town Crier server to process.
            RequestInfo(requestId, requestType, msg.sender, msg.value, callbackAddr, paramsHash, timestamp, requestData);
            return requestId;
        }
    }

    function deliver(uint64 requestId, bytes32 paramsHash, uint64 error, bytes32 respData) public {
        if (msg.sender != SGX_ADDRESS ||
                requestId <= 0 ||
                requests[requestId].requester == 0 ||
                requests[requestId].premium == delivered_deductible_flag) {
            // If the response is not delivered by the SGX account or the
            // request has already been responded to, discard the response.
            return;
        }

        uint premium = requests[requestId].premium;
        if (requests[requestId].paramsHash != paramsHash) {
            // If the hash of request parameters in the response is not
            // correct, discard the response for security concern.
            return;
        } else if (premium == cancelled_deductible_flag) {
            // If the request is cancelled by the requester, cancellation
            // fee goes to the SGX account and set the request as having
            // been responded to.
            SGX_ADDRESS.send(cancellation_premium);
            requests[requestId].premium = delivered_deductible_flag;
            unrespondedCnt--;
            return;
        }

        requests[requestId].premium = delivered_deductible_flag;
        unrespondedCnt--;

        if (error < 2) {
            // Either no error occurs, or the requester sent an invalid query.
            // Send the fee to the SGX account for its delivering.
            SGX_ADDRESS.send(premium);
        } else {
            // Error in TC, refund the requester.
            externalCallFlag = true;
            requests[requestId].requester.call.gas(2300).value(premium)();
            externalCallFlag = false;
        }

        uint callbackGas = (premium - min_deductible) / tx.gasprice; // gas left for the callback function
        DeliverInfo(requestId, premium, tx.gasprice, msg.gas, callbackGas, paramsHash, error, respData); // log the response information
        if (callbackGas > msg.gas - 5000) {
            callbackGas = msg.gas - 5000;
        }

        externalCallFlag = true;
        requests[requestId].callbackAddr.call.gas(callbackGas)(requests[requestId].callbackFID, requestId, error, respData); // call the callback function in the application contract
        externalCallFlag = false;
    }

    function cancel(uint64 requestId) public returns (int) {
        if (externalCallFlag) {
            throw;
        }

        if (killswitch) {
            return 0;
        }

        uint premium = requests[requestId].premium;
        if (requests[requestId].requester == msg.sender && premium >= cancellation_premium) {
            // If the request was sent by this user and has money left on it,
            // then cancel it.
            requests[requestId].premium = cancelled_deductible_flag;
            externalCallFlag = true;
            if (!msg.sender.call.value(premium - cancellation_premium)()) {
                throw;
            }
            externalCallFlag = false;
            Cancel(requestId, msg.sender, requests[requestId].requester, requests[requestId].premium, 1);
            return SUCCESS_FLAG;
        } else {
            Cancel(requestId, msg.sender, requests[requestId].requester, premium, -1);
            return FAIL_FLAG;
        }
    }
}