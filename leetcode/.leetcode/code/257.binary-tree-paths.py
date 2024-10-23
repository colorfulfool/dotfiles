from typing import List

class Solution:
    def binaryTreePaths(self, root: Optional[TreeNode]) -> List[str]:
        ans = []

        def dfs(root, path):
            if not root:
                return None

            path.append(str(root.val))

            if not root.left and not root.right:
                ans.append("->".join(map(str, path)))

            dfs(root.left, path)
            dfs(root.right, path)

            path.pop()

            return

        dfs(root, [])

        return ans
