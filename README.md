# Dividend Distribution Contract

## Use Case:

Let's suppose you are the owner of an ERC20 contract. Say you want the tokens of that ERC20 contract to represent a share of your company's profits. Now, occasionally, you want to distribute those profits, let's say in (DAI), to the holders of your ERC20 token.

This contract attempts to solve the following problems that arise from dividend distribution:

1. We could use a `deposit()` function that receives the DAI, and then we could iterate through all accounts holding our token balance, calculate the proportional share for each user, and create a mapping `address => amountReward` so that the user can later claim that `amountReward`.

   However, doing it this way would be catastrophic:
   - When the owner calls `deposit()`, they would have to update the entire mapping of `address => amountReward`. This would either result in extremely high gas costs for the contract owner when calling `deposit()` or, in the worst case, the network would return a "max gas exceeded" error, preventing the deposit.

2. We could focus on another system:
   Declare a variable called `dividends` that stores the amount contributed in the `deposit()` function and a `claimRewards()` function for users to call to retrieve their corresponding share and subtract the claimed value from the `dividends` variable. Then update a mapping to ensure that the user cannot claim again.

   However, this would also generate a serious problem, as a user could claim dividends, then send their ERC20 tokens to another wallet, and claim dividends again by calling `claimRewards()`.

The solution proposed in this contract:

When the owner calls `deposit()`, a variable called `totalDividendPoints` will be updated. This variable serves as a reference for dividend distribution.

The contract also overrides the `transfer` and `transferFrom` functions so that each time user balances are updated, the amount of dividends they can claim is also updated.

This approach avoids the for loop that could drive up gas costs for the owner and also mitigates the issue of users claiming dividends, as a user can no longer switch wallets and claim again.

I have also added a useful function called `checkRewards()` for the frontend to calculate the dividends that correspond to a user, allowing the users to see theinr rewards before claiming.

## Dividend Distribution Contract Functions:

- `depositDividends(uint256 amount)`: Allows the owner to deposit dividends. Users can then claim their share.
- `claimRewards()`: Users can call this function to claim their dividends.
- `checkRewards(address user)`: Provides a way for the frontend to calculate the dividends that belong to a user.

## DEPENDECIES:
 - OpenZeppelin/openzeppelin-contracts@4.8.3/Ownable
 - OpenZeppelin/openzeppelin-contracts@4.8.3/ERC20
