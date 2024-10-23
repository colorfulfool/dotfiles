from typing import List, Optional

class Solution:
    def fib(self, n: int) -> int:
        db1, db2 = 0, 1

        for i in range(2, n+1):
            db1, db2 = db2, db1 + db2

        return db2         

if __name__ == "__main__":
	print(Solution().fib(3))
