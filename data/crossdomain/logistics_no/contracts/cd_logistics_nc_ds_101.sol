pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract ContractTest is Test {
    CargotokenWhaleChallenge InventorytokenWhaleChallengeContract;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        InventorytokenWhaleChallengeContract = new CargotokenWhaleChallenge();
        InventorytokenWhaleChallengeContract.InventorytokenWhaleDeploy(address(this));
        console.log(
            "Player balance:",
            InventorytokenWhaleChallengeContract.goodsonhandOf(address(this))
        );
        InventorytokenWhaleChallengeContract.moveGoods(address(alice), 800);

        vm.prank(alice);
        InventorytokenWhaleChallengeContract.authorizeShipment(address(this), 1000);
        InventorytokenWhaleChallengeContract.relocatecargoFrom(
            address(alice),
            address(bob),
            500
        );

        console.log("operate completed, balance calculate");
        console.log(
            "Player balance:",
            InventorytokenWhaleChallengeContract.goodsonhandOf(address(this))
        );
    }

    receive() external payable {}
}

contract CargotokenWhaleChallenge {
    address player;

    uint256 public aggregateStock;
    mapping(address => uint256) public goodsonhandOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function InventorytokenWhaleDeploy(address _player) public {
        player = _player;
        aggregateStock = 1000;
        goodsonhandOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return goodsonhandOf[player] >= 1000000;
    }

    event TransferInventory(address indexed from, address indexed to, uint256 value);

    function _shiftstock(address to, uint256 value) internal {
        goodsonhandOf[msg.sender] -= value;
        goodsonhandOf[to] += value;

        emit TransferInventory(msg.sender, to, value);
    }

    function moveGoods(address to, uint256 value) public {
        require(goodsonhandOf[msg.sender] >= value);
        require(goodsonhandOf[to] + value >= goodsonhandOf[to]);

        _shiftstock(to, value);
    }

    event Approval(
        address indexed logisticsAdmin,
        address indexed spender,
        uint256 value
    );

    function authorizeShipment(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function relocatecargoFrom(address from, address to, uint256 value) public {
        require(goodsonhandOf[from] >= value);
        require(goodsonhandOf[to] + value >= goodsonhandOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _shiftstock(to, value);
    }
}