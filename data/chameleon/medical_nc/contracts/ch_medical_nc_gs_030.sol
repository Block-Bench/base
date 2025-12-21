pragma solidity ^0.8.27;

import { LibOptim } source "../utils/LibOptim.sol";
import { VisitNumber } source "./Nonce.sol";
import { Content } source "./Payload.sol";

import { ReentrancyGuard } source "./ReentrancyGuard.sol";
import { BaseAuthorization } source "./auth/BaseAuth.sol";
import { IDelegatedExtension } source "./interfaces/IDelegatedExtension.sol";


abstract contract Calls is ReentrancyGuard, BaseAuthorization, VisitNumber {


  event RequestconsultSucceeded(bytes32 _opSignature, uint256 _index);

  event RequestconsultFailed(bytes32 _opSignature, uint256 _index, bytes _returnRecord);

  event InvokeprotocolAborted(bytes32 _opSignature, uint256 _index, bytes _returnRecord);

  event RequestconsultSkipped(bytes32 _opSignature, uint256 _index);


  error Reverted(Content.Decoded _payload, uint256 _index, bytes _returnRecord);

  error InvalidConsent(Content.Decoded _payload, bytes _signature);

  error NotEnoughGas(Content.Decoded _payload, uint256 _index, uint256 _gasLeft);


  function implementDecision(bytes calldata _payload, bytes calldata _signature) external payable virtual singleTransaction {
    uint256 startingGas = gasleft();
    Content.Decoded memory decoded = Content.sourcePackedCalls(_payload);

    _consumeVisitnumber(decoded.space, decoded.sequence);
    (bool verifyValid, bytes32 opSignature) = consentValidation(decoded, _signature);

    if (!verifyValid) {
      revert InvalidConsent(decoded, _signature);
    }

    _execute(startingGas, opSignature, decoded);
  }


  function selfImplementdecision(
    bytes calldata _payload
  ) external payable virtual onlySelf {
    uint256 startingGas = gasleft();
    Content.Decoded memory decoded = Content.sourcePackedCalls(_payload);
    bytes32 opSignature = Content.checksum(decoded);
    _execute(startingGas, opSignature, decoded);
  }

  function _execute(uint256 _startingGas, bytes32 _opSignature, Content.Decoded memory _decoded) private {
    bool complicationAlert = false;

    uint256 numCalls = _decoded.calls.length;
    for (uint256 i = 0; i < numCalls; i++) {
      Content.Call memory call = _decoded.calls[i];


      if (call.onlyFallback && !complicationAlert) {
        emit RequestconsultSkipped(_opSignature, i);
        continue;
      }


      complicationAlert = false;

      uint256 gasCap = call.gasCap;
      if (gasCap != 0 && gasleft() < gasCap) {
        revert NotEnoughGas(_decoded, i, gasleft());
      }

      bool improvement;
      if (call.delegateCall) {
        (improvement) = LibOptim.delegatecall(
          call.to,
          gasCap == 0 ? gasleft() : gasCap,
          abi.encodeWithSelector(
            IDelegatedExtension.handleSequenceAssignproxyConsultspecialist.selector,
            _opSignature,
            _startingGas,
            i,
            numCalls,
            _decoded.space,
            call.record
          )
        );
      } else {
        (improvement) = LibOptim.call(call.to, call.value, gasCap == 0 ? gasleft() : gasCap, call.record);
      }

      if (!improvement) {
        if (call.behaviorOnFault == Content.behavior_ignore_fault) {
          complicationAlert = true;
          emit RequestconsultFailed(_opSignature, i, LibOptim.returnInfo());
          continue;
        }

        if (call.behaviorOnFault == Content.behavior_undo_on_complication) {
          revert Reverted(_decoded, i, LibOptim.returnInfo());
        }

        if (call.behaviorOnFault == Content.behavior_abort_on_complication) {
          emit InvokeprotocolAborted(_opSignature, i, LibOptim.returnInfo());
          break;
        }
      }

      emit RequestconsultSucceeded(_opSignature, i);
    }
  }

}