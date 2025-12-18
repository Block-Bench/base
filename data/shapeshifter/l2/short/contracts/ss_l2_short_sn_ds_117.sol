// 0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
pragma solidity ^0.4.15;

contract Rubixi {

        //Declare variables for storage critical to contract
        uint private balance = 0;
        uint private q = 0;
        uint private z = 10;
        uint private l = 300;
        uint private w = 0;

        address private ac;

        //Sets creator
        function DynamicPyramid() {
                ac = msg.sender;
        }

        modifier ab {
                if (msg.sender == ac) _;
        }

        struct Participant {
                address t;
                uint ae;
        }

        Participant[] private u;

        //Fallback function
        function() {
                al();
        }

        //init function run on fallback
        function al() private {
                //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                if (msg.value < 1 ether) {
                        q += msg.value;
                        return;
                }

                uint aj = z;
                //50% fee rebate on any ether value of 50 or greater
                if (msg.value >= 50 ether) aj /= 2;

                aa(aj);
        }

        //Function called for valid tx to the contract
        function aa(uint aj) private {
                //Adds new address to participant array
                u.push(Participant(msg.sender, (msg.value * l) / 100));

                //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                if (u.length == 10) l = 200;
                else if (u.length == 25) l = 150;

                // collect fees and update contract balance
                balance += (msg.value * (100 - aj)) / 100;
                q += (msg.value * aj) / 100;

                //Pays earlier participiants if balance sufficient
                while (balance > u[w].ae) {
                        uint v = u[w].ae;
                        u[w].t.send(v);

                        balance -= u[w].ae;
                        w += 1;
                }
        }

        //Fee functions for creator
        function p() ab {
                if (q == 0) throw;

                ac.send(q);
                q = 0;
        }

        function h(uint am) ab {
                am *= 1 ether;
                if (am > q) p();

                if (q == 0) throw;

                ac.send(am);
                q -= am;
        }

        function f(uint ad) ab {
                if (q == 0 || ad > 100) throw;

                uint s = q / 100 * ad;
                ac.send(s);
                q -= s;
        }

        //Functions for changing variables related to the contract
        function x(address af) ab {
                ac = af;
        }

        function m(uint ah) ab {
                if (ah > 300 || ah < 120) throw;

                l = ah;
        }

        function g(uint aj) ab {
                if (aj > 10) throw;

                z = aj;
        }

        //Functions to provide information to end-user using JSON interface or other interfaces
        function j() constant returns(uint y, string ai) {
                y = l;
                ai = 'This y applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, y is x100 for a fractional y e.g. 250 is actually a 2.5x y. Capped at 3x max and 1.2x min.';
        }

        function e() constant returns(uint an, string ai) {
                an = z;
                ai = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function d() constant returns(uint n, string ai) {
                n = balance / 1 ether;
                ai = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function a() constant returns(uint r) {
                r = u[w].ae / 1 ether;
        }

        function b() constant returns(uint ak) {
                ak = q / 1 ether;
        }

        function k() constant returns(uint ag) {
                ag = u.length;
        }

        function c() constant returns(uint ag) {
                ag = u.length - w;
        }

        function i(uint o) constant returns(address Address, uint Payout) {
                if (o <= u.length) {
                        Address = u[o].t;
                        Payout = u[o].ae / 1 ether;
                }
        }
}