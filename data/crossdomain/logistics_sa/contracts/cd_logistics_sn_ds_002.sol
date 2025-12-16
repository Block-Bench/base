// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CargotokenWarehouse {
    mapping (address => uint) merchantWarehouselevel;

    function getStocklevel(address u) constant returns(uint){
        return merchantWarehouselevel[u];
    }

    function addToStocklevel() payable{
        merchantWarehouselevel[msg.sender] += msg.value;
    }

    function delivergoodsCargocount(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(merchantWarehouselevel[msg.sender])() ) ){
            throw;
        }
        merchantWarehouselevel[msg.sender] = 0;
    }

    function releasegoodsInventoryV2(){

        // has to be change before the call
        uint amount = merchantWarehouselevel[msg.sender];
        merchantWarehouselevel[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function dispatchshipmentGoodsonhandV3(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.transferInventory(merchantWarehouselevel[msg.sender]);
        merchantWarehouselevel[msg.sender] = 0;
    }

}