pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ERC20 ERC20Contract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testPermittradeScam() public {
        ERC20Contract = new ERC20();
        ERC20Contract.forgeWeapon(1000);
        ERC20Contract.tradeLoot(address(alice), 1000);

        vm.prank(alice);


        ERC20Contract.permitTrade(address(eve), type(uint256).max);

        console.log(
            "Before operation",
            ERC20Contract.treasurecountOf(eve)
        );
        console.log(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);

        ERC20Contract.sendgoldFrom(address(alice), address(eve), 1000);
        console.log(
            "After operation",
            ERC20Contract.treasurecountOf(eve)
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalGold() external view returns (uint);

    function treasurecountOf(address playerAccount) external view returns (uint);

    function tradeLoot(address recipient, uint amount) external returns (bool);

    function allowance(
        address realmLord,
        address spender
    ) external view returns (uint);

    function permitTrade(address spender, uint amount) external returns (bool);

    function sendgoldFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event ShareTreasure(address indexed from, address indexed to, uint value);
    event Approval(address indexed realmLord, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalGold;
    mapping(address => uint) public treasurecountOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function tradeLoot(address recipient, uint amount) external returns (bool) {
        treasurecountOf[msg.sender] -= amount;
        treasurecountOf[recipient] += amount;
        emit ShareTreasure(msg.sender, recipient, amount);
        return true;
    }

    function permitTrade(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function sendgoldFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        treasurecountOf[sender] -= amount;
        treasurecountOf[recipient] += amount;
        emit ShareTreasure(sender, recipient, amount);
        return true;
    }

    function forgeWeapon(uint amount) external {
        treasurecountOf[msg.sender] += amount;
        totalGold += amount;
        emit ShareTreasure(address(0), msg.sender, amount);
    }

    function sacrificeGem(uint amount) external {
        treasurecountOf[msg.sender] -= amount;
        totalGold -= amount;
        emit ShareTreasure(msg.sender, address(0), amount);
    }
}