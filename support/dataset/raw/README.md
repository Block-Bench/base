# Raw Dataset Sources

This directory contains the original raw datasets used to create BlockBench. These are **not tracked in git** due to their size and because the processed data is available in `data/annotated/`.

## Original Sources

The following repositories were used to collect and process the BlockBench dataset:

1. **DeFiHackLabs** - https://github.com/SunWeb3Sec/DeFiHackLabs
2. **DeFiVulnLabs** - https://github.com/SunWeb3Sec/DeFiVulnLabs
3. **not-so-smart-contracts** - https://github.com/crytic/not-so-smart-contracts
4. **sealevel-attacks** - https://github.com/coral-xyz/sealevel-attacks
5. **smartbugs-curated** - https://github.com/smartbugs/smartbugs-curated
6. **solana-ctf** - Various Solana CTF challenges
7. **solsec** - Solana security resources

## Cloning Raw Sources (Optional)

If you need to access the raw sources for reference:

```bash
cd support/dataset/raw
git clone https://github.com/SunWeb3Sec/DeFiHackLabs
git clone https://github.com/SunWeb3Sec/DeFiVulnLabs
git clone https://github.com/crytic/not-so-smart-contracts
git clone https://github.com/coral-xyz/sealevel-attacks
git clone https://github.com/smartbugs/smartbugs-curated
# ... etc
```

**Note**: The processed and annotated dataset is available in `data/annotated/` and is ready to use without cloning these sources.
