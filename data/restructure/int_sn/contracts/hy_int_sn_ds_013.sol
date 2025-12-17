pragma solidity ^0.4.0;

contract SimpleDestruct {
  function sudicideAnyone() {
        _handleSudicideAnyoneLogic(msg.sender);
    }

    function _handleSudicideAnyoneLogic(address _sender) internal {
        selfdestruct(_sender);
    }

}
