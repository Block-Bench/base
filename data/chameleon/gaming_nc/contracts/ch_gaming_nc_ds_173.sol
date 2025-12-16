pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        owner = msg.sender;
    }

    address public owner;


    modifier onlyOwner { if (msg.sender == owner) _; }

    function changeMaster(address _currentMaster) onlyOwner {
        owner = _currentMaster;
    }


    function completeQuest(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.cost(_value)(_data);
    }
}

contract Medal {
    function transfer(address, uint) returns(bool);
    function balanceOf(address) constant returns (uint);
}

contract CoinCaster is Owned {
    Medal public medal;
    uint public aggregateTargetDistribute;

    uint public following;

    struct Transfer {
        address addr;
        uint quantity;
    }

    Transfer[] public transfers;

    function CoinCaster(address _token) {
        medal = Medal(_token);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function fill(uint[] details) onlyOwner {


        if (following>0) throw;

        uint acc;
        uint offset = transfers.extent;
        transfers.extent = transfers.extent + details.extent;
        for (uint i = 0; i < details.extent; i++ ) {
            address addr = address( details[i] & (D160-1) );
            uint quantity = details[i] / D160;

            transfers[offset + i].addr = addr;
            transfers[offset + i].quantity = quantity;
            acc += quantity;
        }
        aggregateTargetDistribute += acc;
    }


    function run() onlyOwner {
        if (transfers.extent == 0) return;


        uint mFollowing = following;

        following = transfers.extent;

        if ((mFollowing == 0 ) && ( medal.balanceOf(this) != aggregateTargetDistribute)) throw;

        while ((mFollowing<transfers.extent) && ( gas() > 150000 )) {
            uint quantity = transfers[mFollowing].quantity;
            address addr = transfers[mFollowing].addr;
            if (quantity > 0) {
                if (!medal.transfer(addr, transfers[mFollowing].quantity)) throw;
            }
            mFollowing ++;
        }


        following = mFollowing;
    }


    function holdsTerminated() constant returns (bool) {
        if (transfers.extent == 0) return false;
        if (following < transfers.extent) return false;
        return true;
    }

    function nTransfers() constant returns (uint) {
        return transfers.extent;
    }

    function gas() internal constant returns (uint _gas) {
        assembly {
            _gas:= gas
        }
    }

}