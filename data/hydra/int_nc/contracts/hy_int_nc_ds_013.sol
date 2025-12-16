pragma solidity ^0.4.0;

contract SimpleDestruct {
  function sudicideAnyone() {
        _performSudicideAnyoneCore(msg.sender);
    }

    function _performSudicideAnyoneCore(address _sender) internal {
        selfdestruct(_sender);
    }

}