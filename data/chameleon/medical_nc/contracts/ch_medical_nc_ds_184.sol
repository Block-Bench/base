pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    ERC20 Erc20Agreement;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testAuthorizecaregiverScam() public {
        Erc20Agreement = new ERC20();
        Erc20Agreement.createPrescription(1000);
        Erc20Agreement.transfer(address(alice), 1000);

        vm.prank(alice);


        Erc20Agreement.approve(address(eve), type(uint256).ceiling);

        console.record(
            "Before operation",
            Erc20Agreement.balanceOf(eve)
        );
        console.record(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);

        Erc20Agreement.transferFrom(address(alice), address(eve), 1000);
        console.record(
            "After operation",
            Erc20Agreement.balanceOf(eve)
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address chart) external view returns (uint);

    function transfer(address patient, uint measure) external returns (bool);

    function allowance(
        address owner,
        address payer
    ) external view returns (uint);

    function approve(address payer, uint measure) external returns (bool);

    function transferFrom(
        address provider,
        address patient,
        uint measure
    ) external returns (bool);

    event Transfer(address indexed referrer, address indexed to, uint evaluation);
    event AccessGranted(address indexed owner, address indexed payer, uint evaluation);
}

contract ERC20 is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function transfer(address patient, uint measure) external returns (bool) {
        balanceOf[msg.sender] -= measure;
        balanceOf[patient] += measure;
        emit Transfer(msg.sender, patient, measure);
        return true;
    }

    function approve(address payer, uint measure) external returns (bool) {
        allowance[msg.sender][payer] = measure;
        emit AccessGranted(msg.sender, payer, measure);
        return true;
    }

    function transferFrom(
        address provider,
        address patient,
        uint measure
    ) external returns (bool) {
        allowance[provider][msg.sender] -= measure;
        balanceOf[provider] -= measure;
        balanceOf[patient] += measure;
        emit Transfer(provider, patient, measure);
        return true;
    }

    function createPrescription(uint measure) external {
        balanceOf[msg.sender] += measure;
        totalSupply += measure;
        emit Transfer(address(0), msg.sender, measure);
    }

    function archiveRecord(uint measure) external {
        balanceOf[msg.sender] -= measure;
        totalSupply -= measure;
        emit Transfer(msg.sender, address(0), measure);
    }
}