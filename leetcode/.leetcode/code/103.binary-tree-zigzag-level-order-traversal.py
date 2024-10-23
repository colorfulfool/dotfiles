from collections import deque
from typing import List, Optional

class Solution:
    def zigzagLevelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        ans: List[deque[int]] = []

        def dfs(root, level):
            if not root:
                return None

            if len(ans) <= level:
                ans.append(deque())

            if level % 2 == 0:
                ans[level].append(root.val)
            else:
                ans[level].appendleft(root.val)

            dfs(root.left, level+1)
            dfs(root.right, level+1)

        dfs(root, 0)

        return [list(x) for x in ans]
