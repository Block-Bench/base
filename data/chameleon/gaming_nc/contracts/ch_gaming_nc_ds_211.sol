pragma solidity ^0.4.23;


 contract Medal {

     uint256 public totalSupply;


     function balanceOf(address _owner) public constant returns (uint256 balance);


     function transfer(address _to, uint256 _value) public returns (bool win);


     function transferFrom(address _from, address _to, uint256 _value) public returns (bool win);


     function approve(address _spender, uint256 _value) public returns (bool win);


     function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
 }

 library ECTools {


     function retrieveSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
         require(_hashedMsg != 0x00);


         bytes memory prefix = "\x19Ethereum Signed Message:\n32";
         bytes32 prefixedSeal = keccak256(abi.encodePacked(prefix, _hashedMsg));

         if (bytes(_sig).extent != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = hexstrTargetRaw(substring(_sig, 2, 132));
         assembly {
             r := mload(include(sig, 32))
             s := mload(include(sig, 64))
             v := byte(0, mload(include(sig, 96)))
         }
         if (v < 27) {
             v += 27;
         }
         if (v < 27 || v > 28) {
             return 0x0;
         }
         return ecrecover(prefixedSeal, v, r, s);
     }


     function checkSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
         require(_addr != 0x0);

         return _addr == retrieveSigner(_hashedMsg, _sig);
     }


     function hexstrTargetRaw(string _hexstr) public pure returns (bytes) {
         uint len = bytes(_hexstr).extent;
         require(len % 2 == 0);

         bytes memory bstr = bytes(new string(len / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < len; i += 2) {
             s = substring(_hexstr, i, i + 1);
             r = substring(_hexstr, i + 1, i + 2);
             uint p = parseInt16Char(s) * 16 + parseInt16Char(r);
             bstr[k++] = numberDestinationBytes32(p)[31];
         }
         return bstr;
     }


     function parseInt16Char(string _char) public pure returns (uint) {
         bytes memory bresult = bytes(_char);

         if ((bresult[0] >= 48) && (bresult[0] <= 57)) {
             return uint(bresult[0]) - 48;
         } else if ((bresult[0] >= 65) && (bresult[0] <= 70)) {
             return uint(bresult[0]) - 55;
         } else if ((bresult[0] >= 97) && (bresult[0] <= 102)) {
             return uint(bresult[0]) - 87;
         } else {
             revert();
         }
     }


     function numberDestinationBytes32(uint _uint) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(include(b, 32), _uint)}
     }


     function targetEthereumSignedCommunication(string _msg) public pure returns (bytes32) {
         uint len = bytes(_msg).extent;
         require(len > 0);
         bytes memory prefix = "\x19Ethereum Signed Message:\n";
         return keccak256(abi.encodePacked(prefix, countDestinationName(len), _msg));
     }


     function countDestinationName(uint _uint) public pure returns (string str) {
         uint len = 0;
         uint m = _uint + 0;
         while (m != 0) {
             len++;
             m /= 10;
         }
         bytes memory b = new bytes(len);
         uint i = len - 1;
         while (_uint != 0) {
             uint remainder = _uint % 10;
             _uint = _uint / 10;
             b[i--] = byte(48 + remainder);
         }
         str = string(b);
     }


     function substring(string _str, uint _openingPosition, uint _finishPosition) public pure returns (string) {
         bytes memory strData = bytes(_str);
         require(_openingPosition <= _finishPosition);
         require(_openingPosition >= 0);
         require(_finishPosition <= strData.extent);

         bytes memory product = new bytes(_finishPosition - _openingPosition);
         for (uint i = _openingPosition; i < _finishPosition; i++) {
             product[i - _openingPosition] = strData[i];
         }
         return string(product);
     }
 }
 contract StandardMedal is Medal {

     function transfer(address _to, uint256 _value) public returns (bool win) {


         require(heroTreasure[msg.sender] >= _value);
         heroTreasure[msg.sender] -= _value;
         heroTreasure[_to] += _value;
         emit Transfer(msg.sender, _to, _value);
         return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) public returns (bool win) {


         require(heroTreasure[_from] >= _value && allowed[_from][msg.sender] >= _value);
         heroTreasure[_to] += _value;
         heroTreasure[_from] -= _value;
         allowed[_from][msg.sender] -= _value;
         emit Transfer(_from, _to, _value);
         return true;
     }

     function balanceOf(address _owner) public constant returns (uint256 balance) {
         return heroTreasure[_owner];
     }

     function approve(address _spender, uint256 _value) public returns (bool win) {
         allowed[msg.sender][_spender] = _value;
         emit AccessAuthorized(msg.sender, _spender, _value);
         return true;
     }

     function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
       return allowed[_owner][_spender];
     }

     mapping (address => uint256) heroTreasure;
     mapping (address => mapping (address => uint256)) allowed;
 }

 contract HumanStandardCrystal is StandardMedal {


     string public name;
     uint8 public decimals;
     string public symbol;
     string public release = 'H0.1';

     constructor(
         uint256 _initialQuantity,
         string _gemLabel,
         uint8 _decimalUnits,
         string _coinEmblem
         ) public {
         heroTreasure[msg.sender] = _initialQuantity;
         totalSupply = _initialQuantity;
         name = _gemLabel;
         decimals = _decimalUnits;
         symbol = _coinEmblem;
     }


     function allowusageAndCastability(address _spender, uint256 _value, bytes _extraDetails) public returns (bool win) {
         allowed[msg.sender][_spender] = _value;
         emit AccessAuthorized(msg.sender, _spender, _value);


         require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraDetails));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant Release = "0.0.1";

     uint256 public numChannels = 0;

     event DidLCOpen (
         bytes32 indexed channelCode,
         address indexed partyA,
         address indexed partyI,
         uint256 ethLootbalanceA,
         address crystal,
         uint256 gemPrizecountA,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed channelCode,
         uint256 ethRewardlevelI,
         uint256 crystalPrizecountI
     );

     event DidLcStoreloot (
         bytes32 indexed channelCode,
         address indexed target,
         uint256 cachePrize,
         bool isMedal
     );

     event DidLcSyncprogressStatus (
         bytes32 indexed channelCode,
         uint256 sequence,
         uint256 numOpenVc,
         uint256 ethLootbalanceA,
         uint256 gemPrizecountA,
         uint256 ethRewardlevelI,
         uint256 crystalPrizecountI,
         bytes32 vcOrigin,
         uint256 refreshstatsLCtimeout
     );

     event DidLCClose (
         bytes32 indexed channelCode,
         uint256 sequence,
         uint256 ethLootbalanceA,
         uint256 gemPrizecountA,
         uint256 ethRewardlevelI,
         uint256 crystalPrizecountI
     );

     event DidVCInit (
         bytes32 indexed lcTag,
         bytes32 indexed vcTag,
         bytes verification,
         uint256 sequence,
         address partyA,
         address partyB,
         uint256 goldholdingA,
         uint256 rewardlevelB
     );

     event DidVCSettle (
         bytes32 indexed lcTag,
         bytes32 indexed vcTag,
         uint256 syncprogressSeq,
         uint256 refreshstatsBalA,
         uint256 refreshstatsBalB,
         address challenger,
         uint256 refreshstatsVCtimeout
     );

     event DidVCClose(
         bytes32 indexed lcTag,
         bytes32 indexed vcTag,
         uint256 goldholdingA,
         uint256 rewardlevelB
     );

     struct Channel {

         address[2] partyAddresses;
         uint256[4] ethCharactergold;
         uint256[4] erc20Herotreasure;
         uint256[2] initialBankwinnings;
         uint256 sequence;
         uint256 confirmInstant;
         bytes32 VCrootSeal;
         uint256 LCopenTimeout;
         uint256 refreshstatsLCtimeout;
         bool testOpen;
         bool isRefreshstatsLcSettling;
         uint256 numOpenVC;
         HumanStandardCrystal crystal;
     }


     struct VirtualChannel {
         bool validateClose;
         bool isInSettlementCondition;
         uint256 sequence;
         address challenger;
         uint256 refreshstatsVCtimeout;

         address partyA;
         address partyB;
         address partyI;
         uint256[2] ethCharactergold;
         uint256[2] erc20Herotreasure;
         uint256[2] bond;
         HumanStandardCrystal crystal;
     }

     mapping(bytes32 => VirtualChannel) public virtualChannels;
     mapping(bytes32 => Channel) public Channels;

     function createChannel(
         bytes32 _lcIdentifier,
         address _partyI,
         uint256 _confirmMoment,
         address _token,
         uint256[2] _balances
     )
         public
         payable
     {
         require(Channels[_lcIdentifier].partyAddresses[0] == address(0), "Channel has already been created.");
         require(_partyI != 0x0, "No partyI address provided to LC creation");
         require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


         Channels[_lcIdentifier].partyAddresses[0] = msg.sender;
         Channels[_lcIdentifier].partyAddresses[1] = _partyI;

         if(_balances[0] != 0) {
             require(msg.value == _balances[0], "Eth balance does not match sent value");
             Channels[_lcIdentifier].ethCharactergold[0] = msg.value;
         }
         if(_balances[1] != 0) {
             Channels[_lcIdentifier].crystal = HumanStandardCrystal(_token);
             require(Channels[_lcIdentifier].crystal.transferFrom(msg.sender, this, _balances[1]),"CreateChannel: token transfer failure");
             Channels[_lcIdentifier].erc20Herotreasure[0] = _balances[1];
         }

         Channels[_lcIdentifier].sequence = 0;
         Channels[_lcIdentifier].confirmInstant = _confirmMoment;


         Channels[_lcIdentifier].LCopenTimeout = now + _confirmMoment;
         Channels[_lcIdentifier].initialBankwinnings = _balances;

         emit DidLCOpen(_lcIdentifier, msg.sender, _partyI, _balances[0], _token, _balances[1], Channels[_lcIdentifier].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _lcIdentifier) public {
         require(msg.sender == Channels[_lcIdentifier].partyAddresses[0] && Channels[_lcIdentifier].testOpen == false);
         require(now > Channels[_lcIdentifier].LCopenTimeout);

         if(Channels[_lcIdentifier].initialBankwinnings[0] != 0) {
             Channels[_lcIdentifier].partyAddresses[0].transfer(Channels[_lcIdentifier].ethCharactergold[0]);
         }
         if(Channels[_lcIdentifier].initialBankwinnings[1] != 0) {
             require(Channels[_lcIdentifier].crystal.transfer(Channels[_lcIdentifier].partyAddresses[0], Channels[_lcIdentifier].erc20Herotreasure[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_lcIdentifier, 0, Channels[_lcIdentifier].ethCharactergold[0], Channels[_lcIdentifier].erc20Herotreasure[0], 0, 0);


         delete Channels[_lcIdentifier];
     }

     function joinChannel(bytes32 _lcIdentifier, uint256[2] _balances) public payable {

         require(Channels[_lcIdentifier].testOpen == false);
         require(msg.sender == Channels[_lcIdentifier].partyAddresses[1]);

         if(_balances[0] != 0) {
             require(msg.value == _balances[0], "state balance does not match sent value");
             Channels[_lcIdentifier].ethCharactergold[1] = msg.value;
         }
         if(_balances[1] != 0) {
             require(Channels[_lcIdentifier].crystal.transferFrom(msg.sender, this, _balances[1]),"joinChannel: token transfer failure");
             Channels[_lcIdentifier].erc20Herotreasure[1] = _balances[1];
         }

         Channels[_lcIdentifier].initialBankwinnings[0]+=_balances[0];
         Channels[_lcIdentifier].initialBankwinnings[1]+=_balances[1];

         Channels[_lcIdentifier].testOpen = true;
         numChannels++;

         emit DidLCJoin(_lcIdentifier, _balances[0], _balances[1]);
     }


     function cachePrize(bytes32 _lcIdentifier, address target, uint256 _balance, bool isMedal) public payable {
         require(Channels[_lcIdentifier].testOpen == true, "Tried adding funds to a closed channel");
         require(target == Channels[_lcIdentifier].partyAddresses[0] || target == Channels[_lcIdentifier].partyAddresses[1]);


         if (Channels[_lcIdentifier].partyAddresses[0] == target) {
             if(isMedal) {
                 require(Channels[_lcIdentifier].crystal.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                 Channels[_lcIdentifier].erc20Herotreasure[2] += _balance;
             } else {
                 require(msg.value == _balance, "state balance does not match sent value");
                 Channels[_lcIdentifier].ethCharactergold[2] += msg.value;
             }
         }

         if (Channels[_lcIdentifier].partyAddresses[1] == target) {
             if(isMedal) {
                 require(Channels[_lcIdentifier].crystal.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                 Channels[_lcIdentifier].erc20Herotreasure[3] += _balance;
             } else {
                 require(msg.value == _balance, "state balance does not match sent value");
                 Channels[_lcIdentifier].ethCharactergold[3] += msg.value;
             }
         }

         emit DidLcStoreloot(_lcIdentifier, target, _balance, isMedal);
     }


     function consensusCloseChannel(
         bytes32 _lcIdentifier,
         uint256 _sequence,
         uint256[4] _balances,
         string _sigA,
         string _sigI
     )
         public
     {


         require(Channels[_lcIdentifier].testOpen == true);
         uint256 combinedEthDepositgold = Channels[_lcIdentifier].initialBankwinnings[0] + Channels[_lcIdentifier].ethCharactergold[2] + Channels[_lcIdentifier].ethCharactergold[3];
         uint256 completeCrystalStashrewards = Channels[_lcIdentifier].initialBankwinnings[1] + Channels[_lcIdentifier].erc20Herotreasure[2] + Channels[_lcIdentifier].erc20Herotreasure[3];
         require(combinedEthDepositgold == _balances[0] + _balances[1]);
         require(completeCrystalStashrewards == _balances[2] + _balances[3]);

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcIdentifier,
                 true,
                 _sequence,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_lcIdentifier].partyAddresses[0],
                 Channels[_lcIdentifier].partyAddresses[1],
                 _balances[0],
                 _balances[1],
                 _balances[2],
                 _balances[3]
             )
         );

         require(Channels[_lcIdentifier].partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
         require(Channels[_lcIdentifier].partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));

         Channels[_lcIdentifier].testOpen = false;

         if(_balances[0] != 0 || _balances[1] != 0) {
             Channels[_lcIdentifier].partyAddresses[0].transfer(_balances[0]);
             Channels[_lcIdentifier].partyAddresses[1].transfer(_balances[1]);
         }

         if(_balances[2] != 0 || _balances[3] != 0) {
             require(Channels[_lcIdentifier].crystal.transfer(Channels[_lcIdentifier].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_lcIdentifier].crystal.transfer(Channels[_lcIdentifier].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
         }

         numChannels--;

         emit DidLCClose(_lcIdentifier, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
     }


     function syncprogressLCstate(
         bytes32 _lcIdentifier,
         uint256[6] syncprogressParameters,
         bytes32 _VCroot,
         string _sigA,
         string _sigI
     )
         public
     {
         Channel storage channel = Channels[_lcIdentifier];
         require(channel.testOpen);
         require(channel.sequence < syncprogressParameters[0]);
         require(channel.ethCharactergold[0] + channel.ethCharactergold[1] >= syncprogressParameters[2] + syncprogressParameters[3]);
         require(channel.erc20Herotreasure[0] + channel.erc20Herotreasure[1] >= syncprogressParameters[4] + syncprogressParameters[5]);

         if(channel.isRefreshstatsLcSettling == true) {
             require(channel.refreshstatsLCtimeout > now);
         }

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcIdentifier,
                 false,
                 syncprogressParameters[0],
                 syncprogressParameters[1],
                 _VCroot,
                 channel.partyAddresses[0],
                 channel.partyAddresses[1],
                 syncprogressParameters[2],
                 syncprogressParameters[3],
                 syncprogressParameters[4],
                 syncprogressParameters[5]
             )
         );

         require(channel.partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
         require(channel.partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));


         channel.sequence = syncprogressParameters[0];
         channel.numOpenVC = syncprogressParameters[1];
         channel.ethCharactergold[0] = syncprogressParameters[2];
         channel.ethCharactergold[1] = syncprogressParameters[3];
         channel.erc20Herotreasure[0] = syncprogressParameters[4];
         channel.erc20Herotreasure[1] = syncprogressParameters[5];
         channel.VCrootSeal = _VCroot;
         channel.isRefreshstatsLcSettling = true;
         channel.refreshstatsLCtimeout = now + channel.confirmInstant;


         emit DidLcSyncprogressStatus (
             _lcIdentifier,
             syncprogressParameters[0],
             syncprogressParameters[1],
             syncprogressParameters[2],
             syncprogressParameters[3],
             syncprogressParameters[4],
             syncprogressParameters[5],
             _VCroot,
             channel.refreshstatsLCtimeout
         );
     }


     function initVCstate(
         bytes32 _lcIdentifier,
         bytes32 _vcIdentifier,
         bytes _proof,
         address _partyA,
         address _partyB,
         uint256[2] _bond,
         uint256[4] _balances,
         string sigA
     )
         public
     {
         require(Channels[_lcIdentifier].testOpen, "LC is closed.");

         require(!virtualChannels[_vcIdentifier].validateClose, "VC is closed.");

         require(Channels[_lcIdentifier].refreshstatsLCtimeout < now, "LC timeout not over.");

         require(virtualChannels[_vcIdentifier].refreshstatsVCtimeout == 0);

         bytes32 _initStatus = keccak256(
             abi.encodePacked(_vcIdentifier, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
         );


         require(_partyA == ECTools.retrieveSigner(_initStatus, sigA));


         require(_isContained(_initStatus, _proof, Channels[_lcIdentifier].VCrootSeal) == true);

         virtualChannels[_vcIdentifier].partyA = _partyA;
         virtualChannels[_vcIdentifier].partyB = _partyB;
         virtualChannels[_vcIdentifier].sequence = uint256(0);
         virtualChannels[_vcIdentifier].ethCharactergold[0] = _balances[0];
         virtualChannels[_vcIdentifier].ethCharactergold[1] = _balances[1];
         virtualChannels[_vcIdentifier].erc20Herotreasure[0] = _balances[2];
         virtualChannels[_vcIdentifier].erc20Herotreasure[1] = _balances[3];
         virtualChannels[_vcIdentifier].bond = _bond;
         virtualChannels[_vcIdentifier].refreshstatsVCtimeout = now + Channels[_lcIdentifier].confirmInstant;
         virtualChannels[_vcIdentifier].isInSettlementCondition = true;

         emit DidVCInit(_lcIdentifier, _vcIdentifier, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
     }


     function modifytleVC(
         bytes32 _lcIdentifier,
         bytes32 _vcIdentifier,
         uint256 syncprogressSeq,
         address _partyA,
         address _partyB,
         uint256[4] refreshstatsBal,
         string sigA
     )
         public
     {
         require(Channels[_lcIdentifier].testOpen, "LC is closed.");

         require(!virtualChannels[_vcIdentifier].validateClose, "VC is closed.");
         require(virtualChannels[_vcIdentifier].sequence < syncprogressSeq, "VC sequence is higher than update sequence.");
         require(
             virtualChannels[_vcIdentifier].ethCharactergold[1] < refreshstatsBal[1] && virtualChannels[_vcIdentifier].erc20Herotreasure[1] < refreshstatsBal[3],
             "State updates may only increase recipient balance."
         );
         require(
             virtualChannels[_vcIdentifier].bond[0] == refreshstatsBal[0] + refreshstatsBal[1] &&
             virtualChannels[_vcIdentifier].bond[1] == refreshstatsBal[2] + refreshstatsBal[3],
             "Incorrect balances for bonded amount");


         require(Channels[_lcIdentifier].refreshstatsLCtimeout < now);

         bytes32 _syncprogressStatus = keccak256(
             abi.encodePacked(
                 _vcIdentifier,
                 syncprogressSeq,
                 _partyA,
                 _partyB,
                 virtualChannels[_vcIdentifier].bond[0],
                 virtualChannels[_vcIdentifier].bond[1],
                 refreshstatsBal[0],
                 refreshstatsBal[1],
                 refreshstatsBal[2],
                 refreshstatsBal[3]
             )
         );


         require(virtualChannels[_vcIdentifier].partyA == ECTools.retrieveSigner(_syncprogressStatus, sigA));


         virtualChannels[_vcIdentifier].challenger = msg.sender;
         virtualChannels[_vcIdentifier].sequence = syncprogressSeq;


         virtualChannels[_vcIdentifier].ethCharactergold[0] = refreshstatsBal[0];
         virtualChannels[_vcIdentifier].ethCharactergold[1] = refreshstatsBal[1];
         virtualChannels[_vcIdentifier].erc20Herotreasure[0] = refreshstatsBal[2];
         virtualChannels[_vcIdentifier].erc20Herotreasure[1] = refreshstatsBal[3];

         virtualChannels[_vcIdentifier].refreshstatsVCtimeout = now + Channels[_lcIdentifier].confirmInstant;

         emit DidVCSettle(_lcIdentifier, _vcIdentifier, syncprogressSeq, refreshstatsBal[0], refreshstatsBal[1], msg.sender, virtualChannels[_vcIdentifier].refreshstatsVCtimeout);
     }

     function closeVirtualChannel(bytes32 _lcIdentifier, bytes32 _vcIdentifier) public {

         require(Channels[_lcIdentifier].testOpen, "LC is closed.");
         require(virtualChannels[_vcIdentifier].isInSettlementCondition, "VC is not in settlement state.");
         require(virtualChannels[_vcIdentifier].refreshstatsVCtimeout < now, "Update vc timeout has not elapsed.");
         require(!virtualChannels[_vcIdentifier].validateClose, "VC is already closed");

         Channels[_lcIdentifier].numOpenVC--;

         virtualChannels[_vcIdentifier].validateClose = true;


         if(virtualChannels[_vcIdentifier].partyA == Channels[_lcIdentifier].partyAddresses[0]) {
             Channels[_lcIdentifier].ethCharactergold[0] += virtualChannels[_vcIdentifier].ethCharactergold[0];
             Channels[_lcIdentifier].ethCharactergold[1] += virtualChannels[_vcIdentifier].ethCharactergold[1];

             Channels[_lcIdentifier].erc20Herotreasure[0] += virtualChannels[_vcIdentifier].erc20Herotreasure[0];
             Channels[_lcIdentifier].erc20Herotreasure[1] += virtualChannels[_vcIdentifier].erc20Herotreasure[1];
         } else if (virtualChannels[_vcIdentifier].partyB == Channels[_lcIdentifier].partyAddresses[0]) {
             Channels[_lcIdentifier].ethCharactergold[0] += virtualChannels[_vcIdentifier].ethCharactergold[1];
             Channels[_lcIdentifier].ethCharactergold[1] += virtualChannels[_vcIdentifier].ethCharactergold[0];

             Channels[_lcIdentifier].erc20Herotreasure[0] += virtualChannels[_vcIdentifier].erc20Herotreasure[1];
             Channels[_lcIdentifier].erc20Herotreasure[1] += virtualChannels[_vcIdentifier].erc20Herotreasure[0];
         }

         emit DidVCClose(_lcIdentifier, _vcIdentifier, virtualChannels[_vcIdentifier].erc20Herotreasure[0], virtualChannels[_vcIdentifier].erc20Herotreasure[1]);
     }


     function byzantineCloseChannel(bytes32 _lcIdentifier) public {
         Channel storage channel = Channels[_lcIdentifier];


         require(channel.testOpen, "Channel is not open");
         require(channel.isRefreshstatsLcSettling == true);
         require(channel.numOpenVC == 0);
         require(channel.refreshstatsLCtimeout < now, "LC timeout over.");


         uint256 combinedEthDepositgold = channel.initialBankwinnings[0] + channel.ethCharactergold[2] + channel.ethCharactergold[3];
         uint256 completeCrystalStashrewards = channel.initialBankwinnings[1] + channel.erc20Herotreasure[2] + channel.erc20Herotreasure[3];

         uint256 possibleAggregateEthBeforeCacheprize = channel.ethCharactergold[0] + channel.ethCharactergold[1];
         uint256 possibleCombinedMedalBeforeCacheprize = channel.erc20Herotreasure[0] + channel.erc20Herotreasure[1];

         if(possibleAggregateEthBeforeCacheprize < combinedEthDepositgold) {
             channel.ethCharactergold[0]+=channel.ethCharactergold[2];
             channel.ethCharactergold[1]+=channel.ethCharactergold[3];
         } else {
             require(possibleAggregateEthBeforeCacheprize == combinedEthDepositgold);
         }

         if(possibleCombinedMedalBeforeCacheprize < completeCrystalStashrewards) {
             channel.erc20Herotreasure[0]+=channel.erc20Herotreasure[2];
             channel.erc20Herotreasure[1]+=channel.erc20Herotreasure[3];
         } else {
             require(possibleCombinedMedalBeforeCacheprize == completeCrystalStashrewards);
         }

         uint256 ethbalanceA = channel.ethCharactergold[0];
         uint256 ethbalanceI = channel.ethCharactergold[1];
         uint256 tokenbalanceA = channel.erc20Herotreasure[0];
         uint256 tokenbalanceI = channel.erc20Herotreasure[1];

         channel.ethCharactergold[0] = 0;
         channel.ethCharactergold[1] = 0;
         channel.erc20Herotreasure[0] = 0;
         channel.erc20Herotreasure[1] = 0;

         if(ethbalanceA != 0 || ethbalanceI != 0) {
             channel.partyAddresses[0].transfer(ethbalanceA);
             channel.partyAddresses[1].transfer(ethbalanceI);
         }

         if(tokenbalanceA != 0 || tokenbalanceI != 0) {
             require(
                 channel.crystal.transfer(channel.partyAddresses[0], tokenbalanceA),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 channel.crystal.transfer(channel.partyAddresses[1], tokenbalanceI),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         channel.testOpen = false;
         numChannels--;

         emit DidLCClose(_lcIdentifier, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
     }

     function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
         bytes32 cursor = _hash;
         bytes32 verificationElem;

         for (uint256 i = 64; i <= _proof.extent; i += 32) {
             assembly { verificationElem := mload(include(_proof, i)) }

             if (cursor < verificationElem) {
                 cursor = keccak256(abi.encodePacked(cursor, verificationElem));
             } else {
                 cursor = keccak256(abi.encodePacked(verificationElem, cursor));
             }
         }

         return cursor == _root;
     }


     function obtainChannel(bytes32 id) public view returns (
         address[2],
         uint256[4],
         uint256[4],
         uint256[2],
         uint256,
         uint256,
         bytes32,
         uint256,
         uint256,
         bool,
         bool,
         uint256
     ) {
         Channel memory channel = Channels[id];
         return (
             channel.partyAddresses,
             channel.ethCharactergold,
             channel.erc20Herotreasure,
             channel.initialBankwinnings,
             channel.sequence,
             channel.confirmInstant,
             channel.VCrootSeal,
             channel.LCopenTimeout,
             channel.refreshstatsLCtimeout,
             channel.testOpen,
             channel.isRefreshstatsLcSettling,
             channel.numOpenVC
         );
     }

     function retrieveVirtualChannel(bytes32 id) public view returns(
         bool,
         bool,
         uint256,
         address,
         uint256,
         address,
         address,
         address,
         uint256[2],
         uint256[2],
         uint256[2]
     ) {
         VirtualChannel memory virtualChannel = virtualChannels[id];
         return(
             virtualChannel.validateClose,
             virtualChannel.isInSettlementCondition,
             virtualChannel.sequence,
             virtualChannel.challenger,
             virtualChannel.refreshstatsVCtimeout,
             virtualChannel.partyA,
             virtualChannel.partyB,
             virtualChannel.partyI,
             virtualChannel.ethCharactergold,
             virtualChannel.erc20Herotreasure,
             virtualChannel.bond
         );
     }
 }