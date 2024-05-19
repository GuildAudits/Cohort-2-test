<p align="center">
<img src="https://res.cloudinary.com/droqoz7lg/image/upload/q_90/dpr_2.0/c_fill,g_auto,h_320,w_320/f_auto/v1/company/onrir4mtc0ipxx4bg7nz?_a=BATAUVAA0" width="400" alt="OneShot">
<br/>

# Task 2 - Code Review

## OneShot.sol

When opportunity knocks, you gunna answer it? One Shot lets a user mint a rapper NFT, have it gain experience in the streets (staking) and Rap Battle against other NFTs for Cred.

The Rapper NFT.

Users mint a rapper that begins with all the flaws and self-doubt we all experience.
NFT Mints with the following properties:

- `weakKnees` - True
- `heavyArms` - True
- `spaghettiSweater` - True
- `calmandReady` - False
- `battlesWon` - 0

The only way to improve these stats is by staking in the `Streets.sol`:

## Streets.sol

Experience on the streets will earn you Cred and remove your rapper's doubts.

- Staked Rapper NFTs will earn 1 Cred ERC20/day staked up to 4 maximum
- Each day staked a Rapper will have properties change that will help them in their next Rap Battle

## RapBattle.sol

Users can put their Cred on the line to step on stage and battle their Rappers. A base skill of 50 is applied to all rappers in battle, and this is modified by the properties the rapper holds.

- WeakKnees - False = +5
- HeavyArms - False = +5
- SpaghettiSweater - False = +5
- CalmAndReady - True = +10

Each rapper's skill is then used to weight their likelihood of randomly winning the battle!

- Winner is given the total of both bets

## CredToken.sol

ERC20 token that represents a Rapper's credibility and time on the streets. The primary currency at risk in a rap battle.

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

# Usage

## Testing

```
forge test
```

### Test Coverage

```
forge coverage
```

and for coverage based testing:

```
forge coverage --report debug
```

# Audit Scope Details

- In Scope:

```
├── src
│   ├── CredToken.sol
│   ├── OneShot.sol
│   ├── RapBattle.sol
│   ├── Streets.sol
```

## Compatibilities

- Solc Version: `^0.8.20`
- Chain(s) to deploy contract to:
  - Ethereum
  - Arbitrum

# Roles

User - Should be able to mint a rapper, stake and unstake their rapper and go on stage/battle

# Known Issues

None
