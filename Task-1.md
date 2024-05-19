# Task 1: Building

Build a smart contract for a permissionless platform that allows teams to register and get approval for token presales and utilize Uniswap V2, V3, or any AMM for liquidity pools. Include test cases for validation.

### Note

The platform earns a fee from the funds raised during presales. For example, if a presale collects 100 ETH and the fee is 1%, the platform earns 1 ETH. This revenue is used to reward token holders and pay team salaries.

### Example Scenario and Requirements:

- The team starts a 5-day-long presale with 1000 tokens, each priced at 0.1 ETH (fixed price).
- The price is fixed for the MVP, but in later iterations, it should be dynamic, using a Dutch auction, bonding curve, or something similar.
- At the end of the presale, all the tokens are sold and a period of N days (deadline) starts, during which the team decides whether they want to continue with the vesting or not. There are 3 possible outcomes:
  - If they choose not to continue, a separate function will terminate the liquidity phase before the deadline and return the ETH to the users.
  - If the team abandons the project and does not provide liquidity for the liquidity pool (LP), the ETH in the contract is again returned to the users at the end of the deadline.
  - If the team decides to proceed with vesting, they provide more tokens (TX) to create a liquidity pool pair of presale tokens/raised ETH. The ratio of the tokens to ETH deposited in the liquidity pool determines the initial trading price of the token on the DEX. For instance, if 1,000 tokens are paired with 100 ETH, the initial price per token would be 0.1 ETH. The amount of LP tokens provided mustn't result in a lower price than the presale tokens.
  - The platform sets a fee that is distributed to TAO holders; if set at 10%, that means the available ETH for liquidity provision is 90 ETH. This implies that at most 900 tokens can be provided to the pair to maintain a price of 0.1 ETH per token. This is crucial because if, for example, 1000 tokens are provided, the price in the LP would be 0.09, which is lower than the presale price, rendering the presale meaningless.
- In cases where LP is created, the vesting period begins, allowing users to claim their share of tokens they bought at a discount. Since the team also predefines the length of the vesting period, in our case, it will be 10 days. This means funds will be released linearly during this period to prevent immediate selling that could lead to price drops. For example, this means that on day 1, only 100 (1/10) tokens will be released, and from day 10 onward, all of them will be available for claiming.
