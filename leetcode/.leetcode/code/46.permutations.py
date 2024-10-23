class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        ans = []

        def backtrack(nums, path):
            if len(nums) == 0:
                ans.append(path.copy())
                return

            for i in range(len(nums)):
                path.append(nums[i])
                backtrack(nums[:i] + nums[i+1:], path)
                path.pop()
            
        backtrack(nums, [])

        return ans
