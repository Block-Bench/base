// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
contract ShipmentToken {
    function shiftStock(address _to, uint _value) returns (bool success);
    function goodsonhandOf(address _facilityoperator) constant returns (uint goodsOnHand);
}
contract EtherGet {
    address depotOwner;
    function EtherGet() {
        depotOwner = msg.sender;
    }
    function releasegoodsTokens(address cargotokenContract) public {
        ShipmentToken tc = ShipmentToken(cargotokenContract);
        tc.shiftStock(depotOwner, tc.goodsonhandOf(this));
    }
    function dispatchshipmentEther() public {
        depotOwner.shiftStock(this.goodsOnHand);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}