pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    AlternateGoldbankManager buggyManager;
    GoldbankManagerV2 fixedManager;

    function setUp() public {
        buggyManager = new AlternateGoldbankManager();
        fixedManager = new GoldbankManagerV2();


        address[] memory initialBanks = new address[](3);
        string[] memory initialNames = new string[](3);

        initialBanks[0] = address(0x1);
        initialNames[0] = "ABC Bank";

        initialBanks[1] = address(0x2);
        initialNames[1] = "XYZ Bank";

        initialBanks[2] = address(0x3);
        initialNames[2] = "Global Bank";

        buggyManager.addBanks(initialBanks, initialNames);
        fixedManager.addBanks(initialBanks, initialNames);


        emit log_string("Initial state of both bank managers:");
        emit log_named_uint("Alternate manager bank count", buggyManager.getQuestbankCount());
        emit log_named_uint("Fixed manager bank count", fixedManager.getQuestbankCount());
    }

    function testReturnVsBreak() public {

        emit log_string("\nRemoving banks marked for removal");


        address[] memory banksToRemove = new address[](3);
        banksToRemove[0] = address(0x1);
        banksToRemove[1] = address(0x2);
        banksToRemove[2] = address(0x3);
        console.log("------------Testing buggyManager---------------");

        buggyManager.removeBanksWithReturn(banksToRemove);
        emit log_named_uint("Alternate manager (with return) bank count after removal", buggyManager.getQuestbankCount());
        buggyManager.listBanks();

        console.log("------------Testing BankManagerV2---------------");

        fixedManager.removeBanksWithBreak(banksToRemove);
        emit log_named_uint("Fixed manager (with break) bank count after removal", fixedManager.getQuestbankCount());
        fixedManager.listBanks();
    }
}


contract ItembankManager {
    struct GoldBank {
        address goldbankAddress;
        string goldbankName;
    }

    GoldBank[] public banks;


    function addBanks(address[] memory addresses, string[] memory names) public {
        require(addresses.length == names.length, "Arrays must have the same length");

        for (uint i = 0; i < addresses.length; i++) {
            banks.push(GoldBank(addresses[i], names[i]));
        }
    }


    function getQuestbankCount() public view returns (uint) {
        return banks.length;
    }


    function getGoldbank(uint index) public view returns (address, string memory) {
        require(index < banks.length, "Index out of bounds");
        return (banks[index].goldbankAddress, banks[index].goldbankName);
    }


    function _removeBank(uint index) internal {
        require(index < banks.length, "Index out of bounds");


        if (index < banks.length - 1) {
            banks[index] = banks[banks.length - 1];
        }


        banks.pop();
    }
}


contract AlternateGoldbankManager is ItembankManager, Test {


    function removeBanksWithReturn(address[] memory banksToRemove) public {
        for (uint i = 0; i < banks.length; i++) {
            for (uint j = 0; j < banksToRemove.length; j++) {
                if (banks[i].goldbankAddress == banksToRemove[j]) {
                    emit log_string(string(abi.encodePacked(
                        "Removing bank: ", banks[i].goldbankName,
                        " (Address: ", toHexString(uint160(banks[i].goldbankAddress)), ")"
                    )));

                    _removeBank(i);
                    return;
                }
            }
        }
    }


    function listBanks() public {
        emit log_string("Banks in buggy manager:");
        for (uint i = 0; i < banks.length; i++) {
            emit log_string(string(abi.encodePacked(
                "Bank ", toString(i), ": ",
                banks[i].goldbankName, " (Address: ",
                toHexString(uint160(banks[i].goldbankAddress)), ")"
            )));
        }
    }


    function toString(uint value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }


    function toHexString(uint value) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint length = 40;
        bytes memory buffer = new bytes(2 + length);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + length - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}


contract GoldbankManagerV2 is ItembankManager, Test {


    function removeBanksWithBreak(address[] memory banksToRemove) public {

        for (int i = int(banks.length) - 1; i >= 0; i--) {
            for (uint j = 0; j < banksToRemove.length; j++) {
                if (banks[uint(i)].goldbankAddress == banksToRemove[j]) {
                    emit log_string(string(abi.encodePacked(
                        "Removing bank: ", banks[uint(i)].goldbankName,
                        " (Address: ", toHexString(uint160(banks[uint(i)].goldbankAddress)), ")"
                    )));

                    _removeBank(uint(i));
                    break;
                }
            }
        }
    }


    function listBanks() public {
        emit log_string("Banks in fixed manager:");
        for (uint i = 0; i < banks.length; i++) {
            emit log_string(string(abi.encodePacked(
                "Bank ", toString(i), ": ",
                banks[i].goldbankName, " (Address: ",
                toHexString(uint160(banks[i].goldbankAddress)), ")"
            )));
        }
    }


    function toString(uint value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }


    function toHexString(uint value) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint length = 40;
        bytes memory buffer = new bytes(2 + length);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + length - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}