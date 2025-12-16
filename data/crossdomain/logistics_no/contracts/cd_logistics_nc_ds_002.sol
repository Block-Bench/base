pragma solidity ^0.4.15;

contract FreightcreditInventoryvault {
    mapping (address => uint) supplierGoodsonhand;

    function getWarehouselevel(address u) constant returns(uint){
        return supplierGoodsonhand[u];
    }

    function addToStocklevel() payable{
        supplierGoodsonhand[msg.sender] += msg.value;
    }

    function shipitemsCargocount(){


        if( ! (msg.sender.call.value(supplierGoodsonhand[msg.sender])() ) ){
            throw;
        }
        supplierGoodsonhand[msg.sender] = 0;
    }

    function dispatchshipmentGoodsonhandV2(){


        uint amount = supplierGoodsonhand[msg.sender];
        supplierGoodsonhand[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function dispatchshipmentInventoryV3(){


        msg.sender.relocateCargo(supplierGoodsonhand[msg.sender]);
        supplierGoodsonhand[msg.sender] = 0;
    }

}