from typing import List

class Solution:
    def combine(self, n: int, k: int) -> List[List[int]]:
        ans = []

        def backtrack(nums,  path):
            if len(path) == k:
                ans.append(path.copy())

            if not nums:
                return

            for i, num in enumerate(nums):
                path.append(num)
                backtrack(nums[i+1:], path)
                path.pop()

        backtrack(range(1, n+1), [])

        return ans
