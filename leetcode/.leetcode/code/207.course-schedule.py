from typing import List, Optional

class Solution:
    def canFinish(self, numCourses: int, prerequisites: List[List[int]]) -> bool:
        courses = [[] for _ in range(numCourses)]

        for course, required in prerequisites:
            courses[course].append(required)

        state = [0] * numCourses

        def hasCycle(course):
            if state[course] == 1:
                return False
           
            if state[course] == -1:
                return True

            state[course] = -1
           
            for req in courses[course]:
                if hasCycle(req):
                    return True

            state[course] = 1
            return False

        for course in range(numCourses):
            if hasCycle(course):
                return False

        return True
        
if __name__ == "__main__":
	print(Solution().canFinish(2, [[1,0], [0,1]]))
