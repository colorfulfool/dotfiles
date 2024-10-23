from typing import List, Optional

class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        ans = 0
        chars = set([s[0]])
        l = 0

        for r in range(1, len(s)):
            while s[r] in chars:
                chars.remove(s[l])
                l += 1

            chars.add(s[r])

            ans = max(ans, r-l+1)

            print(s[l:r+1])

        return ans
        
if __name__ == "__main__":
	print(Solution().lengthOfLongestSubstring("abcabcbb"))
