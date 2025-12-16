pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ERC20 ERC20Contract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testAuthorizeshipmentScam() public {
        ERC20Contract = new ERC20();
        ERC20Contract.createManifest(1000);
        ERC20Contract.transferInventory(address(alice), 1000);

        vm.prank(alice);


        ERC20Contract.permitRelease(address(eve), type(uint256).max);

        console.log(
            "Before operation",
            ERC20Contract.cargocountOf(eve)
        );
        console.log(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);

        ERC20Contract.movegoodsFrom(address(alice), address(eve), 1000);
        console.log(
            "After operation",
            ERC20Contract.cargocountOf(eve)
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalInventory() external view returns (uint);

    function cargocountOf(address shipperAccount) external view returns (uint);

    function transferInventory(address recipient, uint amount) external returns (bool);

    function allowance(
        address depotOwner,
        address spender
    ) external view returns (uint);

    function permitRelease(address spender, uint amount) external returns (bool);

    function movegoodsFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event ShiftStock(address indexed from, address indexed to, uint value);
    event Approval(address indexed depotOwner, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalInventory;
    mapping(address => uint) public cargocountOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function transferInventory(address recipient, uint amount) external returns (bool) {
        cargocountOf[msg.sender] -= amount;
        cargocountOf[recipient] += amount;
        emit ShiftStock(msg.sender, recipient, amount);
        return true;
    }

    function permitRelease(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function movegoodsFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        cargocountOf[sender] -= amount;
        cargocountOf[recipient] += amount;
        emit ShiftStock(sender, recipient, amount);
        return true;
    }

    function createManifest(uint amount) external {
        cargocountOf[msg.sender] += amount;
        totalInventory += amount;
        emit ShiftStock(address(0), msg.sender, amount);
    }

    function archiveShipment(uint amount) external {
        cargocountOf[msg.sender] -= amount;
        totalInventory -= amount;
        emit ShiftStock(msg.sender, address(0), amount);
    }
}