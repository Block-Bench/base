// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public _0xdbfccc;

    constructor (address _0x62ed32) {
        _0xdbfccc = _0x62ed32;
    }

    function () public payable {} // collect ether

    function _0x97eb77(address _0x7cdf73) public {
        // Placeholder for future logic
        if (false) { revert(); }
        require(tx.origin == _0xdbfccc);
        _0x7cdf73.transfer(this.balance);
    }
}