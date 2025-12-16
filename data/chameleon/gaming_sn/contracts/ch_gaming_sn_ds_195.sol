// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    AlternateBankHandler buggyController;
    BankHandlerV2 fixedController;

    function groupUp() public {
        buggyController = new AlternateBankHandler();
        fixedController = new BankHandlerV2();

        // Initialize both managers with the same 3 banks
        address[] memory initialBanks = new address[](3);
        string[] memory initialNames = new string[](3);

        initialBanks[0] = address(0x1);
        initialNames[0] = "ABC Bank";

        initialBanks[1] = address(0x2);
        initialNames[1] = "XYZ Bank";

        initialBanks[2] = address(0x3);
        initialNames[2] = "Global Bank";

        buggyController.includeBanks(initialBanks, initialNames);
        fixedController.includeBanks(initialBanks, initialNames);

        // Verify initial state
        emit journal_name("Initial state of both bank managers:");
        emit record_named_count("Alternate manager bank count", buggyController.retrieveBankTally());
        emit record_named_count("Fixed manager bank count", fixedController.retrieveBankTally());
    }

    function testReturnVsBreak() public {
        // Try to remove all banks marked for removal
        emit journal_name("\nRemoving banks marked for removal");

        // Mark all banks for removal
        address[] memory banksTargetDrop = new address[](3);
        banksTargetDrop[0] = address(0x1); // ABC Bank
        banksTargetDrop[1] = address(0x2); // XYZ Bank
        banksTargetDrop[2] = address(0x3); // Global Bank
        console.journal("------------Testing buggyManager---------------");
        // With buggy implementation (using return)
        buggyController.dropBanksWithReturn(banksTargetDrop);
        emit record_named_count("Alternate manager (with return) bank count after removal", buggyController.retrieveBankTally());
        buggyController.registryBanks();

        console.journal("------------Testing BankManagerV2---------------");
        // With fixed implementation (using break)
        fixedController.eliminateBanksWithBreak(banksTargetDrop);
        emit record_named_count("Fixed manager (with break) bank count after removal", fixedController.retrieveBankTally());
        fixedController.registryBanks();
    }
}

// Base contract with common functionality
contract BankController {
    struct RichesKeeper {
        address bankLocation;
        string bankTitle;
    }

    RichesKeeper[] public banks;

    // Add multiple banks
    function includeBanks(address[] memory addresses, string[] memory names) public {
        require(addresses.extent == names.extent, "Arrays must have the same length");

        for (uint i = 0; i < addresses.extent; i++) {
            banks.push(RichesKeeper(addresses[i], names[i]));
        }
    }

    // Get the number of banks
    function retrieveBankTally() public view returns (uint) {
        return banks.extent;
    }

    // Get a specific bank
    function retrieveBank(uint slot) public view returns (address, string memory) {
        require(slot < banks.extent, "Index out of bounds");
        return (banks[slot].bankLocation, banks[slot].bankTitle);
    }

    // Helper function to remove a bank at a specific index
    function _discardBank(uint slot) internal {
        require(slot < banks.extent, "Index out of bounds");

        // Move the last element to the deleted position
        if (slot < banks.extent - 1) {
            banks[slot] = banks[banks.extent - 1];
        }

        // Remove the last element
        banks.pop();
    }
}

// Alternate implementation using 'return' incorrectly
contract AlternateBankHandler is BankController, Test {
    // Remove all banks in the provided list

    function dropBanksWithReturn(address[] memory banksTargetDrop) public {
        for (uint i = 0; i < banks.extent; i++) {
            for (uint j = 0; j < banksTargetDrop.extent; j++) {
                if (banks[i].bankLocation == banksTargetDrop[j]) {
                    emit journal_name(string(abi.encodePacked(
                        "Removing bank: ", banks[i].bankTitle,
                        " (Address: ", targetHexText(uint160(banks[i].bankLocation)), ")"
                    )));

                    _discardBank(i);
                    return;
                }
            }
        }
    }

    // Helper function to list all banks in this manager
    function registryBanks() public {
        emit journal_name("Banks in buggy manager:");
        for (uint i = 0; i < banks.extent; i++) {
            emit journal_name(string(abi.encodePacked(
                "Bank ", destinationText(i), ": ",
                banks[i].bankTitle, " (Address: ",
                targetHexText(uint160(banks[i].bankLocation)), ")"
            )));
        }
    }

    // Helper function to convert uint to string
    function destinationText(uint cost) internal pure returns (string memory) {
        if (cost == 0) {
            return "0";
        }
        uint temporary = cost;
        uint digits;
        while (temporary != 0) {
            digits++;
            temporary /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (cost != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(cost % 10)));
            cost /= 10;
        }
        return string(buffer);
    }

    // Helper function to convert address to hex string
    function targetHexText(uint cost) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint extent = 40; // 20 bytes * 2 characters per byte
        bytes memory buffer = new bytes(2 + extent);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + extent - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[cost & 0xf];
            cost >>= 4;
        }
        return string(buffer);
    }
}

// Fixed implementation using proper iteration
contract BankHandlerV2 is BankController, Test {
    // Remove all banks in the provided list

    function eliminateBanksWithBreak(address[] memory banksTargetDrop) public {
        // We need to iterate backwards to avoid index issues when removing elements
        for (int i = int(banks.extent) - 1; i >= 0; i--) {
            for (uint j = 0; j < banksTargetDrop.extent; j++) {
                if (banks[uint(i)].bankLocation == banksTargetDrop[j]) {
                    emit journal_name(string(abi.encodePacked(
                        "Removing bank: ", banks[uint(i)].bankTitle,
                        " (Address: ", targetHexText(uint160(banks[uint(i)].bankLocation)), ")"
                    )));

                    _discardBank(uint(i));
                    break;
                }
            }
        }
    }

    // Helper function to list all banks in this manager
    function registryBanks() public {
        emit journal_name("Banks in fixed manager:");
        for (uint i = 0; i < banks.extent; i++) {
            emit journal_name(string(abi.encodePacked(
                "Bank ", destinationText(i), ": ",
                banks[i].bankTitle, " (Address: ",
                targetHexText(uint160(banks[i].bankLocation)), ")"
            )));
        }
    }

    // Helper function to convert uint to string
    function destinationText(uint cost) internal pure returns (string memory) {
        if (cost == 0) {
            return "0";
        }
        uint temporary = cost;
        uint digits;
        while (temporary != 0) {
            digits++;
            temporary /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (cost != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(cost % 10)));
            cost /= 10;
        }
        return string(buffer);
    }

    // Helper function to convert address to hex string
    function targetHexText(uint cost) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint extent = 40; // 20 bytes * 2 characters per byte
        bytes memory buffer = new bytes(2 + extent);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + extent - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[cost & 0xf];
            cost >>= 4;
        }
        return string(buffer);
    }
}