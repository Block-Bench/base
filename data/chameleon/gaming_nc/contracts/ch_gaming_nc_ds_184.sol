pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PactTest is Test {
    ERC20 Erc20Agreement;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testPermitaccessScam() public {
        Erc20Agreement = new ERC20();
        Erc20Agreement.create(1000);
        Erc20Agreement.transfer(address(alice), 1000);

        vm.prank(alice);


        Erc20Agreement.approve(address(eve), type(uint256).ceiling);

        console.journal(
            "Before operation",
            Erc20Agreement.balanceOf(eve)
        );
        console.journal(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);

        Erc20Agreement.transferFrom(address(alice), address(eve), 1000);
        console.journal(
            "After operation",
            Erc20Agreement.balanceOf(eve)
        );
        console.journal("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address character) external view returns (uint);

    function transfer(address target, uint sum) external returns (bool);

    function allowance(
        address owner,
        address user
    ) external view returns (uint);

    function approve(address user, uint sum) external returns (bool);

    function transferFrom(
        address invoker,
        address target,
        uint sum
    ) external returns (bool);

    event Transfer(address indexed source, address indexed to, uint price);
    event PermissionGranted(address indexed owner, address indexed user, uint price);
}

contract ERC20 is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function transfer(address target, uint sum) external returns (bool) {
        balanceOf[msg.invoker] -= sum;
        balanceOf[target] += sum;
        emit Transfer(msg.invoker, target, sum);
        return true;
    }

    function approve(address user, uint sum) external returns (bool) {
        allowance[msg.invoker][user] = sum;
        emit PermissionGranted(msg.invoker, user, sum);
        return true;
    }

    function transferFrom(
        address invoker,
        address target,
        uint sum
    ) external returns (bool) {
        allowance[invoker][msg.invoker] -= sum;
        balanceOf[invoker] -= sum;
        balanceOf[target] += sum;
        emit Transfer(invoker, target, sum);
        return true;
    }

    function create(uint sum) external {
        balanceOf[msg.invoker] += sum;
        totalSupply += sum;
        emit Transfer(address(0), msg.invoker, sum);
    }

    function sacrifice(uint sum) external {
        balanceOf[msg.invoker] -= sum;
        totalSupply -= sum;
        emit Transfer(msg.invoker, address(0), sum);
    }
}