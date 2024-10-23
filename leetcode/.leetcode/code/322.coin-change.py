from typing import List, Optional

class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        dp = [float('inf')] * (amount+1)

        dp[0] = 0

        for i in range(1, amount+1):
            for coin in coins:
                if i >= coin:
                    continue
                dp[i] = min(dp[i], dp[i-coin])

            dp[i] += 1

        return dp[-1]
        
if __name__ == "__main__":
	print(Solution().coinChange([1,2,5], 11)) # 3
