pragma solidity ^0.4.19;
contract CargoToken {
    function shiftStock(address _to, uint _value) returns (bool success);
    function cargocountOf(address _logisticsadmin) constant returns (uint goodsOnHand);
}
contract EtherGet {
    address facilityOperator;
    function EtherGet() {
        facilityOperator = msg.sender;
    }
    function shipitemsTokens(address freightcreditContract) public {
        CargoToken tc = CargoToken(freightcreditContract);
        tc.shiftStock(facilityOperator, tc.cargocountOf(this));
    }
    function shipitemsEther() public {
        facilityOperator.shiftStock(this.goodsOnHand);
    }
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}