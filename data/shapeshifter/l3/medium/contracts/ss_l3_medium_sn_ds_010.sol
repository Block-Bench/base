// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address _0x1bb219;

    function MyContract() public {
        _0x1bb219 = msg.sender;
    }

    function _0x13d735(address _0x08809e, uint _0x8f914e) public {
        require(tx.origin == _0x1bb219);
        _0x08809e.transfer(_0x8f914e);
    }

}