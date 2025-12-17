// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address _0x842ea1;

    function MyContract() public {
        _0x842ea1 = msg.sender;
    }

    function _0x3224fb(address _0x8469da, uint _0x13bbeb) public {
        require(tx.origin == _0x842ea1);
        _0x8469da.transfer(_0x13bbeb);
    }

}