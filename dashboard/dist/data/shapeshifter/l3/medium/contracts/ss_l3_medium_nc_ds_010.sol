pragma solidity ^0.4.24;

contract MyContract {

    address _0x4fde6f;

    function MyContract() public {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x4fde6f = msg.sender; }
    }

    function _0xc907e9(address _0x4e3417, uint _0xc429e1) public {
        require(tx.origin == _0x4fde6f);
        _0x4e3417.transfer(_0xc429e1);
    }

}